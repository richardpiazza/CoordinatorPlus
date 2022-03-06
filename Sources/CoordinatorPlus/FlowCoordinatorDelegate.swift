import Foundation

/// Receives notifications that a `FlowCoordinator` has completed or that a
/// different `FlowCoordinator` is needed to continue the user's flow through the app.
///
/// - note: An `AppCoordinator` will most likely be a `FlowCoordinatorDelegate`. The
///         extension provides a default implementation hooking into the end() and
///         begin() methods of the `AppCoordinator`.
///
public protocol FlowCoordinatorDelegate: AnyObject {
    
    /// The flow coordinator concluded successfully.
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, ended flow: Flow)
    
    /// The flow coordinator was canceled (used by modal coordinators)
    func flowCoordinator(_ flowCoordinator: FlowCoordinator, canceled flow: Flow)
    
    /// The flow coordinator is reaching out for another coordinator to continue coordination duties.
    ///
    /// - parameters:
    ///   - flowCoordinator: The `FlowCoordinator` reaching out for assistance.
    ///   - begin: The `Flow` that is required to continue the user flow.
    ///   - data: Any data that should be passed to the next Task Coordinator
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
