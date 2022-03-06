#if canImport(UIKit)
import UIKit

/// Extension of `FlowStepCoordinator` that requires a `UINavigationController` as its `flowViewController`.
///
/// To fully track the `currentFlowStep` the coordinator is displaying,
/// A `NavigationFlowStepCoordinator` should implement the `UINavigationControllerDelegate`
/// to track which task is visible. An implementation would look like:
///
/// ```swift
/// // MARK: - UINavigationControllerDelegate
/// extension LoginCoordinator: UINavigationControllerDelegate {
///     func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
///         if let flowStepViewController = viewController as? FlowStepViewController {
///             self.currentFlowStep = flowStepViewController.flowStep
///         }
///     }
/// }
/// ```
///
public protocol NavigationFlowStepCoordinator: FlowStepCoordinator {
}

public extension NavigationFlowStepCoordinator {
    var navigationController: UINavigationController {
        guard let nav = flowViewController as? UINavigationController else {
            preconditionFailure("NavigationFlowStepCoordinator requires `flowViewController` be a UINavigationController.")
        }
        
        return nav
    }
    
    func begin(with data: Any?) {
        beginFlowStep(currentFlowStep, with: data)
    }
    
    func beginFlowStep(_ flowStep: FlowStep, animated: Bool = true, with data: Any? = nil) {
        let vcType = flowStep.viewControllerType
        
        let viewControllers = navigationController.viewControllers
        let types = viewControllers.map({ return type(of: $0) })
        if let index = types.firstIndex(where: { $0 == vcType }) {
            let viewController = viewControllers[index]
            navigationController.popToViewController(viewController, animated: true)
            self.currentFlowStep = flowStep
            
            return
        }
        
        let vc = viewController(for: flowStep, with: data)
        
        if viewControllers.count == 0 {
            navigationController.viewControllers = [vc]
        } else {
            navigationController.pushViewController(vc, animated: animated)
        }
        
        self.currentFlowStep = flowStep
    }
    
    func endFlowStep(_ flowStep: FlowStep, animated: Bool = true) {
        let vcType = flowStep.viewControllerType
        
        let viewControllers = navigationController.viewControllers
        let types = viewControllers.map({ return type(of: $0)})
        
        guard let index = types.firstIndex(where: { $0 == vcType }), index != 0 else {
            return
        }
        
        if index == (types.count - 1) {
            navigationController.popViewController(animated: animated)
            if let subtaskViewController = viewControllers[index - 1] as? FlowStepViewController {
                self.currentFlowStep = subtaskViewController.flowStep
            }
            return
        }
        
        navigationController.viewControllers.remove(at: index)
    }
}

@available(*, deprecated, renamed: "NavigationFlowStepCoordinator")
public typealias NavigationSubtaskCoordinator = NavigationFlowStepCoordinator
#endif
