import Foundation
import Combine

@MainActor
protocol ProStatusProviding {
    var isPro: Bool { get }
    var isProPublished: Bool { get }
}

@MainActor
final class ProStatusProvider: ObservableObject, ProStatusProviding {
#if DEBUG
    @Published var debugIsPro = false {
        didSet { isProPublished = isPro }
    }
#endif

    @Published private(set) var isProPublished: Bool

    init() {
        isProPublished = false
        isProPublished = isPro
    }

    var isPro: Bool {
#if DEBUG
        if debugIsPro { return true }
#endif
        switch AppConfig.entitlementsMode {
        case .freeForAll:
            return true
        case .live:
            return false // Stub: wire to StoreKit later
        }
    }
}
