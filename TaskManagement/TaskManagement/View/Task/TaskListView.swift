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
                Picker("Filter", selection: $viewModel.filterOption) {
                    Text("All").tag(FilterOption.all)
                    Text("Completed").tag(FilterOption.completed)
                    Text("Not Completed").tag(FilterOption.notCompleted)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                SearchBar(text: $viewModel.searchText)
                
                List {
                    ForEach(viewModel.tasks) { task in
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
            .task {
                do {
                    try await viewModel.syncData()
                }
                catch {
                    print("Failed to sync data \(error)")
                }
            }
        }
    }
}


#Preview {
    TaskListView(viewModel: TaskListViewModel(taskRepository: InMemoryTaskRepository()))
}
