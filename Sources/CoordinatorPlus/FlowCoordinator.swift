import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An object that manages a single `Flow`.
///
/// The `flowViewController` of a `FlowCoordinator` can be any `UIViewController` subclass.
/// But there are specialized protocol extensions that are provided for other UIViewController types.
///
/// *   **NavigationFlowStepCoordinator**: requires a `UINavigationController` as it's
///     root and pushes/pops views for `FlowStep`s.
///
/// *   **TabBarFlowStepCoordinator**: Manages adding UIViewControllers for specific
///     `FlowStep`s on to a UITabBarController.
///
/// *   **SplitViewFlowStepCoordinator**: Handles the interaction of `FlowStep`s in
///     the context of a UISplitViewController.
///
public protocol FlowCoordinator: AnyObject {
    
    #if canImport(UIKit)
    /// The view controller which the task coordinator will use to present its managed screens.
    ///
    /// For a single screen task - like 'settings' - this may be a `UINavigationController`.
    var flowViewController: UIViewController { get }
    #endif
    
    /// The `Flow` that this coordinator aims to coordinate.
    var flow: Flow { get }
    
    /// Should the presentation of this coordinator happen modally?
    ///
    /// - note: The default implementations on `AppCoordinator` will only display a single modal flow coordinator at a time.
    var isModal: Bool { get }
    
    /// The flow coordinator's delegate.
    var flowCoordinatorDelegate: FlowCoordinatorDelegate? { get set }
    
    /// Instructs the `FlowCoordinator` to begin its flow.
    func begin(with data: Any?)
    
    /// The coordinator should perform any actions to pause it's flow.
    func pause()
    
    /// The coordinator should perform any actions needed to resume it's flow.
    func resume()
    
    /// Called immediately before the coordinator is terminated.
    @discardableResult func end() -> Any?
}

public extension FlowCoordinator {
    var isModal: Bool {
        return false
    }
    
    func begin(with data: Any?) {
        
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    @discardableResult func end() -> Any? {
        return nil
    }
}

@available(*, deprecated, renamed: "FlowCoordinator")
public typealias TaskCoordinator = FlowCoordinator

public extension FlowCoordinator {
    #if canImport(UIKit)
    @available(*, deprecated, renamed: "flowViewController")
    var taskViewController: UIViewController { flowViewController }
    #endif
    
    @available(*, deprecated, renamed: "flow")
    var task: Flow { flow }
    
    @available(*, deprecated, renamed: "flowCoordinatorDelegate")
    var taskCoordinatorDelegate: FlowCoordinatorDelegate? {
        get { flowCoordinatorDelegate }
        set { flowCoordinatorDelegate = newValue }
    }
}
