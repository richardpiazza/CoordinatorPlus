import Foundation

/// Protocol implemented by `UIViewController` subclasses being managed and displayed by a `FlowStepCoordinator`.
public protocol FlowStepViewController {
    /// The `FlowStep` the `UIViewController` manages.
    var flowStep: FlowStep { get }
    
    /// The coordinator managing this view controller.
    var flowStepCoordinator: FlowStepCoordinator? { get set }
}

@available(*, deprecated, renamed: "FlowStepViewController")
public typealias SubtaskViewController = FlowStepViewController

public extension FlowStepViewController {
    @available(*, deprecated, renamed: "flowStep")
    var subtask: FlowStep { flowStep }
    
    @available(*, deprecated, renamed: "flowStepCoordinator")
    var subtaskCoordinator: FlowStepCoordinator? {
        get { flowStepCoordinator }
        set { flowStepCoordinator = newValue }
    }
}
