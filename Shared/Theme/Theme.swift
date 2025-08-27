import SwiftUI

/// Semantic color tokens backed by Colors.xcassets
public enum ThemeColor: String, CaseIterable {
    case Background, Foreground, Card, CardForeground, Popover, PopoverForeground
    case Primary, PrimaryForeground, Secondary, SecondaryForeground
    case Muted, MutedForeground, Accent, AccentForeground
    case Destructive, DestructiveForeground, Border
    case InputBackground, SwitchBackground, Ring
    case Chart1, Chart2, Chart3, Chart4, Chart5
}

/// Typography tokens using the system font and supporting Dynamic Type
public struct Typography {
    public enum Style {
        case largeTitle, title, headline, body, caption
    }

    public func font(_ style: Style) -> Font {
        switch style {
        case .largeTitle: return .system(.largeTitle, design: .default)
        case .title: return .system(.title, design: .default)
        case .headline: return .system(.headline, design: .default)
        case .body: return .system(.body, design: .default)
        case .caption: return .system(.caption, design: .default)
        }
    }
}

/// Corner radii derived from a 10pt base radius (0.625rem)
public struct Corners {
    private let base: CGFloat = 10
    public var sm: CGFloat { base / 2 }
    public var md: CGFloat { base }
    public var lg: CGFloat { base * 1.5 }
    public var xl: CGFloat { base * 2 }
}

/// Theme container providing access to colors, typography and radii
public struct Theme {
    public let colorScheme: ColorScheme
    public let typography = Typography()
    public let corners = Corners()

    public func color(_ token: ThemeColor) -> Color {
        Color(token.rawValue, bundle: .main)
    }

    public static func current(_ scheme: ColorScheme) -> Theme {
        Theme(colorScheme: scheme)
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme(colorScheme: .light)
}

public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

private struct ThemeProvider: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        content.environment(\.theme, Theme.current(scheme))
    }
}

public extension View {
    /// Injects a Theme derived from the current colorScheme
    func applyTheme() -> some View {
        modifier(ThemeProvider())
    }
}
