import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @State private var importError: String?

    var body: some View {
        TabView {
            CountdownListView()
                .tabItem {
                    Label("Countdowns", systemImage: "timer")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(theme.theme.textPrimary)
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

