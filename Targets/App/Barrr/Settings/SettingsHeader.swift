import SwiftUI

/// 管理視窗頂端：App 圖示、名稱與一句話說明
@MainActor
struct SettingsHeader: View {
    let appIcon: Image

    var body: some View {
        HStack(spacing: SettingsMetrics.headerSpacing) {
            appIcon
                .resizable()
                .frame(width: SettingsMetrics.headerIconSize, height: SettingsMetrics.headerIconSize)
            VStack(alignment: .leading) {
                Text(.settingsTitle)
                    .font(.largeTitle.bold())
                Text(.settingsSubtitle)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
