# TaskManagement

TaskManagement is a iOS application for managing tasks with local storage and cloud synchronization.

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Build and run the application on a simulator or physical device

## Architecture Overview

The TaskManagement app follows the MVVM (Model-View-ViewModel) architecture pattern and is built using SwiftUI for the UI layer.

Key components:
- Models: Core Data entities (TaskModel, PendingSyncModel)
- Views: SwiftUI views (AddTaskView, TaskListView)
- ViewModels: (implied from the MVVM architecture)
- Repositories: TaskRepository protocol and LocalTaskRepository implementation
- Database Managers: PersistentContainer for Core Data operations
- Sync Manager: Handles data synchronization with Firestore
- Network Monitor: Monitors network connectivity

## Key Design Decisions

1. Use of Core Data for local storage instead of third party like realm (deprecated)
2. Implementation of a SyncManager to handle data synchronization between local storage and Firestore
3. Adoption of the Repository pattern to abstract data operations and make the codebase testable
4. Use of SwiftUI for user interface with built in property wrapper like @Published, @State, @Binding
5. Use modern Swift 5.5+ modern feature like Async/Await, Actor, Combine
6. Unit testing with 77% coverage including with UI with [ViewInspector](https://github.com/nalexn/ViewInspector)

## Known Limitations and Future Improvements

1. There is a known bug with NWPathMonitor in the simulator that causes incorrect path status in simulator
2. Implement more robust error handling for sync operations
3. Add support for task categories or tags
4. Improve test coverage, especially for edge cases
5. Implement a more robust sync process incrementally
6. Implement user authentication and multi-user support
