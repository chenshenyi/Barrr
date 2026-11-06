import PerformanceCore
import Testing

struct TransferTests {
    @Test
    func countersGiveRatePerSecond() {
        let rate = TransferCounters(incoming: 300, outgoing: 50)
            .rate(since: TransferCounters(incoming: 100, outgoing: 10), seconds: 2)

        #expect(rate == TransferRate(incomingPerSecond: 100, outgoingPerSecond: 20))
    }

    @Test
    func countersGoingBackwardsHaveNoRate() {
        let rate = TransferCounters(incoming: 1, outgoing: 1)
            .rate(since: TransferCounters(incoming: 100, outgoing: 10), seconds: 2)

        #expect(rate == nil)
    }

    @Test
    func networkRateHandlesCounterWrapAround() {
        let previous = NetworkCounters(interfaces: ["en0": InterfaceCounters(received: .max - 99, sent: 0)])
        let current = NetworkCounters(interfaces: ["en0": InterfaceCounters(received: 100, sent: 0)])

        let rate = current.rate(since: previous, seconds: 2)

        #expect(rate == TransferRate(incomingPerSecond: 100, outgoingPerSecond: 0))
    }

    @Test
    func networkRateSumsInterfacesPresentInBothSamples() {
        let previous = NetworkCounters(interfaces: [
            "en0": InterfaceCounters(received: 0, sent: 0),
            "en1": InterfaceCounters(received: 0, sent: 0),
        ])
        let current = NetworkCounters(interfaces: [
            "en0": InterfaceCounters(received: 10, sent: 2),
            "en1": InterfaceCounters(received: 30, sent: 4),
            "utun0": InterfaceCounters(received: 1000, sent: 1000),
        ])

        let rate = current.rate(since: previous, seconds: 1)

        #expect(rate == TransferRate(incomingPerSecond: 40, outgoingPerSecond: 6))
    }

    @Test
    func diskUsedFractionComesFromAvailableSpace() {
        #expect(DiskUsage(available: 100, total: 400).usedFraction == 0.75)
    }
}
