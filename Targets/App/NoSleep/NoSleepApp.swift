import NoSleepCore
import SwiftUI

/// 進入點（composition root）：建立 live 依賴；只有選單列圖示，沒有視窗與 Dock 圖示（Info.plist 的 LSUIElement）
@main
@MainActor
struct NoSleepApp: App {
    @State private var model = NoSleepModel(awake: LiveAwakeController(), loginItem: LiveLoginItemController())

    var body: some Scene {
        MenuBarExtra {
            NoSleepMenu(model: $model, quit: LiveApplication().quit)
        } label: {
            Image(model.activeMode == nil ? MenuBarSymbol.sleepAllowed : .awake)
        }
    }
}
