import Testing
@testable import NoSleepCore

struct RunnerTests {
    @Test
    func showMenuReadsActiveMode() async {
        let controller = RecordingAwakeController(activeMode: .keepDisplayOn)
        let runner = Runner(controller: controller, executablePath: "/p/nosleep")

        let output = runner.run(arguments: [])

        #expect(output == RunOutput(
            lines: Menu(state: .awake(.keepDisplayOn)).swiftBarLines(executablePath: "/p/nosleep"),
            succeeded: true
        ))
        #expect(await controller.recordedCalls() == [.activeMode])
    }

    @Test
    func showMenuStillSucceedsWhenStateIsUnreadable() {
        let runner = Runner(
            controller: RecordingAwakeController(error: .launchctlUnavailable),
            executablePath: "/p/nosleep"
        )

        let output = runner.run(arguments: [])

        #expect(output == RunOutput(
            lines: Menu(state: .unknown(.launchctlUnavailable)).swiftBarLines(executablePath: "/p/nosleep"),
            succeeded: true
        ))
    }

    @Test
    func startStopsCurrentModeFirst() async {
        let controller = RecordingAwakeController(activeMode: .keepDisplayOn)
        let runner = Runner(controller: controller, executablePath: "/p/nosleep")

        let output = runner.run(arguments: ["start", "system"])

        #expect(output == RunOutput(lines: [], succeeded: true))
        #expect(await controller.recordedCalls() == [.stop, .start(.allowDisplaySleep)])
    }

    @Test
    func stopStopsAllModes() async {
        let controller = RecordingAwakeController(activeMode: .allowDisplaySleep)
        let runner = Runner(controller: controller, executablePath: "/p/nosleep")

        let output = runner.run(arguments: ["stop"])

        #expect(output == RunOutput(lines: [], succeeded: true))
        #expect(await controller.recordedCalls() == [.stop])
    }

    @Test
    func failedActionReportsError() async {
        let controller = RecordingAwakeController(error: .launchctlFailed(status: 5))
        let runner = Runner(controller: controller, executablePath: "/p/nosleep")

        let output = runner.run(arguments: ["start", "display"])

        #expect(output == RunOutput(lines: ["launchctl 執行失敗，狀態 5"], succeeded: false))
        #expect(await controller.recordedCalls() == [.stop])
    }

    @Test
    func invalidArgumentsFailWithoutTouchingController() async {
        let controller = RecordingAwakeController()
        let runner = Runner(controller: controller, executablePath: "/p/nosleep")

        let output = runner.run(arguments: ["toggle"])

        #expect(output == RunOutput(lines: ["無法辨識的參數：toggle"], succeeded: false))
        #expect(await controller.recordedCalls().isEmpty)
    }
}
