/// 系統操作失敗的原因
public enum AwakeControlError: Error, Equatable {
    /// 無法執行 launchctl
    case launchctlUnavailable
    /// launchctl 以非 0 的狀態結束
    case launchctlFailed(status: Int32)
}
