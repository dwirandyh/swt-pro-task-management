//
//  LocalTaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation
import CoreData

class LocalTaskRepository: TaskRepository {
    
    let persistentContainer = NSPersistentContainer(name: "TaskDB")

    init() {
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Failed to load persistent stores: \(error)")
            }
        }
    }

    func fetchTasks() -> [TaskEntity] {
        let request: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        do {
            return try persistentContainer.viewContext.fetch(request).map { TaskEntity(from: $0) }
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }

    func addTask(_ task: TaskEntity) {
        let newTaskEntity = TaskModel(context: persistentContainer.viewContext)
        newTaskEntity.id = task.id
        newTaskEntity.title = task.title
        newTaskEntity.isCompleted = false
        saveContext()
    }

    func updateTask(_ task: TaskEntity) {
        guard let taskEntity = fetchTaskModel(byId: task.id) else { return }
        taskEntity.isCompleted = task.isCompleted
        saveContext()
    }

    func deleteTask(_ task: TaskEntity) {
        guard let taskEntity = fetchTaskModel(byId: task.id) else { return }
        persistentContainer.viewContext.delete(taskEntity)
        saveContext()
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
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            return try persistentContainer.viewContext.fetch(request).map { TaskEntity(from: $0) }
        } catch {
            print("Failed to search tasks: \(error)")
            return []
        }
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
        let request: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let results = try persistentContainer.viewContext.fetch(request)
            return results.first
        } catch {
            print("Failed to fetch task by ID: \(error)")
            return nil
        }
    }

    private func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
