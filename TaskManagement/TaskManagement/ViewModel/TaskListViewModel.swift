//
//  TaskListViewModel.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Combine
import Foundation

class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskModel] = []
    @Published var searchText: String = ""
    @Published var isAddTaskShown: Bool = false

    private let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository = InMemoryTaskRepository()) {
        self.taskRepository = taskRepository
        fetchTasks()
    }

    func fetchTasks() {
        tasks = taskRepository.fetchTasks()
    }

    func addTask(title: String) {
        let newTask = TaskModel(id: UUID(), title: title, isCompleted: false)
        taskRepository.addTask(newTask)
        fetchTasks()
    }

    func updateTask(task: TaskModel) {
        taskRepository.updateTask(task)
        fetchTasks()
    }

    func deleteTask(task: TaskModel) {
        taskRepository.deleteTask(task)
        fetchTasks()
    }

    var filteredTasks: [TaskModel] {
        if searchText.isEmpty {
            return tasks
        } else {
            return tasks.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
