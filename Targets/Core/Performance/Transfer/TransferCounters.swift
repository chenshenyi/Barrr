/// 開機以來累計傳輸的位元組：磁碟的 incoming 是讀取、outgoing 是寫入
public struct TransferCounters: Equatable, Sendable {
    public let incoming: UInt64
    public let outgoing: UInt64

    public init(incoming: UInt64, outgoing: UInt64) {
        self.incoming = incoming
        self.outgoing = outgoing
    }

    /// 從 `previous` 到這次的每秒傳輸量；時間不大於 0 或計數倒退時為 nil
    public func rate(since previous: Self, seconds: Double) -> TransferRate? {
        guard seconds > 0, incoming >= previous.incoming, outgoing >= previous.outgoing else {
            return nil
        }
        return TransferRate(
            incomingPerSecond: Double(incoming - previous.incoming) / seconds,
            outgoingPerSecond: Double(outgoing - previous.outgoing) / seconds
        )
    }
}
