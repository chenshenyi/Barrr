/// 最近一次操作失敗的原因，顯示在選單上
public enum NoSleepFailure: Equatable, Sendable {
    case awake(AwakeControlError)
    case loginItem(LoginItemError)
}
