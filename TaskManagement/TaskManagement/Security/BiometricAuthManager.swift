//
//  BiometricAuthManager.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 22/09/24.
//


import LocalAuthentication

protocol AuthManager {
    func authenticateUser() async -> Bool
}

class BiometricAuthManager: AuthManager {
    static let shared = BiometricAuthManager()
    
    private init() {}
    
    func authenticateUser() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock TaskManagement"
            do {
                return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            } catch {
                return false
            }
        } else {
            // "Biometric authentication not available. Unlocking automatically."
            return true
        }
    }
}
