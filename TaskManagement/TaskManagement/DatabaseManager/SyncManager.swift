//
//  File.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import CoreData
import Foundation
import FirebaseFirestore

class SyncManager {
    
    let firestore = Firestore.firestore()
    let persistentContainer: PersistenceContainer
    
    static var shared: SyncManager?
    
    init(persistentContainer: PersistenceContainer) {
        self.persistentContainer = persistentContainer
        
        
        if SyncManager.shared == nil {
            SyncManager.shared = self
        }
    }
    
    func syncFirestoreToCoreData() async throws {
        try await pushCoreDataToFirestore()
        
        let snapshot = try await firestore.collection("tasks").getDocuments()
        let documents = snapshot.documents
        for document in documents {
            guard let taskId = UUID(uuidString: document.documentID) else { continue }
            let data = document.data()
            let firestoreLastModified = (data["lastModified"] as? Timestamp)?.dateValue() ?? Date()
            
            if let localTask = fetchTaskModel(byId: taskId) {
                if let localLastModified = localTask.lastModified {
                    if firestoreLastModified > localLastModified {
                        self.updateCoreDataTask(from: data, for: localTask)
                    } else if firestoreLastModified < localLastModified {
                        self.savePendingSync(taskId: localTask.id!, actionType: "update")
                    }
                }
            } else {
                self.createNewCoreDataTask(from: document)
            }
        }
    }
    
    func pushCoreDataToFirestore() async throws {
        do {
            let pendingSyncs = try await persistentContainer.fetch(PendingSyncModel.self)
            
            for pendingSync in pendingSyncs {
                if let taskId = pendingSync.taskId {
                    if let task = fetchTaskModel(byId: taskId) {
                        try await pushTaskToFirestore(task: task)
                    }
                    else {
                        try await deleteTaskFromFirestore(taskId: taskId)
                    }
                }
            }
        } catch {
            print("Error fetching PendingSync: \(error)")
        }
    }
    
    private func fetchTaskModel(byId id: UUID) -> TaskModel? {
        let tasks = persistentContainer.fetch(
            TaskModel.self,
            predicate: NSPredicate(format: "id == %@", id as CVarArg)
        )
        return tasks.first
    }
    
    private func updateCoreDataTask(from firestoreData: [String: Any], for localTask: TaskModel) {
        localTask.title = firestoreData["title"] as? String
        localTask.isCompleted = firestoreData["isCompleted"] as? Bool ?? false
        localTask.lastModified = (firestoreData["lastModified"] as? Timestamp)?.dateValue()
        
        persistentContainer.saveContext()
    }
    
    private func createNewCoreDataTask(from document: QueryDocumentSnapshot) {
        let firestoreData = document.data()
        
        let newTask = persistentContainer.create(TaskModel.self)
        newTask.id = UUID(uuidString: document.documentID) ?? UUID()
        newTask.title = firestoreData["title"] as? String
        newTask.isCompleted = firestoreData["isCompleted"] as? Bool ?? false
        newTask.lastModified = (firestoreData["lastModified"] as? Timestamp)?.dateValue()
        
        persistentContainer.saveContext()
    }
    
    private func pushTaskToFirestore(task: TaskModel) async throws {
        guard let taskId = task.id else { return }
        let taskData: [String: Any] = [
            "title": task.title ?? "",
            "isCompleted": task.isCompleted,
            "lastModified": task.lastModified ?? Date()
        ]
        
        try await firestore.collection("tasks").document(taskId.uuidString).setData(taskData)
        
        clearPendingSync(taskId: taskId)
    }
    
    private func deleteTaskFromFirestore(taskId: UUID) async throws {
        try await firestore.collection("tasks").document(taskId.uuidString).delete()
        
        clearPendingSync(taskId: taskId)
    }
    
    func savePendingSync(taskId: UUID, actionType: String) {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.taskId), taskId as CVarArg),
            NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.actionType), actionType)
        ])
        
        let result = persistentContainer.fetch(PendingSyncModel.self, predicate: predicate)
        if result.isEmpty {
            let pendingSync = persistentContainer.create(PendingSyncModel.self)
            pendingSync.taskId = taskId
            pendingSync.actionType = actionType
        }
    }
    
    private func clearPendingSync(taskId: UUID) {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.taskId), taskId as CVarArg)
        let result = persistentContainer.fetch(PendingSyncModel.self, predicate: predicate)
        for pendingSync in result {
            persistentContainer.delete(pendingSync)
        }
    }
}
