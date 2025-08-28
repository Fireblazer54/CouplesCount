import SwiftUI
import SwiftData
import UIKit

struct CountdownListView: View {
    @EnvironmentObject private var pro: ProStatusProvider
    @StateObject private var nowProvider = NowProvider()

    @Query(filter: #Predicate<Countdown> { !$0.isArchived },
           sort: \.targetUTC, order: .forward)
    private var items: [Countdown]

    @State private var showAddEdit = false
    @State private var editing: Countdown? = nil
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false
    @State private var showPaywall = false
    @State private var selectedCountdown: Countdown? = nil
    @State private var showSettingsPage = false
    @Namespace private var heroNamespace

    var refreshAction: (() async -> Void)? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                VStack(spacing: 0) {
                    if items.isEmpty {
                        EmptyStateView()
                    } else {
                        CountdownListSection(
                            items: items,
                            editing: $editing,
                            showAddEdit: $showAddEdit,
                            shareURL: $shareURL,
                            showShareSheet: $showShareSheet,
                            selectedCountdown: $selectedCountdown,
                            refreshAction: refreshAction,
                            heroNamespace: heroNamespace
                        )
                    }

                    if !Entitlements.current.hidesAds {
                        AdBannerPlaceholderView()
                    }
                }

                AddButton(
                    itemCount: items.count,
                    showAddEdit: $showAddEdit,
                    showPaywall: $showPaywall,
                    editing: $editing
                )
            }
            .sheet(isPresented: $showAddEdit, content: addEditSheet)
            .sheet(isPresented: $showShareSheet, content: shareSheet)
            .fullScreenCover(isPresented: $showPaywall, content: paywallSheet)
            .sheet(isPresented: $showSettingsPage) {
                SettingsView()
            }
            .fullScreenCover(item: $selectedCountdown) { countdown in
                CountdownDetailView(countdown: countdown)
            }
            .navigationTitle("Countdowns")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showPaywall = true } label: {
                        Image(systemName: "crown")
                            .foregroundStyle(Color("Foreground"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettingsPage = true } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color("Foreground"))
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Countdowns")
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color("Foreground"))
                        Text("Shared moments with loved ones")
                            .font(.subheadline)
                            .foregroundStyle(Color("Secondary"))
                    }
                    .multilineTextAlignment(.center)
                }
            }
        }
        .tint(Theme.accent)
        .environmentObject(nowProvider)
    }

    private func addEditSheet() -> some View {
        AddEditCountdownView(existing: editing)
            .environmentObject(pro)
    }

    @ViewBuilder
    private func shareSheet() -> some View {
        if let shareURL {
            ShareSheet(activityItems: [shareURL])
        }
    }

    private func paywallSheet() -> some View {
        PaywallView()
    }
}

private struct EmptyStateView: View {
    var body: some View {
        Spacer(minLength: 40)
        VStack(spacing: 8) {
            Text("No countdowns yet")
                .font(.headline)
                .foregroundStyle(Color("Secondary"))
            Text("Tap + to add your first one")
                .font(.subheadline)
                .foregroundStyle(Color("Secondary"))
        }
        Spacer()
    }
}

private struct AddButton: View {
    let itemCount: Int
    @Binding var showAddEdit: Bool
    @Binding var showPaywall: Bool
    @Binding var editing: Countdown?

    var body: some View {
        VStack {
            Spacer()
            Button {
                if Entitlements.current.isUnlimited || itemCount < AppLimits.freeMaxCountdowns {
                    editing = nil
                    showAddEdit = true
                } else {
                    showPaywall = true
                }
            } label: {
                Image(systemName: "plus")
                    .font(.title)
                    .padding(20)
                    .background(Circle().fill(Theme.accent))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Add countdown")
                    .accessibilityHint("Create new countdown")
            }
            .buttonStyle(OpacityButtonStyle())
            .safeAreaPadding(.bottom)
            .padding(.bottom, 16)

        }
        .frame(maxWidth: .infinity)
    }
}

private struct CountdownListSection: View {
    @Environment(\.modelContext) private var modelContext

    var items: [Countdown]
    @Binding var editing: Countdown?
    @Binding var showAddEdit: Bool
    @Binding var shareURL: URL?
    @Binding var showShareSheet: Bool
    @Binding var selectedCountdown: Countdown?
    var refreshAction: (() async -> Void)?
    var heroNamespace: Namespace.ID

    var body: some View {
        List {
            ForEach(items) { item in
                CountdownRowView(
                    countdown: item,
                    heroNamespace: heroNamespace,
                    onShare: { url in
                        shareURL = url
                        showShareSheet = true
                    },
                    onEdit: { countdown in
                        editing = countdown
                        showAddEdit = true
                    },
                    onDelete: { countdown in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            modelContext.delete(countdown)
                            try? modelContext.save()
                            let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                            updateWidgetSnapshot(afterSaving: all)
                        }
                        Haptics.warning()
                    },
                    onArchiveToggle: { countdown in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            countdown.isArchived.toggle()
                            try? modelContext.save()
                            let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                            updateWidgetSnapshot(afterSaving: all)
                        }
                        if countdown.isArchived { Haptics.light() }
                    },
                    onSelect: { countdown in
                        selectedCountdown = countdown
                    }
                )
            }
        }
        .listStyle(.plain)
        .listRowSpacing(16)
        .scrollContentBackground(.hidden)
        .padding(.top, 16)
        .refreshable { await refreshAction?() }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: items)
    }
}

