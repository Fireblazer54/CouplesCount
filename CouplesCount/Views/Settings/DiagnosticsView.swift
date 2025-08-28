#if DEBUG
import SwiftUI
import UIKit

struct DiagnosticsView: View {
    // Injectable diagnostics service for easier testing
    var service: DiagnosticsService.Type = DiagnosticsService.self

    @State private var report: DiagnosticsReport?

    var body: some View {
        NavigationStack {
            List {
                if let report {
                    ForEach(items(from: report)) { item in
                        HStack {
                            Circle()
                                .fill(item.status.color)
                                .frame(width: 10, height: 10)
                            Text(item.title)
                            Spacer()
                            Text(item.detail)
                                .foregroundStyle(Color("Secondary"))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Diagnostics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if report != nil {
                        Button("Copy Report", action: copyReport)
                    }
                }
            }
        }
        .task {
            report = await service.runAllChecks()
        }
    }

    private func copyReport() {
        guard
            let report,
            let data = try? JSONEncoder().encode(report),
            let json = String(data: data, encoding: .utf8)
        else { return }
        UIPasteboard.general.string = json
    }

    private struct DiagnosticItem: Identifiable {
        enum Status {
            case success, warning, failure
            var color: Color {
                switch self {
                case .success: return .green
                case .warning: return .yellow
                case .failure: return .red
                }
            }
        }
        let id = UUID()
        let title: String
        let detail: String
        let status: Status
    }

    private func items(from report: DiagnosticsReport) -> [DiagnosticItem] {
        [
            .init(title: "CloudKit", detail: report.cloudKit.status, status: report.cloudKit.status == "available" ? .success : .warning),
            .init(title: "Notifications", detail: report.notifications.authorizationStatus, status: status(for: report.notifications.authorizationStatus)),
            .init(title: "Photo permission string", detail: report.permissions.photoLibrary ? "present" : "missing", status: report.permissions.photoLibrary ? .success : .failure),
            .init(title: "Camera permission string", detail: report.permissions.camera ? "present" : "missing", status: report.permissions.camera ? .success : .failure),
            .init(title: "Accessibility labels", detail: "\(report.accessibility.missingLabels.count) missing", status: report.accessibility.missingLabels.isEmpty ? .success : .warning),
            .init(title: "Hard-coded fonts", detail: "\(report.dynamicType.hardCodedFonts.count) found", status: report.dynamicType.hardCodedFonts.isEmpty ? .success : .warning),
            .init(title: "Widget reload", detail: report.widgets.reloadSucceeded ? "succeeded" : "failed", status: report.widgets.reloadSucceeded ? .success : .failure),
            .init(title: "Shared widget data", detail: report.widgets.hasSharedData ? "exists" : "missing", status: report.widgets.hasSharedData ? .success : .warning),
            .init(title: "Entitlements", detail: "mode: \(report.entitlements.mode)", status: .success),
            .init(title: "Within limit", detail: "\(report.entitlements.countdownCount)/\(report.entitlements.freeMaxCountdowns)", status: report.entitlements.withinLimit ? .success : .warning)
        ]
    }

    private func status(for authorization: String) -> DiagnosticItem.Status {
        switch authorization.lowercased() {
        case "authorized": return .success
        case "denied": return .failure
        default: return .warning
        }
    }
}
#endif
