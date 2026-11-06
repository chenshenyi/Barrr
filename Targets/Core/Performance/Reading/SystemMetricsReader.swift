/// 讀取系統的數據；live 實作在 App 的 `Dependencies/Live/`
public protocol SystemMetricsReader: Sendable {
    func cpuTicks() throws(SystemMetricsError) -> CPUTicks
    func memoryUsage() throws(SystemMetricsError) -> MemoryUsage
    func energyStatus() throws(SystemMetricsError) -> EnergyStatus
    func diskUsage() throws(SystemMetricsError) -> DiskUsage
    /// 所有磁碟開機以來累計的讀寫位元組
    func diskTransfer() throws(SystemMetricsError) -> TransferCounters
    func networkCounters() throws(SystemMetricsError) -> NetworkCounters
}
