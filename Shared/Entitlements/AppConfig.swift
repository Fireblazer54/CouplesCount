import Foundation

enum AppEntitlementsMode {
    case freeForAll
    case live
}

enum AppConfig {
    /// Flip this one line later to enable live gating
    static var entitlementsMode: AppEntitlementsMode = .freeForAll

    /// Main-actor isolated so we can safely read main-actor state
    /// like `Entitlements.current.isPro` from here.
    @MainActor
    static var isStrictLight: Bool {
        entitlementsMode == .live && !Entitlements.current.isPro
    }
}

enum AppLimits {
    static let freeMaxCountdowns = 3
}
