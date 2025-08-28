import Foundation
import Combine

@MainActor
final class NowProvider: ObservableObject {
    @Published private(set) var now: Date = Date()
    private var cancellable: AnyCancellable?

    init() {
        cancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.now = date
            }
    }

    deinit {
        cancellable?.cancel()
    }
}
