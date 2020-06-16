#if canImport(UIKit)
import UIKit

/// Extension of `SubtaskCoordinator` that requires a `UISplitViewController` as its `taskViewController`.
public protocol SplitViewSubtaskCoordinator: SubtaskCoordinator {
    func masterViewControllerType() -> UIViewController.Type
    func masterViewController(with data: Any?) -> UIViewController
    func detailViewController(for subtask: Subtask, with data: Any?) -> UIViewController
}

public extension SplitViewSubtaskCoordinator {
    var splitViewController: UISplitViewController {
        guard let split = taskViewController as? UISplitViewController else {
            preconditionFailure("SplitViewSubtaskCoordinator requires 'taskViewController' be a UISplitViewController.")
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
    
    func viewController(for subtask: Subtask, with data: Any?) -> UIViewController {
        return detailViewController(for: subtask, with: data)
    }
    
    func begin(with data: Any?) {
        beginSubtask(currentSubtask, with: data)
    }
    
    func beginSubtask(_ subtask: Subtask, animated: Bool = true, with data: Any? = nil) {
        let viewController = detailViewController(for: subtask, with: data)
        detailNavigationController?.viewControllers = [viewController]
        
        self.currentSubtask = subtask
    }
    
    func endSubtask(_ subtask: Subtask, animated: Bool) {
        
    }
}
#endif
