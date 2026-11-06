import PerformanceCore
import Testing

struct BatteryTests {
    @Test(arguments: [
        (true, false, true, BatteryState.charging),
        (false, true, true, .charged),
        (false, false, true, .onPowerNotCharging),
        (false, false, false, .discharging),
        (false, true, false, .discharging),
    ])
    func stateFollowsSystemFlags(
        isCharging: Bool,
        isFullyCharged: Bool,
        isExternalConnected: Bool,
        expected: BatteryState
    ) {
        let state = BatteryState(
            isCharging: isCharging,
            isFullyCharged: isFullyCharged,
            isExternalConnected: isExternalConnected
        )

        #expect(state == expected)
    }

    @Test
    func levelIsCurrentShareOfMaxCapacity() {
        let level = BatteryLevel(currentCapacity: 26, maxCapacity: 100, state: .discharging)

        #expect(level == BatteryLevel(fraction: 0.26, state: .discharging))
    }

    @Test
    func levelIsNilWithoutMaxCapacity() {
        #expect(BatteryLevel(currentCapacity: 26, maxCapacity: 0, state: .discharging) == nil)
    }
}
