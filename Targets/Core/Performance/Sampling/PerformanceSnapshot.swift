/// 顯示用的一次結果：使用率與速率由前後兩次取樣算出；讀不到或第一次取樣算不出的項目為 nil
public struct PerformanceSnapshot: Equatable, Sendable {
    /// CPU 使用率（0–1）
    public let cpuUsage: Double?
    public let memory: MemoryUsage?
    public let energy: EnergyStatus?
    public let disk: DiskUsage?
    /// 磁碟每秒的讀取（incoming）與寫入（outgoing）
    public let diskRate: TransferRate?
    /// 網路每秒的下載（incoming）與上傳（outgoing）
    public let networkRate: TransferRate?

    public init(
        cpuUsage: Double? = nil,
        memory: MemoryUsage? = nil,
        energy: EnergyStatus? = nil,
        disk: DiskUsage? = nil,
        diskRate: TransferRate? = nil,
        networkRate: TransferRate? = nil
    ) {
        self.cpuUsage = cpuUsage
        self.memory = memory
        self.energy = energy
        self.disk = disk
        self.diskRate = diskRate
        self.networkRate = networkRate
    }

    /// 由這次的取樣與前一次（第一次取樣時為 nil）組成；`seconds` 是兩次取樣相隔的秒數
    init(previous: MetricsSample?, current: MetricsSample, seconds: Double) {
        func compare<Value>(
            _ value: (MetricsSample) -> Value?,
            _ body: (Value, Value) -> TransferRate?
        ) -> TransferRate? {
            guard let previous, let before = value(previous), let now = value(current) else {
                return nil
            }
            return body(now, before)
        }
        let cpuUsage: Double? = if let before = previous?.cpuTicks, let now = current.cpuTicks {
            now.usage(since: before)
        } else {
            nil
        }
        self.init(
            cpuUsage: cpuUsage,
            memory: current.memory,
            energy: current.energy,
            disk: current.disk,
            diskRate: compare(\.diskTransfer) { $0.rate(since: $1, seconds: seconds) },
            networkRate: compare(\.network) { $0.rate(since: $1, seconds: seconds) }
        )
    }
}
