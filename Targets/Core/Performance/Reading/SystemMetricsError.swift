/// 讀取系統數據失敗的原因；`code` 是系統回傳的錯誤碼（`kern_return_t`、`errno`）
public enum SystemMetricsError: Error, Equatable {
    case cpuUnavailable(code: Int32)
    case memoryUnavailable(code: Int32)
    /// IORegistry 的電池資料讀不到或格式不符
    case energyUnavailable
    case diskUnavailable
    case diskTransferUnavailable
    case networkUnavailable(code: Int32)
}
