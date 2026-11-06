/// 以 `UserDefaultsCenter` 保存工具的順序與顯示設定（存 `Tool` 的 raw value 陣列）
public struct UserDefaultsToolLayoutStorage: ToolLayoutStorage, Sendable {
    private let center: UserDefaultsCenter

    public init(center: UserDefaultsCenter) {
        self.center = center
    }

    public func load() -> ToolLayout? {
        guard let order = center.value(for: .toolOrder) else {
            return nil
        }
        return ToolLayout(storedOrder: order, storedHidden: center.value(for: .toolHidden) ?? [])
    }

    public func save(_ layout: ToolLayout) {
        center.setValue(layout.storedOrder, for: .toolOrder)
        center.setValue(layout.storedHidden, for: .toolHidden)
    }
}
