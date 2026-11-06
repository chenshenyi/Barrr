/// 電池的充電狀態
public enum BatteryState: Equatable, Sendable {
    case charging
    /// 接著電源且已充滿
    case charged
    /// 接著電源但沒有充電（例如系統暫停充電以保護電池）
    case onPowerNotCharging
    case discharging

    /// 由系統回報的三個旗標判斷
    public init(isCharging: Bool, isFullyCharged: Bool, isExternalConnected: Bool) {
        switch (isCharging, isFullyCharged, isExternalConnected) {
        case (true, _, _): self = .charging
        case (false, true, true): self = .charged
        case (false, false, true): self = .onPowerNotCharging
        case (false, _, false): self = .discharging
        }
    }
}
