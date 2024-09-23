# TaskManagement

TaskManagement is an iOS application for managing tasks with local storage and cloud synchronization.



https://github.com/user-attachments/assets/986fccbf-cbf3-4026-940d-4bfc11433d63



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

1. Use of Core Data for local storage instead of third party like realm (deprecated) & increased app size 5 to 8 Mb [Docs](https://realm.netlify.app/docs/swift/latest/#faq)
2. Implementation of a SyncManager to handle data synchronization between local storage and Firestore
3. Adoption of the Repository pattern to abstract data operations and make the codebase testable
4. Use of SwiftUI for user interface with built in property wrapper like @Published, @State, @Binding
5. Use modern Swift 5.5+ modern feature like Async/Await, Actor, Combine
6. Unit testing with 77% coverage including with UI with [ViewInspector](https://github.com/nalexn/ViewInspector)

## Known Limitations and Future Improvements

1. There’s a known bug with NWPathMonitor in the simulator where it shows incorrect path status, like showing "satisfied" when disconnected and not showing "failed" when connected. It works fine on actual devices. [Source](https://forums.developer.apple.com/forums/thread/713330)
2. Add support for widget & search from spotlight
4. Improve test coverage, especially for edge cases
5. Implement a more robust sync process that can sync data incrementally
6. Implement user authentication for multi-user support
