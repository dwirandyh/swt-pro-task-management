//
//  TaskListViewTests.swift
//  TaskManagementTests
//
//  Created by Dwi Randy H on 22/09/24.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import TaskManagement

@MainActor
class TaskListViewTests: XCTestCase {
    var mockViewModel: TaskListViewModel!
    var mockRepository: MockTaskRepository!
    var mockAuthManager: MockBiometricAuthManager!

    override func setUp() {
        super.setUp()
        mockRepository = MockTaskRepository()
        mockAuthManager = MockBiometricAuthManager()
        mockViewModel = TaskListViewModel(taskRepository: mockRepository, authManager: mockAuthManager)
    }

    func testInitialState() throws {
        let view = TaskListView(viewModel: self.mockViewModel)
        let lockedView = try view.inspect().find(viewWithTag: "lockedView")
        
        ViewHosting.host(view: view)
        XCTAssertNotNil(lockedView)
    }

    func testUnlockedState() throws {
        mockViewModel.isUnlocked = true
        let view = TaskListView(viewModel: self.mockViewModel)
        let taskList = try view.inspect().find(viewWithTag: "taskList")
        ViewHosting.host(view: view)
        XCTAssertNotNil(taskList)
    }

    func testTaskRow() throws {
        mockViewModel.isUnlocked = true
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false, lastModified: Date())
        mockViewModel.tasks = [task]
        let view = TaskListView(viewModel: self.mockViewModel)
        let taskRow = try view.inspect().find(TaskRow.self)
        ViewHosting.host(view: view)
        XCTAssertEqual(try taskRow.actualView().task.title, "Test Task")
    }
}
