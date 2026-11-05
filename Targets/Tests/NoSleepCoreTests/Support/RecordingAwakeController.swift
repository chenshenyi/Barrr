import NoSleepCore

/// 記錄呼叫的替身：回傳建立時給定的狀態，`error` 不為 nil 時每個操作都拋出它
struct RecordingAwakeController: AwakeController {
    enum Call: Equatable, Sendable {
        case activeMode
        case start(AwakeMode)
        case stop
    }

    private let mode: AwakeMode?
    private let error: AwakeControlError?
    private let calls: AsyncStream<Call>
    private let continuation: AsyncStream<Call>.Continuation

    init(activeMode: AwakeMode? = nil, error: AwakeControlError? = nil) {
        mode = activeMode
        self.error = error
        (calls, continuation) = AsyncStream.makeStream()
    }

    func activeMode() throws(AwakeControlError) -> AwakeMode? {
        try record(.activeMode)
        return mode
    }

    func start(_ mode: AwakeMode) throws(AwakeControlError) {
        try record(.start(mode))
    }

    func stop() throws(AwakeControlError) {
        try record(.stop)
    }

    /// 依序的呼叫；取得後不再記錄
    func recordedCalls() async -> [Call] {
        continuation.finish()
        var recorded: [Call] = []
        for await call in calls {
            recorded.append(call)
        }
        return recorded
    }

    private func record(_ call: Call) throws(AwakeControlError) {
        continuation.yield(call)
        if let error {
            throw error
        }
    }
}
