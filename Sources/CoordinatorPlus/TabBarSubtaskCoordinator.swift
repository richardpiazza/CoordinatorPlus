#if canImport(UIKit)
import UIKit

/// Extension of `SubtaskCoordinator` that requires a `UITabBarController` as its `taskViewController`.
///
/// A basic implementation of beginSubtask() is provided to add and select the
/// correct UIViewController for a given `Subtask`. The default implementation does
/// not allow for a `Subtask` to be ended, i.e. removed from the TabBar.
///
/// To fully track the `currentSubtask` state, the UITabBarControllerDelegate should
/// be implemented. An example is:
///
/// ```swift
/// // MARK: - UITabBarControllerDelegate
/// extension TabbedCoordinator: UITabBarControllerDelegate {
///     func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
///         var subtaskViewController: SubtaskViewController?
///         if let typedViewController = viewController as? SubtaskViewController {
///             subtaskViewController = typedViewController
///         } else if let navigationController = viewController as? UINavigationController, let typedViewController = navigationController.viewControllers.first as? SubtaskViewController {
///             subtaskViewController = typedViewController
///         }
///
///         guard let viewController = subtaskViewController else {
///             return
///         }
///
///         self.currentSubtask = viewController.subtask
///     }
/// }
/// ```
///
public protocol TabBarSubtaskCoordinator: SubtaskCoordinator {
    
}

public extension TabBarSubtaskCoordinator {
    var tabBarController: UITabBarController {
        guard let tab = taskViewController as? UITabBarController else {
            preconditionFailure("TabBarSubtaskCoordinator requires 'taskViewController' be a UITabBarController.")
        }
        
        return tab
    }
    
    func begin(with data: Any?) {
        beginSubtask(currentSubtask, with: data)
        let viewControllers = tabBarController.viewControllers ?? []
        
        guard viewControllers.count > 0 else {
            let viewController = self.viewController(for: currentSubtask, with: data)
            tabBarController.viewControllers = [viewController]
            return
        }
        
        viewControllers.forEach { (viewController) in
            guard let subtaskViewController = viewController as? SubtaskViewController else {
                return
            }
            
            guard subtaskViewController.subtask.isEqual(currentSubtask) else {
                return
            }
            
            tabBarController.selectedViewController = viewController
        }
    }
    
    func beginSubtask(_ subtask: Subtask, animated: Bool = true, with data: Any?) {
        let vcType = subtask.viewControllerType
        
        var viewControllers = tabBarController.viewControllers ?? []
        for viewController in viewControllers {
            if type(of: viewController) == vcType {
                self.tabBarController.selectedViewController = viewController
                self.currentSubtask = subtask
                return
            } else if let nav = viewController as? UINavigationController, let root = nav.viewControllers.first, type(of: root) == vcType {
                self.tabBarController.selectedViewController = viewController
                self.currentSubtask = subtask
                return
            }
        }
        
        let viewController = self.viewController(for: subtask, with: data)
        viewControllers.append(viewController)
        
        self.tabBarController.setViewControllers(viewControllers, animated: true)
        self.tabBarController.selectedViewController = viewController
        
        self.currentSubtask = subtask
    }
    
    func endSubtask(_ subtask: Subtask, animated: Bool) {
        
    }
}
#endif
