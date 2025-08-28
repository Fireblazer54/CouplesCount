import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    private var backgroundGradient: LinearGradient {
        let light = [
            Color(red: 1.0, green: 0.95, blue: 0.92),
            Color(red: 1.0, green: 0.90, blue: 0.85)
        ]
        return LinearGradient(
            colors: light,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.orange.opacity(0.6), .clear],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 120, height: 120)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .accessibilityHidden(true)
                    }

                    Text("Unlock the Deluxe Experience")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Text("Transform your countdowns into magical shared moments")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    VStack(spacing: 16) {
                        BenefitRow(icon: "infinity", title: "Unlimited Countdowns", subtitle: "Create as many special moments as you want")
                        BenefitRow(icon: "heart.text.square", title: "Shared Reactions", subtitle: "Send hearts, pokes, and notes to loved ones")
                        BenefitRow(icon: "paintbrush", title: "Premium Themes", subtitle: "Exclusive beautiful themes and customizations")
                        BenefitRow(icon: "person.2.fill", title: "More Personalization", subtitle: "Advanced sharing and collaboration features")
                    }
                    .padding(.horizontal)

                    Button("Upgrade Now") {
                        // upgrade action
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal)

                    Button("Maybe Later") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.horizontal)

                    Text("No commitments, cancel anytime.")
                        .font(.footnote)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 8)
                        .padding(.bottom)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
                .padding(.bottom)
            }

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .padding()
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Close")
        }
    }
}

private struct BenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            .thinMaterial,
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

#Preview {
    PaywallView()
}
