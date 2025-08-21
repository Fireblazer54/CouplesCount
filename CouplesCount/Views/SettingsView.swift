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
    @State private var activeAlert: ActiveAlert?

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
                        NavigationLink {
                            ArchiveView()
                                .environmentObject(theme)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "archivebox.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 30, height: 30)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(theme.theme.accent)
                                    )
                                Text("Manage Archive")
                                    .font(.body)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(theme.theme.accent)
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

struct ArchiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager
    @Query(filter: #Predicate<Countdown> { $0.isArchived },
           sort: \Countdown.targetDate, order: .forward)
    private var items: [Countdown]

    @State private var deleteConfirm: Countdown? = nil

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
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(items) { item in
                                let days = DateUtils.daysUntil(target: item.targetDate, in: item.timeZoneID)
                                let dateText = DateUtils.readableDate.string(from: item.targetDate)

                                CountdownCardView(
                                    title: item.title,
                                    daysLeft: days,
                                    dateText: dateText,
                                    archived: item.isArchived,
                                    backgroundStyle: item.backgroundStyle,
                                    colorHex: item.backgroundColorHex,
                                    imageData: item.backgroundImageData,
                                    shared: item.isShared
                                )
                                .environmentObject(theme)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        deleteConfirm = item
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        item.isArchived = false
                                        try? modelContext.save()
                                    } label: {
                                        Label("Unarchive", systemImage: "tray.and.arrow.up")
                                    }
                                    .tint(.blue)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Archive")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
            }
            .confirmationDialog(
                "Delete Countdown?",
                isPresented: Binding(
                    get: { deleteConfirm != nil },
                    set: { if !$0 { deleteConfirm = nil } }
                )
            ) {
                Button("Delete", role: .destructive) {
                    if let item = deleteConfirm {
                        modelContext.delete(item)
                        try? modelContext.save()
                    }
                    deleteConfirm = nil
                }
                Button("Cancel", role: .cancel) { deleteConfirm = nil }
            }
        }
        .tint(theme.theme.accent)
    }
}

private enum ActiveAlert: Identifiable {
    case reminders

    var id: Int { hashValue }
}
