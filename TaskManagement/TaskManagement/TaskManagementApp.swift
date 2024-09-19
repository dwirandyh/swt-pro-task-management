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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let persistentContainer: NSPersistentContainer = NSPersistentContainer(name: "TaskDB")
    
    init() {
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                print("Failed to load persistent stores: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView(
                viewModel: TaskListViewModel(
                    taskRepository: LocalTaskRepository(
                        persistentContainer: persistentContainer,
                        syncManager: SyncManager(context: persistentContainer.viewContext)
                    )
                )
            )
        }
    }
}
