import BarrrCore
import Testing

@MainActor
struct SettingsModelTests {
    @Test(arguments: [true, false])
    func startsWithSystemLoginItemState(enabled: Bool) {
        let model = SettingsModel(loginItem: FixedLoginItemController(enabled: enabled))

        #expect(model.launchesAtLogin == enabled)
    }

    @Test(arguments: [true, false])
    func launchesAtLoginFollowsSystemState(enabled: Bool) {
        var model = SettingsModel(loginItem: FixedLoginItemController(enabled: enabled))

        model.setLaunchesAtLogin(!enabled)

        #expect(model.launchesAtLogin == enabled)
    }

    @Test
    func failedChangeReportsFailure() {
        var model = SettingsModel(loginItem: FixedLoginItemController(error: .registerFailed))

        model.setLaunchesAtLogin(true)

        #expect(model.failure == .registerFailed)
    }

    @Test
    func successfulChangeHasNoFailure() {
        var model = SettingsModel(loginItem: FixedLoginItemController())

        model.setLaunchesAtLogin(true)

        #expect(model.failure == nil)
    }
}
