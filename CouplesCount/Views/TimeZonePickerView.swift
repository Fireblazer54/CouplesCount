import SwiftUI

struct TimeZonePickerView: View {
    @Binding var selectedID: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(TimeZone.knownTimeZoneIdentifiers, id: \.self) { id in
            HStack {
                Text(id)
                Spacer()
                if id == selectedID {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedID = id
                dismiss()
            }
        }
        .navigationTitle("Time Zone")
        .navigationBarTitleDisplayMode(.inline)
    }
}
