import PerformanceCore
import Testing

struct MemoryUsageTests {
    @Test
    func fractionIsUsedShareOfTotal() {
        let memory = MemoryUsage(used: 12, total: 16)

        #expect(memory.fraction == 0.75)
    }

    @Test
    func fractionIsNilWithoutTotal() {
        let memory = MemoryUsage(used: 12, total: 0)

        #expect(memory.fraction == nil)
    }

    @Test
    func fractionIsCappedAtOne() {
        let memory = MemoryUsage(used: 20, total: 16)

        #expect(memory.fraction == 1)
    }
}
