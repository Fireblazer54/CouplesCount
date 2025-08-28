import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: Self { self }

    var colorScheme: ColorScheme {
        switch self {
        case .light: return .light
        case .dark: return .dark
        }
    }
}
