//
//  BackgroundTaskManager.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation
import UIKit

class BackgroundTaskManager: ObservableObject {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    let logger: Logger
    
    init() {
        self.logger = .init(category: "BackgroundTaskManager")
    }
    
    func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "SyncTask") {
            self.endBackgroundTask()
        }
        
        if backgroundTask != .invalid {
            Task(priority: .background) {
                do {
                    try await SyncManager.shared.pushCoreDataToFirestore()
                } catch {
                    logger.error("Failed to sync Firestore to CoreData: \(error.localizedDescription)")
                }
                
                self.endBackgroundTask()
            }
        }
    }
    
    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
