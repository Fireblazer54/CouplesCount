import SwiftUI

extension View {
    @ViewBuilder
    func ifLet<A, B>(_ a: A?, _ b: B?, transform: (Self, A, B) -> some View) -> some View {
        if let a, let b {
            transform(self, a, b)
        } else {
            self
        }
    }
}

