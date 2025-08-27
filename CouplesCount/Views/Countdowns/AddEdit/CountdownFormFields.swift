import SwiftUI

struct CountdownFormFields: View {
    @Environment(\.theme) private var theme
    @Binding var title: String
    @Binding var date: Date
    @Binding var timeZoneID: String
    @Binding var cardFontStyle: CardFontStyle

    var body: some View {
        SettingsCard {
            TextField("", text: $title, prompt: Text("Title (e.g., Anniversary)").foregroundStyle(theme.color(.MutedForeground)))
                .foregroundStyle(theme.color(.Foreground))
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
                    .foregroundStyle(theme.color(.Foreground))
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .foregroundStyle(theme.color(.Foreground))
            }

            NavigationLink {
                TimeZonePickerView(selectedID: $timeZoneID)
            } label: {
                HStack {
                    Text("Time Zone")
                        .foregroundStyle(theme.color(.Foreground))
                    Spacer()
                    Text(TimeZone(identifier: timeZoneID)?.identifier ?? "System")
                        .foregroundStyle(theme.color(.MutedForeground))
                }
            }
        }
    }
}

