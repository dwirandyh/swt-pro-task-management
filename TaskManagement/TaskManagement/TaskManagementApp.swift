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
    let persistentContainer = NSPersistentContainer(name: "TaskDB")
    
    init() {
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                assertionFailure("Failed to load persistence \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView(viewModel: TaskListViewModel(taskRepository: LocalTaskRepository(context: persistentContainer.viewContext)))
        }
    }
}
