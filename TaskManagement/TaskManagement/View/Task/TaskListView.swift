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
                if viewModel.isUnlocked {
                    taskList()
                        .tag("taskList")
                } else {
                    lockedView()
                        .tag("lockedView")
                }
            }
            .alert(viewModel.error ?? "Oops! Something went wrong. Please try again.", isPresented: $viewModel.error.isNotNil()) {
                Button("OK", role: .cancel) { }
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
    private func taskList() -> some View {
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
        .sheet(isPresented: $viewModel.isAddTaskShown) {
            AddTaskView { title in
                Task {
                    await viewModel.addTask(title: title)
                }
            }
        }
        .navigationBarTitle("Tasks")
        .navigationBarItems(trailing: Button(action: {
            viewModel.isAddTaskShown = true
        }) {
            Image(systemName: "plus")
        })
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
    
    @ViewBuilder
    private func lockedView() -> some View {
        VStack {
            Text("Task Management")
                .font(.largeTitle)
            Button("Unlock with Face ID") {
                Task {
                    await viewModel.authenticateUser()
                }
            }
        }
    }
}


#Preview {
    TaskListView(viewModel: TaskListViewModel(taskRepository: InMemoryTaskRepository(), authManager: BiometricAuthManager.shared))
}
