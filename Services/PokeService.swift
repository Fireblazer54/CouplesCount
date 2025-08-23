import Foundation

protocol PokeServiceProtocol {
    static func sendPoke(countdownID: UUID, userID: UUID)
}

enum PokeService: PokeServiceProtocol {
    static func sendPoke(countdownID: UUID, userID: UUID) {
        // Stub implementation
        #if DEBUG
        print("Poke to \(userID) for countdown \(countdownID)")
        #endif
    }
}
