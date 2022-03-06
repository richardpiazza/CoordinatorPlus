#if canImport(UIKit)
import UIKit

/// Extension of `FlowStepCoordinator` that requires a `UITabBarController` as its `flowViewController`.
///
/// A basic implementation of beginSubtask() is provided to add and select the
/// correct UIViewController for a given `FlowStep`. The default implementation does
/// not allow for a `FlowStep` to be ended, i.e. removed from the TabBar.
///
/// To fully track the `currentSubtask` state, the UITabBarControllerDelegate should
/// be implemented. An example is:
///
/// ```swift
/// // MARK: - UITabBarControllerDelegate
/// extension TabbedCoordinator: UITabBarControllerDelegate {
///     func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
///         var subtaskViewController: FlowStepViewController?
///         if let typedViewController = viewController as? FlowStepViewController {
///             subtaskViewController = typedViewController
///         } else if let navigationController = viewController as? UINavigationController, let typedViewController = navigationController.viewControllers.first as? FlowStepViewController {
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
public protocol TabBarFlowStepCoordinator: FlowStepCoordinator {
    
}

public extension TabBarFlowStepCoordinator {
    var tabBarController: UITabBarController {
        guard let tab = flowViewController as? UITabBarController else {
            preconditionFailure("TabBarFlowStepCoordinator requires `flowViewController` be a UITabBarController.")
        }
        
        return tab
    }
    
    func begin(with data: Any?) {
        beginFlowStep(currentFlowStep, with: data)
        let viewControllers = tabBarController.viewControllers ?? []
        
        guard viewControllers.count > 0 else {
            let viewController = self.viewController(for: currentFlowStep, with: data)
            tabBarController.viewControllers = [viewController]
            return
        }
        
        viewControllers.forEach { (viewController) in
            guard let subtaskViewController = viewController as? FlowStepViewController else {
                return
            }
            
            guard subtaskViewController.flowStep.isEqual(currentFlowStep) else {
                return
            }
            
            tabBarController.selectedViewController = viewController
        }
    }
    
    func beginFlowStep(_ flowStep: FlowStep, animated: Bool = true, with data: Any?) {
        let vcType = flowStep.viewControllerType
        
        var viewControllers = tabBarController.viewControllers ?? []
        for viewController in viewControllers {
            if type(of: viewController) == vcType {
                self.tabBarController.selectedViewController = viewController
                self.currentFlowStep = flowStep
                return
            } else if let nav = viewController as? UINavigationController, let root = nav.viewControllers.first, type(of: root) == vcType {
                self.tabBarController.selectedViewController = viewController
                self.currentFlowStep = flowStep
                return
            }
        }
        
        let viewController = self.viewController(for: flowStep, with: data)
        viewControllers.append(viewController)
        
        self.tabBarController.setViewControllers(viewControllers, animated: true)
        self.tabBarController.selectedViewController = viewController
        
        self.currentFlowStep = flowStep
    }
    
    func endFlowStep(_ flowStep: FlowStep, animated: Bool) {
        
    }
}
#endif
