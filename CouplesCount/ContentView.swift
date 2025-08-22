import SwiftUI
import SwiftData

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
        .tint(theme.theme.accent)
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
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Countdown> { !$0.isArchived },
           sort: \.targetDate, order: .forward)
    private var items: [Countdown]

    @State private var showAddEdit = false
    @State private var editing: Countdown? = nil
    @State private var showSettings = false
    @State private var showPremium = false
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false

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
                            Image(systemName: "crown.fill").font(.title2)
                        }
                        Spacer()
                        Text(Date.now, format: .dateTime.weekday(.wide).month().day())
                            .font(.system(size: 28, weight: .semibold))
                        Spacer()
                        Button { showSettings = true } label: {
                            Image(systemName: "gearshape.fill").font(.title2)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

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
                                  let days = DateUtils.daysUntil(
                                      target: item.targetDate,
                                      in: item.timeZoneID
                                  )
                                  let dateText = DateUtils.readableDate.string(from: item.targetDate)
                                  let exportURL = CountdownShareService.exportURL(for: item)

                                CountdownCardView(
                                    title: item.title,
                                    daysLeft: days,
                                    dateText: dateText,
                                    archived: item.isArchived,
                                    backgroundStyle: item.backgroundStyle,
                                    colorHex: item.backgroundColorHex,
                                    imageData: item.backgroundImageData,
                                    shared: item.isShared,
                                    shareAction: {
                                        shareURL = exportURL
                                        showShareSheet = shareURL != nil
                                    }
                                )
                                .environmentObject(theme)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editing = item
                                    showAddEdit = true
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .listRowBackground(theme.theme.background)
                                .contextMenu {
                                    if let exportURL {
                                        Button {
                                            shareURL = exportURL
                                            showShareSheet = true
                                        } label: {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        withAnimation(.easeInOut) {
                                            modelContext.delete(item)
                                            try? modelContext.save()
                                          }
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
                                          withAnimation(.easeInOut) {
                                              item.isArchived.toggle()
                                              try? modelContext.save()
                                          }
                                      } label: {
                                          Image(systemName: item.isArchived ? "arrow.uturn.backward" : "archivebox")
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
                          .listRowSpacing(16)
                          .padding(.top, 28)
                          .scrollContentBackground(.hidden)
                          .animation(.easeInOut, value: items)
                      }
                }

                // Centered bottom +
                VStack {
                    Spacer()
                    Button {
                        editing = nil
                        showAddEdit = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title)
                            .padding(20)
                            .background(Circle().fill(.tint))
                            .foregroundStyle(.white)
                            .shadow(radius: 6, y: 3)
                    }
                    .padding(.bottom, 24)
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
            .sheet(isPresented: $showAddEdit) {
                AddEditCountdownView(existing: editing)
                    .environmentObject(theme)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(theme)
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
        }
        .tint(theme.theme.accent)
    }
}
