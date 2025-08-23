import SwiftUI

struct AboutLegalView: View {
    @EnvironmentObject private var theme: ThemeManager
    let privacyURL: URL
    let termsURL: URL

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Link(destination: privacyURL) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
                Link(destination: termsURL) {
                    Label("Terms of Service", systemImage: "doc.text")
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(theme.theme.background.ignoresSafeArea())
        .tint(theme.theme.accent)
        .navigationTitle("About & Legal")
    }
}
