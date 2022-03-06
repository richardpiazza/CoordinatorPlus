import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An extension of `FlowCoordinator` designed for handling multi-view tasks.
///
/// For instance: A 'Login' workflow that might have a login view,
/// registration view, and password reset view.
///
/// `UIViewController` subclasses being managed by a `FlowStepCoordinator` should
/// implement the `FlowStepViewController` protocol. This allows the coordinator
/// to track the `currentFlowStep` during begin() and end() calls.
///
public protocol FlowStepCoordinator: FlowCoordinator {
    /// The `FlowStep` that this coordinator is currently displaying.
    var currentFlowStep: FlowStep { get set }
    
    #if canImport(UIKit)
    /// Initializes the `UIViewController` for the `FlowStep`.
    ///
    /// Assign any DataSource/Delegates.
    ///
    /// - parameters:
    ///   - flowStep: The `FlowStep`
    ///   - data: Any data that should be passed to the `UIViewController` instance.
    /// - returns: An initialized `UIViewController` for the specified `FlowStep`.
    func viewController(for flowStep: FlowStep, with data: Any?) -> UIViewController
    #endif
    
    /// Begin displaying the specific `FlowStep`.
    ///
    /// The default implementation pushes `UIViewController`s onto the navigation
    /// stack. If a request to begin a `FlowStep` associated with the
    /// `rootViewControllerType` is called, the stack will pop to the root.
    ///
    /// - parameters:
    ///   - flowStep: The specific `FlowStep`
    ///   - animated: Indicates wether animation is to be performed.
    ///   - data: Data that should be passed on to an initialized view controller.
    func beginFlowStep(_ flowStep: FlowStep, animated: Bool, with data: Any?)
    
    /// Ends the requested `FlowStep`. The default implementation will locate the `UIViewController` for the task and remove it from the stack.
    ///
    /// If it's the current UIViewController, a pop is performed.
    ///
    /// - parameters:
    ///   - flowStep: The `FlowStep` to end.
    ///   - animated: Indicates wether animation is to be performed.
    func endFlowStep(_ flowStep: FlowStep, animated: Bool)
}
