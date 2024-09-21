//
//  File.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

@preconcurrency import CoreData
import Foundation
import FirebaseFirestore

protocol SyncManagerProtocol {
    func syncFirestoreToCoreData() async throws
    func savePendingSync(taskId: UUID, actionType: String) async throws
    func pushCoreDataToFirestore() async throws
}

actor SyncManager: SyncManagerProtocol {
    
    private let firestore: Firestore
    private let persistentContainer: PersistenceContainer
    private var activeSyncTask: Task<Void, Error>?
    private let logger: Logger
    
    static var shared: SyncManager = .init(persistentContainer: .shared)
    
    private init(persistentContainer: PersistenceContainer) {
        self.persistentContainer = persistentContainer
        self.firestore = Firestore.firestore()
        self.logger = .init(category: "SyncManager")
    }
    
    func syncFirestoreToCoreData() async throws {
        if activeSyncTask != nil {
            try await activeSyncTask?.value
        }
        
        let task = Task<Void, Error> {
            try await pushCoreDataToFirestore()
            
            let snapshot = try await firestore.collection("tasks").getDocuments()
            let documents = snapshot.documents
            for document in documents {
                guard let taskId = UUID(uuidString: document.documentID) else { continue }
                let data = document.data()
                let firestoreLastModified = (data["lastModified"] as? Timestamp)?.dateValue() ?? Date()
                
                if let localTask = try await fetchTaskModel(byId: taskId) {
                    if let localLastModified = localTask.lastModified {
                        if firestoreLastModified > localLastModified {
                            try await self.updateCoreDataTask(from: data, for: localTask)
                        } else if firestoreLastModified < localLastModified {
                            try await self.savePendingSync(taskId: localTask.id!, actionType: "update")
                        }
                    }
                } else {
                    await self.createNewCoreDataTask(from: document)
                }
            }
        }
        
        activeSyncTask = task
        
        try await task.value
    }
    
    func pushCoreDataToFirestore() async throws {
        do {
            let pendingSyncs = try await persistentContainer.fetch(PendingSyncModel.self)
            
            for pendingSync in pendingSyncs {
                if let taskId = pendingSync.taskId {
                    if let task = try await fetchTaskModel(byId: taskId) {
                        try await pushTaskToFirestore(task: task)
                    }
                    else {
                        try await deleteTaskFromFirestore(taskId: taskId)
                    }
                }
            }
        } catch {
            logger.error("Error fetching PendingSync: \(error)")
        }
    }
    
    private func fetchTaskModel(byId id: UUID) async throws -> TaskModel? {
        let tasks = try await persistentContainer.fetch(
            TaskModel.self,
            predicate: NSPredicate(format: "id == %@", id as CVarArg)
        )
        return tasks.first
    }
    
    private func updateCoreDataTask(from firestoreData: [String: Any], for localTask: TaskModel) async throws {
        localTask.title = firestoreData["title"] as? String
        localTask.isCompleted = firestoreData["isCompleted"] as? Bool ?? false
        localTask.lastModified = (firestoreData["lastModified"] as? Timestamp)?.dateValue()
        
        await persistentContainer.update(localTask)
    }
    
    private func createNewCoreDataTask(from document: QueryDocumentSnapshot) async {
        let firestoreData = document.data()
        
        await persistentContainer.create(TaskModel.self) { newTask in
            newTask.id = UUID(uuidString: document.documentID)!
            newTask.title = firestoreData["title"] as? String
            newTask.isCompleted = firestoreData["isCompleted"] as? Bool ?? false
            newTask.lastModified = (firestoreData["lastModified"] as? Timestamp)?.dateValue()
        }
    }
    
    private func pushTaskToFirestore(task: TaskModel) async throws {
        guard let taskId = task.id else { return }
        let taskData: [String: Any] = [
            "title": task.title ?? "",
            "isCompleted": task.isCompleted,
            "lastModified": task.lastModified ?? Date()
        ]
        
        try await firestore.collection("tasks").document(taskId.uuidString).setData(taskData)
        
        try await clearPendingSync(taskId: taskId)
    }
    
    private func deleteTaskFromFirestore(taskId: UUID) async throws {
        try await firestore.collection("tasks").document(taskId.uuidString).delete()
        
        try await clearPendingSync(taskId: taskId)
    }
    
    func savePendingSync(taskId: UUID, actionType: String) async throws {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.taskId), taskId as CVarArg),
            NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.actionType), actionType)
        ])
        
        let result = try await persistentContainer.fetch(PendingSyncModel.self, predicate: predicate)
        if result.isEmpty {
            await persistentContainer.create(PendingSyncModel.self) { pendingSync in
                pendingSync.taskId = taskId
                pendingSync.actionType = actionType
            }
        }
    }
    
    private func clearPendingSync(taskId: UUID) async throws {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(PendingSyncModel.taskId), taskId as CVarArg)
        let result = try await persistentContainer.fetch(PendingSyncModel.self, predicate: predicate)
        for pendingSync in result {
            await persistentContainer.delete(pendingSync)
        }
    }
}
