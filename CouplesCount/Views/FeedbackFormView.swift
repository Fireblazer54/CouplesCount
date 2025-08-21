import SwiftUI

struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var theme: ThemeManager

    @State private var rating: Int = 3
    @State private var message: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("How can we improve?")
                    .font(.headline)

                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.title)
                            .foregroundStyle(.yellow)
                            .onTapGesture { rating = index }
                    }
                }
                .padding(.vertical)

                TextEditor(text: $message)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.secondary.opacity(0.2))
                    )

                Button("Submit") {
                    // TODO: Send feedback to backend
                    print("Feedback rating: \(rating), message: \(message)")
                    dismiss()
                }
                .frame(maxWidth: .infinity)
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
        .tint(theme.theme.accent)
    }
}

