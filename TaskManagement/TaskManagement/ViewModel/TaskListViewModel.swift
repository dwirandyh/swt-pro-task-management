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

@MainActor
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
    private let logger: Logger
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
        self.logger = Logger()
        filterAndSearchTasks()
    }
    
    func syncData() async throws {
        try await taskRepository.syncData()
        filterAndSearchTasks()
    }

    func addTask(title: String) async {
        do {
            let newTask = TaskEntity(
                id: UUID(),
                title: title,
                isCompleted: false,
                lastModified: Date()
            )
            try await taskRepository.addTask(newTask)
            filterAndSearchTasks()
        } catch {
            logger.error("Failed to add task \(error)")
        }
    }

    func updateTask(task: TaskEntity) async {
        do {
            try await taskRepository.updateTask(task)
            filterAndSearchTasks()
        } catch {
            logger.error("Failed to update task \(error)")
        }
    }

    func deleteTask(task: TaskEntity) async {
        do {
            try await taskRepository.deleteTask(task)
            filterAndSearchTasks()
        } catch {
            logger.error("Failed to delete task \(error)")
        }
    }
    
    func filterAndSearchTasks() {
        tasks = taskRepository.searchTasks(byTitle: searchText, filter: filterOption)
    }
}
