import AppKit
import SwiftUI

/// 包裝 `NSApplication` 與 `ProcessInfo`：SwiftUI 沒有結束 App、取得 App 圖示與保持常駐的 API
@MainActor
struct LiveApplication {
    private static let keepRunningReason = "Barrr lives in the menu bar"

    /// App 圖示（AppIcon.icon 編譯後的結果）
    var icon: Image {
        Image(nsImage: NSApplication.shared.applicationIconImage)
    }

    /// 關閉自動終止：SwiftUI 在啟動過程中會啟用它，沒有開著視窗的 App 會被系統（loginwindow 的 TAL）悄悄結束；
    /// 必須在啟動完成後呼叫，在 App 的 init 呼叫會被 SwiftUI 之後的設定抵銷
    func keepRunning() {
        ProcessInfo.processInfo.disableAutomaticTermination(Self.keepRunningReason)
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }
}
