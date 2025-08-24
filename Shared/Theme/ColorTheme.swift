import SwiftUI

/// Semantic color tokens for the app.
enum ColorTheme: String, CaseIterable, Codable, Sendable {
    case light

    static let `default`: ColorTheme = .light

    init(rawOrDefault raw: String?) {
        self = ColorTheme(rawValue: raw ?? "") ?? .light
    }

    var displayName: String { "Light" }

    /// Primary brand color (Rose)
    var primary: Color { Color(hex: "#D94A6A") ?? Color.pink }

    /// Secondary accent (Lavender)
    var accent: Color { Color(hex: "#C7B8EA") ?? Color.purple }

    /// Solid fallback background color
    var background: Color { Color(hex: "#F9FBFF") ?? Color.white }

    /// Background gradient (baby blue to white)
    var backgroundGradient: LinearGradient {
        let top = Color(hex: "#E7F3FF") ?? Color.blue.opacity(0.1)
        let bottom = Color.white
        return LinearGradient(colors: [top, bottom], startPoint: .top, endPoint: .bottom)
    }

    /// Base neutral used for text and outlines
    private var neutralBase: Color { Color(hex: "#222222") ?? Color.black }

    var textPrimary: Color { neutralBase }
    var textSecondary: Color { neutralBase.opacity(0.65) }
    var textTertiary: Color { neutralBase.opacity(0.45) }
    var outline: Color { neutralBase.opacity(0.9) }
    var divider: Color { neutralBase.opacity(0.1) }
}
