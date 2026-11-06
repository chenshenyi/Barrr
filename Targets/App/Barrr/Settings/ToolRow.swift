import BarrrCore
import SwiftUI

/// 工具清單的一列：拖曳把手、圖示、名稱與說明、是否顯示的開關
@MainActor
struct ToolRow: View {
    private static let iconWidth: CGFloat = 28

    let tool: Tool
    @Binding var isVisible: Bool
    let canHide: Bool

    var body: some View {
        HStack(spacing: SettingsMetrics.cardPadding) {
            Image(AppSymbol.dragHandle)
                .foregroundStyle(.tertiary)
            Image(AppSymbol(tool))
                .font(.title3)
                .frame(width: Self.iconWidth)
            VStack(alignment: .leading) {
                Text(tool)
                    .font(.headline)
                Text(ToolSummary(tool: tool))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle(isOn: $isVisible) {
                Text(tool)
            }
            .toggleStyle(.switch)
            .labelsHidden()
            .disabled(!canHide)
        }
        .padding(.horizontal, SettingsMetrics.cardPadding)
        .frame(maxWidth: .infinity, minHeight: SettingsMetrics.toolRowHeight)
    }
}
