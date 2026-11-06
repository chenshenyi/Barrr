import BarrrCore

/// 記錄寫入的替身：`load` 回傳建立時給定的內容，`save` 依序記下
struct RecordingToolLayoutStorage: ToolLayoutStorage {
    private let stored: ToolLayout?
    private let saves: AsyncStream<ToolLayout>
    private let continuation: AsyncStream<ToolLayout>.Continuation

    init(stored: ToolLayout? = nil) {
        self.stored = stored
        (saves, continuation) = AsyncStream.makeStream()
    }

    func load() -> ToolLayout? {
        stored
    }

    func save(_ layout: ToolLayout) {
        continuation.yield(layout)
    }

    /// 依序寫入的內容；取得後不再記錄
    func savedLayouts() async -> [ToolLayout] {
        continuation.finish()
        var recorded: [ToolLayout] = []
        for await layout in saves {
            recorded.append(layout)
        }
        return recorded
    }
}
