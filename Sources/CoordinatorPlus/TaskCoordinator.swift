import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// An object that manages a single `Task`.
///
/// The `taskViewController` of a `TaskCoordinator` can be any `UIViewController`
/// subclass. But there are specialized protocol extensions that are provided for
/// other UIViewController types.
///
/// *   **NavigationSubtaskCoordinator**: requires a `UINavigationController` as it's
///     root and pushes/pops views for `Subtask`s.
///
/// *   **TabBarSubtaskCoordinator**: Manages adding UIViewControllers for specific
///     `Subtask`s on to a UITabBarController.
///
/// *   **SplitViewSubtaskCoordinator**: Handles the interaction of `Subtask`s in
///     the context of a UISplitViewController.
///
public protocol TaskCoordinator: class {
    
    #if canImport(UIKit)
    /// The view controller which the task coordinator will use to present
    /// its managed screens. For a single screen task - like 'settings' -,
    /// this may be a `UINavigationController`.
    var taskViewController: UIViewController { get }
    #endif
    
    /// The `Task` that this coordinator aims to coordinate.
    var task: Task { get }
    
    /// Should the presentation of this coordinator happen modally?
    /// - note: The default implementations on `AppCoordinator` will
    ///         only display a single modal task coordinator at a time.
    var isModal: Bool { get }
    
    /// The task coordinator's delegate.
    var taskCoordinatorDelegate: TaskCoordinatorDelegate? { get set }
    
    /// Instructs the TaskCoordinator to begin its task.
    func begin(with data: Any?)
    
    /// The coordinator should perform any actions to pause it's task.
    func pause()
    
    /// The coordinator should perform any actions needed to resume it's task.
    func resume()
    
    /// Called immediately before the task is removed from the view stack.
    @discardableResult
    func end() -> Any?
}

public extension TaskCoordinator {
    var isModal: Bool {
        return false
    }
    
    func begin(with data: Any?) {
        
    }
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    @discardableResult
    func end() -> Any? {
        return nil
    }
}
