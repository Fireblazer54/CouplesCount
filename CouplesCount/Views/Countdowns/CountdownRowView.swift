import SwiftUI
import SwiftData

struct CountdownRowView: View {
    @EnvironmentObject private var theme: ThemeManager

    let countdown: Countdown
    let heroNamespace: Namespace.ID
    let useHeroTransition: Bool
    let onShare: (URL) -> Void
    let onEdit: (Countdown) -> Void
    let onDelete: (Countdown) -> Void
    let onArchiveToggle: (Countdown) -> Void
    let onSelect: (Countdown) -> Void

    @State private var isPressing = false

    var body: some View {
        let dateText = DateUtils.readableDate.string(from: countdown.targetDate)
        let exportURL = CountdownShareService.exportURL(for: countdown)

        let card = CountdownCardView(
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
        .environmentObject(theme)
        .contentShape(Rectangle())
        .scaleEffect(isPressing ? 0.97 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressing)
        .onLongPressGesture(minimumDuration: 0.4, maximumDistance: 50, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressing = pressing
            }
        }) {
            Haptics.light()
            onEdit(countdown)
        }

        if useHeroTransition {
            styledRow(
                card.onTapGesture { onSelect(countdown) }
            )
        } else {
            styledRow(
                NavigationLink(value: countdown.id) {
                    card
                }
            )
        }
    }

    @ViewBuilder
    private func styledRow<Content: View>(_ content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
            .listRowBackground(theme.theme.background)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                DeleteSwipeButton { onDelete(countdown) }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                ArchiveSwipeButton(
                    { onArchiveToggle(countdown) },
                    label: countdown.isArchived ? "Unarchive" : "Archive",
                    systemImage: countdown.isArchived ? "arrow.uturn.backward" : "archivebox",
                    hint: countdown.isArchived ? "Restore countdown" : "Archive countdown"
                )
            }
    }
}
