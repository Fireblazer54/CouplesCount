import SwiftUI
import StoreKit
import UIKit
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var pro: ProStatusProvider

    private let themes: [ColorTheme] = [.light, .dark, .royalBlues, .barbie]
    private let supportEmail = "support@couplescount.app"
    @State private var activeAlert: ActiveAlert?
    @State private var showEnjoyPrompt = false
    @State private var showFeedbackForm = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if !AppConfig.isStrictLight {
                        SettingsCard {
                            LazyVGrid(
                                columns: [GridItem(.flexible(), spacing: 12),
                                          GridItem(.flexible(), spacing: 12)],
                                spacing: 12
                            ) {
                                ForEach(themes, id: \.self) { t in
                                    let ent = Entitlements.current
                                    let locked = AppConfig.entitlementsMode == .live && ((t == .dark && !ent.hasDarkMode) || (t != .light && t != .dark && !ent.hasPremiumThemes))
                                    ThemeSwatch(theme: t, isSelected: t == theme.theme, isLocked: locked) {
                                        if locked {
                                            showPaywall = true
                                        } else {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            theme.setTheme(t)   // instant global update
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if AppConfig.entitlementsMode == .live && !Entitlements.current.isUnlimited {
                        SettingsCard {
                            SettingsButtonRow(icon: "crown.fill", title: "Go Pro") { showPaywall = true }
#if DEBUG
                            Divider().overlay(theme.theme.textPrimary.opacity(0.1))
                            Toggle("Simulate Pro", isOn: $pro.debugIsPro)
#endif
                        }
                    }

                    // NOTIFICATIONS
                    SettingsCard {
                        SettingsButtonRow(icon: "bell.badge.fill", title: "Reminders") {
                            activeAlert = .reminders
                        }
                    }

                    // ARCHIVE
                    SettingsCard {
                        NavigationLink {
                            ArchiveView()
                                .environmentObject(theme)
                        } label: {
                              HStack(spacing: 12) {
                                  Image(systemName: "archivebox.fill")
                                      .font(.title3)
                                      .foregroundStyle(theme.theme.textPrimary)
                                      .frame(width: 30, height: 30)
                                      .background(
                                          RoundedRectangle(cornerRadius: 8)
                                              .fill(theme.theme.textPrimary.opacity(0.1))
                                      )
                                      .accessibilityHidden(true)
                                  Text("Manage Archive")
                                      .font(.body)
                                      .foregroundStyle(theme.theme.textPrimary)
                                  Spacer()
                              }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }

                    // SUPPORT
                    SectionHeader(text: "Support")
                    SettingsCard {
                        SettingsButtonRow(icon: "envelope.fill", title: "Contact Support") {
                            if let url = URL(string: "mailto:\(supportEmail)") {
                                openURL(url)
                            }
                        }
                        Divider().overlay(theme.theme.textPrimary.opacity(0.1))
                        SettingsButtonRow(icon: "star.fill", title: "Rate CouplesCount") {
                            showEnjoyPrompt = true
                        }
                    }

                    // ABOUT
                    SectionHeader(text: "About")
                    SettingsCard {
                        SettingsKeyValueRow(
                            key: "Version",
                            value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                        )
                        Divider().overlay(theme.theme.textPrimary.opacity(0.08))
                        SettingsKeyValueRow(
                            key: "Build",
                            value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                        )
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(theme.theme.background.ignoresSafeArea())
            .tint(theme.theme.textPrimary)            // default icons
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
            .toolbarColorScheme(theme.theme == .light ? .light : .dark, for: .navigationBar)
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
            }
        }
        .confirmationDialog(
            "Are you enjoying the app so far?",
            isPresented: $showEnjoyPrompt,
            titleVisibility: .visible
        ) {
            Button("Yes") {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    AppStore.requestReview(in: scene)
                }
            }
            Button("No") { showFeedbackForm = true }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showFeedbackForm) {
            FeedbackFormView()
                .environmentObject(theme)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(theme)
        }
    }

}

private enum ActiveAlert: Identifiable {
    case reminders

    var id: Int { hashValue }
}
