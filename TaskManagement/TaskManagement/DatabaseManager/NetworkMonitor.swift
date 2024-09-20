//
//  NetworkMonitor.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 20/09/24.
//

import Foundation
import Network

class NetworkMonitor {
    
    private let monitor = NWPathMonitor()
    var onNetworkStatusChanged: ((Bool) -> Void)?
    
    func setOnNetworkStatusChanged(_ onNetworkStatusChanged: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            let isConnected = path.status == .satisfied
            onNetworkStatusChanged(isConnected)
        }
    }
    
    func startMonitoring() {
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
