import BarrrCore
import NoSleepCore
import SwiftUI

/// 進入點（composition root）：建立 live 依賴
///
/// 每個功能一個選單列圖示；管理視窗在登入時自動開啟時不出現，從 Finder、Spotlight 開啟 App 時才顯示。
/// 沒有 Dock 圖示與 App 選單（Info.plist 的 LSUIElement）。
@main
@MainActor
struct BarrrApp: App {
    private static let settingsWindowID = "settings"

    @State private var settings = SettingsModel(loginItem: LiveLoginItemController())
    @State private var noSleep = NoSleepModel(awake: LiveAwakeController())

    var body: some Scene {
        Window(Text(.settingsTitle), id: Self.settingsWindowID) {
            SettingsView(model: $settings, quit: LiveApplication().quit)
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)

        MenuBarExtra {
            NoSleepMenu(model: $noSleep)
        } label: {
            Image(noSleep.activeMode == nil ? MenuBarSymbol.sleepAllowed : .awake)
                .opensSettingsOnReopen(windowID: Self.settingsWindowID, reopens: LiveAppReopen().reopens)
        }
    }
}
