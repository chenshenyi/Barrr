import NoSleepCore
import SwiftUI

/// 不休眠圖示的選單：只有兩種方式，勾選中的再點一次即恢復休眠；失敗時才多一行原因
@MainActor
struct NoSleepMenu: View {
    @Binding var model: NoSleepModel

    var body: some View {
        ForEach(AwakeMode.allCases, id: \.self) { mode in
            Toggle(isOn: Binding(get: { model.activeMode == mode }, set: { _ in model.toggle(mode) })) {
                Text(mode)
            }
        }
        if let failure = model.failure {
            Divider()
            Text(failure)
        }
    }
}
