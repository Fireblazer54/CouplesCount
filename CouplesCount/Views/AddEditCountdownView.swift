import SwiftUI
import SwiftData
import PhotosUI
import AVFoundation

// MARK: - Reminder presets

enum ReminderPreset: String, CaseIterable, Identifiable {
    case none, h1, h2, d1, d2, d3
    var id: String { rawValue }
    var title: String {
        switch self {
        case .none: return "No reminder"
        case .h1:   return "1 hour before"
        case .h2:   return "2 hours before"
        case .d1:   return "1 day before"
        case .d2:   return "2 days before"
        case .d3:   return "3 days before"
        }
    }
    var minutes: Int? {
        switch self {
        case .none: return nil
        case .h1:   return 60
        case .h2:   return 120
        case .d1:   return 60*24
        case .d2:   return 60*48
        case .d3:   return 60*72
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
    @State private var includeTime: Bool = false
    @State private var timeZoneID: String = TimeZone.current.identifier

    // Background selection
    @State private var backgroundStyle: String = "color" // "color" | "image"
    @State private var colorHex: String = "#0A84FF"
    @State private var imageData: Data? = nil
    @State private var showPhotoPicker = false
    @State private var showCamera = false

    // Reminder
    @State private var preset: ReminderPreset = .none

    // UX
    @State private var showValidation = false
    @State private var saveError: String?

    init(existing: Countdown? = nil) { self.existing = existing }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    // MARK: Swipable widget preview (square → rectangular)
                    TabView {
                        // Square
                        WidgetPreview(
                            title: title.isEmpty ? "Countdown" : title,
                            targetDate: date,
                            tzID: timeZoneID,
                            backgroundStyle: backgroundStyle,
                            bgColorHex: colorHex,
                            imageData: imageData
                        )
                        .frame(width: 160, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .padding(.vertical, 8)

                        // Rectangular
                        WidgetPreview(
                            title: title.isEmpty ? "Countdown" : title,
                            targetDate: date,
                            tzID: timeZoneID,
                            backgroundStyle: backgroundStyle,
                            bgColorHex: colorHex,
                            imageData: imageData
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
                        Text("Details")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        TextField("Title (e.g., Anniversary)", text: $title)
                            .textInputAutocapitalization(.words)

                        Toggle("Include time", isOn: $includeTime)

                        DatePicker(
                            "Date",
                            selection: $date,
                            displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date]
                        )

                        HStack {
                            Text("Time Zone")
                            Spacer()
                            Text(TimeZone(identifier: timeZoneID)?.identifier ?? "System")
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { timeZoneID = TimeZone.current.identifier }
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

                    // MARK: Reminder
                    SettingsCard {
                        Text("Reminder")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Picker("Notify me", selection: $preset) {
                            ForEach(ReminderPreset.allCases) { p in
                                Text(p.title).tag(p)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: preset, initial: false) { _, _ in
                            NotificationManager.requestAuthorizationIfNeeded()
                        }
                    }

                    if showValidation && title.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Please enter a title.")
                            .foregroundStyle(.red)
                            .padding(.horizontal, 16)
                    }

                    if let existing {
                        SettingsCard {
                            Button(role: .destructive) {
                                NotificationManager.cancelAll(for: existing.id)
                                modelContext.delete(existing)
                                try? modelContext.save()
                                dismiss()
                            } label: {
                                Label("Delete Countdown", systemImage: "trash")
                            }
                        }
                    }

                    // MARK: Big Save at bottom
                    SettingsCard {
                        Button(action: save) {
                            Label("Save", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(theme.theme.accent)
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 0)
                    .padding(.bottom, 24)
                }
                .padding(.top, 14)
                .padding(.horizontal, 16)
            }
            .background(theme.theme.background.ignoresSafeArea())
            .tint(theme.theme.accent)
            .navigationTitle(existing == nil ? "Add Countdown" : "Edit Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .bold()
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showPhotoPicker) { PhotoPicker(imageData: $imageData) }
            .sheet(isPresented: $showCamera) { CameraPicker(imageData: $imageData) }
            .onAppear {
                if let existing {
                    title = existing.title
                    date = existing.targetDate
                    timeZoneID = existing.timeZoneID
                    includeTime = hasTime(existing.targetDate)
                    backgroundStyle = existing.backgroundStyle
                    colorHex = existing.backgroundColorHex ?? colorHex
                    imageData = existing.backgroundImageData
                    preset = Self.preset(from: existing.reminderOffsetMinutes)
                } else {
                    NotificationManager.requestAuthorizationIfNeeded()
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
                existing.backgroundStyle = backgroundStyle
                existing.backgroundColorHex = colorHex
                existing.backgroundImageData = imageData
                existing.reminderOffsetMinutes = preset.minutes
                NotificationManager.cancelAll(for: existing.id)
                if preset.minutes != nil { NotificationManager.scheduleReminder(for: existing) }
            } else {
                let cd = Countdown(
                    title: trimmed,
                    targetDate: date,
                    timeZoneID: timeZoneID,
                    backgroundStyle: backgroundStyle,
                    backgroundColorHex: colorHex,
                    backgroundImageData: imageData,
                    reminderOffsetMinutes: preset.minutes
                )
                modelContext.insert(cd)
                if preset.minutes != nil { NotificationManager.scheduleReminder(for: cd) }
            }

            try modelContext.save()
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }

    // MARK: Helpers

    private static func preset(from minutes: Int?) -> ReminderPreset {
        switch minutes {
        case nil: return .none
        case 60:  return .h1
        case 120: return .h2
        case 1440: return .d1
        case 2880: return .d2
        case 4320: return .d3
        default:  return .none
        }
    }

    private func hasTime(_ d: Date) -> Bool {
        let c = Calendar.current.dateComponents([.hour,.minute,.second], from: d)
        return (c.hour ?? 0) != 0 || (c.minute ?? 0) != 0 || (c.second ?? 0) != 0
    }

    @ViewBuilder
    private func labelButton(_ title: String, system: String) -> some View {
        Label(title, systemImage: system)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.tint.opacity(0.15)))
    }
}
