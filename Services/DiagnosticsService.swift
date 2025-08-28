import Foundation
import CloudKit
import UserNotifications
import SwiftUI
import WidgetKit
import SwiftData

struct DiagnosticsReport: Codable {
    struct CloudKitResult: Codable {
        let status: String
    }
    struct NotificationsResult: Codable {
        let authorizationStatus: String
    }
    struct PermissionsResult: Codable {
        let photoLibrary: Bool
        let camera: Bool
    }
    struct AccessibilityResult: Codable {
        let missingLabels: [String]
    }
    struct DynamicTypeResult: Codable {
        let hardCodedFonts: [String]
    }
    struct WidgetResult: Codable {
        let reloadSucceeded: Bool
        let hasSharedData: Bool
    }
    struct EntitlementsResult: Codable {
        let mode: String
        let isPro: Bool
        let countdownCount: Int
        let freeMaxCountdowns: Int
        let withinLimit: Bool
    }

    let cloudKit: CloudKitResult
    let notifications: NotificationsResult
    let permissions: PermissionsResult
    let accessibility: AccessibilityResult
    let dynamicType: DynamicTypeResult
    let widgets: WidgetResult
    let entitlements: EntitlementsResult

    var summary: String {
        [
            "CloudKit: \(cloudKit.status)",
            "Notifications: \(notifications.authorizationStatus)",
            "Photo permission: \(permissions.photoLibrary)",
            "Camera permission: \(permissions.camera)",
            "Missing accessibility labels: \(accessibility.missingLabels.count)",
            "Hard-coded fonts: \(dynamicType.hardCodedFonts.count)",
            "Widgets reload: \(widgets.reloadSucceeded)",
            "Entitlements mode: \(entitlements.mode)",
            "Countdowns: \(entitlements.countdownCount)/\(entitlements.freeMaxCountdowns)"
        ].joined(separator: "\n")
    }

    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
        return obj
    }
}

enum DiagnosticsService {
    @MainActor
    static func runAllChecks() async -> DiagnosticsReport {
        async let ck = checkCloudKit()
        async let notifications = checkNotifications()
        let permissions = checkInfoPlist()
        let accessibility = checkAccessibility()
        let dynamicType = checkDynamicType()
        async let widgets = checkWidgets()
        let entitlements = await checkEntitlements()

        return DiagnosticsReport(
            cloudKit: await ck,
            notifications: await notifications,
            permissions: permissions,
            accessibility: accessibility,
            dynamicType: dynamicType,
            widgets: await widgets,
            entitlements: entitlements
        )
    }

    private static func checkCloudKit() async -> DiagnosticsReport.CloudKitResult {
        do {
            let status = try await CKContainer.default().accountStatus()
            return .init(status: String(describing: status))
        } catch {
            return .init(status: "error: \(error.localizedDescription)")
        }
    }

    private static func checkNotifications() async -> DiagnosticsReport.NotificationsResult {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: .init(authorizationStatus: String(describing: settings.authorizationStatus)))
            }
        }
    }

    private static func checkInfoPlist() -> DiagnosticsReport.PermissionsResult {
        let dict = Bundle.main.infoDictionary ?? [:]
        let photo = dict["NSPhotoLibraryUsageDescription"] != nil
        let camera = dict["NSCameraUsageDescription"] != nil
        return .init(photoLibrary: photo, camera: camera)
    }

    @MainActor
    private static func checkAccessibility() -> DiagnosticsReport.AccessibilityResult {
        var missing: [String] = []
        let topViews: [AnyView] = [
            AnyView(CountdownListView()),
            AnyView(SettingsView())
        ]
        for view in topViews {
            let mirror = Mirror(reflecting: view)
            for child in mirror.children {
                if String(describing: child.value).contains("Button") {
                    // Naive placeholder check
                    if !(String(describing: child.value).contains("accessibilityLabel") ||
                         String(describing: child.value).contains("accessibilityIdentifier")) {
                        missing.append(String(describing: type(of: child.value)))
                    }
                }
            }
        }
        return .init(missingLabels: missing)
    }

    @MainActor
    private static func checkDynamicType() -> DiagnosticsReport.DynamicTypeResult {
        var hard: [String] = []
        let views: [Any] = [CountdownListView(), SettingsView()]
        for view in views {
            let desc = String(describing: view)
            if desc.contains("Font.system(size:") {
                hard.append(String(describing: type(of: view)))
            }
        }
        return .init(hardCodedFonts: hard)
    }

    private static func checkWidgets() async -> DiagnosticsReport.WidgetResult {
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        let sharedURL = AppGroup.containerURL
        let hasShared = FileManager.default.fileExists(atPath: sharedURL.path)
        return .init(reloadSucceeded: true, hasSharedData: hasShared)
#else
        return .init(reloadSucceeded: false, hasSharedData: false)
#endif
    }

    @MainActor
    private static func checkEntitlements() -> DiagnosticsReport.EntitlementsResult {
        let mode = String(describing: AppConfig.entitlementsMode)
        let ent = Entitlements.current
        let context = Persistence.container.mainContext
        let all = (try? context.fetch(FetchDescriptor<Countdown>())) ?? []
        let count = all.count
        let within = ent.isUnlimited || count < AppLimits.freeMaxCountdowns
        return .init(
            mode: mode,
            isPro: ent.isPro,
            countdownCount: count,
            freeMaxCountdowns: AppLimits.freeMaxCountdowns,
            withinLimit: within
        )
    }
}

