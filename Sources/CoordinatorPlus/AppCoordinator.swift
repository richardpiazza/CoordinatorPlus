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
///     except through its delegate (usually a `FlowCoordinator`).
///
/// *   No view controller should have knowledge of any other view controller save those
///     which it directly parents (embed segue or custom containment).
///
/// *   View Controllers should never access the Service layer directly;
///     always mediate access through a delegate and dataSource.
///
/// *   A view controller may be used by any number of FlowCoordinator objects,
///     so long as they are able to fulfill its data and delegation needs.
///
public protocol AppCoordinator: AnyObject {
    
    #if canImport(UIKit)
    /// Required initializer
    ///
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
    /// - parameters:
    ///   - window: The UIWindow provided form the UIApplicationDelegate
    init(window: UIWindow)
    
    /// A reference to the UIWindow provided from the app delegate
    var window: UIWindow { get }
    #endif
    
    /// The current *non-modal* coordinator handling user interaction
    var currentCoordinator: FlowCoordinator? { get set }
    
    /// The current *modal* coordinator handling user interaction
    var modalCoordinator: FlowCoordinator? { get set }
    
    /// Responsible for creating and vending `FlowCoordinator` for the given task.
    ///
    /// - parameters:
    ///   - flow: The `Flow` for which a coordinator should be vended.
    ///   - data: Any data to pass to the coordinator.
    func coordinator(for flow: Flow, with data: Any?) -> FlowCoordinator
    
    /// Returns a `Flow` that should begin after the specified `Flow` finishes.
    ///
    /// - parameters:
    ///   - flow: The flow being finished
    /// - returns: A new `Flow` to begin, or nil.
    func nextFlow(after flow: Flow) -> Flow?
    
    /// Begin or Restart a flow
    ///
    /// Logic/Handling:
    /// - initializing a coordinator for the task
    /// - call coordinators `begin(with:)` method
    /// - call dismiss()/present() as needed
    /// - set currentCoordinator/modalCoordinator
    ///
    /// - parameters:
    ///   - flow: The `Flow` to begin/restart
    ///   - animated: Indicates wether animation is performed in transition
    ///   - data: Any data to pass to the taskCoordinator being started.
    func beginFlow(_ flow: Flow, animated: Bool, with data: Any?)
    
    /// End a task
    ///
    /// Logic/Handling:
    /// - identify the task coordinator for the task
    /// - call coordinators `prepareForRemoval()`
    /// - call `dismiss(taskCoordinator:)`
    /// - nil currentCoordinator/modalCoordinator
    ///
    /// - parameters:
    ///   - flow: The `Flow` to end
    func endFlow(_ flow: Flow)
    
    /// Handles the dismissal/removal of the `FlowCoordinator`s taskViewController.
    ///
    /// - parameters:
    ///   - flowCoordinator: The `FlowCoordinator` to dismiss
    ///   - animated: Indicates wether animation is performed in dismissal
    ///   - completion: Handler called upon completion of dismissal
    func dismiss(flowCoordinator: FlowCoordinator, animated: Bool, completion: (() -> Void)?)
    
    /// Handles the presentation/adding of the `FlowCoordinator`s taskViewController.
    ///
    /// - parameters:
    ///   - flowCoordinator: The `FlowCoordinator` to present
    ///   - animated: Indicates wether animation is performed in adding
    ///   - completion: Handler called upon completion of adding
    func present(flowCoordinator: FlowCoordinator, animated: Bool, completion:(() -> Void)?)
}

public extension AppCoordinator {
    func nextFlow(after flow: Flow) -> Flow? {
        return nil
    }
    
