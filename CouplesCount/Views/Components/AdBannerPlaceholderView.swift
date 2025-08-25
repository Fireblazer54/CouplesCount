import SwiftUI

struct AdBannerPlaceholderView: View {
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        Rectangle()
            .fill(theme.theme.accent.opacity(0.2))
            .frame(height: 50)
            .overlay(
                Text("Ad Banner")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            )
    }
}
