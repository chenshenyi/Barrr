import BarrrCore
import SwiftUI

/// App 共用的設定：登入時開啟
@MainActor
struct GeneralSection: View {
    @Binding var launchesAtLogin: Bool
    let failure: LoginItemError?

    var body: some View {
        SettingsSection(title: Text(.settingsGeneralHeader), footer: Text(.settingsReopenHint)) {
            VStack(alignment: .leading) {
                HStack {
                    Text(.settingsLaunchAtLogin)
                    Spacer()
                    // 開關靠右，與工具清單的開關對齊
                    Toggle(isOn: $launchesAtLogin) {
                        Text(.settingsLaunchAtLogin)
                    }
                    .toggleStyle(.switch)
                    .labelsHidden()
                }
                if let failure {
                    Text(failure)
                        .font(.caption)
                }
            }
            .padding(SettingsMetrics.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular, in: .rect(cornerRadius: SettingsMetrics.cardCornerRadius))
        }
    }
}
