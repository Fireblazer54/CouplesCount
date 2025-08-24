import SwiftUI

/// Semantic color tokens for the app. Light theme is the default, but legacy
/// themes remain available behind paywall.

enum ColorTheme: String, CaseIterable, Codable, Sendable {
    case light

    static let `default`: ColorTheme = .light

    init(rawOrDefault raw: String?) { self = .light }

    var displayName: String { "Light" }

    /// Primary brand color (Rose)
    var primary: Color {
        switch self {
        case .light: Color(hex: "#D94A6A") ?? .pink
        case .dark, .royalBlues, .barbie, .lucky: .white
        }
    }

    /// Secondary accent (Lavender for light theme)
    var accent: Color {
        switch self {
        case .light: Color(hex: "#C7B8EA") ?? .purple
        case .dark: .white
        case .royalBlues: .white
        case .barbie: .white
        case .lucky: .white
        }
    }

    /// Solid fallback background color
    var background: Color {
        switch self {
        case .light: Color(hex: "#F9FBFF") ?? .white
        case .dark: Color(.secondarySystemBackground)
        case .royalBlues: Color(red: 0.08, green: 0.19, blue: 0.45)
        case .barbie: Color(red: 0.98, green: 0.36, blue: 0.72)
        case .lucky: Color(red: 0.10, green: 0.55, blue: 0.28)
        }
    }

    /// Background gradient (light theme uses baby blue to white)
    var backgroundGradient: LinearGradient {
        switch self {
        case .light:
            return LinearGradient(
                colors: [Color(hex: "#E7F3FF") ?? .blue.opacity(0.1), .white],
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(colors: [background, background],
                                  startPoint: .top, endPoint: .bottom)
        }
    }

    /// Base neutral used for text and outlines
    private var neutralBase: Color {
        switch self {
        case .light: return Color(hex: "#222222") ?? .black
        case .dark, .royalBlues, .barbie, .lucky: return .white
        }
    }


    var textPrimary: Color { neutralBase }
    var textSecondary: Color { neutralBase.opacity(0.7) }
    var textTertiary: Color { neutralBase.opacity(0.4) }
    var outline: Color { neutralBase.opacity(0.15) }
    var divider: Color { neutralBase.opacity(0.1) }
}
