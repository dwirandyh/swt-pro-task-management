//
//  Logger.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 21/09/24.
//

import Foundation
import os

class Logger {
    private let logger: OSLog

    init(subsystem: String = "com.dwirandyh.taskmgmt", category: String = "") {
        self.logger = OSLog(subsystem: subsystem, category: category)
    }

    func error(_ message: String) {
        os_log("%@", log: logger, type: .error, String(format: message))
    }
}
