import Foundation
import UIKit

struct CountdownDTO: Codable, Identifiable {
    var id: UUID
    var title: String
    var targetUTC: Date
    var timeZoneID: String
    var includeTime: Bool
    var colorTheme: String
    var hasImage: Bool
    var thumbnailBase64: String?
    var lastEdited: Date
}

enum WidgetSnapshotStore {
    static var fileURL: URL {
        AppGroup.containerURL.appendingPathComponent("widget-countdowns.json")
    }

    static func write(_ countdowns: [CountdownDTO]) {
        do {
            let data = try JSONEncoder().encode(countdowns)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("WidgetSnapshotStore write error: \(error)")
        }
    }

    static func read() -> [CountdownDTO] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        do {
            return try JSONDecoder().decode([CountdownDTO].self, from: data)
        } catch {
            print("WidgetSnapshotStore read error: \(error)")
            return []
        }
    }
}

enum SnapshotThumb {
    static func make(from data: Data) -> String? {
        guard let image = UIImage(data: data) else { return nil }
        let target: CGFloat = 256
        let maxDim = max(image.size.width, image.size.height)
        let scale = min(target / maxDim, 1)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let jpeg = resized?.jpegData(compressionQuality: 0.7) else { return nil }
        return jpeg.base64EncodedString()
    }
}

func updateWidgetSnapshot(afterSaving countdowns: [Countdown]) {
    DispatchQueue.global(qos: .background).async {
        let upcoming = countdowns
            .sorted { $0.targetUTC < $1.targetUTC }
            .prefix(5)
        let dtos = upcoming.map { cd in
            CountdownDTO(
                id: cd.id,
                title: cd.title,
                targetUTC: cd.targetUTC,
                timeZoneID: cd.timeZoneID,
                includeTime: cd.includeTime,
                colorTheme: cd.colorTheme,
                hasImage: cd.hasImage,
                thumbnailBase64: cd.imageData.flatMap { SnapshotThumb.make(from: $0) },
                lastEdited: cd.lastEdited
            )
        }
        WidgetSnapshotStore.write(Array(dtos))
        AppGroup.logonce("snapshot-write")
    }
}

