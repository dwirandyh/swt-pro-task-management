//
//  AddTaskViewTests.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 22/09/24.
//


import SwiftUI
import XCTest
import ViewInspector
@testable import TaskManagement

class AddTaskViewTests: XCTestCase {
    
    func testAddTaskViewInitialState() throws {
        let sut = AddTaskView { _ in }
        
        let form = try sut.inspect().implicitAnyView().navigationView().form()
        
        // Check Section
        let section = try form.section(0)
        XCTAssertEqual(try section.header().text().string(), "New Task")
        
        // Check TextField
        let textField = try section.textField(0)
        XCTAssertEqual(try textField.input(), "")
        
        // Check Add Task Button
        let addButton = try form.button(1)
        XCTAssertEqual(try addButton.labelView().text().string(), "Add Task")
        
        // Check Cancel Button
        let cancelButton = try sut.inspect().implicitAnyView().find(viewWithTag: "button-cancel").button()
        XCTAssertEqual(try cancelButton.labelView().text().string(), "Cancel")
    }
}
