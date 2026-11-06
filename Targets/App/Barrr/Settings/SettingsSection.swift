import SwiftUI

/// 管理視窗的一個區塊：標題、內容與說明
@MainActor
struct SettingsSection<Content: View>: View {
    let title: Text
    let footer: Text?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: SettingsMetrics.sectionSpacing) {
            title
                .font(.headline)
            content
            if let footer {
                footer
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
