//
//  EncryptionTests.swift
//  TaskManagementTests
//
//  Created by Dwi Randy H on 21/09/24.
//

import XCTest
@testable import TaskManagement

class EncryptionTests: XCTestCase {
    
    var encryption: Encryption!
    
    override func setUp() {
        super.setUp()
        encryption = Encryption.default
    }
    
    override func tearDown() {
        encryption = nil
        super.tearDown()
    }
    
    func testEncryptionAndDecryption() {
        let originalString = "secret message"
        
        guard let encryptedString = encryption.encrypt(string: originalString) else {
            XCTFail("Encryption failed")
            return
        }
        
        XCTAssertNotEqual(originalString, encryptedString, "Encrypted string should be different with original")
        
        guard let decryptedString = encryption.decrypt(string: encryptedString) else {
            XCTFail("Decryption failed")
            return
        }
        
        XCTAssertEqual(originalString, decryptedString, "Decrypted string should same as original")
    }
    
    func testDecryptionWithInvalidInput() {
        let invalidEncryptedString = "Not valid encrypted string"
        
        let decryptedString = encryption.decrypt(string: invalidEncryptedString)
        
        XCTAssertNil(decryptedString, "Decryption should fail with invalid data")
    }
}
