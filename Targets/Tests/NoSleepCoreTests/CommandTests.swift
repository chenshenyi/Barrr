import Testing
@testable import NoSleepCore

struct CommandTests {
    @Test(arguments: [
        ([], Command.showMenu),
        (["start", "display"], .start(.keepDisplayOn)),
        (["start", "system"], .start(.allowDisplaySleep)),
        (["stop"], .stop),
    ])
    func parsesArguments(arguments: [String], expected: Command) throws {
        let command = try Command(arguments: arguments)

        #expect(command == expected)
    }

    @Test(arguments: [["start"], ["start", "display", "extra"], ["stop", "extra"], ["toggle"]])
    func rejectsInvalidArguments(arguments: [String]) {
        #expect(throws: CommandError.invalidArguments(arguments)) {
            try Command(arguments: arguments)
        }
    }

    @Test
    func rejectsUnknownMode() {
        #expect(throws: CommandError.unknownMode("screen")) {
            try Command(arguments: ["start", "screen"])
        }
    }

    @Test(arguments: [Command.showMenu, .start(.keepDisplayOn), .start(.allowDisplaySleep), .stop])
    func argumentsParseBackToSameCommand(command: Command) throws {
        let parsed = try Command(arguments: command.arguments)

        #expect(parsed == command)
    }
}
