/// 保存工具的順序與顯示設定；live 實作在 App 的 `Dependencies/Live/`
public protocol ToolLayoutStorage: Sendable {
    /// 沒有存過時回傳 nil
    func load() -> ToolLayout?
    func save(_ layout: ToolLayout)
}
