//
//  MockSyncManager.swift
//  TaskManagementTests
//
//  Created by Dwi Randy H on 21/09/24.
//

import Foundation
@testable import TaskManagement

class MockSyncManager: SyncManagerProtocol {
    var syncFirestoreToCoreDataCalled = false
    var savePendingSyncCalled = false
    var pushCoreDataToFirestoreCalled = false

    func syncFirestoreToCoreData() async throws {
        syncFirestoreToCoreDataCalled = true
    }

    func savePendingSync(taskId: UUID, actionType: String) async throws {
        savePendingSyncCalled = true
    }

    func pushCoreDataToFirestore() async throws {
        pushCoreDataToFirestoreCalled = true
    }
}
