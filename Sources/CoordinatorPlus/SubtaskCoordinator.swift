import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An extension of `TaskCoordinator` designed for handling multi-view tasks.
///
/// For instance: A 'Login' workflow that might have a login view,
/// registration view, and password reset view.
///
/// `UIViewController` subclasses being managed by a `SubtaskCoordinator` should
/// implement the `SubtaskViewController` protocol. This allows the coordinator
/// to track the `currentSubtask` during begin() and end() calls.
///
public protocol SubtaskCoordinator: TaskCoordinator {
    /// The `Subtask` that this coordinator is currently displaying.
    var currentSubtask: Subtask { get set }
    
    #if canImport(UIKit)
    /// Initializes the `UIViewController` for the `Subtask`.
    /// Assign any DataSource/Delegates.
    ///
    /// - parameter subtask: The `Subtask`
    /// - parameter data: Any data that should be passed to the `UIViewController` instance.
    /// - returns: An initialized `UIViewController` for the specified `Subtask`.
    func viewController(for subtask: Subtask, with data: Any?) -> UIViewController
    #endif
    
    /// Begin displaying the specific `Subtask`.
    /// The default implementation pushes `UIViewController`s onto the navigation
    /// stack. If a request to begin a `Subtask` associated with the
    /// `rootViewControllerType` is called, the stack will pop to the root.
    ///
    /// - parameter subtask: The specific `Subtask`
    /// - parameter animated: Indicates wether animation is to be performed.
    /// - parameter data: Data that should be passed on to an initialized view controller.
    func beginSubtask(_ subtask: Subtask, animated: Bool, with data: Any?)
    
    /// Ends the requested `Subtask`. The default implementation will
    /// locate the `UIViewController` for the task and remove it from the stack.
    /// If it's the current UIViewController, a pop is performed.
    ///
    /// - parameter subtask: The `Subtask` to end.
    /// - parameter animated: Indicates wether animation is to be performed.
    func endSubtask(_ subtask: Subtask, animated: Bool)
}
