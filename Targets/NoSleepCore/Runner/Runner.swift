/// 依指令列參數執行：輸出選單，或開關不休眠
public struct Runner<Controller: AwakeController>: Sendable {
    private let controller: Controller
    private let executablePath: String

    /// - Parameter executablePath: 自己的路徑，選單項目點選時以它重新執行
    public init(controller: Controller, executablePath: String) {
        self.controller = controller
        self.executablePath = executablePath
    }

    public func run(arguments: [String]) -> RunOutput {
        let command: Command
        do throws(CommandError) {
            command = try Command(arguments: arguments)
        } catch {
            return RunOutput(lines: [MenuText.description(of: error)], succeeded: false)
        }
        do throws(AwakeControlError) {
            switch command {
            case .showMenu:
                return RunOutput(lines: menu().swiftBarLines(executablePath: executablePath), succeeded: true)
            case let .start(mode):
                // 一次只有一種方式生效：先停掉目前的
                try controller.stop()
                try controller.start(mode)
            case .stop:
                try controller.stop()
            }
            return RunOutput(lines: [], succeeded: true)
        } catch {
            return RunOutput(lines: [MenuText.description(of: error)], succeeded: false)
        }
    }

    private func menu() -> Menu {
        do throws(AwakeControlError) {
            return try Menu(state: controller.activeMode().map(MenuState.awake) ?? .sleepAllowed)
        } catch {
            return Menu(state: .unknown(error))
        }
    }
}
