//
//  TaskRow.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI

struct TaskRow: View {
    let task: TaskEntity
    let onUpdate: (TaskEntity) -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { task.isCompleted },
                set: { newValue in
                    var updatedTask = task
                    updatedTask.isCompleted = newValue
                    onUpdate(updatedTask)
                }
            )) {
                Text(task.title)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
        }
    }
}
