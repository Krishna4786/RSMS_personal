import SwiftUI

// MARK: - Pop to Root Notification
extension Notification.Name {
    static let popToRootHome = Notification.Name("popToRootHome")
}

// MARK: - Pop to Root Environment Key
struct PopToRootKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var popToRoot: () -> Void {
        get { self[PopToRootKey.self] }
        set { self[PopToRootKey.self] = newValue }
    }
}
