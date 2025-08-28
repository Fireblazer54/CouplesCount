import SwiftUI

struct OnboardingView: View {
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
        .background(Color("Background").ignoresSafeArea())
        .tint(Color("Primary"))
    }

    @ViewBuilder
    private func slide(image: String, text: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color("Foreground"))
                .accessibilityHidden(true)
            Text(text)
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("Foreground"))
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
                .foregroundStyle(Color("Primary"))
                .accessibilityHidden(true)
            Text("Share with your partner.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("Foreground"))
                .padding(.top, 24)
                .padding(.horizontal)
            Button(action: finishOnboarding) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(Color("Background"))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color("Primary")))
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
}
