import SwiftUI
import UIKit

struct PremiumPromoView: View {
    @Binding var show: Bool

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()

            VStack {
                Spacer()
                Image(systemName: "crown.fill")
                    .font(.system(size: UIFontMetrics(forTextStyle: .largeTitle).scaledValue(for: 80)))
                    .foregroundStyle(Color("Primary"))
                    .accessibilityHidden(true)
                Text("CouplesCount Premium")
                    .font(.largeTitle.bold())
                    .padding(.top, 12)
                Text("Unlock exclusive features and themes.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
        }
        .tint(Color("Foreground"))
        .safeAreaInset(edge: .top, alignment: .leading) {
            Button {
                withAnimation(.spring()) { show = false }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                    .accessibilityLabel("Close")
                    .accessibilityHint("Dismiss premium promotion")
            }
        }
    }
}
