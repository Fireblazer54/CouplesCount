import Foundation
import Combine

protocol ProStatusProviding {
    var isPro: Bool { get }
}

@MainActor
final class ProStatusProvider: ObservableObject, ProStatusProviding {
#if DEBUG
    @Published var debugIsPro = false
#endif
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
