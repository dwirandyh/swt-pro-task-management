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
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Sync tasks from Firestore to Core Data
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
    
    // Push local changes from Core Data to Firestore
    func pushCoreDataToFirestore() async throws {
        do {
            let pendingSyncs = try await context.perform {
                let fetchRequest: NSFetchRequest<PendingSyncModel> = PendingSyncModel.fetchRequest()
                return try self.context.fetch(fetchRequest)
            }
            
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
        let request: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Failed to fetch task by ID: \(error)")
            return nil
        }
    }
    
    // Update Core Data task with Firestore data
    private func updateCoreDataTask(from firestoreData: [String: Any], for localTask: TaskModel) {
        localTask.title = firestoreData["title"] as? String
        localTask.isCompleted = firestoreData["isCompleted"] as? Bool ?? false
        localTask.lastModified = (firestoreData["lastModified"] as? Timestamp)?.dateValue()
        
        saveContext()
    }
    
    // Create a new Core Data task from Firestore data
    private func createNewCoreDataTask(from document: QueryDocumentSnapshot) {
        let firestoreData = document.data()
        
        let newTask = TaskModel(context: context)
        newTask.id = UUID(uuidString: document.documentID) ?? UUID()
        newTask.title = firestoreData["title"] as? String
        newTask.isCompleted = firestoreData["isCompleted"] as? Bool ?? false
        newTask.lastModified = (firestoreData["lastModified"] as? Timestamp)?.dateValue()
        
        saveContext()
    }
    
    // Push Core Data task to Firestore
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
    
    // Delete deleted pending task to Firestore
    private func deleteTaskFromFirestore(taskId: UUID) async throws {
        try await firestore.collection("tasks").document(taskId.uuidString).delete()
        
        clearPendingSync(taskId: taskId)
    }
    
    // Save pending sync action
    func savePendingSync(taskId: UUID, actionType: String) {
        let fetchRequest: NSFetchRequest<PendingSyncModel> = PendingSyncModel.fetchRequest()
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.taskId), taskId as CVarArg),
            NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.actionType), actionType)
        ])
        
        if let result = try? context.fetch(fetchRequest), result.isEmpty {
            let pendingSync = PendingSyncModel(context: context)
            pendingSync.taskId = taskId
            pendingSync.actionType = actionType
            
            saveContext()
        }
    }
    
    // Clear pending sync action
    private func clearPendingSync(taskId: UUID) {
        let fetchRequest: NSFetchRequest<PendingSyncModel> = PendingSyncModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.taskId), taskId as CVarArg)
        
        if let result = try? context.fetch(fetchRequest) {
            for pendingSync in result {
                context.delete(pendingSync)
            }
            
            saveContext()
        }
    }
    
    // Save Core Data context
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save Core Data: \(error)")
        }
    }
}
