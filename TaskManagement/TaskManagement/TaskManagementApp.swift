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
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var backgroundTaskManager: BackgroundTaskManager
    
    init() {
        backgroundTaskManager = BackgroundTaskManager()
    }
    
    var body: some Scene {
        WindowGroup {
            TaskListView(
                viewModel: TaskListViewModel(
                    taskRepository: LocalTaskRepository(
                        persistentContainer: PersistenceContainer.shared,
                        syncManager: SyncManager.shared
                    )
                )
            )
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                backgroundTaskManager.startBackgroundTask()
            }
        }
    }
}
