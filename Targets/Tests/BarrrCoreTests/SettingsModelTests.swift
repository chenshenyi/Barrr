import BarrrCore
import Testing

@MainActor
struct SettingsModelTests {
    @Test(arguments: [true, false])
    func startsWithSystemLoginItemState(enabled: Bool) {
        let model = SettingsModel(
            loginItem: FixedLoginItemController(enabled: enabled),
            layoutStorage: RecordingToolLayoutStorage()
        )

        #expect(model.launchesAtLogin == enabled)
    }

    @Test(arguments: [true, false])
    func launchesAtLoginFollowsSystemState(enabled: Bool) {
        var model = SettingsModel(
            loginItem: FixedLoginItemController(enabled: enabled),
            layoutStorage: RecordingToolLayoutStorage()
        )

        model.setLaunchesAtLogin(!enabled)

        #expect(model.launchesAtLogin == enabled)
    }

    @Test
    func failedChangeReportsFailure() {
        var model = SettingsModel(
            loginItem: FixedLoginItemController(error: .registerFailed),
            layoutStorage: RecordingToolLayoutStorage()
        )

        model.setLaunchesAtLogin(true)

        #expect(model.failure == .registerFailed)
    }

    @Test
    func successfulChangeHasNoFailure() {
        var model = SettingsModel(loginItem: FixedLoginItemController(), layoutStorage: RecordingToolLayoutStorage())

        model.setLaunchesAtLogin(true)

        #expect(model.failure == nil)
    }

    @Test
    func startsWithStoredLayout() {
        var stored = ToolLayout()
        stored.setVisible(.noSleep, false)

        let model = SettingsModel(
            loginItem: FixedLoginItemController(),
            layoutStorage: RecordingToolLayoutStorage(stored: stored)
        )

        #expect(model.layout == stored)
    }

    @Test
    func startsWithDefaultLayoutWhenNothingStored() {
        let model = SettingsModel(loginItem: FixedLoginItemController(), layoutStorage: RecordingToolLayoutStorage())

        #expect(model.layout == ToolLayout())
    }

    @Test
    func layoutChangesAreSaved() async {
        let storage = RecordingToolLayoutStorage()
        var model = SettingsModel(loginItem: FixedLoginItemController(), layoutStorage: storage)

        model.setVisible(.noSleep, false)
        model.moveTool(from: 1, to: 0)

        var hidden = ToolLayout()
        hidden.setVisible(.noSleep, false)
        var moved = hidden
        moved.move(from: 1, to: 0)
        #expect(await storage.savedLayouts() == [hidden, moved])
    }
}
