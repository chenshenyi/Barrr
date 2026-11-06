import NoSleepCore
import Testing

@MainActor
struct NoSleepModelTests {
    @Test
    func startsWithSleepAllowed() {
        let model = NoSleepModel(awake: RecordingAwakeController(), loginItem: FixedLoginItemController())

        #expect(model.activeMode == nil)
    }

    @Test
    func toggleHoldsMode() async {
        let awake = RecordingAwakeController()
        var model = NoSleepModel(awake: awake, loginItem: FixedLoginItemController())

        model.toggle(.keepDisplayOn)

        #expect(model.activeMode == .keepDisplayOn)
        #expect(await awake.recordedCalls() == [.hold(.keepDisplayOn)])
    }

    @Test
    func toggleActiveModeResumesSleep() async {
        let awake = RecordingAwakeController()
        var model = NoSleepModel(awake: awake, loginItem: FixedLoginItemController())
        model.toggle(.keepDisplayOn)

        model.toggle(.keepDisplayOn)

        #expect(model.activeMode == nil)
        #expect(await awake.recordedCalls() == [
            .hold(.keepDisplayOn),
            .release(AwakeAssertion(id: RecordingAwakeController.assertionID, mode: .keepDisplayOn)),
        ])
    }

    @Test
    func toggleOtherModeReleasesCurrentFirst() async {
        let awake = RecordingAwakeController()
        var model = NoSleepModel(awake: awake, loginItem: FixedLoginItemController())
        model.toggle(.keepDisplayOn)

        model.toggle(.allowDisplaySleep)

        #expect(model.activeMode == .allowDisplaySleep)
        #expect(await awake.recordedCalls() == [
            .hold(.keepDisplayOn),
            .release(AwakeAssertion(id: RecordingAwakeController.assertionID, mode: .keepDisplayOn)),
            .hold(.allowDisplaySleep),
        ])
    }

    @Test
    func resumeReleasesAssertion() {
        var model = NoSleepModel(awake: RecordingAwakeController(), loginItem: FixedLoginItemController())
        model.toggle(.allowDisplaySleep)

        model.resume()

        #expect(model.activeMode == nil)
        #expect(model.failure == nil)
    }

    @Test
    func failedHoldKeepsSleepAllowedAndReportsFailure() {
        let awake = RecordingAwakeController(holdError: .holdFailed(code: -536_870_212))
        var model = NoSleepModel(awake: awake, loginItem: FixedLoginItemController())

        model.toggle(.keepDisplayOn)

        #expect(model.activeMode == nil)
        #expect(model.failure == .awake(.holdFailed(code: -536_870_212)))
    }

    @Test
    func failedReleaseKeepsAssertionAndDoesNotHoldOtherMode() async {
        let awake = RecordingAwakeController(releaseError: .releaseFailed(code: -536_870_206))
        var model = NoSleepModel(awake: awake, loginItem: FixedLoginItemController())
        model.toggle(.keepDisplayOn)

        model.toggle(.allowDisplaySleep)

        #expect(model.activeMode == .keepDisplayOn)
        #expect(model.failure == .awake(.releaseFailed(code: -536_870_206)))
        #expect(await awake.recordedCalls() == [
            .hold(.keepDisplayOn),
            .release(AwakeAssertion(id: RecordingAwakeController.assertionID, mode: .keepDisplayOn)),
        ])
    }

    @Test
    func nextSuccessfulActionClearsFailure() {
        var model = NoSleepModel(
            awake: RecordingAwakeController(),
            loginItem: FixedLoginItemController(error: .registerFailed)
        )
        model.setLaunchesAtLogin(true)

        model.toggle(.keepDisplayOn)

        #expect(model.failure == nil)
    }

    @Test(arguments: [true, false])
    func launchesAtLoginFollowsSystemState(enabled: Bool) {
        var model = NoSleepModel(
            awake: RecordingAwakeController(),
            loginItem: FixedLoginItemController(enabled: enabled)
        )

        model.setLaunchesAtLogin(!enabled)

        #expect(model.launchesAtLogin == enabled)
    }

    @Test
    func failedLoginItemChangeReportsFailure() {
        var model = NoSleepModel(
            awake: RecordingAwakeController(),
            loginItem: FixedLoginItemController(error: .registerFailed)
        )

        model.setLaunchesAtLogin(true)

        #expect(model.failure == .loginItem(.registerFailed))
    }
}
