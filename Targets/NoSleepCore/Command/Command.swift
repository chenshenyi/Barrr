/// 指令列參數（不含執行檔路徑）對應的動作
public enum Command: Equatable, Sendable {
    /// 沒有參數：SwiftBar 定期執行，輸出選單
    case showMenu
    /// `start <mode>`：以指定方式不休眠
    case start(AwakeMode)
    /// `stop`：恢復休眠
    case stop

    private static let startName = "start"
    private static let stopName = "stop"

    public init(arguments: [String]) throws(CommandError) {
        guard let name = arguments.first else {
            self = .showMenu
            return
        }
        let rest = arguments.dropFirst()
        switch name {
        case Self.startName:
            guard let modeName = rest.first, rest.count == 1 else {
                throw .invalidArguments(arguments)
            }
            guard let mode = AwakeMode(rawValue: modeName) else {
                throw .unknownMode(modeName)
            }
            self = .start(mode)
        case Self.stopName:
            guard rest.isEmpty else {
                throw .invalidArguments(arguments)
            }
            self = .stop
        default:
            throw .invalidArguments(arguments)
        }
    }

    /// 轉回指令列參數，選單項目以此組出要執行的指令
    public var arguments: [String] {
        switch self {
        case .showMenu: []
        case let .start(mode): [Self.startName, mode.rawValue]
        case .stop: [Self.stopName]
        }
    }
}
