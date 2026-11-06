import PerformanceCore
import SwiftUI

/// 系統效能的選單：CPU、記憶體、磁碟、網路、能耗與打開活動監視器；沒有電池的 Mac 不顯示電池、系統沒有回報耗電時不顯示耗電
@MainActor
struct PerformanceMenu: View {
    let snapshot: PerformanceSnapshot?
    let openActivityMonitor: @MainActor () -> Void

    var body: some View {
        Text(.performanceCPU(PerformanceFormat.percent(snapshot?.cpuUsage)))
        Text(.performanceMemory(
            PerformanceFormat.memory(snapshot?.memory?.used),
            PerformanceFormat.memory(snapshot?.memory?.total),
            PerformanceFormat.percent(snapshot?.memory?.fraction)
        ))
        Text(.performanceDisk(
            PerformanceFormat.file(snapshot?.disk?.available),
            PerformanceFormat.file(snapshot?.disk?.total)
        ))
        Text(.performanceDiskRate(
            PerformanceFormat.rate(snapshot?.diskRate?.incomingPerSecond),
            PerformanceFormat.rate(snapshot?.diskRate?.outgoingPerSecond)
        ))
        Text(.performanceNetwork(
            PerformanceFormat.rate(snapshot?.networkRate?.incomingPerSecond),
            PerformanceFormat.rate(snapshot?.networkRate?.outgoingPerSecond)
        ))
        if let battery = snapshot?.energy?.battery {
            Text(BatteryDescription(level: battery))
        }
        if let watts = snapshot?.energy?.systemPowerWatts {
            Text(.performancePower(PerformanceFormat.watts(watts)))
        }
        Divider()
        Button(action: openActivityMonitor) {
            Text(.performanceOpenActivityMonitor)
        }
    }
}
