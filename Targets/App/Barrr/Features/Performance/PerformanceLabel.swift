import PerformanceCore
import SwiftUI

/// 系統效能在選單列的圖示與 CPU 使用率；顯示期間持續取樣（離開選單列時 task 取消，取樣跟著停止），以 `report` 交回結果
@MainActor
struct PerformanceLabel: View {
    let snapshot: PerformanceSnapshot?
    let sampler: PerformanceSampler<ContinuousClock>
    let report: @MainActor (PerformanceSnapshot) -> Void

    var body: some View {
        HStack {
            Image(AppSymbol.performance)
            Text(verbatim: PerformanceFormat.percent(snapshot?.cpuUsage))
                .monospacedDigit()
        }
        .task {
            for await snapshot in sampler.snapshots() {
                report(snapshot)
            }
        }
    }
}
