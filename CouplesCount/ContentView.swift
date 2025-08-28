import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var importError: String?

    var body: some View {
        ZStack {
            Theme.backgroundGradient
                .ignoresSafeArea()

            CountdownListView()
        }
        .tint(Theme.accent)
        .onOpenURL { url in
            do {
                try CountdownShareService.importCountdown(from: url, context: modelContext)
            } catch {
                importError = error.localizedDescription
            }

        }
        .alert("Import Failed", isPresented: Binding(get: { importError != nil }, set: { if !$0 { importError = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importError ?? "")
        }
    }
}

