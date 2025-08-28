import SwiftUI
import SwiftData

struct AddEditCountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let existing: Countdown?

    @State private var title: String = ""
    @State private var date: Date = Date().addingTimeInterval(86_400)
    @State private var timeZoneID: String = TimeZone.current.identifier
    @State private var cardFontStyle: CardFontStyle = .classic

    @State private var backgroundStyle: String = "color"
    @State private var colorHex: String = ""
    @State private var imageData: Data? = nil

    // Live preview values
    @State private var previewTitle: String = "Countdown"
    @State private var previewDate: Date = Date().addingTimeInterval(86_400)
    @State private var previewColorHex: String = ""
    @State private var previewImageData: Data? = nil

    // Reminders
    @State private var selectedReminders: Set<ReminderOption> = []

    // UX
    @State private var showValidation = false
    @State private var saveError: String?

    // Sharing
    @State private var isShared: Bool = false
    @State private var selectedFriends: Set<UUID> = []
    @Query(sort: \Friend.name) private var friends: [Friend]
    @State private var shareURL: URL? = nil
    @State private var showShareSheet = false

    init(existing: Countdown? = nil) { self.existing = existing }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    LivePreviewSection(
                        previewTitle: previewTitle,
                        previewDate: previewDate,
                        timeZoneID: timeZoneID,
                        cardFontStyle: cardFontStyle,
                        backgroundStyle: backgroundStyle,
                        colorHex: previewColorHex,
                        imageData: previewImageData
                    )
                    .animation(.easeInOut(duration: 0.2), value: title)
                    .animation(.easeInOut(duration: 0.2), value: date)
                    .animation(.easeInOut(duration: 0.2), value: backgroundStyle)
                    .animation(.easeInOut(duration: 0.2), value: colorHex)
                    .animation(.easeInOut(duration: 0.2), value: imageData)

                    CountdownFormFields(
                        title: $title,
                        date: $date,
                        timeZoneID: $timeZoneID,
                        cardFontStyle: $cardFontStyle
                    )

                    BackgroundPickerSection(
                        backgroundStyle: $backgroundStyle,
                        colorHex: $colorHex,
                        imageData: $imageData
                    )

                    ShareSection(
                        isShared: $isShared,
                        selectedFriends: $selectedFriends,
                        friends: friends
                    )

                    ReminderPickerSection(selectedReminders: $selectedReminders)

                    if showValidation && title.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Please enter a title.")
                            .foregroundStyle(.red)
                            .padding(.horizontal, 16)
                    }

                    if let existing {
                        SettingsCard {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    existing.isArchived.toggle()
                                    if existing.isArchived {
                                        NotificationManager.cancelReminders(for: existing.id)
                                    }
                                    try? modelContext.save()
                                    let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                    updateWidgetSnapshot(afterSaving: all)
                                }
                                if existing.isArchived { Haptics.light() }
                                dismiss()
                            } label: {
                                Label(existing.isArchived ? "Unarchive Countdown" : "Archive Countdown",
                                      systemImage: existing.isArchived ? "tray.and.arrow.up" : "archivebox")
                    .foregroundStyle(Color("Foreground"))
                            }
                        }

                        SettingsCard {
                            Button(role: .destructive) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    NotificationManager.cancelAll(for: existing.id)
                                    modelContext.delete(existing)
                                    try? modelContext.save()
                                    let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                    updateWidgetSnapshot(afterSaving: all)
                                }
                                Haptics.warning()
                                dismiss()
                            } label: {
                                Label("Delete Countdown", systemImage: "trash")
                                    .foregroundStyle(Color("Foreground"))
                            }
                        }
                    }
                }
                .padding(.top, 14)
                .padding(.horizontal, 16)
            }
            .scrollIndicators(.hidden)
            .overlay(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(.gray.opacity(0.4))
                    .frame(width: 6)
                    .padding(.vertical, 8)
                    .padding(.trailing, 2)
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .tint(Theme.accent)
            .navigationTitle(existing == nil ? "Add Countdown" : "Edit Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.backgroundTop, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("Foreground"))
                }
                ToolbarItem(placement: .principal) {
                    Text(existing == nil ? "Add Countdown" : "Edit Countdown")
                        .foregroundStyle(Color("Foreground"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if let existing {
                            Button {
                                shareURL = CountdownShareService.exportURL(for: existing)
                                showShareSheet = shareURL != nil
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .frame(width: 44, height: 44)
                                    .contentShape(Rectangle())
                                    .accessibilityLabel("Share")
                                    .accessibilityHint("Share countdown")
                                    .foregroundStyle(Color("Foreground"))
                            }
                        }
                        Button(action: save) {
                            Image(systemName: "checkmark")
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                                .accessibilityLabel("Save")
                                .accessibilityHint("Save countdown")
                                .foregroundStyle(Color("Foreground"))
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
            .onChange(of: title, initial: false) { _, new in
                previewTitle = new.isEmpty ? "Countdown" : new
            }
            .onChange(of: date, initial: false) { _, new in
                previewDate = new
            }
            .onChange(of: colorHex, initial: false) { _, new in
                previewColorHex = new
                Haptics.light()
            }
            .onChange(of: imageData, initial: false) { _, new in
                previewImageData = new
                if new != nil { Haptics.light() }
            }
            .onAppear {
                let defaultHex = Theme.accent.hexString
                if let existing {
                    title = existing.title
                    date = existing.targetDate
                    timeZoneID = existing.timeZoneID
                    cardFontStyle = existing.cardFontStyle
                    backgroundStyle = existing.backgroundStyle
                    let stored = existing.backgroundColorHex?.uppercased()
                    if stored == nil || stored == "#FFFFFF" || stored == defaultHex.uppercased() {
                        colorHex = defaultHex
                    } else {
                        colorHex = stored ?? defaultHex
                    }
                    imageData = existing.backgroundImageData
                    selectedReminders = Set(existing.reminderOffsets.compactMap { ReminderOption(rawValue: $0) })
                    isShared = existing.isShared
                    selectedFriends = Set(existing.sharedWith.map { $0.id })
                    previewTitle = existing.title
                    previewDate = existing.targetDate
                    previewColorHex = colorHex
                    previewImageData = existing.backgroundImageData
                } else {
                    NotificationManager.requestAuthorizationIfNeeded()
                    colorHex = defaultHex
                    previewTitle = title
                    previewDate = date
                    previewColorHex = defaultHex
                    previewImageData = imageData
                }
            }
        }
        .tint(Theme.accent)
        .alert("Couldn’t Save",
               isPresented: Binding(get: { saveError != nil },
                                   set: { if !$0 { saveError = nil } })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveError ?? "Unknown error")
        }
    }

    // MARK: Save

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { showValidation = true; return }

        do {
            let defaultHex = Theme.accent.hexString.uppercased()
            let chosenHex = colorHex.uppercased()
            let storedHex: String? = (chosenHex == defaultHex) ? nil : chosenHex

            if let existing {
                existing.title = trimmed
                existing.targetDate = date
                existing.timeZoneID = timeZoneID
                existing.cardFontStyle = cardFontStyle
                existing.backgroundStyle = backgroundStyle
                existing.backgroundColorHex = storedHex
                existing.backgroundImageData = imageData
                existing.hasImage = backgroundStyle == "image"
                existing.reminderOffsets = selectedReminders.map { $0.rawValue }
                existing.lastEdited = .now
                existing.isShared = isShared
                existing.sharedWith = friends.filter { selectedFriends.contains($0.id) }
                NotificationManager.cancelAll(for: existing.id)
                if !selectedReminders.isEmpty { NotificationManager.scheduleReminders(for: existing) }
            } else {
                let cd = Countdown(
                    title: trimmed,
                    targetDate: date,
                    timeZoneID: timeZoneID,
                    cardFontStyle: cardFontStyle,
                    backgroundStyle: backgroundStyle,
                    backgroundColorHex: storedHex,
                    backgroundImageData: imageData,
                    reminderOffsets: selectedReminders.map { $0.rawValue },
                    isShared: isShared,
                    sharedWith: friends.filter { selectedFriends.contains($0.id) }
                )
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    modelContext.insert(cd)
                }
                if !selectedReminders.isEmpty { NotificationManager.scheduleReminders(for: cd) }
            }

            try modelContext.save()
            let all = try modelContext.fetch(FetchDescriptor<Countdown>())
            updateWidgetSnapshot(afterSaving: all)
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}

