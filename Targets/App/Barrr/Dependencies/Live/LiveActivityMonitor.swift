import AppKit

/// 打開系統的「活動監視器」
@MainActor
struct LiveActivityMonitor {
    private static let bundleIdentifier = "com.apple.ActivityMonitor"

    func open() {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: Self.bundleIdentifier) else {
            return
        }
        NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
    }
}
