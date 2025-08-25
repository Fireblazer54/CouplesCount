import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.largeTitle)
                .foregroundStyle(theme.theme.primary)
                .accessibilityHidden(true)
            Text("CouplesCount Pro")
                .font(.title2.weight(.semibold))
            Text("Upgrade to unlock premium features.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Close") { dismiss() }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
        }
        .padding()
    }
}
