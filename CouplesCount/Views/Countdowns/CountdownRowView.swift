import SwiftUI
import SwiftData

struct CountdownRowView: View {

    let countdown: Countdown
    let heroNamespace: Namespace.ID
    let onShare: (URL) -> Void
    let onEdit: (Countdown) -> Void
    let onDelete: (Countdown) -> Void
    let onArchiveToggle: (Countdown) -> Void
    let onSelect: (Countdown) -> Void

    @State private var isPressed = false

    var body: some View {
        let dateText = DateUtils.readableDate.string(from: countdown.targetDate)
        let exportURL = CountdownShareService.exportURL(for: countdown)

        CountdownCardView(
            title: countdown.title,
            targetDate: countdown.targetDate,
            timeZoneID: countdown.timeZoneID,
            dateText: dateText,
            archived: countdown.isArchived,
            backgroundStyle: countdown.backgroundStyle,
            colorHex: countdown.backgroundColorHex,
            imageData: countdown.backgroundImageData,
            fontStyle: countdown.cardFontStyle,
            shared: countdown.isShared,
            shareAction: {
                if let exportURL { onShare(exportURL) }
            }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            Haptics.light()
            onSelect(countdown)
        }
        .scaleEffect(isPressed ? 0.97 : 1)
        .shadow(color: .black.opacity(0.05), radius: isPressed ? 0 : 4, y: 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0.4, maximumDistance: 50, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        }) {
            Haptics.light()
            onEdit(countdown)
        }
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            DeleteSwipeButton({ onDelete(countdown) }, background: Color("Destructive"), foreground: .white)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            ArchiveSwipeButton(
                { onArchiveToggle(countdown) },
                label: countdown.isArchived ? "Unarchive" : "Archive",
                systemImage: countdown.isArchived ? "arrow.uturn.backward" : "archivebox",
                hint: countdown.isArchived ? "Restore countdown" : "Archive countdown",
                background: Theme.accent,
                foreground: .white
            )
        }
    }
}

