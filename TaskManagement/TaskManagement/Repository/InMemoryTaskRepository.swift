//
//  InMemoryTaskRepository.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation

class InMemoryTaskRepository: TaskRepository {
    
    private(set) var tasks: [TaskEntity] = []
    
    func syncData() async throws {
        tasks = [
            TaskEntity(
                id: UUID(),
                title: "Task 1",
                isCompleted: true
            ),
            TaskEntity(
                id: UUID(),
                title: "Task 2",
                isCompleted: true
            )
        ]
    }

    func fetchTasks() -> [TaskEntity] {
        return tasks
    }

    func addTask(_ task: TaskEntity) async throws {
        tasks.append(task)
    }

    func updateTask(_ task: TaskEntity) async throws {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }

    func deleteTask(_ task: TaskEntity) async throws {
        tasks.removeAll { $0.id == task.id }
    }
    
    func searchTasks(byTitle title: String, filter: FilterOption) -> [TaskEntity] {
        return tasks.filter { task in
            let titleMatch = title.isEmpty || task.title.lowercased().contains(title.lowercased())
            let filterMatch: Bool
            switch filter {
            case .all:
                filterMatch = true
            case .completed:
                filterMatch = task.isCompleted
            case .notCompleted:
                filterMatch = !task.isCompleted
            }
            return titleMatch && filterMatch
        }
    }
}
