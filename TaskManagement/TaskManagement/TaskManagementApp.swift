//
//  TaskManagementApp.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI

@main
struct TaskManagementApp: App {
    @StateObject var taskListViewModel: TaskListViewModel = TaskListViewModel()
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: taskListViewModel)
        }
    }
}
