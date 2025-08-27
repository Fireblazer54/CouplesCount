import SwiftUI
import SwiftData
import UIKit

struct CountdownListView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var pro: ProStatusProvider

    @Query(filter: #Predicate<Countdown> { !$0.isArchived },
           sort: \.targetUTC, order: .forward)
    private var items: [Countdown]

    @State private var showAddEdit = false
    @State private var editing: Countdown? = nil
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false
    @State private var showPaywall = false
    @State private var showingBlankDetail = false
    @Namespace private var heroNamespace

    var refreshAction: (() async -> Void)? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                theme.theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    HeaderView()
                        .environmentObject(theme)

                    if items.isEmpty {
                        EmptyStateView()
                    } else {
                        CountdownListSection(
                            items: items,
                            editing: $editing,
                            showAddEdit: $showAddEdit,
                            shareURL: $shareURL,
                            showShareSheet: $showShareSheet,
                            showingBlankDetail: $showingBlankDetail,
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
                .environmentObject(theme)
            }
            .sheet(isPresented: $showAddEdit, content: addEditSheet)
            .sheet(isPresented: $showShareSheet, content: shareSheet)
            .sheet(isPresented: $showPaywall, content: paywallSheet)
            .fullScreenCover(isPresented: $showingBlankDetail) {
                blankDetailOverlay(isPresented: $showingBlankDetail, onClose: { showingBlankDetail = false })
            }
        }
        .tint(theme.theme.textPrimary)
    }

    // MARK: - Overlays & Sheets

    @ViewBuilder
    private func blankDetailOverlay(isPresented _: Binding<Bool>, onClose _: () -> Void) -> some View {
        BlankDetailView()
            .environmentObject(theme)
    }

    private func addEditSheet() -> some View {
        AddEditCountdownView(existing: editing)
            .environmentObject(theme)
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
            .environmentObject(theme)
    }
}

private struct HeaderView: View {
    @EnvironmentObject private var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Countdowns")
                .font(.largeTitle.bold())
                .foregroundStyle(theme.theme.textPrimary)
            Text("Shared moments with loved ones")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 32)
        .padding(.bottom, 16)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        Spacer(minLength: 40)
        VStack(spacing: 8) {
            Text("No countdowns yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap + to add your first one")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        Spacer()
    }
}

private struct AddButton: View {
    @EnvironmentObject private var theme: ThemeManager
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
                    .background(Circle().fill(theme.theme.primary))
                    .foregroundStyle(Color.white)
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
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.modelContext) private var modelContext

    var items: [Countdown]
    @Binding var editing: Countdown?
    @Binding var showAddEdit: Bool
    @Binding var shareURL: URL?
    @Binding var showShareSheet: Bool
    @Binding var showingBlankDetail: Bool
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
                    onSelect: { _ in
                        showingBlankDetail = true
                    }
                )
            }
        }
        .listStyle(.plain)
        .listRowSpacing(16)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 8)
        }
        .scrollContentBackground(.hidden)
        .refreshable { await refreshAction?() }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: items)
    }
}

