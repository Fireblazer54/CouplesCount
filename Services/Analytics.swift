import Foundation

enum Analytics {
    static func log(_ event: String) {
        #if DEBUG
        print("Analytics event: \(event)")
        #endif
    }
}
