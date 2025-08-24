import SwiftUI

struct AdBannerPlaceholderView: View {
    var body: some View {
        Rectangle()
            .fill(ColorTheme.default.textPrimary.opacity(0.2))
            .frame(height: 50)
            .overlay(
                Text("Ad Banner")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            )
    }
}
