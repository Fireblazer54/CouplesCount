import SwiftUI
import WidgetKit

@MainActor
final class ThemeManager: ObservableObject {
    private let key = "global_color_theme"
    private let defaults = AppGroup.defaults
    private let pro: ProStatusProviding

    @Published var theme: ColorTheme
    @Published private(set) var isStrictLight: Bool

    init(pro: ProStatusProviding) {
        self.pro = pro
        let raw = defaults.string(forKey: key)
        self.theme = ColorTheme(rawOrDefault: raw)
        self.isStrictLight = AppConfig.entitlementsMode == .live && !pro.isPro
    }

    func refreshStrictLight() {
        isStrictLight = AppConfig.entitlementsMode == .live && !pro.isPro
    }

    // Update theme and notify widgets.
    func setTheme(_ newTheme: ColorTheme) {
        theme = newTheme
        defaults.set(newTheme.rawValue, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
