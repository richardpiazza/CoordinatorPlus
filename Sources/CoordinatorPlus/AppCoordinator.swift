import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Root object of the application.
///
/// The `AppCoordinator` is responsible for bootstrapping the app and determining initial state.
/// It coordinates between tasks, and generally manages the flow of the application.
///
/// These rules should be followed to maintain conformance to the CoordinatedMVC Pattern.
///
/// *   No view controller should access information except from its dataSource (View Model).
///
/// *   No view controller should attempt to mutate state outside of itself
///     except through its delegate (usually a TaskCoordinator).
///
/// *   No view controller should have knowledge of any other view controller save those
///     which it directly parents (embed segue or custom containment).
///
/// *   View Controllers should never access the Service layer directly;
///     always mediate access through a delegate and dataSource.
///
/// *   A view controller may be used by any number of TaskCoordinator objects,
///     so long as they are able to fulfill its data and delegation needs.
///
public protocol AppCoordinator: class {
    
    #if canImport(UIKit)
    /// Required initializer
    /// The initializer of an `AppCoordinator` is responsible for capturing the window
    /// reference, creating any services needed, and beginning an initial `Task`.
    ///
    /// By default the AppCoordinator protocol has default implementations of the
    /// primary functions for begin/end and present/dismiss.
    ///
    /// *UIWindow / Root View Controller*
    ///
    /// * The rootViewController of the UIWindow is a plain UIViewController
    /// * This **can not** be an instance of UITabBarController or UINavigationController.
    /// * If you choose to do otherwise, you should implement dismiss()/present() yourself.
    ///
    /// - parameter window: The UIWindow provided form the UIApplicationDelegate
    ///
    init(window: UIWindow)
    
    /// A reference to the UIWindow provided from the app delegate
    var window: UIWindow { get }
    #endif
    
    /// The current *non-modal* coordinator handling user interaction
    var currentCoordinator: TaskCoordinator? { get set }
    
    /// The current *modal* coordinator handling user interaction
    var modalCoordinator: TaskCoordinator? { get set }
    
    /// Responsible for creating and vending `TaskCoordinator` for the given task.
    ///
    /// - parameter task: The `Task` to vend a coordinator for.
    /// - parameter data: Any data to pass to the coordinator.
    func coordinator(for task: Task, with data: Any?) -> TaskCoordinator
    
    /// Returns a task that should begin after the specified task finishes.
    ///
    /// - parameter task: The task being finished
    /// - returns: A new task to begin, or nil.
    func nextTask(after task: Task) -> Task?
    
    /// Begin or Restart a task
    ///
    /// Logic/Handling:
    /// - initializing a coordinator for the task
    /// - call coordinators `begin(with:)` method
    /// - call dismiss()/present() as needed
    /// - set currentCoordinator/modalCoordinator
    ///
    /// - parameter task: The Task to begin/restart
    /// - parameter animated: Indicates wether animation is performed in transition
    /// - parameter data: Any data to pass to the taskCoordinator being started.
    func beginTask(_ task: Task, animated: Bool, with data: Any?)
    
    /// End a task
    ///
    /// Logic/Handling:
    /// - identify the task coordinator for the task
    /// - call coordinators `prepareForRemoval()`
    /// - call `dismiss(taskCoordinator:)`
    /// - nil currentCoordinator/modalCoordinator
    ///
    /// - parameter task: The Task to end
    func endTask(_ task: Task)
    
    /// Handles the dismissal/removal of the `TaskCoordinator`s taskViewController.
    ///
    /// - parameter taskCoordinator: The `TaskCoordinator` to dismiss
    /// - parameter animated: Indicates wether animation is performed in dismissal
    /// - parameter completion: Handler called upon completion of dismissal
    func dismiss(taskCoordinator: TaskCoordinator, animated: Bool, completion: (() -> Void)?)
    
    /// Handles the presentation/adding of the `TaskCoordinator`s taskViewController.
    ///
    /// - parameter taskCoordinator: The `TaskCoordinator` to present
    /// - parameter animated: Indicates wether animation is performed in adding
    /// - parameter completion: Handler called upon completion of adding
    func present(taskCoordinator: TaskCoordinator, animated: Bool, completion:(() -> Void)?)
}

public extension AppCoordinator {
    func nextTask(after task: Task) -> Task? {
        return nil
    }
    
