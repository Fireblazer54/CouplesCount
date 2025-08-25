import SwiftUI
import WidgetKit

@MainActor
final class ThemeManager: ObservableObject {
    private let key = "global_color_theme"
    private let defaults = AppGroup.defaults

    @Published var theme: ColorTheme

    init() {
        let raw = defaults.string(forKey: key)
        self.theme = ColorTheme(rawOrDefault: raw)
        if raw == "lucky" {
            defaults.set(ColorTheme.light.rawValue, forKey: key)
        }
    }

    // Update theme and notify widgets.
    func setTheme(_ newTheme: ColorTheme) {
        theme = newTheme
        defaults.set(newTheme.rawValue, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
