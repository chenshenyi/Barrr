import AppKit
import CoreServices

/// 「再次開啟 App」的事件（從 Finder、Spotlight 開啟已在執行的 Barrr）
///
/// AppKit 的做法（AppDelegate 的 `applicationShouldHandleReopen`、`NSAppleEventManager`）都需要 class；
/// 這裡改用 Apple Event 的 C API 安裝 reopen（`rapp`）的處理函式，它接受不捕捉任何值的 C 函式，不需要物件。
/// 處理函式只發出通知，由串流轉交給 SwiftUI。安裝後會取代 AppKit 預設的 reopen 處理。
/// 選單列 App（LSUIElement）再次開啟時系統不會把它切到前景，串流每次送出事件前先切到前景，視窗才會出現在最前面。
struct LiveAppReopen: Sendable {
    private static let reopened = Notification.Name("com.chenshenyi.Barrr.reopened")

    /// 第一次呼叫時安裝處理函式；必須在 App 啟動完成後呼叫，否則會被 AppKit 安裝的預設處理蓋掉
    @MainActor
    func reopens() -> AsyncStream<Void> {
        AEInstallEventHandler(AEEventClass(kCoreEventClass), AEEventID(kAEReopenApplication), { _, _, _ in
            NotificationCenter.default.post(name: LiveAppReopen.reopened, object: nil)
            return OSErr(noErr)
        }, nil, false)
        return AsyncStream { continuation in
            let task = Task { @MainActor in
                for await _ in NotificationCenter.default.notifications(named: Self.reopened) {
                    NSApplication.shared.activate()
                    continuation.yield()
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
