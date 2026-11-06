import BarrrCore
import NoSleepCore
import PerformanceCore
import SwiftUI

/// 點開工具圖示後的選單
@MainActor
struct ToolMenu: View {
    let tool: Tool
    @Binding var noSleep: NoSleepModel
    let performance: PerformanceSnapshot?
    let openActivityMonitor: @MainActor () -> Void

    var body: some View {
        switch tool {
        case .noSleep:
            NoSleepMenu(model: $noSleep)
        case .performance:
            PerformanceMenu(snapshot: performance, openActivityMonitor: openActivityMonitor)
        }
    }
}
