//
//  TaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation

protocol TaskRepository {
    func fetchTasks() -> [TaskModel]
    func addTask(_ task: TaskModel)
    func updateTask(_ task: TaskModel)
    func deleteTask(_ task: TaskModel)
}

class InMemoryTaskRepository: TaskRepository {
    private var tasks: [TaskModel] = []

    func fetchTasks() -> [TaskModel] {
        return tasks
    }

    func addTask(_ task: TaskModel) {
        tasks.append(task)
    }

    func updateTask(_ task: TaskModel) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func deleteTask(_ task: TaskModel) {
        tasks.removeAll { $0.id == task.id }
    }
}


