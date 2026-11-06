/// 設定登入時開啟失敗的原因
public enum LoginItemError: Error, Equatable {
    case registerFailed
    case unregisterFailed
}
