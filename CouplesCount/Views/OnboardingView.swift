import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var theme: ThemeManager
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
        .background(theme.theme.background.ignoresSafeArea())
        .tint(theme.theme.primary)
    }

    @ViewBuilder
    private func slide(image: String, text: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(theme.theme.primary)
                .accessibilityHidden(true)
            Text(text)
                .font(.title2)
                .multilineTextAlignment(.center)
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
                .foregroundStyle(theme.theme.primary)
                .accessibilityHidden(true)
            Text("Share with your partner.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal)
            Button(action: finishOnboarding) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(theme.theme.primary))
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

#Preview {
    OnboardingView(onDenied: {})
        .environmentObject(ThemeManager())
}
