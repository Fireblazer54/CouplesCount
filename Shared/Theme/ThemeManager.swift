import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    @Published var theme: ColorTheme = .light

    init() {}

    // Theme changes are ignored; the app stays in light mode.
    func setTheme(_ newTheme: ColorTheme) {
        theme = .light
    }
}
