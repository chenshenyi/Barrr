import Testing
@testable import PerformanceCore

struct PerformanceSnapshotTests {
    private let memory = MemoryUsage(used: 8, total: 16)

    @Test
    func firstSampleHasOnlyCurrentReadings() {
        let snapshot = PerformanceSnapshot(previous: nil, current: FixedSystemMetricsReader.sample, seconds: 0)

        #expect(snapshot == PerformanceSnapshot(
            memory: FixedSystemMetricsReader.sample.memory,
            energy: FixedSystemMetricsReader.sample.energy,
            disk: FixedSystemMetricsReader.sample.disk
        ))
    }

    @Test
    func laterSampleHasUsageAndRates() {
        let previous = MetricsSample(
            cpuTicks: CPUTicks(user: 0, system: 0, idle: 0, nice: 0),
            diskTransfer: TransferCounters(incoming: 0, outgoing: 0),
            network: NetworkCounters(interfaces: ["en0": InterfaceCounters(received: 0, sent: 0)])
        )
        let current = MetricsSample(
            cpuTicks: CPUTicks(user: 1, system: 0, idle: 3, nice: 0),
            diskTransfer: TransferCounters(incoming: 200, outgoing: 100),
            network: NetworkCounters(interfaces: ["en0": InterfaceCounters(received: 400, sent: 20)])
        )

        let snapshot = PerformanceSnapshot(previous: previous, current: current, seconds: 2)

        #expect(snapshot == PerformanceSnapshot(
            cpuUsage: 0.25,
            diskRate: TransferRate(incomingPerSecond: 100, outgoingPerSecond: 50),
            networkRate: TransferRate(incomingPerSecond: 200, outgoingPerSecond: 10)
        ))
    }

    @Test
    func unreadableCurrentReadingsHaveNoUsageOrRates() {
        let snapshot = PerformanceSnapshot(
            previous: FixedSystemMetricsReader.sample,
            current: MetricsSample(),
            seconds: 2
        )

        #expect(snapshot == PerformanceSnapshot())
    }
}
