import SwiftUI

/// Semantic color tokens for the app. The app only supports a single light
/// theme, but the structure remains to keep the `ThemeManager` API stable.
enum ColorTheme: String, CaseIterable, Codable, Sendable {
    case light

    static let `default`: ColorTheme = .light

    init(rawOrDefault raw: String?) { self = .light }

    var displayName: String { "Light" }

    /// Primary brand color (Rose)
    var primary: Color { Color(hex: "#D94A6A") ?? .pink }

    /// Soft accent color (Lavender)
    var accent: Color { Color(hex: "#C7B8EA") ?? .purple }

    /// Solid fallback background color
    var background: Color { Color(hex: "#F9FBFF") ?? .white }

    /// Gradient background from baby blue to white
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#E7F3FF") ?? .blue.opacity(0.1), .white],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    /// Base neutral used for text and outlines (#222222)
    private var neutralBase: Color { Color(hex: "#222222") ?? .black }

    var textPrimary: Color { neutralBase }
    var textSecondary: Color { neutralBase.opacity(0.7) }
    var textTertiary: Color { neutralBase.opacity(0.4) }
    var outline: Color { neutralBase.opacity(0.15) }
    var divider: Color { neutralBase.opacity(0.1) }
}
