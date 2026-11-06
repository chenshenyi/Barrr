import BarrrCore
import SwiftUI

/// 工具清單：拖曳排列選單列的順序，開關決定是否顯示；整個清單是一塊玻璃卡片
@MainActor
struct ToolList: View {
    let layout: ToolLayout
    let setVisible: @MainActor (Tool, Bool) -> Void
    let move: @MainActor (Int, Int) -> Void

    var body: some View {
        SettingsSection(title: Text(.settingsToolsHeader), footer: Text(.settingsToolsFooter)) {
            List {
                ForEach(layout.order, id: \.self) { tool in
                    ToolRow(
                        tool: tool,
                        isVisible: Binding(get: { layout.isVisible(tool) }, set: { setVisible(tool, $0) }),
                        canHide: layout.canHide(tool)
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .onMove { sources, destination in
                    if let source = sources.first {
                        move(source, destination)
                    }
                }
            }
            .listStyle(.plain)
            // 去掉 List 自帶的留白，卡片與其他區塊同寬
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .frame(height: SettingsMetrics.toolRowHeight * CGFloat(layout.order.count))
            .glassEffect(.regular, in: .rect(cornerRadius: SettingsMetrics.cardCornerRadius))
        }
    }
}
