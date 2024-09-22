//
//  AddTaskView.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismissAction
    @State private var title: String = ""
    var onAdd: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Task")) {
                    TextField("Task Title", text: $title)
                        .tag("textfield-task-title")
                }
                
                Button("Add Task") {
                    if !title.isEmpty {
                        onAdd(title)
                        dismissAction()
                    }
                }
                .tag("button-add-task")
            }
            .navigationBarTitle("Add Task")
            .navigationBarItems(
                trailing: Button(
                    "Cancel"
                ) {
                    dismissAction()
                }
                .tag("button-cancel")
            )
        }
    }
}


#Preview {
    AddTaskView { _ in }
}
