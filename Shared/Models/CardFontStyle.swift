import SwiftUI

enum CardFontStyle: String, CaseIterable, Identifiable, Codable {
    case classic, cursive, minimalist, artsy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .cursive: return "Cursive"
        case .minimalist: return "Minimalist"
        case .artsy: return "Artsy"
        }
    }

    /// Underlying font names for custom styles. `nil` uses the system font.
    var fontName: String? {
        switch self {
        case .classic: return nil // System font (SF Pro)
        case .cursive: return "Snell Roundhand"
        case .minimalist: return nil
        case .artsy: return nil
        }
    }
}

