import PerformanceCore
import Testing

struct PerformanceSamplerTests {
    @Test
    func samplesRepeatedly() async {
        let sampler = PerformanceSampler(
            reader: FixedSystemMetricsReader(),
            clock: ImmediateClock(),
            interval: .seconds(2)
        )

        var count = 0
        for await snapshot in sampler.snapshots().prefix(3) {
            #expect(snapshot.memory == FixedSystemMetricsReader.sample.memory)
            count += 1
        }

        #expect(count == 3)
    }

    @Test
    func unreadableMetricsStillProduceSnapshots() async {
        let sampler = PerformanceSampler(
            reader: FixedSystemMetricsReader(error: .energyUnavailable),
            clock: ImmediateClock(),
            interval: .seconds(2)
        )

        var iterator = sampler.snapshots().makeAsyncIterator()
        let first = await iterator.next()

        #expect(first == PerformanceSnapshot())
    }
}
