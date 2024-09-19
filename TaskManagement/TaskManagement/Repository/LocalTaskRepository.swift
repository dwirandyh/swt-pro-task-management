//
//  LocalTaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation
import CoreData

class LocalTaskRepository: TaskRepository {
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchTasks() -> [TaskEntity] {
        let request: NSFetchRequest<TaskModel> = TaskModel.fetchRequest()
        do {
            return try context.fetch(request).map { TaskEntity(from: $0) }
        } catch {
            print("Failed to fetch tasks: \(error)")
            return []
        }
    }

    func addTask(_ task: TaskEntity) {
        let newTaskEntity = TaskModel(context: context)
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
        context.delete(taskEntity)
        saveContext()
    }

    func fetchTaskModel(byId id: UUID) -> TaskModel? {
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

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
}
