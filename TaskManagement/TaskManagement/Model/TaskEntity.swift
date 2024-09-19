//
//  Task.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import Foundation

struct TaskEntity: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

extension TaskEntity {
    init(from model: TaskModel) {
        self.id = model.id ?? UUID()
        self.title = model.title ?? ""
        self.isCompleted = model.isCompleted
    }
}
