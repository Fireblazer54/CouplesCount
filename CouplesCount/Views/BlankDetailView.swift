import SwiftUI

struct BlankDetailView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            theme.theme.background
                .ignoresSafeArea()
            Text("Detail (blank)")
                .font(.title2)
        }
        .overlay(alignment: .topLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .padding()
                    .foregroundStyle(theme.theme.textPrimary)
            }
        }
    }
}

#Preview {
    BlankDetailView().environmentObject(ThemeManager())
}
