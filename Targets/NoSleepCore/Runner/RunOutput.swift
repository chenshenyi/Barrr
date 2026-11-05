/// 一次執行的結果：要輸出的內容與結束狀態
public struct RunOutput: Equatable, Sendable {
    public let lines: [String]
    public let succeeded: Bool

    public init(lines: [String], succeeded: Bool) {
        self.lines = lines
        self.succeeded = succeeded
    }
}
