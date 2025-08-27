import SwiftUI

struct PlaceholderPageView: View {
    @EnvironmentObject private var theme: ThemeManager
    let title: String

    var body: some View {
        ZStack {
            theme.theme.background
                .ignoresSafeArea()
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        PlaceholderPageView(title: "Preview")
            .environmentObject(ThemeManager())
    }
}
