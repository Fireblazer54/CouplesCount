import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Countdown> { $0.isArchived })
    private var archivedItems: [Countdown]

    @AppStorage("appearance") private var appearance: Appearance = .light
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
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .tint(Theme.accent)
            .scrollIndicators(.hidden)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
        }
        .preferredColorScheme(appearance.colorScheme)
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

private extension SettingsView {
    var appearanceSection: some View {
        SettingsCard {
            HStack(spacing: 12) {
                Image(systemName: "paintpalette.fill")
                    .font(.title3)
                    .foregroundStyle(Color("Foreground"))
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Foreground").opacity(0.1))
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Appearance")
                        .font(.body)
                        .foregroundStyle(Color("Foreground"))
                    Text("Choose your preferred theme")
                        .font(.footnote)
                        .foregroundStyle(Color("Secondary"))

                    Picker("Appearance", selection: $appearance) {
                        Text("Light").tag(Appearance.light)
                        Text("Dark").tag(Appearance.dark)
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    var premiumSection: some View {
        SettingsCard {
            Button(action: { showPaywall = true }) {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(Color("Foreground"))
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Foreground").opacity(0.1))
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Premium")
                            .font(.body)
                            .foregroundStyle(Color("Foreground"))
                        Text("Unlock unlimited countdowns and features")
                            .font(.footnote)
                            .foregroundStyle(Color("Secondary"))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color("Secondary"))
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
                        .foregroundStyle(Color("Foreground"))
                        .frame(width: 30, height: 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Foreground").opacity(0.1))
                        )
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Archive")
                            .font(.body)
                            .foregroundStyle(Color("Foreground"))
                        Text("\(archivedItems.count) completed countdowns")
                            .font(.footnote)
                            .foregroundStyle(Color("Secondary"))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color("Secondary"))
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
                .foregroundStyle(Color("Secondary"))
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                .font(.footnote)
                .foregroundStyle(Color("Secondary"))
            Text("Made with ❤️ for shared moments")
                .font(.footnote)
                .foregroundStyle(Color("Secondary"))
        }
        .padding(.top, 12)
    }
}

