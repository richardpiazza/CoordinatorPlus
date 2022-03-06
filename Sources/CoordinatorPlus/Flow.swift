import Foundation

/// The basic unit of functionality of an app.
///
/// Each `Flow` has a corresponding `FlowCoordinator` which manages the views and data needed to carry out the functionality.
///
/// A typical implementation is declared as an enumeration. i.e.
///
/// ```swift
/// enum AppFlow: Int, Flow {
///     case login
///     case dashboard
///     case settings
/// }
/// ```
///
/// - note: When declared as an enum with a `RawValue` conforming to `Equatable`
///         the required func `isEqual(_:)` is automatically synthesized.
///
public protocol Flow {
    func isEqual(_ flow: Flow) -> Bool
}

public extension Flow where Self: RawRepresentable, Self.RawValue: Equatable {
    func isEqual(_ flow: Flow) -> Bool {
        guard let typed = flow as? Self else {
            return false
        }
        
        return self.rawValue == typed.rawValue
    }
}

@available(*, deprecated, renamed: "Flow", message: "Avoid namespace collisions with Swift Concurrency 'Task'.")
public typealias Task = Flow
