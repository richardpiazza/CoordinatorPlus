#if canImport(UIKit)
import UIKit

/// Extension of `FlowStepCoordinator` that requires a `UISplitViewController` as its `flowViewController`.
public protocol SplitViewFlowStepCoordinator: FlowStepCoordinator {
    func masterViewControllerType() -> UIViewController.Type
    func masterViewController(with data: Any?) -> UIViewController
    func detailViewController(for flowStep: FlowStep, with data: Any?) -> UIViewController
}

public extension SplitViewFlowStepCoordinator {
    var splitViewController: UISplitViewController {
        guard let split = flowViewController as? UISplitViewController else {
            preconditionFailure("SplitViewFlowStepCoordinator requires `flowViewController` be a UISplitViewController.")
        }
        
        return split
    }
    
    var masterNavigationController: UINavigationController? {
        return splitViewController.viewControllers.first as? UINavigationController
    }
    
    var masterViewController: UIViewController? {
        guard let nav = masterNavigationController else {
            return splitViewController.viewControllers.first
        }
        
        return nav.viewControllers.first
    }
    
    var detailNavigationController: UINavigationController? {
        return splitViewController.viewControllers.last as? UINavigationController
    }
    
    var detailViewController: UIViewController? {
        guard let nav = detailNavigationController else {
            return splitViewController.viewControllers.last
        }
        
        return nav.viewControllers.first
    }
    
    func viewController(for flowStep: FlowStep, with data: Any?) -> UIViewController {
        return detailViewController(for: flowStep, with: data)
    }
    
    func begin(with data: Any?) {
        beginFlowStep(currentFlowStep, with: data)
    }
    
    func beginFlowStep(_ flowStep: FlowStep, animated: Bool = true, with data: Any? = nil) {
        let viewController = detailViewController(for: flowStep, with: data)
        detailNavigationController?.viewControllers = [viewController]
        
        self.currentFlowStep = flowStep
    }
    
    func endFlowStep(_ flowStep: FlowStep, animated: Bool) {
        
    }
}

@available(*, deprecated, renamed: "SplitViewFlowStepCoordinator")
public typealias SplitViewSubtaskCoordinator = SplitViewFlowStepCoordinator
#endif
