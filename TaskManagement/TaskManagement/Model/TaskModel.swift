//
//  TaskModel.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation

struct TaskModel: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
