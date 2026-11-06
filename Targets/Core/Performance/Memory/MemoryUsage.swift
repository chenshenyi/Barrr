/// 記憶體用量（位元組）
public struct MemoryUsage: Equatable, Sendable {
    /// 已使用：App 記憶體、聯繫（wired）與壓縮，與「活動監視器」的「已使用記憶體」相同的算法
    public let used: UInt64
    /// 實體記憶體總量
    public let total: UInt64

    public init(used: UInt64, total: UInt64) {
        self.used = used
        self.total = total
    }

    /// 已使用的比例（0–1）；總量為 0 時為 nil
    public var fraction: Double? {
        guard total > 0 else {
            return nil
        }
        return min(Double(used) / Double(total), 1)
    }
}
