/// 能耗：電池與整台 Mac 目前的耗電功率
public struct EnergyStatus: Equatable, Sendable {
    /// 沒有電池的 Mac（桌上型）為 nil
    public let battery: BatteryLevel?
    /// 整台 Mac 目前的耗電（瓦）；系統沒有回報時為 nil
    public let systemPowerWatts: Double?

    public init(battery: BatteryLevel?, systemPowerWatts: Double?) {
        self.battery = battery
        self.systemPowerWatts = systemPowerWatts
    }
}
