import PerformanceCore

/// 建立以真實時鐘與系統數據取樣的 `PerformanceSampler`
enum LivePerformanceSampler: Sendable {
    private static let intervalSeconds = 2
    private static let toleranceMilliseconds = 200
    private static let interval: Duration = .seconds(intervalSeconds)
    /// 允許延後喚醒的幅度，讓系統合併計時器以省電
    private static let tolerance: Duration = .milliseconds(toleranceMilliseconds)

    static func make() -> PerformanceSampler<ContinuousClock> {
        PerformanceSampler(
            reader: LiveSystemMetricsReader(),
            clock: ContinuousClock(),
            interval: interval,
            tolerance: tolerance
        )
    }
}
