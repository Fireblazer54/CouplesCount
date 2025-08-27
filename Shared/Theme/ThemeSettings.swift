import SwiftUI

/// Represents the app-wide appearance mode.
enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    /// Optional ColorScheme corresponding to the theme.
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

/// Stores and publishes the current `AppTheme` selection.
@MainActor
final class ThemeSettings: ObservableObject {
    @AppStorage("app_theme_selection") private var stored = AppTheme.system.rawValue
    @Published var selection: AppTheme = .system

    init() {
        selection = AppTheme(rawValue: stored) ?? .system
    }

    func set(_ newValue: AppTheme) {
        selection = newValue
        stored = newValue.rawValue
    }
}

