/// 要求或交還「不休眠」失敗的原因；`code` 是系統回傳的錯誤碼（IOKit 的 `IOReturn`）
public enum AwakeControlError: Error, Equatable {
    case holdFailed(code: Int32)
    case releaseFailed(code: Int32)
}
