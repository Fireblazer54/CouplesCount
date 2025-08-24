import SwiftUI

struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager

    @State private var rating: Int = 3
    @State private var message: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("I'm a solo dev and every review means a lot. I read every suggestion, so please let me know how I can improve.")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                TextEditor(text: $message)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.theme.outline)
                    )

                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundStyle(theme.theme.accent)
                            .onTapGesture { rating = index }
                    }
                }
                .padding(.vertical)

                Button("Submit") {
                    // TODO: Send feedback to backend
                    print("Feedback rating: \(rating), message: \(message)")
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .background(theme.theme.backgroundGradient.ignoresSafeArea())
        .tint(theme.theme.primary)
    }
}

