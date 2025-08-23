import SwiftUI

struct TreeGrowthView: View {
    var progress: Double
    @State private var animated: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.brown)
                    .frame(width: geo.size.width * 0.1,
                           height: geo.size.height * CGFloat(animated))
                Circle()
                    .fill(Color.green)
                    .frame(width: geo.size.width * 0.6,
                           height: geo.size.width * 0.6)
                    .scaleEffect(animated)
                    .offset(y: -geo.size.height * CGFloat(animated))
                if animated >= 1 {
                    Text("🎉")
                        .font(.largeTitle)
                        .offset(y: -geo.size.height * 0.8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 1.0), value: animated)
        }
        .onAppear { animated = progress }
        .onChange(of: progress) { _, newValue in
            animated = newValue
        }
    }
}

#Preview {
    TreeGrowthView(progress: 0.5)
        .frame(width: 100, height: 100)
}
