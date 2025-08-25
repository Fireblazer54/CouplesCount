import SwiftUI

enum ColorTheme: String, CaseIterable, Codable, Sendable {
    case light, dark, royalBlues, barbie, lucky

    static let `default`: ColorTheme = .light

    init(rawOrDefault raw: String?) {
        self = ColorTheme(rawValue: raw ?? "") ?? .light
    }

    var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .royalBlues: "Royal Blues"
        case .barbie: "Barbie"
        case .lucky: "Lucky"
        }
    }

    var primary: Color {
        switch self {
        case .light: Color(red: 0.851, green: 0.290, blue: 0.416)
        case .dark, .royalBlues, .barbie, .lucky: background
        }
    }

    var background: Color {
        switch self {
        case .light: Color(red: 0.976, green: 0.984, blue: 1.000)
        case .dark: Color(.secondarySystemBackground)
        case .royalBlues: Color(red: 0.08, green: 0.19, blue: 0.45)
        case .barbie: Color(red: 0.98, green: 0.36, blue: 0.72)
        case .lucky: Color(red: 0.10, green: 0.55, blue: 0.28)
        }
    }

    var accent: Color {
        switch self {
        case .light: Color(red: 0.780, green: 0.722, blue: 0.918)
        case .dark: .white
        case .royalBlues: .white
        case .barbie: .white
        case .lucky: .white
        }
    }
}
