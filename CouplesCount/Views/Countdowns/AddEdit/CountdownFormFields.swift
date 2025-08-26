import SwiftUI

struct CountdownFormFields: View {
    @EnvironmentObject private var theme: ThemeManager
    @Binding var title: String
    @Binding var date: Date
    @Binding var timeZoneID: String
    @Binding var cardFontStyle: CardFontStyle

    var body: some View {
        SettingsCard {
            TextField("", text: $title, prompt: Text("Title (e.g., Anniversary)").foregroundStyle(theme.theme.textSecondary))
                .foregroundStyle(theme.theme.textPrimary)
                .textInputAutocapitalization(.words)
                .onSubmit { Haptics.light() }

            Picker("Font", selection: $cardFontStyle) {
                ForEach(CardFontStyle.allCases) { f in
                    Text(f.displayName).tag(f)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: cardFontStyle, initial: false) { _, _ in Haptics.light() }

            HStack {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .foregroundStyle(theme.theme.textPrimary)
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .foregroundStyle(theme.theme.textPrimary)
            }

            NavigationLink {
                TimeZonePickerView(selectedID: $timeZoneID)
            } label: {
                HStack {
                    Text("Time Zone")
                        .foregroundStyle(theme.theme.textPrimary)
                    Spacer()
                    Text(TimeZone(identifier: timeZoneID)?.identifier ?? "System")
                        .foregroundStyle(theme.theme.textSecondary)
                }
            }
        }
    }
}

