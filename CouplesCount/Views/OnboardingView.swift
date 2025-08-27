import SwiftUI

struct OnboardingView: View {
    @Environment(\.theme) private var theme
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    /// Called when notification access is denied so the host can present guidance.
    let onDenied: () -> Void

    var body: some View {
        TabView {
            slide(image: "calendar.badge.plus", text: "Create & customize a countdown.")
            slide(image: "bell", text: "Get reminders before your special day.")
            finalSlide
        }
        .tabViewStyle(.page)
        .background(theme.color(.Background).ignoresSafeArea())
        .tint(theme.color(.Primary))
    }

    @ViewBuilder
    private func slide(image: String, text: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(theme.color(.Foreground))
                .accessibilityHidden(true)
            Text(text)
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.color(.Foreground))
                .padding(.top, 24)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }

    private var finalSlide: some View {
        VStack {
            Spacer()
            Image(systemName: "heart.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(theme.color(.Primary))
                .accessibilityHidden(true)
            Text("Share with your partner.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(theme.color(.Foreground))
                .padding(.top, 24)
                .padding(.horizontal)
            Button(action: finishOnboarding) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(theme.color(.PrimaryForeground))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(theme.color(.Primary)))
            }
            .padding(.top, 32)
            .padding(.horizontal)
            Spacer()
        }
        .padding()
    }

    private func finishOnboarding() {
        hasSeenOnboarding = true
        NotificationManager.requestAuthorization { granted in
            if !granted {
                onDenied()
            }
        }
    }
}

#Preview("Light") {
    OnboardingView(onDenied: {})
        .environment(\.theme, Theme(colorScheme: .light))
}

#Preview("Dark") {
    OnboardingView(onDenied: {})
        .environment(\.theme, Theme(colorScheme: .dark))
}
