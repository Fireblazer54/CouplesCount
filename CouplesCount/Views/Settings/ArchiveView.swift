import SwiftUI
import SwiftData

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
                            .foregroundStyle(theme.theme.textSecondary)
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
                                        .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 16), weight: .bold))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(theme.theme.primary))
                                        .foregroundStyle(theme.theme.textPrimary)
                                        .accessibilityLabel("Delete")
                                        .accessibilityHint("Remove countdown")
                                }
                                .tint(.clear)
                                .contentShape(Rectangle())
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
                                        .font(.system(size: UIFontMetrics(forTextStyle: .body).scaledValue(for: 16), weight: .bold))
                                        .frame(width: 44, height: 44)
                                        .background(Circle().fill(theme.theme.primary))
                                        .foregroundStyle(theme.theme.textPrimary)
                                        .accessibilityLabel("Unarchive")
                                        .accessibilityHint("Restore countdown")
                                }
                                .tint(.clear)
                                .contentShape(Rectangle())
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
        .tint(theme.theme.textPrimary)
    }
}

