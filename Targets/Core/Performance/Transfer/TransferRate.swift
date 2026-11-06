/// 每秒傳輸的位元組：磁碟的 incoming 是讀取、outgoing 是寫入；網路的 incoming 是下載、outgoing 是上傳
public struct TransferRate: Equatable, Sendable {
    public let incomingPerSecond: Double
    public let outgoingPerSecond: Double

    public init(incomingPerSecond: Double, outgoingPerSecond: Double) {
        self.incomingPerSecond = incomingPerSecond
        self.outgoingPerSecond = outgoingPerSecond
    }
}
