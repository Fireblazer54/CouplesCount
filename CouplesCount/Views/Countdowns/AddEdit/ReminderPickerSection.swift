import SwiftUI

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

struct ReminderPickerSection: View {
    @Binding var selectedReminders: Set<ReminderOption>
    @State private var showReminderSheet = false

    var body: some View {
        SettingsCard {
            HStack {
                Text("Reminders")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("Secondary"))
                Spacer()
                Button("+ Add Reminder") {
                    NotificationManager.requestAuthorizationIfNeeded()
                    showReminderSheet = true
                }
                .foregroundStyle(Color("Foreground"))
            }

            if !selectedReminders.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 8)], alignment: .leading, spacing: 8) {
                    ForEach(Array(selectedReminders).sorted { $0.rawValue < $1.rawValue }, id: \.self) { opt in
                        HStack(spacing: 4) {
                            Text(opt.label)
                                .foregroundStyle(Color("Foreground"))
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color("Secondary"))
                                .onTapGesture { selectedReminders.remove(opt) }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("Foreground").opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(.top, 4)
            }
        }
        .sheet(isPresented: $showReminderSheet) {
            ReminderPicker(selections: $selectedReminders)
        }
    }
}

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
                            .foregroundStyle(Color("Foreground"))
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(isSel ? Color("Foreground").opacity(0.2) : Color("Foreground").opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSel ? Color("Foreground") : .clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                if isSel { temp.remove(option) } else { temp.insert(option) }
                            }
                    }
                }
                .padding()
            }
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .tint(Theme.accent)
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.backgroundTop, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Reminders")
                        .foregroundStyle(Color("Foreground"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        selections = temp
                        dismiss()
                    }
                    .foregroundStyle(Color("Foreground"))
                }
            }
        }
    }
}

