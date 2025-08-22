import SwiftUI

enum TitleFont: String, CaseIterable, Identifiable, Codable {
    case `default`, rounded, serif, monospaced
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .default: return "Default"
        case .rounded: return "Rounded"
        case .serif: return "Serif"
        case .monospaced: return "Monospaced"
        }
    }
    var design: Font.Design {
        switch self {
        case .default: return .default
        case .rounded: return .rounded
        case .serif: return .serif
        case .monospaced: return .monospaced
        }
    }
}
