import SwiftUI
import StoreKit
import UIKit
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var pro: ProStatusProvider

    private let themes: [ColorTheme] = [.light, .dark, .royalBlues, .barbie, .lucky]
    private let supportEmail = "support@couplescount.app"
    @State private var activeAlert: ActiveAlert?
    @State private var showEnjoyPrompt = false
    @State private var showFeedbackForm = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
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
                                .environmentObject(theme)
                            }
                        }
                    }

                    if AppConfig.entitlementsMode == .live && !Entitlements.current.isUnlimited {
                        SettingsCard {
                            buttonRow(icon: "crown.fill", title: "Go Pro") { showPaywall = true }
#if DEBUG
                            Divider().opacity(0.1)
                            Toggle("Simulate Pro", isOn: $pro.debugIsPro)
#endif
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
                        NavigationLink {
                            ArchiveView()
                                .environmentObject(theme)
                        } label: {
                              HStack(spacing: 12) {
                                  Image(systemName: "archivebox.fill")
                                      .font(.title3)
                                      .foregroundStyle(theme.theme.background)
                                      .frame(width: 30, height: 30)
                                      .background(
                                          RoundedRectangle(cornerRadius: 8)
                                              .fill(theme.theme.accent)
                                      )
                                  Text("Manage Archive")
                                      .font(.body)
                                  Spacer()
                              }
                            .contentShape(Rectangle())
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
                            showEnjoyPrompt = true
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
            }
        }
        .confirmationDialog(
            "Are you enjoying the app so far?",
            isPresented: $showEnjoyPrompt,
            titleVisibility: .visible
        ) {
            Button("Yes") {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
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
                    .foregroundStyle(theme.theme.background)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(theme.theme.accent)
                    )
                Text(title).font(.body)
                Spacer()
            }
            .contentShape(Rectangle())
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

struct ArchiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager
    @Query(filter: #Predicate<Countdown> { $0.isArchived },
           sort: \Countdown.targetUTC, order: .forward)
    private var items: [Countdown]

    var body: some View {
        NavigationStack {
            ZStack {
                theme.theme.background.ignoresSafeArea()

                if items.isEmpty {
                    VStack(spacing: 8) {
                        Text("No archived countdowns")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(items) { item in
                            let dateText = DateUtils.readableDate.string(from: item.targetDate)

                                CountdownCardView(
                                    title: item.title,
                                    targetDate: item.targetDate,
                                    timeZoneID: item.timeZoneID,
                                    dateText: dateText,
                                    archived: item.isArchived,
                                    backgroundStyle: item.backgroundStyle,
                                    colorHex: item.backgroundColorHex,
                                    imageData: item.backgroundImageData,
                                    fontStyle: item.cardFontStyle,
                                    shared: item.isShared,
                                    shareAction: nil
                                )
                            .environmentObject(theme)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        modelContext.delete(item)
                                        try? modelContext.save()
                                        let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                        updateWidgetSnapshot(afterSaving: all)
                                    }
                                    Haptics.warning()
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 16, weight: .bold))
                                        .padding(12)
                                        .background(Circle().fill(Color.red))
                                        .foregroundStyle(.white)
                                }
                                .tint(.clear)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                        item.isArchived = false
                                        try? modelContext.save()
                                        let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                        updateWidgetSnapshot(afterSaving: all)
                                    }
                                } label: {
                                    Image(systemName: "arrow.uturn.backward")
                                        .font(.system(size: 16, weight: .bold))
                                        .padding(12)
                                        .background(Circle().fill(Color.blue))
                                        .foregroundStyle(.white)
                                }
                                .tint(.clear)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .padding(.top, 12)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: items)
                }
            }
            .navigationTitle("Archive")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
        }
        .tint(theme.theme.accent)
    }
}

private enum ActiveAlert: Identifiable {
    case reminders

    var id: Int { hashValue }
}
