import Foundation

/// Receives notifications that a `TaskCoordinator` has completed or that a
/// different `TaskCoordinator` is needed to continue the user's flow through the app.
///
/// - note: An `AppCoordinator` will most likely be a `TaskCoordinatorDelegate`. The
///         extension provides a default implementation hooking into the end() and
///         begin() methods of the `AppCoordinator`.
///
public protocol TaskCoordinatorDelegate: class {
    
    /// The task coordinator concluded successfully.
    func taskCoordinator(_ taskCoordinator: TaskCoordinator, ended task: Task)
    
    /// The task coordinator was canceled (used by modal coordinators)
    func taskCoordinator(_ taskCoordinator: TaskCoordinator, canceled task: Task)
    
    /// The task coordinator is reaching out for another coordinator to continue coordination duties.
    ///
    /// - Parameter taskCoordinator: The `TaskCoordinator` reaching out for assistance.
    /// - Parameter changeTask: The `Task` that is required to continue the user flow.
    /// - Parameter data: Any data that should be passed to the next Task Coordinator
    func taskCoordinator(_ taskCoordinator: TaskCoordinator, begin task: Task, with data: Any?)
}

public extension TaskCoordinatorDelegate where Self: AppCoordinator {
    func taskCoordinator(_ taskCoordinator: TaskCoordinator, ended task: Task) {
        endTask(task)
        
        if let nextTask = self.nextTask(after: task) {
            beginTask(nextTask, with: nil)
        }
    }
    
    func taskCoordinator(_ taskCoordinator: TaskCoordinator, canceled task: Task) {
        endTask(task)
    }
    
    func taskCoordinator(_ taskCoordinator: TaskCoordinator, begin task: Task, with data: Any?) {
        beginTask(task, with: data)
    }
}
