import Foundation
import SwiftData

struct FriendService {
    static func addFriend(name: String, identifier: String, context: ModelContext) {
        let friend = Friend(name: name, identifier: identifier)
        context.insert(friend)
        try? context.save()
    }
}
