/// 選單上的文字與圖示
enum MenuText: Sendable {
    static let sleepAllowedSymbol = "moon.zzz"
    static let awakeSymbol = "cup.and.heat.waves.fill"
    static let unknownSymbol = "exclamationmark.triangle"

    static let sleepAllowed = "休眠：照系統設定"
    static let awake = "休眠已關閉"
    static let resume = "恢復休眠"
    static let keepDisplayOn = "不休眠（螢幕保持亮）"
    static let allowDisplaySleep = "不休眠（螢幕可關閉）"

    private static let launchctlUnavailable = "無法執行 launchctl"
    private static let launchctlFailed = "launchctl 執行失敗，狀態 "
    private static let invalidArguments = "無法辨識的參數："
    private static let unknownMode = "未知的方式："
    private static let argumentSeparator = " "

    static func title(of mode: AwakeMode) -> String {
        switch mode {
        case .keepDisplayOn: keepDisplayOn
        case .allowDisplaySleep: allowDisplaySleep
        }
    }

    static func description(of error: AwakeControlError) -> String {
        switch error {
        case .launchctlUnavailable: launchctlUnavailable
        case let .launchctlFailed(status): launchctlFailed + String(status)
        }
    }

    static func description(of error: CommandError) -> String {
        switch error {
        case let .invalidArguments(arguments): invalidArguments + arguments.joined(separator: argumentSeparator)
        case let .unknownMode(name): unknownMode + name
        }
    }
}
