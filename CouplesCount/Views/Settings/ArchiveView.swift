import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Countdown> { $0.isArchived },
           sort: \Countdown.targetUTC, order: .forward)
    private var items: [Countdown]

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background").ignoresSafeArea()

                if items.isEmpty {
                    VStack(spacing: 8) {
                        Text("No archived countdowns")
                            .font(.headline)
                            .foregroundStyle(Color("Secondary"))
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
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                DeleteSwipeButton(
                                    {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            modelContext.delete(item)
                                            try? modelContext.save()
                                            let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                            updateWidgetSnapshot(afterSaving: all)
                                        }
                                        Haptics.warning()
                                    },
                                    background: Color("Destructive"),
                                    foreground: Color("Background")
                                )
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                ArchiveSwipeButton(
                                    {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            item.isArchived = false
                                            try? modelContext.save()
                                            let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                            updateWidgetSnapshot(afterSaving: all)
                                        }
                                    },
                                    label: "Unarchive",
                                    systemImage: "arrow.uturn.backward",
                                    hint: "Restore countdown",
                                    background: Color("Primary"),
                                    foreground: Color("Background")
                                )
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
        .tint(Color("Foreground"))
    }
}

