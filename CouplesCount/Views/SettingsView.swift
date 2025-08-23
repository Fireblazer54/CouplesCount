import SwiftUI
import StoreKit
import UIKit
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var theme: ThemeManager

    private let themes: [ColorTheme] = [.light, .dark, .royalBlues, .barbie, .lucky]
    private let supportEmail = "support@couplescount.app"
    private let privacyURL = URL(string: "https://example.com/privacy")!
    private let termsURL = URL(string: "https://example.com/terms")!

    @State private var activeAlert: ActiveAlert?

    var body: some View {
        NavigationStack {
            List {
                Section("Support") {
                    Button {
                        rateApp()
                    } label: {
                        Label("Rate CouplesCount", systemImage: "star.fill")
                    }
                    .accessibilityHint("Opens App Store review prompt")

                    Button {
                        contactSupport()
                    } label: {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }
                    .accessibilityHint("Opens Mail with pre-filled app and iOS version")
                }

                Section("Appearance") {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(themes, id: \.self) { t in
                            ThemeSwatch(theme: t, isSelected: t == theme.theme) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                theme.setTheme(t)
                            }
                            .environmentObject(theme)
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowInsets(EdgeInsets())
                }

                Section("Notifications") {
                    Button {
                        activeAlert = .reminders
                    } label: {
                        Label("Reminders", systemImage: "bell.badge.fill")
                    }
                }

                Section("Archive") {
                    NavigationLink {
                        ArchiveView()
                            .environmentObject(theme)
                    } label: {
                        Label("Manage Archive", systemImage: "archivebox.fill")
                    }
                }

                Section("Legal") {
                    Link(destination: privacyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }

                    NavigationLink {
                        AboutLegalView(privacyURL: privacyURL, termsURL: termsURL)
                            .environmentObject(theme)
                    } label: {
                        Label("About & Legal", systemImage: "info.circle.fill")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(theme.theme.background.ignoresSafeArea())
            .tint(theme.theme.accent)
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
    }

    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    private func contactSupport() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        let iosVersion = UIDevice.current.systemVersion
        let subject = "CouplesCount Support"
        let body = "App Version: \(appVersion) (\(build))\niOS Version: \(iosVersion)"

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(supportEmail)?subject=\(encodedSubject)&body=\(encodedBody)"

        if let url = URL(string: urlString) {
            openURL(url)
        }
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
