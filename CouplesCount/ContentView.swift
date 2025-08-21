import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager

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
    @State private var deleteConfirm: Countdown? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                theme.theme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Button { /* premium placeholder */ } label: {
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
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(items) { item in
                                    // Compute per-item display values
                                    let days = DateUtils.daysUntil(
                                        target: item.targetDate,
                                        in: item.timeZoneID
                                    )
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
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editing = item
                                        showAddEdit = true
                                    }
                                    .gesture(
                                        DragGesture(minimumDistance: 30, coordinateSpace: .local)
                                            .onEnded { value in
                                                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                                                if value.translation.width < -80 {
                                                    deleteConfirm = item
                                                } else if value.translation.width > 80 {
                                                    item.isArchived.toggle()
                                                    try? modelContext.save()
                                                }
                                            }
                                    )
                                }
                                .padding(.horizontal) // nice side gutters
                                .padding(.top, 12)
                            }
                        }
                        .scrollIndicators(.hidden)
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
            .sheet(isPresented: $showAddEdit) {
                AddEditCountdownView(existing: editing)
                    .environmentObject(theme)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView().environmentObject(theme)
            }
            .confirmationDialog(
                "Delete Countdown?",
                isPresented: Binding(
                    get: { deleteConfirm != nil },
                    set: { if !$0 { deleteConfirm = nil } }
                ),
                titleVisibility: .visible
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
