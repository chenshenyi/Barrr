import NoSleepCore
import SwiftUI

/// 點選單列圖示後的選單：兩種不休眠方式（勾選中的再點一次即恢復）、恢復休眠、失敗原因、登入時開啟、結束
@MainActor
struct NoSleepMenu: View {
    private static let quitKey: KeyEquivalent = "q"

    @Binding var model: NoSleepModel
    let quit: @MainActor () -> Void

    var body: some View {
        ForEach(AwakeMode.allCases, id: \.self) { mode in
            Toggle(isOn: Binding(get: { model.activeMode == mode }, set: { _ in model.toggle(mode) })) {
                Text(mode)
            }
        }
        Divider()
        Button {
            model.resume()
        } label: {
            Text(.menuResume)
        }
        .disabled(model.activeMode == nil)
        if let failure = model.failure {
            Divider()
            Text(failure)
        }
        Divider()
        Toggle(isOn: Binding(get: { model.launchesAtLogin }, set: { model.setLaunchesAtLogin($0) })) {
            Text(.menuLaunchAtLogin)
        }
        Button(action: quit) {
            Text(.menuQuit)
        }
        .keyboardShortcut(Self.quitKey)
    }
}
