import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager
    @Query(filter: #Predicate<Countdown> { $0.isArchived })
    private var archivedItems: [Countdown]

    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    appearanceSection

                    if AppConfig.entitlementsMode == .live && !Entitlements.current.isUnlimited {
                        premiumSection
                    }

                    archiveSection

                    footer
                }
                .padding(.vertical, 20)
            }
            .background(theme.theme.background.ignoresSafeArea())
            .tint(theme.theme.textPrimary)
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
            .toolbarColorScheme(theme.theme == .light ? .light : .dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
                .environmentObject(theme)
        }
    }
}

private extension SettingsView {
    var appearanceSection: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "paintpalette.fill")
                        .font(.title3)
                        .foregroundStyle(theme.theme.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.theme.textPrimary.opacity(0.1))
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Appearance")
                            .font(.body)
                            .foregroundStyle(theme.theme.textPrimary)
                        Text("Choose your preferred theme")
                            .font(.footnote)
                            .foregroundStyle(theme.theme.textSecondary)
                    }

                    Spacer()
                }

                Picker(
                    "Appearance",
                    selection: Binding(
                        get: { theme.theme },
                        set: { theme.setTheme($0) }
                    )
                ) {
                    Text("Light").tag(ColorTheme.light)
                    Text("Dark").tag(ColorTheme.dark)
                }
                .pickerStyle(.segmented)
            }
        }
    }

    var premiumSection: some View {
        SettingsCard {
            Button(action: { showPaywall = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(theme.theme.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.theme.textPrimary.opacity(0.1))
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Premium")
                            .font(.body)
                            .foregroundStyle(theme.theme.textPrimary)
                        Text("Unlock unlimited countdowns and features")
                            .font(.footnote)
                            .foregroundStyle(theme.theme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(theme.theme.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    var archiveSection: some View {
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

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Archive")
                            .font(.body)
                            .foregroundStyle(theme.theme.textPrimary)
                        Text("\(archivedItems.count) completed countdowns")
                            .font(.footnote)
                            .foregroundStyle(theme.theme.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(theme.theme.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    var footer: some View {
        VStack(spacing: 4) {
            Text("Countdowns")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(theme.theme.textSecondary)
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                .font(.footnote)
                .foregroundStyle(theme.theme.textSecondary)
            Text("Made with ❤️ for shared moments")
                .font(.footnote)
                .foregroundStyle(theme.theme.textSecondary)
        }
        .padding(.top, 12)
    }
}

