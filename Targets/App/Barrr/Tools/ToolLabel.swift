import BarrrCore
import NoSleepCore
import PerformanceCore
import SwiftUI

/// 工具在選單列的標籤
@MainActor
struct ToolLabel: View {
    let tool: Tool
    let noSleep: NoSleepModel
    let performance: PerformanceSnapshot?
    let sampler: PerformanceSampler<ContinuousClock>
    let reportPerformance: @MainActor (PerformanceSnapshot) -> Void

    var body: some View {
        switch tool {
        case .noSleep:
            NoSleepLabel(activeMode: noSleep.activeMode)
        case .performance:
            PerformanceLabel(snapshot: performance, sampler: sampler, report: reportPerformance)
        }
    }
}
