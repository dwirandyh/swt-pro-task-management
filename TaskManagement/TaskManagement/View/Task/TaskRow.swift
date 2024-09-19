//
//  TaskRow.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI

struct TaskRow: View {
    var task: TaskModel
    var onUpdate: (TaskModel) -> Void
    var onDelete: () -> Void

    @State private var isCompleted: Bool

    init(task: TaskModel, onUpdate: @escaping (TaskModel) -> Void, onDelete: @escaping () -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _isCompleted = State(initialValue: task.isCompleted)
    }

    var body: some View {
        HStack {
            Toggle(isOn: $isCompleted) {
                Text(task.title)
            }
            .onChange(of: isCompleted) { newValue in
                var updatedTask = task
                updatedTask.isCompleted = newValue
                onUpdate(updatedTask)
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
        }
    }
}
