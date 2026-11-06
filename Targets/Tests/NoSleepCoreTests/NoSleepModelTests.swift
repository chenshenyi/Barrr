import NoSleepCore
import Testing

@MainActor
struct NoSleepModelTests {
    @Test
    func startsWithSleepAllowed() {
        let model = NoSleepModel(awake: RecordingAwakeController())

        #expect(model.activeMode == nil)
    }

    @Test
    func toggleHoldsMode() async {
        let awake = RecordingAwakeController()
        var model = NoSleepModel(awake: awake)

        model.toggle(.keepDisplayOn)

        #expect(model.activeMode == .keepDisplayOn)
        #expect(await awake.recordedCalls() == [.hold(.keepDisplayOn)])
    }

    @Test
    func toggleActiveModeResumesSleep() async {
        let awake = RecordingAwakeController()
        var model = NoSleepModel(awake: awake)
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
        var model = NoSleepModel(awake: awake)
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
    func failedHoldKeepsSleepAllowedAndReportsFailure() {
        let awake = RecordingAwakeController(holdError: .holdFailed(code: -536_870_212))
        var model = NoSleepModel(awake: awake)

        model.toggle(.keepDisplayOn)

        #expect(model.activeMode == nil)
        #expect(model.failure == .holdFailed(code: -536_870_212))
    }

    @Test
    func failedReleaseKeepsAssertionAndDoesNotHoldOtherMode() async {
        let awake = RecordingAwakeController(releaseError: .releaseFailed(code: -536_870_206))
        var model = NoSleepModel(awake: awake)
        model.toggle(.keepDisplayOn)

        model.toggle(.allowDisplaySleep)

        #expect(model.activeMode == .keepDisplayOn)
        #expect(model.failure == .releaseFailed(code: -536_870_206))
        #expect(await awake.recordedCalls() == [
            .hold(.keepDisplayOn),
            .release(AwakeAssertion(id: RecordingAwakeController.assertionID, mode: .keepDisplayOn)),
        ])
    }
}
