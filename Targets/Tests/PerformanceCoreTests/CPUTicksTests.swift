import PerformanceCore
import Testing

struct CPUTicksTests {
    @Test
    func usageIsBusyShareOfElapsedTicks() throws {
        let previous = CPUTicks(user: 100, system: 50, idle: 800, nice: 0)
        let current = CPUTicks(user: 130, system: 60, idle: 860, nice: 0)

        let usage = try #require(current.usage(since: previous))

        #expect(usage == 0.4)
    }

    @Test
    func usageIsNilWithoutElapsedTicks() {
        let ticks = CPUTicks(user: 100, system: 50, idle: 800, nice: 0)

        #expect(ticks.usage(since: ticks) == nil)
    }

    @Test
    func usageIsNilWhenTicksGoBackwards() {
        let previous = CPUTicks(user: 100, system: 50, idle: 800, nice: 0)
        let current = CPUTicks(user: 10, system: 5, idle: 80, nice: 0)

        #expect(current.usage(since: previous) == nil)
    }
}
