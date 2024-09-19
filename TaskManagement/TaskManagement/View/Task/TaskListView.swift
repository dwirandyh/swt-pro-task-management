//
//  TaskListView.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI

struct TaskListView: View {
    @ObservedObject var viewModel: TaskListViewModel

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                
                List {
                    ForEach(viewModel.filteredTasks) { task in
                        TaskRow(task: task, onUpdate: { updatedTask in
                            viewModel.updateTask(task: updatedTask)
                        }, onDelete: {
                            viewModel.deleteTask(task: task)
                        })
                    }
                }
                .navigationBarTitle("Tasks")
                .navigationBarItems(trailing: Button(action: {
                    viewModel.isAddTaskShown = true
                }) {
                    Image(systemName: "plus")
                })
            }
            .sheet(isPresented: $viewModel.isAddTaskShown) {
                AddTaskView { title in
                    viewModel.addTask(title: title)
                }
            }
        }
    }
}


#Preview {
    TaskListView(viewModel: TaskListViewModel())
}
