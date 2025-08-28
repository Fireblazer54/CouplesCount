import SwiftUI

struct BlankDetailView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("Background")
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
                    .foregroundStyle(Color("Foreground"))
            }
        }
    }
}

#Preview {
    BlankDetailView()
}
