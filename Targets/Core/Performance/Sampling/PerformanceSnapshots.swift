/// 定時取樣的結果串流（`PerformanceSampler.snapshots()`）
///
/// 每次的截止時間由上一次的截止時間往後推 `interval`，取樣花的時間不會累積成誤差；
/// 落後超過一個間隔（例如 Mac 睡眠醒來）時從現在重新對齊，不會連續補取樣。
public struct PerformanceSnapshots<C: Clock>: AsyncSequence, Sendable where C.Duration == Duration {
    public typealias Element = PerformanceSnapshot

    let reader: any SystemMetricsReader
    let clock: C
    let interval: Duration
    let tolerance: Duration?

    public func makeAsyncIterator() -> Iterator {
        Iterator(reader: reader, clock: clock, interval: interval, tolerance: tolerance)
    }

    public struct Iterator: AsyncIteratorProtocol, Sendable {
        let reader: any SystemMetricsReader
        let clock: C
        let interval: Duration
        let tolerance: Duration?
        private var deadline: C.Instant?
        private var previous: (sample: MetricsSample, instant: C.Instant)?

        init(reader: any SystemMetricsReader, clock: C, interval: Duration, tolerance: Duration?) {
            self.reader = reader
            self.clock = clock
            self.interval = interval
            self.tolerance = tolerance
        }

        /// task 取消時回傳 nil，結束 `for await`
        public mutating func next() async -> PerformanceSnapshot? {
            if let deadline {
                do {
                    try await clock.sleep(until: deadline, tolerance: tolerance)
                } catch {
                    // 只有 task 取消時會拋出
                    return nil
                }
                let next = deadline.advanced(by: interval)
                self.deadline = next < clock.now ? clock.now.advanced(by: interval) : next
            } else {
                deadline = clock.now.advanced(by: interval)
            }
            guard !Task.isCancelled else {
                return nil
            }
            let now = clock.now
            let sample = MetricsSample(reading: reader)
            let seconds = previous.map { $0.instant.duration(to: now) / .seconds(1) } ?? 0
            let snapshot = PerformanceSnapshot(previous: previous?.sample, current: sample, seconds: seconds)
            previous = (sample, now)
            return snapshot
        }
    }
}