    func beginFlow(_ flow: Flow, animated: Bool = true, with data: Any? = nil) {
        if let currentCoordinator = self.currentCoordinator, currentCoordinator.flow.isEqual(flow) {
            DispatchQueue.main.async {
                currentCoordinator.resume()
            }
            return
        } else if let modalCoordinator = self.modalCoordinator, modalCoordinator.flow.isEqual(flow) {
            DispatchQueue.main.async {
                modalCoordinator.resume()
            }
            return
        }
        
        let nextCoordinator = coordinator(for: flow, with: data)
        
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
            dismiss(flowCoordinator: modalCoordinator, animated: animated) { [unowned self] in
                nextCoordinator.begin(with: data)
                self.present(flowCoordinator: nextCoordinator, animated: animated, completion: nil)
            }
        } else if let currentCoordinator = self.currentCoordinator, !nextCoordinator.isModal {
            DispatchQueue.main.async {
                currentCoordinator.end()
            }
            dismiss(flowCoordinator: currentCoordinator, animated: animated) { [unowned self] in
                nextCoordinator.begin(with: data)
                self.present(flowCoordinator: nextCoordinator, animated: animated, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                self.currentCoordinator?.pause()
                nextCoordinator.begin(with: data)
            }
            present(flowCoordinator: nextCoordinator, animated: animated, completion: nil)
        }
    }
    
    func endFlow(_ flow: Flow) {
        if let coordinator = self.currentCoordinator, coordinator.flow.isEqual(flow) {
            DispatchQueue.main.async {
                coordinator.end()
            }
            dismiss(flowCoordinator: coordinator, animated: true, completion: nil)
            self.currentCoordinator = nil
        } else if let coordinator = self.modalCoordinator, coordinator.flow.isEqual(flow) {
            DispatchQueue.main.async {
                coordinator.end()
            }
            dismiss(flowCoordinator: coordinator, animated: true, completion: nil)
            self.modalCoordinator = nil
            DispatchQueue.main.async {
                self.currentCoordinator?.resume()
            }
        }
    }
}

#if canImport(UIKit)
public extension AppCoordinator {
    var flowViewController: UIViewController {
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
    
    func dismiss(flowCoordinator: FlowCoordinator, animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if flowCoordinator.isModal {
                self.flowViewController.dismiss(animated: animated, completion: completion)
            } else {
                flowCoordinator.flowViewController.willMove(toParent: nil)
                flowCoordinator.flowViewController.view.removeFromSuperview()
                flowCoordinator.flowViewController.removeFromParent()
                completion?()
            }
        }
    }
    
    func present(flowCoordinator: FlowCoordinator, animated: Bool = true, completion:(() -> Void)? = nil) {
        if flowCoordinator.isModal {
            let controller = currentCoordinator?.flowViewController ?? flowViewController
            DispatchQueue.main.async {
                controller.present(flowCoordinator.flowViewController, animated: animated, completion: completion)
            }
            return
        }
        
        if animated {
            DispatchQueue.main.async {
                flowCoordinator.flowViewController.view.frame = self.flowViewController.view.frame
                flowCoordinator.flowViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                flowCoordinator.flowViewController.view.alpha = 0.0
                
                self.flowViewController.view.addSubview(flowCoordinator.flowViewController.view)
                self.flowViewController.addChild(flowCoordinator.flowViewController)
                
                if #available(iOS 10.0, tvOS 10.0, macCatalyst 13.0, *) {
                    let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear, animations: {
                        flowCoordinator.flowViewController.view.alpha = 1.0
                    })
                    animator.addCompletion { (_) in
                        flowCoordinator.flowViewController.didMove(toParent: self.flowViewController)
                        DispatchQueue.main.async {
                            completion?()
                        }
                    }
                    animator.startAnimation()
                } else {
                    UIView.animate(withDuration: 1.0, animations: {
                        flowCoordinator.flowViewController.view.alpha = 1.0
                    }) { (_) in
                        flowCoordinator.flowViewController.didMove(toParent: self.flowViewController)
                        DispatchQueue.main.async {
                            completion?()
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.flowViewController.addChild(flowCoordinator.flowViewController)
                self.flowViewController.view.addSubview(flowCoordinator.flowViewController.view)
                flowCoordinator.flowViewController.view.frame = self.flowViewController.view.frame
                flowCoordinator.flowViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                flowCoordinator.flowViewController.didMove(toParent: self.flowViewController)
                completion?()
            }
        }
    }
}
#endif
