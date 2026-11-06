/// 不休眠的方式
public enum AwakeMode: CaseIterable, Sendable {
    /// 系統與螢幕都不休眠
    case keepDisplayOn
    /// 系統不休眠，螢幕照設定關閉
    case allowDisplaySleep
}
