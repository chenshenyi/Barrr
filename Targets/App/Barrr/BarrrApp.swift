import BarrrCore
import NoSleepCore
import PerformanceCore
import SwiftUI

/// 進入點（composition root）：建立 live 依賴
///
/// 每個顯示中的工具一個選單列圖示；管理視窗（Settings scene）啟動時不出現，App 已在執行時從 Finder、Spotlight 再開啟一次才顯示。
/// 沒有 Dock 圖示與 App 選單（Info.plist 的 LSUIElement）。
@main
@MainActor
struct BarrrApp: App {
    @State private var settings = SettingsModel(
        loginItem: LiveLoginItemController(),
        layoutStorage: UserDefaultsToolLayoutStorage(center: UserDefaultsCenter(storage: LiveUserDefaultsStorage()))
    )
    @State private var noSleep = NoSleepModel(awake: LiveAwakeController())
    @State private var performance: PerformanceSnapshot?

    var body: some Scene {
        // 選單列的位置：順序由 ToolLayout 決定，不靠系統記住的位置；位置數量等於 Tool 的數量。
        // 先宣告的位置在選單列的右邊，因此第 i 個位置顯示倒數第 i 個顯示中的工具，清單的第一個在最左邊
        toolSlot(0)
        toolSlot(1)

        // 管理視窗用 Settings scene 而不是 Window：有 Window scene 時，SwiftUI 會在最後一個視窗關閉
        // （包括以 Escape 關閉選單）時結束 App；Settings 不算 App 的視窗，選單列 App 才能常駐
        Settings {
            SettingsView(
                model: $settings,
                appIcon: LiveApplication().icon,
                setVisible: setVisible,
                quit: LiveApplication().quit
            )
            .containerBackground(.clear, for: .window)
            // Settings scene 的標題列會顯示「Barrr 設定」，與視窗內的標題重複
            .toolbar(removing: .title)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }

    private func toolSlot(_ index: Int) -> some Scene {
        MenuBarExtra(isInserted: Binding(
            get: { tool(at: index) != nil },
            // 使用者以 ⌘ 拖曳把圖示拖出選單列時隱藏該工具
            set: { inserted in
                if !inserted, let tool = tool(at: index) {
                    setVisible(tool, false)
                }
            }
        )) {
            if let tool = tool(at: index) {
                ToolMenu(
                    tool: tool,
                    noSleep: $noSleep,
                    performance: performance,
                    openActivityMonitor: LiveActivityMonitor().open
                )
            }
        } label: {
            if let tool = tool(at: index) {
                ToolLabel(
                    tool: tool,
                    noSleep: noSleep,
                    performance: performance,
                    sampler: LivePerformanceSampler.make(),
                    reportPerformance: { performance = $0 }
                )
                .opensSettingsOnReopen(LiveAppReopen().reopens)
                .keepsAppRunning(LiveApplication().keepRunning)
            }
        }
    }

    /// 第 `index` 個位置（由右往左數）的工具
    private func tool(at index: Int) -> Tool? {
        let tools = Array(settings.layout.visibleTools.reversed())
        return tools.indices.contains(index) ? tools[index] : nil
    }

    /// 隱藏不休眠時一併恢復休眠，不留下看不到的不休眠
    private func setVisible(_ tool: Tool, _ visible: Bool) {
        settings.setVisible(tool, visible)
        if !settings.layout.isVisible(.noSleep) {
            noSleep.allowSleep()
        }
    }
}
