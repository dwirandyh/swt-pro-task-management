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
    var mockAuthManager: MockBiometricAuthManager!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        mockAuthManager = MockBiometricAuthManager()
        viewModel = TaskListViewModel(taskRepository: mockRepository, authManager: mockAuthManager)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testAuthenticationSuccess() async {
        mockAuthManager.shouldSucceed = true
        
        await viewModel.authenticateUser()
        
        XCTAssertTrue(mockAuthManager.authenticateUserCalled)
        XCTAssertTrue(viewModel.isUnlocked)
    }
    
    func testAuthenticationFailure() async {
        mockAuthManager.shouldSucceed = false
        
        await viewModel.authenticateUser()
        
        XCTAssertTrue(mockAuthManager.authenticateUserCalled)
        XCTAssertFalse(viewModel.isUnlocked)
    }
    
    func testSyncData() async throws {
        try await viewModel.syncData()
        XCTAssertTrue(mockRepository.syncDataCalled)
    }
    
    func testSyncDataError() async throws {
        let expectation = expectation(description: "expect call to throw error when sync data")
        var actualError: Error? = nil
        mockRepository.errorToThrow = NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        
        do {
            try await viewModel.syncData()
        } catch {
            actualError = error
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation])
        XCTAssertEqual(actualError?.localizedDescription, "Mock error")
    }

    
    func testAddTask() async {
        await viewModel.addTask(title: "Test Task")
        XCTAssertTrue(mockRepository.addTaskCalled)
        XCTAssertEqual(mockRepository.tasks.count, 1)
        XCTAssertEqual(mockRepository.tasks.first?.title, "Test Task")
    }
    
    func testAddTaskError() async throws {
        mockRepository.errorToThrow = NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        
        await viewModel.addTask(title: "Task 1")
        
        XCTAssertNotNil(viewModel.error)
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
    
    func testEditTaskError() async throws {
        mockRepository.errorToThrow = NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())

        await viewModel.updateTask(task: task)
        
        XCTAssertNotNil(viewModel.error)
    }
    
    func testDeleteTask() async {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        mockRepository.tasks = [task]
        
        await viewModel.deleteTask(task: task)
        XCTAssertTrue(mockRepository.deleteTaskCalled)
        XCTAssertTrue(mockRepository.tasks.isEmpty)
    }
    
    func testDeleteTaskError() async throws {
        mockRepository.errorToThrow = NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Mock error"])
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())

        await viewModel.deleteTask(task: task)
        
        XCTAssertNotNil(viewModel.error)
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
