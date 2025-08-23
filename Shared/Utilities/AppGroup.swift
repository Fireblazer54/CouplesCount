import Foundation

enum AppGroup {
    static let id = "group.com.fireblazer.CouplesCount"

    static var hasEntitlement: Bool {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id) != nil
    }

    static var containerURL: URL {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id) {
            return url
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var defaults: UserDefaults {
        UserDefaults(suiteName: id) ?? .standard
    }

    private static var logged: Set<String> = []
    static func logonce(_ token: String) {
        guard !logged.contains(token) else { return }
        logged.insert(token)
        let status = hasEntitlement ? "enabled" : "missing"
        print("AppGroup entitlement \(status) at \(containerURL.path)")
    }
}

