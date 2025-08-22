import SwiftUI
import WidgetKit

@MainActor
final class ThemeManager: ObservableObject {
    // App Group identifier used for shared user defaults
    private let appGroupSuite: String? = "group.com.fireblazer.CouplesCount"
    private let key = "global_color_theme"

    // Stored defaults, initialized before anything else is used.
    private let defaults: UserDefaults

    @Published var theme: ColorTheme

    init() {
        // 1) Initialize defaults without touching 'self' computed properties.
        if let suite = appGroupSuite, let d = UserDefaults(suiteName: suite) {
            self.defaults = d
        } else {
            self.defaults = .standard
        }

        // 2) Initialize theme from defaults (must set all stored properties before using 'self').
        let raw = defaults.string(forKey: key)
        self.theme = ColorTheme(rawOrDefault: raw)
    }

    // Update theme and notify widgets.
    func setTheme(_ newTheme: ColorTheme) {
        theme = newTheme
        defaults.set(newTheme.rawValue, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
