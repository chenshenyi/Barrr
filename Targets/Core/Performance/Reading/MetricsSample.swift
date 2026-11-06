/// 一次取樣讀到的原始數據；讀不到的項目為 nil
public struct MetricsSample: Equatable, Sendable {
    public let cpuTicks: CPUTicks?
    public let memory: MemoryUsage?
    public let energy: EnergyStatus?
    public let disk: DiskUsage?
    public let diskTransfer: TransferCounters?
    public let network: NetworkCounters?

    public init(
        cpuTicks: CPUTicks? = nil,
        memory: MemoryUsage? = nil,
        energy: EnergyStatus? = nil,
        disk: DiskUsage? = nil,
        diskTransfer: TransferCounters? = nil,
        network: NetworkCounters? = nil
    ) {
        self.cpuTicks = cpuTicks
        self.memory = memory
        self.energy = energy
        self.disk = disk
        self.diskTransfer = diskTransfer
        self.network = network
    }

    /// 讀取每一項，讀不到的記為 nil
    init(reading reader: any SystemMetricsReader) {
        func read<Value>(_ body: () throws(SystemMetricsError) -> Value) -> Value? {
            do throws(SystemMetricsError) {
                return try body()
            } catch {
                return nil
            }
        }
        self.init(
            cpuTicks: read(reader.cpuTicks),
            memory: read(reader.memoryUsage),
            energy: read(reader.energyStatus),
            disk: read(reader.diskUsage),
            diskTransfer: read(reader.diskTransfer),
            network: read(reader.networkCounters)
        )
    }
}
