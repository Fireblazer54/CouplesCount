import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var theme: ThemeManager

    private let themes: [ColorTheme] = [.light, .dark, .royalBlues, .barbie, .lucky]
    private let supportEmail = "support@couplescount.app"
    @State private var activeAlert: ActiveAlert?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // APPEARANCE
                    SectionHeader(text: "Appearance")
                    SettingsCard {
                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 12),
                                      GridItem(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(themes, id: \.self) { t in
                                ThemeSwatch(theme: t, isSelected: t == theme.theme) {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    theme.setTheme(t)   // instant global update
                                }
                                .environmentObject(theme)
                            }
                        }
                    }

                    // NOTIFICATIONS
                    SettingsCard {
                        buttonRow(icon: "bell.badge.fill", title: "Reminders") {
                            activeAlert = .reminders
                        }
                    }

                    // ARCHIVE
                    SettingsCard {
                        buttonRow(icon: "archivebox.fill", title: "Manage Archive") {
                            activeAlert = .archive
                        }
                    }

                    // SUPPORT
                    SectionHeader(text: "Support")
                    SettingsCard {
                        buttonRow(icon: "envelope.fill", title: "Contact Support") {
                            if let url = URL(string: "mailto:\(supportEmail)") {
                                openURL(url)
                            }
                        }
                        Divider().opacity(0.1)
                        buttonRow(icon: "star.fill", title: "Rate CouplesCount") {
                            if let scene = UIApplication.shared.connectedScenes
                                .first as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        }
                    }

                    // ABOUT
                    SectionHeader(text: "About")
                    SettingsCard {
                        keyValueRow(
                            key: "Version",
                            value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                        )
                        Divider().opacity(0.08)
                        keyValueRow(
                            key: "Build",
                            value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                        )
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(theme.theme.background.ignoresSafeArea())
            .tint(theme.theme.accent)            // accent flows everywhere
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .reminders:
                return Alert(
                    title: Text("Coming Soon"),
                    message: Text("Configure reminders coming soon."),
                    dismissButton: .default(Text("OK"))
                )
            case .archive:
                return Alert(
                    title: Text("Coming Soon"),
                    message: Text("Archived countdowns coming soon."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Row helpers

    @ViewBuilder
    private func buttonRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.theme.accent)
                    )
                Text(title).font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(theme.theme.accent)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func keyValueRow(key: String, value: String) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
        .font(.body)
    }
}

private enum ActiveAlert: Identifiable {
    case reminders, archive

    var id: Int { hashValue }
}
