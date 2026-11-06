import NoSleepCore

/// 記錄呼叫的替身：`hold` 一律回傳識別碼 `assertionID`，給定的錯誤不為 nil 時拋出它
struct RecordingAwakeController: AwakeController {
    enum Call: Equatable, Sendable {
        case hold(AwakeMode)
        case release(AwakeAssertion)
    }

    static let assertionID: UInt32 = 42

    private let holdError: AwakeControlError?
    private let releaseError: AwakeControlError?
    private let calls: AsyncStream<Call>
    private let continuation: AsyncStream<Call>.Continuation

    init(holdError: AwakeControlError? = nil, releaseError: AwakeControlError? = nil) {
        self.holdError = holdError
        self.releaseError = releaseError
        (calls, continuation) = AsyncStream.makeStream()
    }

    func hold(_ mode: AwakeMode) throws(AwakeControlError) -> AwakeAssertion {
        continuation.yield(.hold(mode))
        if let holdError {
            throw holdError
        }
        return AwakeAssertion(id: Self.assertionID, mode: mode)
    }

    func release(_ assertion: AwakeAssertion) throws(AwakeControlError) {
        continuation.yield(.release(assertion))
        if let releaseError {
            throw releaseError
        }
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
}
