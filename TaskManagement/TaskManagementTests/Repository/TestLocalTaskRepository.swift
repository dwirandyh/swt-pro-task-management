//
//  TestLocalTaskRepository.swift
//  TaskManagementTests
//
//  Created by Dwi Randy H on 21/09/24.
//

import Foundation
import XCTest
import CoreData
@testable import TaskManagement

class LocalTaskRepositoryTests: XCTestCase {
    var repository: LocalTaskRepository!
    var persistentContainer: PersistenceContainer!
    var mockSyncManager: MockSyncManager!

    override func setUp() {
        super.setUp()
        persistentContainer = PersistenceContainer(inMemory: true)
        mockSyncManager = MockSyncManager()
        repository = LocalTaskRepository(persistentContainer: persistentContainer, syncManager: mockSyncManager)
    }

    override func tearDown() {
        repository = nil
        persistentContainer = nil
        mockSyncManager = nil
        super.tearDown()
    }

    func testAddTask() async throws {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        try await repository.addTask(task)

        let fetchedTasks = repository.fetchTasks()
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertEqual(fetchedTasks.first?.title, "Test Task")
        XCTAssertTrue(mockSyncManager.savePendingSyncCalled)
    }

    func testUpdateTask() async throws {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        try await repository.addTask(task)

        var updatedTask = task
        updatedTask.isCompleted = true
        try await repository.updateTask(updatedTask)

        let fetchedTasks = repository.fetchTasks()
        XCTAssertEqual(fetchedTasks.count, 1)
        XCTAssertTrue(fetchedTasks.first!.isCompleted)
        XCTAssertTrue(mockSyncManager.savePendingSyncCalled)
    }

    func testDeleteTask() async throws {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        try await repository.addTask(task)

        try await repository.deleteTask(task)

        let fetchedTasks = repository.fetchTasks()
        XCTAssertTrue(fetchedTasks.isEmpty)
        XCTAssertTrue(mockSyncManager.savePendingSyncCalled)
    }

    func testSearchTasks() async throws {
        let task1 = TaskEntity(id: UUID(), title: "Task 1", isCompleted: false, lastModified: Date())
        let task2 = TaskEntity(id: UUID(), title: "Task 2", isCompleted: true, lastModified: Date())
        let task3 = TaskEntity(id: UUID(), title: "Create Documentation", isCompleted: false, lastModified: Date())

        try await repository.addTask(task1)
        try await repository.addTask(task2)
        try await repository.addTask(task3)

        let allTasks = repository.searchTasks(byTitle: "", filter: .all)
        XCTAssertEqual(allTasks.count, 3)

        let tasksTitleSearch = repository.searchTasks(byTitle: "Task", filter: .all)
        XCTAssertEqual(tasksTitleSearch.count, 2)

        let completedTasks = repository.searchTasks(byTitle: "", filter: .completed)
        XCTAssertEqual(completedTasks.count, 1)
        XCTAssertEqual(completedTasks.first?.title, "Task 2")

        let notCompletedTasks = repository.searchTasks(byTitle: "", filter: .notCompleted)
        XCTAssertEqual(notCompletedTasks.count, 2)
    }

    func testSyncData() async throws {
        try await repository.syncData()
        XCTAssertTrue(mockSyncManager.syncFirestoreToCoreDataCalled)
    }
}
