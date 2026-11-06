import BarrrCore
import SwiftUI

/// 管理視窗：App 共用的設定與結束
@MainActor
struct SettingsView: View {
    private static let width: CGFloat = 360

    @Binding var model: SettingsModel
    let quit: @MainActor () -> Void

    var body: some View {
        Form {
            Section {
                Toggle(isOn: Binding(get: { model.launchesAtLogin }, set: { model.setLaunchesAtLogin($0) })) {
                    Text(.settingsLaunchAtLogin)
                }
                if let failure = model.failure {
                    Text(failure)
                }
            } footer: {
                Text(.settingsReopenHint)
            }
            Section {
                Button(action: quit) {
                    Text(.settingsQuit)
                }
            }
        }
        .formStyle(.grouped)
        // 視窗高度貼合內容（grouped Form 預設會撐滿可用高度）
        .scrollDisabled(true)
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: Self.width)
    }
}
