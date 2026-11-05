/// 不休眠的方式；raw value 是指令列參數（`nosleep start <rawValue>`）
public enum AwakeMode: String, CaseIterable, Sendable {
    /// 系統與螢幕都不休眠
    case keepDisplayOn = "display"
    /// 系統不休眠，螢幕照設定關閉
    case allowDisplaySleep = "system"

    /// 交給 `caffeinate` 的參數：`-d` 螢幕、`-i` 閒置、`-s` 接電源時的系統休眠
    public var caffeinateFlags: [String] {
        switch self {
        case .keepDisplayOn: ["-d", "-i", "-s"]
        case .allowDisplaySleep: ["-i", "-s"]
        }
    }
}
