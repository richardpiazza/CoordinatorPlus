import Foundation

/// The basic unit of functionality of an app.
///
/// Each `Task` has a corresponding `TaskCoordinator` which manages the
/// views and data needed to carry out the `Task`.
///
/// A typical implementation is declared as an enumeration. i.e.
///
/// ```swift
/// enum AppTask: Int, Task {
///     case login
///     case dashboard
///     case settings
/// }
/// ```
///
/// - note: When declared as an enum with a `RawValue` conforming to `Equatable`
///         the required func `isEqual(_:)` is automatically synthesized.
///
public protocol Task {
    func isEqual(_ task: Task) -> Bool
}

public extension Task where Self: RawRepresentable, Self.RawValue: Equatable {
    func isEqual(_ task: Task) -> Bool {
        guard let typed = task as? Self else {
            return false
        }
        
        return self.rawValue == typed.rawValue
    }
}
