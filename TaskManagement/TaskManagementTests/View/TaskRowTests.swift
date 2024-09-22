//
//  TaskRowTests.swift
//  TaskManagementTests
//
//  Created by Dwi Randy H on 21/09/24.
//

import XCTest
import ViewInspector
@testable import TaskManagement


class TaskRowTests: XCTestCase {
    
    func testTaskRowInitialState() throws {
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false)
        let sut = TaskRow(task: task, onUpdate: { _ in }, onDelete: {})
        
        let hStack = try sut.inspect().implicitAnyView().hStack()
        
        // Check Toggle
        let toggle = try hStack.toggle(0)
        XCTAssertFalse(sut.task.isCompleted)
        XCTAssertEqual(try toggle.labelView().text().string(), "Test Task")
        
        // Check Delete Button
        let isButtonResponsive = try hStack.find(viewWithTag: "button-delete").button().isResponsive()
        XCTAssertEqual(isButtonResponsive, true)
    }
    
    func testTaskRowToggleUpdate() throws {
        var updatedTask: TaskEntity?
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false)
        let sut = TaskRow(task: task, onUpdate: { updatedTask = $0 }, onDelete: {})
        
        let toggle = try sut.inspect().implicitAnyView().hStack().toggle(0)
        try toggle.tap()
        
        XCTAssertNotNil(updatedTask)
        XCTAssertTrue(updatedTask?.isCompleted == true)
    }

    func testTaskRowDeleteAction() throws {
        var deleteActionCalled = false
        let task = TaskEntity(id: UUID(), title: "Test Task", isCompleted: false)
        let sut = TaskRow(task: task, onUpdate: { _ in }, onDelete: { deleteActionCalled = true })
        
        let deleteButton = try sut.inspect().implicitAnyView().find(viewWithTag: "button-delete").button()
        try deleteButton.tap()
        
        XCTAssertTrue(deleteActionCalled)
    }
}
