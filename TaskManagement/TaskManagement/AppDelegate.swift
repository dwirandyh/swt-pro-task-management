//
//  AppDelegate.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import FirebaseCore
import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        setupNetworkSync()
        
        return true
    }
    
    private func setupNetworkSync() {
        let networkMonitor = NetworkMonitor()
        networkMonitor.setOnNetworkStatusChanged { isConnected in
            if isConnected {
                Task {
                    try await SyncManager.shared.syncFirestoreToCoreData()
                }
            }
        }
        
        networkMonitor.startMonitoring()
    }
}
