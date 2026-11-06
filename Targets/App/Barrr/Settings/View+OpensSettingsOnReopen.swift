import SwiftUI

extension View {
    /// 每次再次開啟 App 時打開管理視窗（已經開著就移到最前面）
    ///
    /// 掛在常駐的選單列圖示上：管理視窗關閉時它的 View 不存在，接不到事件；`.task` 也確保在 App 啟動完成後才開始接。
    func opensSettingsOnReopen(
        windowID: String,
        reopens: @escaping @MainActor () -> AsyncStream<Void>
    ) -> some View {
        modifier(OpensSettingsOnReopen(windowID: windowID, reopens: reopens))
    }
}

@MainActor
private struct OpensSettingsOnReopen: ViewModifier {
    let windowID: String
    let reopens: @MainActor () -> AsyncStream<Void>

    @Environment(\.openWindow) private var openWindow

    func body(content: Content) -> some View {
        content.task {
            for await _ in reopens() {
                openWindow(id: windowID)
            }
        }
    }
}
