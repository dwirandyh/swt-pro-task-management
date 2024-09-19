//
//  TaskRow.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI

struct TaskRow: View {
    var task: TaskEntity
    var onUpdate: (TaskEntity) -> Void
    var onDelete: () -> Void

    @State private var isCompleted: Bool

    init(task: TaskEntity, onUpdate: @escaping (TaskEntity) -> Void, onDelete: @escaping () -> Void) {
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    var updatedTaskEntity = task
                    updatedTaskEntity.isCompleted = newValue
                    onUpdate(updatedTaskEntity)
                }
            }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
        }
    }
}
