import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// # FlowStep
///
/// A `FlowStep` is used by a `FlowStepCoordinator` to differentiate between unique views of a `Flow`.
public protocol FlowStep: Flow {
    #if canImport(UIKit)
    /// Used for determining the `UIViewController` subclass that will handle a specific `FlowStep`.
    ///
    /// Helpful in determining if an existing `UIViewController` existing in the navigation stack.
    var viewControllerType: UIViewController.Type { get }
    #endif
}
