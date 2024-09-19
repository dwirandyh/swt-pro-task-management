//
//  TaskListViewModel.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Combine
import Foundation

enum FilterOption {
    case all
    case completed
    case notCompleted
}

class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskEntity] = []
    @Published var searchText: String = "" {
        didSet {
            filterAndSearchTasks()
        }
    }
    @Published var filterOption: FilterOption = .all {
        didSet {
            filterAndSearchTasks()
        }
    }
    @Published var isAddTaskShown: Bool = false

    private let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
        filterAndSearchTasks()
    }
    
    func syncData() async throws {
        try await taskRepository.syncData()
        await MainActor.run {
            filterAndSearchTasks()
        }
    }

    func addTask(title: String) {
        let newTask = TaskEntity(
            id: UUID(),
            title: title,
            isCompleted: false,
            lastModified: Date()
        )
        taskRepository.addTask(newTask)
        filterAndSearchTasks()
    }

    func updateTask(task: TaskEntity) {
        taskRepository.updateTask(task)
        filterAndSearchTasks()
    }

    func deleteTask(task: TaskEntity) {
        taskRepository.deleteTask(task)
        filterAndSearchTasks()
    }
    
    func filterAndSearchTasks() {
        tasks = taskRepository.searchTasks(byTitle: searchText, filter: filterOption)
    }
}
