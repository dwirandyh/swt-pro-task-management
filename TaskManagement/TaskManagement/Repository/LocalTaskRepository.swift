//
//  LocalTaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation
import CoreData

class LocalTaskRepository: TaskRepository {
    
    private let persistentContainer: PersistenceContainer
    private let syncManager: SyncManager

    init(persistentContainer: PersistenceContainer, syncManager: SyncManager) {
        self.persistentContainer = persistentContainer
        self.syncManager = syncManager
    }
    
    func syncData() async throws {
        try await syncManager.syncFirestoreToCoreData()
    }
    
    func fetchTasks() -> [TaskEntity] {
        return persistentContainer.fetch(TaskModel.self).map { TaskEntity(from: $0) }
    }

    func addTask(_ task: TaskEntity) async throws {
        let newTaskEntity = TaskModel(from: task, context: persistentContainer.context)
        
        persistentContainer.saveContext()
        
        try await syncManager.savePendingSync(taskId: task.id, actionType: "create")
    }

    func updateTask(_ task: TaskEntity) async throws {
        guard let taskModel = fetchTaskModel(byId: task.id) else { return }
        taskModel.isCompleted = task.isCompleted
        taskModel.lastModified = Date()
        
        
        await persistentContainer.update(taskModel)
        
        try await syncManager.savePendingSync(taskId: task.id, actionType: "update")
    }

    func deleteTask(_ task: TaskEntity) async throws {
        guard let taskModel = fetchTaskModel(byId: task.id) else { return }
        
        
        await persistentContainer.delete(taskModel)
        
        try await syncManager.savePendingSync(taskId: task.id, actionType: "delete")
    }
    
    func searchTasks(byTitle title: String, filter: FilterOption) -> [TaskEntity] {
        let request: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        
        var predicates: [NSPredicate] = []

        if !title.isEmpty {
            predicates.append(NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TaskModel.title), title))
        }
        
        if let filterPredicate = createFilterPredicate(filter) {
            predicates.append(filterPredicate)
        }
        
        return persistentContainer.fetch(
            TaskModel.self,
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        ).map { TaskEntity(from: $0) }
    }
    
    private func createFilterPredicate(_ option: FilterOption) -> NSPredicate? {
        switch option {
        case .all:
            return nil
        case .completed:
            return NSPredicate(format: "%K == %@", #keyPath(TaskModel.isCompleted), NSNumber(value: true))
        case .notCompleted:
            return NSPredicate(format: "%K == %@", #keyPath(TaskModel.isCompleted), NSNumber(value: false))
        }
    }
    
    private func fetchTaskModel(byId id: UUID) -> TaskModel? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return persistentContainer.fetch(TaskModel.self, predicate: predicate).first
    }
}
