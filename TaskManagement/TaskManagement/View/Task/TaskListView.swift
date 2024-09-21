//
//  TaskListView.swift
//  TaskManagement
//
//  Created by Dwi Randy H on 19/09/24.
//

import SwiftUI

struct TaskListView: View {
    @StateObject var viewModel: TaskListViewModel
    
    let logger: Logger = .init(category: "View")

    var body: some View {
        NavigationView {
            VStack {
                statusPicker()
                
                SearchBar(text: $viewModel.searchText)
                
                List {
                    ForEach(viewModel.tasks) { task in
                        TaskRow(task: task, onUpdate: { updatedTask in
                            Task {
                                await viewModel.updateTask(task: updatedTask)
                            }
                        }, onDelete: {
                            Task {
                                await viewModel.deleteTask(task: task)
                            }
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
                    Task {
                        await viewModel.addTask(title: title)
                    }
                }
            }
            .task {
                do {
                    try await viewModel.syncData()
                }
                catch {
                    logger.error("Failed to sync data \(error)")
                }
            }
        }
    }
    
    @ViewBuilder
    private func statusPicker() -> some View {
        Picker("Filter", selection: $viewModel.filterOption) {
            Text("All").tag(FilterOption.all)
            Text("Completed").tag(FilterOption.completed)
            Text("Not Completed").tag(FilterOption.notCompleted)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}


#Preview {
    TaskListView(viewModel: TaskListViewModel(taskRepository: InMemoryTaskRepository()))
}
