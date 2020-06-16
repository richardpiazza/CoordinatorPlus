import Foundation

/// Protocol implemented by `UIViewController` subclasses being managed and displayed by a `SubtaskCoordinator`.
public protocol SubtaskViewController {
    /// The `Subtask` the `UIViewController` manages.
    var subtask: Subtask { get }
    
    /// The coordinator managing this view controller.
    var subtaskCoordinator: SubtaskCoordinator? { get set }
}
