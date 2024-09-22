//
//  MockTaskRepository.swift
//  TaskManagementTests
//
//  Created by Dwi Randy H on 21/09/24.
//

import Foundation
@testable import TaskManagement

class MockTaskRepository: TaskRepository {
    var tasks: [TaskEntity] = []
    var syncDataCalled = false
    var addTaskCalled = false
    var updateTaskCalled = false
    var deleteTaskCalled = false
    
    var errorToThrow: Error?
    
    func syncData() async throws {
        if let error = errorToThrow {
            throw error
        }
        syncDataCalled = true
    }
    
    func fetchTasks() -> [TaskEntity] {
        return tasks
    }
    
    func addTask(_ task: TaskEntity) async throws {
        if let error = errorToThrow {
            throw error
        }
        addTaskCalled = true
        tasks.append(task)
    }
    
    func updateTask(_ task: TaskEntity) async throws {
        if let error = errorToThrow {
            throw error
        }
        updateTaskCalled = true
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(_ task: TaskEntity) async throws {
        if let error = errorToThrow {
            throw error
        }
        deleteTaskCalled = true
        tasks.removeAll { $0.id == task.id }
    }
    
    func searchTasks(byTitle title: String, filter: FilterOption) -> [TaskEntity] {
        var filteredTasks = tasks
        
        if !title.isEmpty {
            filteredTasks = filteredTasks.filter { $0.title.lowercased().contains(title.lowercased()) }
        }
        
        switch filter {
        case .completed:
            filteredTasks = filteredTasks.filter { $0.isCompleted }
        case .notCompleted:
            filteredTasks = filteredTasks.filter { !$0.isCompleted }
        case .all:
            break
        }
        
        return filteredTasks
    }
}
