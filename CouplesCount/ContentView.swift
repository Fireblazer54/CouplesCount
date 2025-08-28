import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var importError: String?

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color("Background"), Color("Primary")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

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
            .tint(Color("Primary"))
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
}

