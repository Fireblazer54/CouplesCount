import SwiftUI

struct PlaceholderPageView: View {
    let title: String

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        PlaceholderPageView(title: "Preview")
    }
}
