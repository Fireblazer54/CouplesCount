import SwiftUI
import SwiftData

struct CountdownDetailHeroView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var pro: ProStatusProvider

    let countdown: Countdown
    let namespace: Namespace.ID
    var dismiss: () -> Void

    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()
                .onTapGesture { close() }
                .transition(.opacity)

            CountdownDetailContent(countdown: countdown, namespace: namespace, onClose: close)
                .environmentObject(theme)
                .environmentObject(pro)
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = max(value.translation.height, 0)
                        }
                        .onEnded { value in
                            if value.translation.height > 120 {
                                close()
                            } else {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .transition(.identity)
        .onAppear { Haptics.medium() }
    }

    private func close() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            dismiss()
        }
        Haptics.light()
    }
}

