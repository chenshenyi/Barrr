import Foundation
import PerformanceCore

/// 電池一行的文字：電量與充電狀態（每種狀態一個 key，電量是參數）
struct BatteryDescription: LocalizedStringResourceConvertible, Sendable {
    let level: BatteryLevel

    var localizedStringResource: LocalizedStringResource {
        let percent = PerformanceFormat.percent(level.fraction)
        return switch level.state {
        case .charging: .performanceBatteryCharging(percent)
        case .charged: .performanceBatteryCharged(percent)
        case .onPowerNotCharging: .performanceBatteryOnPower(percent)
        case .discharging: .performanceBatteryDischarging(percent)
        }
    }
}
