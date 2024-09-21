//
//  Encryption.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 21/09/24.
//

import CryptoKit
import Foundation

class Encryption {
    
    static let `default` = Encryption()
    
    private var key: SymmetricKey
    private let logger: Logger
    
    init() {
        self.logger = .init(category: "Encryption")
        
        if let storedKey = Encryption.loadKeyFromKeychain() {
            self.key = storedKey
        } else {
            self.key = SymmetricKey(size: .bits256)
            Encryption.storeKeyInKeychain(key: self.key)
        }
    }
    
    // Encrypts a string
    func encrypt(string: String) -> String? {
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            let combined = sealedBox.combined!
            return combined.base64EncodedString() // Return as Base64-encoded string
        } catch {
            logger.error("Encryption error: \(error)")
            return nil
        }
    }
    
    // Decrypts a string
    func decrypt(string: String) -> String? {
        guard let data = Data(base64Encoded: string) else {
            return nil
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8) // Convert back to string
        } catch {
            logger.error("Decryption error: \(error)")
            return nil
        }
    }
    
    private static func storeKeyInKeychain(key: SymmetricKey) {
        let keyData = key.withUnsafeBytes { Data($0) }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "encryptionKey",
            kSecValueData as String: keyData
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private static func loadKeyFromKeychain() -> SymmetricKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "encryptionKey",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let keyData = item as? Data else {
            return nil
        }
        
        return SymmetricKey(data: keyData)
    }
}
