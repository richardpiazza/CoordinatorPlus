import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// # Subtask
///
/// A `Subtask` is used by a `SubtaskCoordinator` to differentiate between
/// unique workflows(views) of a `Task`.
///
public protocol Subtask: Task {
    #if canImport(UIKit)
    /// Used for determining the `UIViewController` subclass that will
    /// handle a specific `Subtask`. Helpful in determining if an existing
    /// `UIViewController` existing in the navigation stack.
    var viewControllerType: UIViewController.Type { get }
    #endif
}
