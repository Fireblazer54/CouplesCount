import SwiftUI

struct BlankDetailView: View {
    @EnvironmentObject private var theme: ThemeManager
    let onClose: () -> Void

    var body: some View {
        ZStack {
            theme.theme.background
                .ignoresSafeArea()
            Text("Detail (blank)")
                .font(.title2)
        }
        .overlay(alignment: .topLeading) {
            Button {
                Haptics.light()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    onClose()
                }

            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .padding()
                    .foregroundStyle(theme.theme.textPrimary)
            }
            .accessibilityLabel("Close")
        }
        .accessibilityAddTraits(.isModal)
    }
}

#Preview {
    BlankDetailView(onClose: {}).environmentObject(ThemeManager())

}
