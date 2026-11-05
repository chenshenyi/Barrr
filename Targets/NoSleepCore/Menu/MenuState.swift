/// 選單要呈現的狀態
public enum MenuState: Equatable, Sendable {
    /// 沒有生效的方式，照系統設定休眠
    case sleepAllowed
    /// 以指定方式不休眠
    case awake(AwakeMode)
    /// 讀不到狀態
    case unknown(AwakeControlError)
}
