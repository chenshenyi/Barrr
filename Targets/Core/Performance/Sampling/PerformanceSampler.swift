/// 定時取樣 CPU 與記憶體的設定；以 `snapshots()` 取得取樣結果的串流
///
/// 時鐘是泛型而非 `any Clock`：對固定的截止時間睡（`sleep(until:)`）才不會累積誤差，而它不能用在 existential 上。
public struct PerformanceSampler<C: Clock>: Sendable where C.Duration == Duration {
    private let reader: any SystemMetricsReader
    private let clock: C
    private let interval: Duration
    private let tolerance: Duration?

    /// - Parameter tolerance: 允許系統延後喚醒的幅度，讓系統合併計時器以省電
    public init(reader: any SystemMetricsReader, clock: C, interval: Duration, tolerance: Duration? = nil) {
        self.reader = reader
        self.clock = clock
        self.interval = interval
        self.tolerance = tolerance
    }

    /// 立刻取樣一次，之後每隔 `interval` 取樣；所在的 task 取消時結束
    public func snapshots() -> PerformanceSnapshots<C> {
        PerformanceSnapshots(reader: reader, clock: clock, interval: interval, tolerance: tolerance)
    }
}
