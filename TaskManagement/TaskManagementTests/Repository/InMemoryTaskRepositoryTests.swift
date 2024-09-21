//
//  InMemoryTaskRepositoryTests.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 21/09/24.
//


import XCTest
@testable import TaskManagement

class InMemoryTaskRepositoryTests: XCTestCase {
    var repository: InMemoryTaskRepository!

    override func setUp() {
        super.setUp()
        repository = InMemoryTaskRepository()
    }

    override func tearDown() {
        repository = nil
        super.tearDown()
    }

    func testAddTask() async throws {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        try await repository.addTask(task)

        XCTAssertEqual(repository.tasks.count, 1)
        XCTAssertEqual(repository.tasks.first?.title, "Test Task")    }

    func testUpdateTask() async throws {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        try await repository.addTask(task)

        var updatedTask = task
        updatedTask.isCompleted = true
        try await repository.updateTask(updatedTask)

        XCTAssertEqual(repository.tasks.count, 1)
        XCTAssertTrue(repository.tasks.first?.isCompleted ?? false)
    }

    func testDeleteTask() async throws {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        try await repository.addTask(task)

        try await repository.deleteTask(task)

        XCTAssertTrue(repository.tasks.isEmpty)    }

    func testSearchTasks() async throws {
        let task1 = TaskEntity(id: UUID(), title: "Task 1", isCompleted: false, lastModified: Date())
        let task2 = TaskEntity(id: UUID(), title: "Task 2", isCompleted: true, lastModified: Date())
        let task3 = TaskEntity(id: UUID(), title: "Another", isCompleted: false, lastModified: Date())

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
        XCTAssertEqual(repository.tasks.count, 2)
    }

    func testFetchTasks() async throws {
        try await repository.syncData()

        let fetchedTasks = repository.fetchTasks()
        XCTAssertEqual(fetchedTasks.count, 2)
    }
}
