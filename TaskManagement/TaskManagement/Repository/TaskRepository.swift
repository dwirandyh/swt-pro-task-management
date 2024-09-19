//
//  TaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation

protocol TaskRepository {
    func fetchTasks() -> [TaskEntity]
    func addTask(_ task: TaskEntity)
    func updateTask(_ task: TaskEntity)
    func deleteTask(_ task: TaskEntity)
}

