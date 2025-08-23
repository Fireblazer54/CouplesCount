import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation
import UIKit

// MARK: - Reminder options

enum ReminderOption: Int, CaseIterable, Identifiable {
    case h1 = -60
    case h2 = -120
    case h3 = -180
    case h6 = -360
    case h12 = -720
    case d1 = -1440
    case d2 = -2880
    case d3 = -4320
    case d7 = -10080

    var id: Int { rawValue }
    var label: String {
        switch self {
        case .h1: return "1h"
        case .h2: return "2h"
        case .h3: return "3h"
        case .h6: return "6h"
        case .h12: return "12h"
        case .d1: return "1d"
        case .d2: return "2d"
        case .d3: return "3d"
        case .d7: return "7d"
        }
    }
}

// MARK: - Add/Edit Screen

struct AddEditCountdownView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager

    let existing: Countdown?

    @State private var title: String = ""
    @State private var date: Date = Date().addingTimeInterval(86_400)
    @State private var timeZoneID: String = TimeZone.current.identifier
    @State private var titleFont: TitleFont = .default

    // Background selection
    @State private var backgroundStyle: String = "color" // "color" | "image"
    @State private var colorHex: String = "#0A84FF"
    @State private var imageData: Data? = nil
    @State private var showPhotoPicker = false
    @State private var showCamera = false

    // Live preview values
    @State private var previewTitle: String = "Countdown"
    @State private var previewDate: Date = Date().addingTimeInterval(86_400)
    @State private var previewColorHex: String = "#0A84FF"
    @State private var previewImageData: Data? = nil

    // Reminders
    @State private var selectedReminders: Set<ReminderOption> = []
    @State private var showReminderSheet = false

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

                    // MARK: Swipable widget preview (square → rectangular)
                    TabView {
                        // Square
                        WidgetPreview(
                            title: previewTitle,
                            targetDate: previewDate,
                            tzID: timeZoneID,
                            titleFontName: titleFont.rawValue,
                            backgroundStyle: backgroundStyle,
                            bgColorHex: previewColorHex,
                            imageData: previewImageData
                        )
                        .frame(width: 160, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.vertical, 8)

                        // Rectangular
                        WidgetPreview(
                            title: previewTitle,
                            targetDate: previewDate,
                            tzID: timeZoneID,
                            titleFontName: titleFont.rawValue,
                            backgroundStyle: backgroundStyle,
                            bgColorHex: previewColorHex,
                            imageData: previewImageData
                        )
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.vertical, 8)
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .automatic))
                    .frame(height: 180)
                    .padding(.horizontal, 16)
                    .animation(.easeInOut(duration: 0.2), value: title)
                    .animation(.easeInOut(duration: 0.2), value: date)
                    .animation(.easeInOut(duration: 0.2), value: backgroundStyle)
                    .animation(.easeInOut(duration: 0.2), value: colorHex)
                    .animation(.easeInOut(duration: 0.2), value: imageData)

                    // MARK: Details
                    SettingsCard {
                        TextField("Title (e.g., Anniversary)", text: $title)
                            .textInputAutocapitalization(.words)
                            .onSubmit { lightHaptic() }

                        Picker("Font", selection: $titleFont) {
                            ForEach(TitleFont.allCases) { f in
                                Text(f.displayName).tag(f)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: titleFont, initial: false) { _, _ in lightHaptic() }

                        HStack {
                            DatePicker("Date", selection: $date, displayedComponents: .date)
                            DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }

                        NavigationLink {
                            TimeZonePickerView(selectedID: $timeZoneID)
                        } label: {
                            HStack {
                                Text("Time Zone")
                                Spacer()
                                Text(TimeZone(identifier: timeZoneID)?.identifier ?? "System")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // MARK: Background
                    SettingsCard {
                        Text("Background")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Picker("Style", selection: $backgroundStyle) {
                            Text("Color").tag("color")
                            Text("Image").tag("image")
                        }
                        .pickerStyle(.segmented)

                        if backgroundStyle == "color" {
                            HStack(spacing: 10) {
                                ForEach(["#0A84FF","#5856D6","#FF2D55","#34C759","#FF9F0A"], id: \.self) { hex in
                                    Circle()
                                        .fill(Color(hex: hex) ?? .blue)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Circle().stroke(Color.white.opacity(colorHex == hex ? 0.9 : 0), lineWidth: 2)
                                        )
                                        .onTapGesture { colorHex = hex }
                                }
                                Spacer()
                                ColorPicker("", selection: Binding(
                                    get: { Color(hex: colorHex) ?? .blue },
                                    set: { colorHex = $0.hexString }
                                ))
                                .labelsHidden()
                            }
                        } else {
                            if let data = imageData, let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            } else {
                                Text("No image selected")
                                    .foregroundStyle(.secondary)
                            }

                            HStack(spacing: 12) {
                                Button {
                                    PHPhotoLibrary.requestAuthorization { status in
                                        if status == .authorized || status == .limited {
                                            DispatchQueue.main.async { showPhotoPicker = true }
                                        }
                                    }
                                } label: { labelButton("Choose Photo", system: "photo") }

                                Button {
                                    AVCaptureDevice.requestAccess(for: .video) { ok in
                                        if ok { DispatchQueue.main.async { showCamera = true } }
                                    }
                                } label: { labelButton("Camera", system: "camera") }
                            }
                        }
                    }
                    // MARK: Sharing
                    SettingsCard {
                        Toggle("Shared countdown", isOn: $isShared)
                        if isShared {
                            ForEach(friends) { friend in
                                let isSelected = Binding<Bool>(
                                    get: { selectedFriends.contains(friend.id) },
                                    set: { newVal in
                                        if newVal { selectedFriends.insert(friend.id) } else { selectedFriends.remove(friend.id) }
                                    }
                                )
                                Toggle(friend.name, isOn: isSelected)
                            }
                        }
                    }

                    // MARK: Reminders
                    SettingsCard {
                        HStack {
                            Text("Reminders")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("+ Add Reminder") {
                                NotificationManager.requestAuthorizationIfNeeded()
                                showReminderSheet = true
                            }
                        }

                        if !selectedReminders.isEmpty {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 8)], alignment: .leading, spacing: 8) {
                                ForEach(Array(selectedReminders).sorted { $0.rawValue < $1.rawValue }, id: \.self) { opt in
                                    HStack(spacing: 4) {
                                        Text(opt.label)
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                            .onTapGesture { selectedReminders.remove(opt) }
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .sheet(isPresented: $showReminderSheet) {
                        ReminderPicker(selections: $selectedReminders)
                    }

                    if showValidation && title.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Please enter a title.")
                            .foregroundStyle(.red)
                            .padding(.horizontal, 16)
                    }

                    if let existing {
                        SettingsCard {
                            Button {
                                existing.isArchived.toggle()
                                try? modelContext.save()
                                let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                updateWidgetSnapshot(afterSaving: all)
                                dismiss()
                            } label: {
                                Label(existing.isArchived ? "Unarchive Countdown" : "Archive Countdown",
                                      systemImage: existing.isArchived ? "tray.and.arrow.up" : "archivebox")
                            }
                        }

                        SettingsCard {
                            Button(role: .destructive) {
                                NotificationManager.cancelAll(for: existing.id)
                                modelContext.delete(existing)
                                try? modelContext.save()
                                let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                updateWidgetSnapshot(afterSaving: all)
                                dismiss()
                            } label: {
                                Label("Delete Countdown", systemImage: "trash")
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
            .background(theme.theme.background.ignoresSafeArea())
            .tint(theme.theme.accent)
            .navigationTitle(existing == nil ? "Add Countdown" : "Edit Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if let existing {
                            Button {
                                shareURL = CountdownShareService.exportURL(for: existing)
                                showShareSheet = shareURL != nil
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        Button(action: save) {
                            Image(systemName: "checkmark")
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showPhotoPicker) { PhotoPicker(imageData: $imageData) }
            .sheet(isPresented: $showCamera) { CameraPicker(imageData: $imageData) }
            .sheet(isPresented: $showShareSheet) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
            // Live preview & haptics
            .onChange(of: title) { _, new in
                previewTitle = new.isEmpty ? "Countdown" : new
            }
            .onChange(of: date) { _, new in
                previewDate = new
            }
            .onChange(of: colorHex, initial: false) { _, new in
                previewColorHex = new
                lightHaptic()
            }
            .onChange(of: imageData, initial: false) { _, new in
                previewImageData = new
                if new != nil { lightHaptic() }
            }
            .onAppear {
                if let existing {
                    title = existing.title
                    date = existing.targetDate
                    timeZoneID = existing.timeZoneID
                    titleFont = TitleFont(rawValue: existing.titleFontName) ?? .default
                    backgroundStyle = existing.backgroundStyle
                    colorHex = existing.backgroundColorHex ?? colorHex
                    imageData = existing.backgroundImageData
                    selectedReminders = Set(existing.reminderOffsets.compactMap { ReminderOption(rawValue: $0) })
                    isShared = existing.isShared
                    selectedFriends = Set(existing.sharedWith.map { $0.id })
                    previewTitle = existing.title
                    previewDate = existing.targetDate
                    previewColorHex = existing.backgroundColorHex ?? colorHex
                    previewImageData = existing.backgroundImageData
                } else {
                    NotificationManager.requestAuthorizationIfNeeded()
                    previewTitle = title
                    previewDate = date
                    previewColorHex = colorHex
                    previewImageData = imageData
                }
            }
        }
        .tint(theme.theme.accent)
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
            if let existing {
                existing.title = trimmed
                existing.targetDate = date
                existing.timeZoneID = timeZoneID
                existing.titleFontName = titleFont.rawValue
                existing.backgroundStyle = backgroundStyle
                existing.backgroundColorHex = colorHex
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
                    titleFontName: titleFont.rawValue,
                    backgroundStyle: backgroundStyle,
                    backgroundColorHex: colorHex,
                    backgroundImageData: imageData,
                    reminderOffsets: selectedReminders.map { $0.rawValue },
                    isShared: isShared,
                    sharedWith: friends.filter { selectedFriends.contains($0.id) }
                )
                modelContext.insert(cd)
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

    @ViewBuilder
    private func labelButton(_ title: String, system: String) -> some View {
        Label(title, systemImage: system)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.tint.opacity(0.15)))
    }

    private func lightHaptic() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - Reminder Picker Sheet

struct ReminderPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selections: Set<ReminderOption>
    @State private var temp: Set<ReminderOption>

    init(selections: Binding<Set<ReminderOption>>) {
        self._selections = selections
        self._temp = State(initialValue: selections.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 12)], spacing: 12) {
                    ForEach(ReminderOption.allCases) { option in
                        let isSel = temp.contains(option)
                        Text(option.label)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(isSel ? Color.accentColor.opacity(0.2) : Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSel ? Color.accentColor : .clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                if isSel { temp.remove(option) } else { temp.insert(option) }
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        selections = temp
                        dismiss()
                    }
                }
            }
        }
    }
}
