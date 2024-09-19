//
//  TaskManagementApp.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI
import CoreData

@main
struct TaskManagementApp: App {
    
    init() {
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: TaskListViewModel(taskRepository: LocalTaskRepository()))
        }
    }
}
