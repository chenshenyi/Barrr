/// 一個網路介面開機以來收送的位元組；系統以 32 位元計數，超過 4 GB 會從 0 重新開始
public struct InterfaceCounters: Equatable, Sendable {
    public let received: UInt32
    public let sent: UInt32

    public init(received: UInt32, sent: UInt32) {
        self.received = received
        self.sent = sent
    }
}
