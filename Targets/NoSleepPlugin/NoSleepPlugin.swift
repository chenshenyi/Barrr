import NoSleepCore

/// 進入點（composition root）：建立 live 依賴，交給 Runner
@main
enum NoSleepPlugin: Sendable {
    static func main() {
        // SwiftBar 以完整路徑執行 plugin，選單項目以同一個路徑重新執行自己
        let executablePath = CommandLine.arguments.first ?? ""
        let runner = Runner(controller: LiveAwakeController(), executablePath: executablePath)
        let output = runner.run(arguments: Array(CommandLine.arguments.dropFirst()))
        LiveTerminal().finish(lines: output.lines, succeeded: output.succeeded)
    }
}
