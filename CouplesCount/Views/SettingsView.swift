import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var theme: ThemeManager

    private let themes: [ColorTheme] = [.light, .dark, .royalBlues, .barbie, .lucky]
    private let supportEmail = "support@couplescount.app"

    var body: some View {
        NavigationStack {
            ScrollView {
                // Precompute any formatted values to keep SwiftUI type-checking fast
                let previewDateText = Date.now.formatted(date: .abbreviated, time: .shortened)

                VStack(spacing: 18) {
                    // APPEARANCE
                    SectionHeader(text: "Appearance")
                    SettingsCard {
                        // Live preview responds instantly to theme
                        MiniCountdownPreview(
                            title: "Dinner Date",
                            days: 12,
                            dateText: previewDateText
                        )
                        .tint(theme.theme.accent)

                        // Swatches grid
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
                    SectionHeader(text: "Notifications")
                    SettingsCard {
                        NavigationLink {
                            Text("Configure reminders (coming soon)")
                                .navigationTitle("Reminders")
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "bell.badge.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(.tint))
                                Text("Reminders")
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    // ARCHIVE
                    SectionHeader(text: "Archive")
                    SettingsCard {
                        NavigationLink {
                            Text("Archived countdowns (coming soon)")
                                .navigationTitle("Archive")
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "archivebox.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(.tint))
                                Text("Manage Archive")
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                        .buttonStyle(.plain)
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
                    .background(RoundedRectangle(cornerRadius: 8).fill(.tint))
                Text(title).font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondary)
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
