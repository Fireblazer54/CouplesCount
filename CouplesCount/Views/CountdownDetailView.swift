import SwiftUI
import SwiftData

struct CountdownDetailView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var pro: ProStatusProvider
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let countdown: Countdown

    @State private var showShareSheet = false
    @State private var shareURL: URL? = nil
    @State private var showEdit = false
    @State private var showDeleteAlert = false
    @State private var now = Date()
    @State private var progress: Double = 0
    @State private var showPokeToast = false
    @State private var toastMessage = ""
    @State private var streak: Int = 0

    private let participantsStore = ParticipantsStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero
                info
                sharedSection
                TreeGrowthView(progress: progress)
                    .frame(height: 180)
                Button("Remind me to check in") {
                    NotificationManager.scheduleCheckInReminder()
                    Analytics.log("reminder_stub_tapped")
                }
                .buttonStyle(.borderedProminent)
                Text("You checked this \(streak) days in a row")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .safeAreaPadding(.bottom, 40)

        }
        .background(theme.theme.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: share) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .accessibilityLabel("Share")
                        .accessibilityHint("Share countdown")
                }
                Button(action: { showEdit = true }) {
                    Image(systemName: "pencil")
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .accessibilityLabel("Edit")
                        .accessibilityHint("Edit countdown")
                }
                Menu {
                    Button(countdown.isArchived ? "Unarchive" : "Archive") {
                        toggleArchive()
                    }
                    Button("Delete", role: .destructive) { showDeleteAlert = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .accessibilityLabel("More options")
                        .accessibilityHint("Show additional actions")
                }
            }
        }
        .sheet(isPresented: $showShareSheet, onDismiss: { Haptics.success() }) {
            if let shareURL { ShareSheet(activityItems: [shareURL]) }
        }
        .sheet(isPresented: $showEdit) {
            AddEditCountdownView(existing: countdown)
                .environmentObject(theme)
                .environmentObject(pro)
        }
        .alert("Delete Countdown?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(countdown)
                try? modelContext.save()
                Haptics.warning()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .overlay(alignment: .bottom) {
            if showPokeToast {
                Text(toastMessage)
                    .padding()
                    .background(.black.opacity(0.7))
                    .foregroundStyle(.white)
                    .cornerRadius(8)
                    .safeAreaPadding(.bottom, 40)
                    .transition(.opacity)
            }
        }
        .onAppear {
            Analytics.log("detail_view_opened")
            updateProgress()
            incrementStreak()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { t in
            now = t
            updateProgress()
        }
        .accessibilityLabel("Countdown \(countdown.title), \(DateUtils.remainingText(to: countdown.targetDate, from: now, in: countdown.timeZoneID))")
    }

    private var hero: some View {
        let width = UIScreen.main.bounds.width - 32
        return CountdownCardView(
            title: countdown.title,
            targetDate: countdown.targetDate,
            timeZoneID: countdown.timeZoneID,
            dateText: DateUtils.readableDate.string(from: countdown.targetDate),
            archived: countdown.isArchived,
            backgroundStyle: countdown.backgroundStyle,
            colorHex: countdown.backgroundColorHex,
            imageData: countdown.backgroundImageData,
            fontStyle: countdown.cardFontStyle,
            shared: countdown.isShared,
            shareAction: nil,
            height: width
        )
        .environmentObject(theme)
        .frame(width: width, height: width)
    }

    private var info: some View {
        VStack(spacing: 8) {
            Text(countdown.title)
                .font(CardTypography.font(for: countdown.cardFontStyle, role: .title))
            Text(DateUtils.readableDate.string(from: countdown.targetDate))
                .font(CardTypography.font(for: countdown.cardFontStyle, role: .date))
            Text(DateUtils.remainingText(to: countdown.targetDate, from: now, in: countdown.timeZoneID))
                .font(CardTypography.font(for: countdown.cardFontStyle, role: .number))
        }
        .multilineTextAlignment(.center)
    }

    private var sharedSection: some View {
        let participants = participantsStore.participants(for: countdown)
        return VStack(alignment: .leading, spacing: 8) {
            if participants.isEmpty {
                Button("Share with partner") { share() }
                    .font(.subheadline)
            } else {
                DisclosureGroup("Shared With") {
                    ForEach(participants) { p in
                        HStack {
                            p.image
                            Text(p.name)
                            Spacer()
                            Button("Poke") { poke(p) }
                                .buttonStyle(.bordered)
                        }
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
    }

    private func poke(_ p: Participant) {
        PokeService.sendPoke(countdownID: countdown.id, userID: p.id)
        toastMessage = "Poked \(p.name)"
        withAnimation { showPokeToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showPokeToast = false }
        }
        Haptics.light()
        Analytics.log("poke_tapped")
    }

    private func share() {
        shareURL = CountdownShareService.exportURL(for: countdown)
        showShareSheet = shareURL != nil
        Analytics.log("share_tapped")
    }

    private func toggleArchive() {
        countdown.isArchived.toggle()
        try? modelContext.save()
    }

    private func updateProgress() {
        let start = countdown.lastEdited
        let total = countdown.targetDate.timeIntervalSince(start)
        guard total > 0 else { progress = 1; return }
        progress = max(0, min(1, now.timeIntervalSince(start) / total))
    }

    private func incrementStreak() {
        let key = "streak-\(countdown.id.uuidString)"
        let current = UserDefaults.standard.integer(forKey: key)
        streak = current + 1
        UserDefaults.standard.set(streak, forKey: key)
    }
}

#Preview {
    let countdown = Countdown(title: "Preview", targetDate: .now.addingTimeInterval(3600), timeZoneID: TimeZone.current.identifier)
    return CountdownDetailView(countdown: countdown)
        .environmentObject(ThemeManager())
}
