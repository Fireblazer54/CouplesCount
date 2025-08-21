import SwiftUI

struct PremiumPromoView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Binding var show: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            theme.theme.background.ignoresSafeArea()

            VStack {
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(theme.theme.accent)
                Text("CouplesCount Premium")
                    .font(.largeTitle.bold())
                    .padding(.top, 12)
                Text("Unlock exclusive features and themes.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }

            Button {
                withAnimation(.spring()) { show = false }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .padding()
            }
        }
    }
}
