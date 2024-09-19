//
//  InMemoryTaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation

class InMemoryTaskRepository: TaskRepository {
    private var tasks: [TaskEntity] = []

    func fetchTasks() -> [TaskEntity] {
        return tasks
    }

    func addTask(_ task: TaskEntity) {
        tasks.append(task)
    }

    func updateTask(_ task: TaskEntity) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func deleteTask(_ task: TaskEntity) {
        tasks.removeAll { $0.id == task.id }
    }
}
