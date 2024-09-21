//
//  TaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation

protocol TaskRepository {
    func syncData() async throws
    func fetchTasks() -> [TaskEntity]
    func addTask(_ task: TaskEntity) async throws
    func updateTask(_ task: TaskEntity) async throws
    func deleteTask(_ task: TaskEntity) async throws
    func searchTasks(byTitle title: String, filter: FilterOption) -> [TaskEntity]
}

