//
//  MockBiometricAuthManager.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 22/09/24.
//


import Foundation
@testable import TaskManagement

class MockBiometricAuthManager: AuthManager {
    var shouldSucceed: Bool = true
    var authenticateUserCalled = false

    func authenticateUser() async -> Bool {
        authenticateUserCalled = true
        return shouldSucceed
    }
}
