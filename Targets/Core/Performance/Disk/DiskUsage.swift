/// 開機磁碟的空間（位元組）
public struct DiskUsage: Equatable, Sendable {
    /// 可用空間（含系統可清除的空間，與 Finder 顯示的「可用」相同）
    public let available: UInt64
    public let total: UInt64

    public init(available: UInt64, total: UInt64) {
        self.available = available
        self.total = total
    }

    /// 已使用的比例（0–1）；總量為 0 時為 nil
    public var usedFraction: Double? {
        guard total > 0 else {
            return nil
        }
        return Double(total - min(available, total)) / Double(total)
    }
}
