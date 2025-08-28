import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.theme) private var theme
    @Query(filter: #Predicate<Countdown> { $0.isArchived })
    private var archivedItems: [Countdown]

    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if AppConfig.entitlementsMode == .live && !Entitlements.current.isUnlimited {
                        premiumSection
                    }

                    archiveSection

                    footer
                }
                .padding(.vertical, 20)
            }
            .background(theme.color(.Background).ignoresSafeArea())
            .tint(theme.color(.Primary))
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

private extension SettingsView {
    var premiumSection: some View {
        SettingsCard {
            Button(action: { showPaywall = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(theme.color(.Foreground))
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.color(.Foreground).opacity(0.1))
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Premium")
                            .font(.body)
                            .foregroundStyle(theme.color(.Foreground))
                        Text("Unlock unlimited countdowns and features")
                            .font(.footnote)
                            .foregroundStyle(theme.color(.MutedForeground))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(theme.color(.MutedForeground))
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
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "archivebox.fill")
                        .font(.title3)
                        .foregroundStyle(theme.color(.Foreground))
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.color(.Foreground).opacity(0.1))
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Archive")
                            .font(.body)
                            .foregroundStyle(theme.color(.Foreground))
                        Text("\(archivedItems.count) completed countdowns")
                            .font(.footnote)
                            .foregroundStyle(theme.color(.MutedForeground))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(theme.color(.MutedForeground))
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
                .foregroundStyle(theme.color(.MutedForeground))
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                .font(.footnote)
                .foregroundStyle(theme.color(.MutedForeground))
            Text("Made with ❤️ for shared moments")
                .font(.footnote)
                .foregroundStyle(theme.color(.MutedForeground))
        }
        .padding(.top, 12)
    }
}

