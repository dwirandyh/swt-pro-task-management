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

    func debug(_ message: String) {
        os_log("%@", log: logger, type: .debug, String(format: message))
    }

    func info(_ message: String) {
        os_log("%@", log: logger, type: .info, String(format: message))
    }

    func error(_ message: String) {
        os_log("%@", log: logger, type: .error, String(format: message))
    }

    func fault(_ message: String) {
        os_log("%@", log: logger, type: .fault, String(format: message))
    }
}
