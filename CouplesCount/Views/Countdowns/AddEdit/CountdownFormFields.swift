import SwiftUI

struct CountdownFormFields: View {
    @Binding var title: String
    @Binding var date: Date
    @Binding var timeZoneID: String
    var showValidation: Bool

    var body: some View {
        SettingsCard {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "textformat")
                        .foregroundStyle(Color("Secondary"))
                        .frame(width: 24)
                    TextField("Title", text: $title)
                        .foregroundStyle(Color("Foreground"))
                        .textInputAutocapitalization(.words)
                        .onSubmit { Haptics.light() }
                }
                .frame(minHeight: 44)

                if showValidation && title.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Please enter a title")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                }

                Divider().padding(.vertical, 8)

                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color("Secondary"))
                        .frame(width: 24)
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .foregroundStyle(Color("Foreground"))
                    Spacer()
                    DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .foregroundStyle(Color("Foreground"))
                }
                .frame(minHeight: 44)

                Divider().padding(.vertical, 8)

                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .foregroundStyle(Color("Secondary"))
                        .frame(width: 24)
                    NavigationLink {
                        TimeZonePickerView(selectedID: $timeZoneID)
                    } label: {
                        HStack {
                            Text(TimeZone(identifier: timeZoneID)?.identifier ?? "System")
                                .foregroundStyle(Color("Secondary"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote)
                                .foregroundStyle(Color("Secondary"))
                        }
                    }
                }
                .frame(minHeight: 44)
            }
        }
    }
}

