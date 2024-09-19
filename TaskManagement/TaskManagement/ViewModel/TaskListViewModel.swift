//
//  TaskListViewModel.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Combine
import Foundation

class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskEntity] = []
    @Published var searchText: String = "" {
        didSet {
            searchTasks()
        }
    }
    @Published var isAddTaskShown: Bool = false

    private let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
        fetchTasks()
    }

    func fetchTasks() {
        tasks = taskRepository.fetchTasks()
    }

    func addTask(title: String) {
        let newTask = TaskEntity(id: UUID(), title: title, isCompleted: false)
        taskRepository.addTask(newTask)
        fetchTasks()
    }

    func updateTask(task: TaskEntity) {
        taskRepository.updateTask(task)
        fetchTasks()
    }

    func deleteTask(task: TaskEntity) {
        taskRepository.deleteTask(task)
        fetchTasks()
    }
    
    func searchTasks() {
        if searchText.isEmpty {
            fetchTasks()
        }
        else {
            tasks = taskRepository.searchTasks(byTitle: searchText)
        }
    }
}
