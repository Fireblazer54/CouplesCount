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

    @State private var isPressing = false
    @State private var showTrailingActions = false
    @State private var showLeadingActions = false

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
        .onTapGesture { onSelect(countdown) }
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
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
        .listRowBackground(Color.white)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete(countdown)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(Color("Destructive"))
            .onAppear { showTrailingActions = true }
            .onDisappear { showTrailingActions = false }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                onArchiveToggle(countdown)
            } label: {
                Label(countdown.isArchived ? "Unarchive" : "Archive",
                      systemImage: countdown.isArchived ? "arrow.uturn.backward" : "archivebox")
            }
            .tint(Theme.accent)
            .onAppear { showLeadingActions = true }
            .onDisappear { showLeadingActions = false }
        }
        .onChange(of: showTrailingActions, initial: false) { _, newValue in
            if newValue { Haptics.light() }
        }
        .onChange(of: showLeadingActions, initial: false) { _, newValue in
            if newValue { Haptics.light() }
        }
    }
}

