import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @State private var importError: String?

    var body: some View {
        TabView {
            CountdownListView()
                .tabItem {
                    Label("Countdowns", systemImage: "timer")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(theme.theme.textPrimary)
        .onOpenURL { url in
            do {
                try CountdownShareService.importCountdown(from: url, context: modelContext)
            } catch {
                importError = error.localizedDescription
            }
        }
        .alert("Import Failed", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "")
        }
    }
}

struct CountdownListView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var pro: ProStatusProvider
    @Environment(\.modelContext) private var modelContext

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
                    // Top bar
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

                    // List
                    if items.isEmpty {
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
                    } else {
                        List {
                            ForEach(items) { item in
                                // Compute per-item display values
                                let dateText = DateUtils.readableDate.string(from: item.targetDate)
                                let exportURL = CountdownShareService.exportURL(for: item)

                                // Build the countdown card separately to reduce type-checking complexity
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
                                        Haptics.medium()
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            showingBlankDetail = true
                                        }

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
                    if !Entitlements.current.hidesAds {
                        AdBannerPlaceholderView()
                    }
                }

                // Centered bottom +
                VStack {
                    Spacer()
                    Button {
                        if Entitlements.current.isUnlimited || items.count < AppLimits.freeMaxCountdowns {
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
                .frame(maxWidth: .infinity) // centers horizontally
            }
            .overlay(alignment: .topLeading) {
                if showPremium {
                    PremiumPromoView(show: $showPremium)
                        .environmentObject(theme)
                        .transition(.scale(scale: 0.1, anchor: .topLeading).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .overlay {
                if showingBlankDetail {
                    ZStack {
                        Color.black.opacity(0.08)
                            .ignoresSafeArea()
                            .transition(.opacity)

                        BlankDetailView {
                            showingBlankDetail = false
                        }
                        .environmentObject(theme)
                        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity),
                                                 removal: .opacity))
                        .zIndex(1)
                    }
                    .zIndex(1)
                }
            }
            .sheet(isPresented: $showAddEdit) {
                AddEditCountdownView(existing: editing)
                    .environmentObject(theme)
                    .environmentObject(pro)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(theme).environmentObject(pro)
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView().environmentObject(theme)
            }
            .fullScreenCover(isPresented: $showingBlankDetail) {
                BlankDetailView()
                    .environmentObject(theme)
            }
        }
        .tint(theme.theme.textPrimary)
    }
}

struct OpacityButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }
}