    func beginTask(_ task: Task, animated: Bool = true, with data: Any? = nil) {
        if let currentCoordinator = self.currentCoordinator, currentCoordinator.task.isEqual(task) {
            DispatchQueue.main.async {
                currentCoordinator.resume()
            }
            return
        } else if let modalCoordinator = self.modalCoordinator, modalCoordinator.task.isEqual(task) {
            DispatchQueue.main.async {
                modalCoordinator.resume()
            }
            return
        }
        
        let nextCoordinator = coordinator(for: task, with: data)
        
        defer {
            if nextCoordinator.isModal {
                self.modalCoordinator = nextCoordinator
            } else {
                self.currentCoordinator = nextCoordinator
            }
        }
        
        // Don't stack modals & don't present a non-modal over existing modal
        if let modalCoordinator = self.modalCoordinator, nextCoordinator.isModal {
            DispatchQueue.main.async {
                modalCoordinator.end()
            }
            dismiss(taskCoordinator: modalCoordinator, animated: animated) { [unowned self] in
                nextCoordinator.begin(with: data)
                self.present(taskCoordinator: nextCoordinator, animated: animated, completion: nil)
            }
        } else if let currentCoordinator = self.currentCoordinator, !nextCoordinator.isModal {
            DispatchQueue.main.async {
                currentCoordinator.end()
            }
            dismiss(taskCoordinator: currentCoordinator, animated: animated) { [unowned self] in
                nextCoordinator.begin(with: data)
                self.present(taskCoordinator: nextCoordinator, animated: animated, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                self.currentCoordinator?.pause()
                nextCoordinator.begin(with: data)
            }
            present(taskCoordinator: nextCoordinator, animated: animated, completion: nil)
        }
    }
    
    func endTask(_ task: Task) {
        if let coordinator = self.currentCoordinator, coordinator.task.isEqual(task) {
            DispatchQueue.main.async {
                coordinator.end()
            }
            dismiss(taskCoordinator: coordinator, animated: true, completion: nil)
            self.currentCoordinator = nil
        } else if let coordinator = self.modalCoordinator, coordinator.task.isEqual(task) {
            DispatchQueue.main.async {
                coordinator.end()
            }
            dismiss(taskCoordinator: coordinator, animated: true, completion: nil)
            self.modalCoordinator = nil
            DispatchQueue.main.async {
                self.currentCoordinator?.resume()
            }
        }
    }
}

#if canImport(UIKit)
public extension AppCoordinator {
    var taskViewController: UIViewController {
        if let _ = window.rootViewController as? UITabBarController {
            preconditionFailure("AppCoordinator window.rootViewController must be a UIViewController, not a UITabBarController.")
        }
        if let _ = window.rootViewController as? UINavigationController {
            preconditionFailure("AppCoordinator window.rootViewController must be a UIViewController, not a UINavigationController.")
        }
        if let _ = window.rootViewController as? UISplitViewController {
            preconditionFailure("AppCoordinator window.rootViewController must be a UIViewController, not a UISplitViewController.")
        }
        
        guard let viewController = window.rootViewController else {
            preconditionFailure("AppCoordinator window.rootViewController must be a UIViewController.")
        }
        
        return viewController
    }
    
    func dismiss(taskCoordinator: TaskCoordinator, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if taskCoordinator.isModal {
                self.taskViewController.dismiss(animated: animated, completion: completion)
            } else {
                taskCoordinator.taskViewController.willMove(toParent: nil)
                taskCoordinator.taskViewController.view.removeFromSuperview()
                taskCoordinator.taskViewController.removeFromParent()
                completion?()
            }
        }
    }
    
    func present(taskCoordinator: TaskCoordinator, animated: Bool = true, completion:(() -> Void)? = nil) {
        if taskCoordinator.isModal {
            let controller = currentCoordinator?.taskViewController ?? taskViewController
            DispatchQueue.main.async {
                controller.present(taskCoordinator.taskViewController, animated: animated, completion: completion)
            }
            return
        }
        
        if animated {
            DispatchQueue.main.async {
                taskCoordinator.taskViewController.view.frame = self.taskViewController.view.frame
                taskCoordinator.taskViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                taskCoordinator.taskViewController.view.alpha = 0.0
                
                self.taskViewController.view.addSubview(taskCoordinator.taskViewController.view)
                self.taskViewController.addChild(taskCoordinator.taskViewController)
                
                let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear, animations: {
                    taskCoordinator.taskViewController.view.alpha = 1.0
                })
                animator.addCompletion { (_) in
                    taskCoordinator.taskViewController.didMove(toParent: self.taskViewController)
                    DispatchQueue.main.async {
                        completion?()
                    }
                }
                animator.startAnimation()
            }
        } else {
            DispatchQueue.main.async {
                self.taskViewController.addChild(taskCoordinator.taskViewController)
                self.taskViewController.view.addSubview(taskCoordinator.taskViewController.view)
                taskCoordinator.taskViewController.view.frame = self.taskViewController.view.frame
                taskCoordinator.taskViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                taskCoordinator.taskViewController.didMove(toParent: self.taskViewController)
                completion?()
            }
        }
    }
}
#endif
