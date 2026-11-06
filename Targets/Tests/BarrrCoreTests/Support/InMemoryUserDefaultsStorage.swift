import BarrrCore

/// 記憶體實作的儲存：讀取建立時給定的內容，寫入依序記下（不改變讀到的內容，見單元測試規則的 Independent）
struct InMemoryUserDefaultsStorage: UserDefaultsStorage {
    enum Write: Equatable, Sendable {
        case set([String], key: String)
        case remove(key: String)
    }

    private let values: [String: [String]]
    private let writes: AsyncStream<Write>
    private let continuation: AsyncStream<Write>.Continuation

    init(values: [String: [String]] = [:]) {
        self.values = values
        (writes, continuation) = AsyncStream.makeStream()
    }

    func stringArray(forKey key: String) -> [String]? {
        values[key]
    }

    func set(_ value: [String], forKey key: String) {
        continuation.yield(.set(value, key: key))
    }

    func removeObject(forKey key: String) {
        continuation.yield(.remove(key: key))
    }

    /// 依序的寫入；取得後不再記錄
    func recordedWrites() async -> [Write] {
        continuation.finish()
        var recorded: [Write] = []
        for await write in writes {
            recorded.append(write)
        }
        return recorded
    }
}
