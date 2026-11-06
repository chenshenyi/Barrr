/// 開機以來所有 CPU 累計的 tick 數（Mach 的 `HOST_CPU_LOAD_INFO`），兩次取樣的差即是這段時間的使用率
public struct CPUTicks: Equatable, Sendable {
    public let user: UInt64
    public let system: UInt64
    public let idle: UInt64
    public let nice: UInt64

    public init(user: UInt64, system: UInt64, idle: UInt64, nice: UInt64) {
        self.user = user
        self.system = system
        self.idle = idle
        self.nice = nice
    }

    /// 從 `previous` 到這次之間 CPU 忙碌的比例（0–1）；tick 沒有增加或倒退時為 nil
    public func usage(since previous: Self) -> Double? {
        let busy = (user + system + nice).subtractingReportingOverflow(previous.user + previous.system + previous.nice)
        let idle = idle.subtractingReportingOverflow(previous.idle)
        guard !busy.overflow, !idle.overflow, busy.partialValue + idle.partialValue > 0 else {
            return nil
        }
        return Double(busy.partialValue) / Double(busy.partialValue + idle.partialValue)
    }
}
