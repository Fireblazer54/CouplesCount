#if DEBUG
import SwiftUI

/// Simple developer screen to inspect theme colors
struct ThemePreviewView: View {
    @State private var scheme: ColorScheme = .light

    private var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        let theme = Theme(colorScheme: scheme)
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(ThemeColor.allCases, id: \.self) { token in
                        SwatchView(token: token)
                            .frame(height: 44)
                            .background(theme.color(token))
                            .cornerRadius(theme.corners.sm)
                    }
                }
                .padding()
            }
            .navigationTitle("Theme Preview")
            .toolbar {
                Toggle("Dark", isOn: Binding(
                    get: { scheme == .dark },
                    set: { scheme = $0 ? .dark : .light }
                ))
            }
        }
        .environment(\.theme, theme)
    }
}

private struct SwatchView: View {
    @Environment(\.theme) private var theme
    let token: ThemeColor

    var body: some View {
        ZStack {
            theme.color(token)
            Text(token.rawValue)
                .font(theme.typography.font(.caption))
                .foregroundStyle(theme.color(.Foreground))
        }
        .clipShape(RoundedRectangle(cornerRadius: theme.corners.sm))
    }
}

#Preview("Light") {
    ThemePreviewView()
        .environment(\.theme, Theme(colorScheme: .light))
}

#Preview("Dark") {
    ThemePreviewView()
        .environment(\.theme, Theme(colorScheme: .dark))
}

#Preview("XL") {
    ThemePreviewView()
        .environment(\.theme, Theme(colorScheme: .light))
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}
#endif
