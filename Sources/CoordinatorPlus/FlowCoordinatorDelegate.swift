import Foundation

/// Receives notifications that a `TaskCoordinator` has completed or that a
/// different `TaskCoordinator` is needed to continue the user's flow through the app.
///
/// - note: An `AppCoordinator` will most likely be a `TaskCoordinatorDelegate`. The
///         extension provides a default implementation hooking into the end() and
///         begin() methods of the `AppCoordinator`.
///
public protocol FlowCoordinatorDelegate: AnyObject {
    
    /// The task coordinator concluded successfully.
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, ended flow: Flow)
    
    /// The task coordinator was canceled (used by modal coordinators)
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, canceled flow: Flow)
    
    /// The task coordinator is reaching out for another coordinator to continue coordination duties.
    ///
    /// - Parameter taskCoordinator: The `TaskCoordinator` reaching out for assistance.
    /// - Parameter changeTask: The `Task` that is required to continue the user flow.
    /// - Parameter data: Any data that should be passed to the next Task Coordinator
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, begin flow: Flow, with data: Any?)
}

public extension FlowCoordinatorDelegate where Self: AppCoordinator {
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, ended flow: Flow) {
        endFlow(flow)
        
        if let nextTask = self.nextFlow(after: flow) {
            beginFlow(nextTask, with: nil)
        }
    }
    
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, canceled flow: Flow) {
        endFlow(flow)
    }
    
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, begin flow: Flow, with data: Any?) {
        beginFlow(flow, with: data)
    }
}

@available(*, deprecated, renamed: "FlowCoordinatorDelegate")
public typealias TaskCoordinatorDelegate = FlowCoordinatorDelegate

public extension FlowCoordinatorDelegate {
    @available(*, deprecated, renamed: "flowCoordinator(_:ended:)")
    func taskCoordinator(_ taskCoordinator: FlowCoordinator, ended task: Flow) {
        flowCoordinator(taskCoordinator, ended: task)
    }
    
    @available(*, deprecated, renamed: "flowCoordinator(_:canceled:)")
    func taskCoordinator(_ taskCoordinator: FlowCoordinator, canceled task: Flow) {
        flowCoordinator(taskCoordinator, canceled: task)
    }
    
    @available(*, deprecated, renamed: "flowCoordinator(_:begin:with:)")
    func taskCoordinator(_ taskCoordinator: FlowCoordinator, begin task: Flow, with data: Any?) {
        flowCoordinator(taskCoordinator, begin: task, with: data)
    }
}
