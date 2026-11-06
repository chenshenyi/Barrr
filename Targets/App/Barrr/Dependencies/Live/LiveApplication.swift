import AppKit

/// 包裝 `NSApplication`：SwiftUI 沒有結束 App 的 API
@MainActor
struct LiveApplication {
    func quit() {
        NSApplication.shared.terminate(nil)
    }
}
