import SwiftUI

enum ColorTheme: String, CaseIterable, Codable, Sendable {
    case light

    static let `default`: ColorTheme = .light

    init(rawOrDefault _: String?) {
        self = .light
    }

    var displayName: String { "Light" }

    var primary: Color { Color(red: 0.851, green: 0.290, blue: 0.416) }

    var background: Color { Color(red: 0.976, green: 0.984, blue: 1.000) }

    var accent: Color { Color(red: 0.780, green: 0.722, blue: 0.918) }

    // MARK: - Text colors

    private static let lightTextPrimary = Color(red: 0.067, green: 0.067, blue: 0.067) // #111111

    var textPrimary: Color { Self.lightTextPrimary }

    var textSecondary: Color { Self.lightTextPrimary.opacity(0.65) }

    var textTertiary: Color { Self.lightTextPrimary.opacity(0.45) }

    /// Maps the theme to a SwiftUI `ColorScheme` used by the new `Theme` system.
    var colorScheme: ColorScheme { .light }
}
