import PerformanceCore

/// 固定數據的替身：每次回傳建立時給定的取樣；`error` 不為 nil 時每一項都拋出它
struct FixedSystemMetricsReader: SystemMetricsReader {
    // 固定的測試資料：規則允許測試資料使用數字，內建的 no_magic_numbers 只認得 @Test 函式裡的
    // swiftlint:disable no_magic_numbers
    static let sample = MetricsSample(
        cpuTicks: CPUTicks(user: 1, system: 1, idle: 1, nice: 0),
        memory: MemoryUsage(used: 8, total: 16),
        energy: EnergyStatus(battery: BatteryLevel(fraction: 0.5, state: .discharging), systemPowerWatts: 3),
        disk: DiskUsage(available: 100, total: 400),
        diskTransfer: TransferCounters(incoming: 10, outgoing: 20),
        network: NetworkCounters(interfaces: ["en0": InterfaceCounters(received: 30, sent: 40)])
    )
    // swiftlint:enable no_magic_numbers

    private let error: SystemMetricsError?

    init(error: SystemMetricsError? = nil) {
        self.error = error
    }

    func cpuTicks() throws(SystemMetricsError) -> CPUTicks {
        try value(Self.sample.cpuTicks)
    }

    func memoryUsage() throws(SystemMetricsError) -> MemoryUsage {
        try value(Self.sample.memory)
    }

    func energyStatus() throws(SystemMetricsError) -> EnergyStatus {
        try value(Self.sample.energy)
    }

    func diskUsage() throws(SystemMetricsError) -> DiskUsage {
        try value(Self.sample.disk)
    }

    func diskTransfer() throws(SystemMetricsError) -> TransferCounters {
        try value(Self.sample.diskTransfer)
    }

    func networkCounters() throws(SystemMetricsError) -> NetworkCounters {
        try value(Self.sample.network)
    }

    private func value<Value>(_ value: Value?) throws(SystemMetricsError) -> Value {
        guard let value, error == nil else {
            throw error ?? .energyUnavailable
        }
        return value
    }
}
