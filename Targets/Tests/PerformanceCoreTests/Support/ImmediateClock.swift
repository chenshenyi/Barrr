/// 不等待的時鐘：`now` 固定、`sleep` 立刻返回（task 已取消時拋出），測試不必等真實時間
struct ImmediateClock: Clock {
    struct Instant: InstantProtocol {
        let offset: Duration

        func advanced(by duration: Duration) -> Self {
            Self(offset: offset + duration)
        }

        func duration(to other: Self) -> Duration {
            other.offset - offset
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.offset < rhs.offset
        }
    }

    let now = Instant(offset: .zero)
    let minimumResolution: Duration = .zero

    func sleep(until _: Instant, tolerance _: Duration?) async throws {
        try Task.checkCancellation()
    }
}
