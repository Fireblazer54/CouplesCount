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
    @State private var showSettings = false
    @State private var showPremium = false
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false
    @State private var pressingID: UUID? = nil
    @State private var showPaywall = false
    @State private var showingBlankDetail = false

    var refreshAction: (() async -> Void)? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                theme.theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    TopBar(showPremium: $showPremium, showSettings: $showSettings)
                        .environmentObject(theme)

                    if items.isEmpty {
                        EmptyStateView()
                    } else {
                        CountdownListSection(
                            items: items,
                            pressingID: $pressingID,
                            editing: $editing,
                            showAddEdit: $showAddEdit,
                            shareURL: $shareURL,
                            showShareSheet: $showShareSheet,
                            showingBlankDetail: $showingBlankDetail,
                            refreshAction: refreshAction
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
            .overlay(alignment: .topLeading) {
                if showPremium {
                    PremiumPromoView(show: $showPremium)
                        .environmentObject(theme)
                        .transition(.scale(scale: 0.1, anchor: .topLeading).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .sheet(isPresented: $showAddEdit) {
                AddEditCountdownView(existing: editing)
                    .environmentObject(theme)
                    .environmentObject(pro)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(theme)
                    .environmentObject(pro)
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(theme)
            }
            .fullScreenCover(isPresented: $showingBlankDetail) {
                BlankDetailView()
                    .environmentObject(theme)
            }
        }
        .tint(theme.theme.textPrimary)
    }
}

private struct TopBar: View {
    @EnvironmentObject private var theme: ThemeManager
    @Binding var showPremium: Bool
    @Binding var showSettings: Bool

    var body: some View {
        HStack {
            Button {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showPremium = true
                }
            } label: {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Go Pro")
                    .accessibilityHint("View premium features")
            }
            Spacer()
            Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                .font(.system(size: UIFontMetrics(forTextStyle: .title1).scaledValue(for: 28), weight: .semibold))
                .foregroundStyle(theme.theme == .light ? theme.theme.textPrimary : .primary)

            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Open settings")
            }
        }
        .padding(.horizontal)
        .safeAreaPadding(.top, 12)
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
    @Binding var pressingID: UUID?
    @Binding var editing: Countdown?
    @Binding var showAddEdit: Bool
    @Binding var shareURL: URL?
    @Binding var showShareSheet: Bool
    @Binding var showingBlankDetail: Bool
    var refreshAction: (() async -> Void)?

    var body: some View {
        List {
            ForEach(items) { item in
                let dateText = DateUtils.readableDate.string(from: item.targetDate)
                let exportURL = CountdownShareService.exportURL(for: item)

                let card = CountdownCardView(
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
                    shareAction: {
                        shareURL = exportURL
                        showShareSheet = shareURL != nil
                    }
                )

                card
                    .environmentObject(theme)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showingBlankDetail = true
                    }
                    .scaleEffect(pressingID == item.id ? 0.97 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pressingID == item.id)
                    .onLongPressGesture(minimumDuration: 0.4, maximumDistance: 50, pressing: { pressing in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            pressingID = pressing ? item.id : nil
                        }
                    }) {
                        Haptics.light()
                        editing = item
                        showAddEdit = true
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(theme.theme.background)
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
                                .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 16), weight: .bold))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.red))
                                .foregroundStyle(.white)
                                .accessibilityLabel("Delete")
                                .accessibilityHint("Remove countdown")
                        }
                        .tint(.clear)
                        .contentShape(Rectangle())
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                item.isArchived.toggle()
                                try? modelContext.save()
                                let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                updateWidgetSnapshot(afterSaving: all)
                            }
                            if item.isArchived { Haptics.light() }
                        } label: {
                            Image(systemName: item.isArchived ? "arrow.uturn.backward" : "archivebox")
                                .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 16), weight: .bold))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.blue))
                                .foregroundStyle(.white)
                                .accessibilityLabel(item.isArchived ? "Unarchive" : "Archive")
                                .accessibilityHint(item.isArchived ? "Restore countdown" : "Archive countdown")
                        }
                        .tint(.clear)
                        .contentShape(Rectangle())
                    }
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

