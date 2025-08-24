import Foundation

struct Entitlements {
    let isUnlimited: Bool
    let hasPremiumThemes: Bool
    let hasDarkMode: Bool
    let hidesAds: Bool

    @MainActor private static var provider: ProStatusProviding = ProStatusProvider()


    init(provider: ProStatusProviding) {
        let pro = provider.isPro
        isUnlimited = pro
        hasPremiumThemes = pro
        hasDarkMode = pro
        hidesAds = pro
    }

    @MainActor static var current: Entitlements { Entitlements(provider: provider) }

    @MainActor static func setProvider(_ newProvider: ProStatusProviding) {

        provider = newProvider
    }
}
