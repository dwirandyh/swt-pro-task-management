//
//  TaskListViewModelTests.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 21/09/24.
//


import XCTest
@testable import TaskManagement

@MainActor
class TaskListViewModelTests: XCTestCase {
    var viewModel: TaskListViewModel!
    var mockRepository: MockTaskRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        viewModel = TaskListViewModel(taskRepository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testSyncData() async throws {
        try await viewModel.syncData()
        XCTAssertTrue(mockRepository.syncDataCalled)
    }
    
    func testAddTask() async {
        await viewModel.addTask(title: "Test Task")
        XCTAssertTrue(mockRepository.addTaskCalled)
        XCTAssertEqual(mockRepository.tasks.count, 1)
        XCTAssertEqual(mockRepository.tasks.first?.title, "Test Task")
    }
    
    func testUpdateTask() async {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        mockRepository.tasks = [task]
        
        var updatedTask = task
        updatedTask.isCompleted = true
        
        await viewModel.updateTask(task: updatedTask)
        XCTAssertTrue(mockRepository.updateTaskCalled)
        XCTAssertTrue(mockRepository.tasks.first?.isCompleted ?? false)
    }
    
    func testDeleteTask() async {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        mockRepository.tasks = [task]
        
        await viewModel.deleteTask(task: task)
        XCTAssertTrue(mockRepository.deleteTaskCalled)
        XCTAssertTrue(mockRepository.tasks.isEmpty)
    }
    
    func testFilterAndSearchTasks() {
        let task1 = TaskEntity(id: UUID(), title: "Unit Test", isCompleted: false, lastModified: Date())
        let task2 = TaskEntity(id: UUID(), title: "UI Test", isCompleted: true, lastModified: Date())
        let task3 = TaskEntity(id: UUID(), title: "Snapshot", isCompleted: false, lastModified: Date())
        mockRepository.tasks = [task1, task2, task3]
        
        viewModel.filterAndSearchTasks()
        XCTAssertEqual(viewModel.tasks.count, 3)
        
        viewModel.searchText = "Test"
        viewModel.filterAndSearchTasks()
        XCTAssertEqual(viewModel.tasks.count, 2)
        
        viewModel.filterOption = .completed
        viewModel.filterAndSearchTasks()
        XCTAssertEqual(viewModel.tasks.count, 1)
        XCTAssertEqual(viewModel.tasks.first?.title, "UI Test")
        
        viewModel.searchText = ""
        viewModel.filterOption = .notCompleted
        viewModel.filterAndSearchTasks()
        XCTAssertEqual(viewModel.tasks.count, 2)
    }
}
