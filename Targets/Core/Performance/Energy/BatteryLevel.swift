/// 電池的電量與充電狀態
public struct BatteryLevel: Equatable, Sendable {
    /// 電量（0–1）
    public let fraction: Double
    public let state: BatteryState

    public init(fraction: Double, state: BatteryState) {
        self.fraction = fraction
        self.state = state
    }

    /// 由系統回報的目前容量與最大容量換算；最大容量不大於 0 時為 nil
    public init?(currentCapacity: Int, maxCapacity: Int, state: BatteryState) {
        guard maxCapacity > 0 else {
            return nil
        }
        self.init(fraction: min(max(Double(currentCapacity) / Double(maxCapacity), 0), 1), state: state)
    }
}
