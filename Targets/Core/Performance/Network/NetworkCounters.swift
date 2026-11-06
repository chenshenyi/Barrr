/// 所有網路介面（不含 loopback）的收送計數，以介面名稱為 key
public struct NetworkCounters: Equatable, Sendable {
    public let interfaces: [String: InterfaceCounters]

    public init(interfaces: [String: InterfaceCounters]) {
        self.interfaces = interfaces
    }

    /// 從 `previous` 到這次的每秒下載與上傳量；時間不大於 0 時為 nil
    ///
    /// 逐個介面計算差值再加總：32 位元計數繞回時以溢位減法取得正確的差（取樣間隔內不會超過 4 GB）；
    /// 只出現在其中一次的介面（剛連上或斷開）不計入。
    public func rate(since previous: Self, seconds: Double) -> TransferRate? {
        guard seconds > 0 else {
            return nil
        }
        var received: UInt64 = 0
        var sent: UInt64 = 0
        for (name, current) in interfaces {
            guard let before = previous.interfaces[name] else {
                continue
            }
            received += UInt64(current.received &- before.received)
            sent += UInt64(current.sent &- before.sent)
        }
        return TransferRate(incomingPerSecond: Double(received) / seconds, outgoingPerSecond: Double(sent) / seconds)
    }
}
