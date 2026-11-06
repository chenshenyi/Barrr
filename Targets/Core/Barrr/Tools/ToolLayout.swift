/// 工具在選單列的順序與是否顯示；至少保留一個顯示中的工具（否則沒有入口可以再次開啟管理視窗以外的功能）
public struct ToolLayout: Equatable, Sendable {
    /// 所有工具的順序（含隱藏的），每個工具剛好出現一次
    public private(set) var order: [Tool]
    public private(set) var hidden: Set<Tool>

    /// 預設：`Tool` 宣告的順序，全部顯示
    public init() {
        order = Tool.allCases
        hidden = []
    }

    /// 由儲存的識別碼還原：忽略不認得或重複的識別碼，新增的工具接在最後並顯示；若全部隱藏則顯示第一個
    public init(storedOrder: [String], storedHidden: [String]) {
        var order: [Tool] = []
        for tool in storedOrder.compactMap(Tool.init(rawValue:)) where !order.contains(tool) {
            order.append(tool)
        }
        order += Tool.allCases.filter { !order.contains($0) }
        self.order = order
        hidden = Set(storedHidden.compactMap(Tool.init(rawValue:)))
        if let first = order.first, visibleTools.isEmpty {
            hidden.remove(first)
        }
    }

    /// 儲存用的識別碼
    public var storedOrder: [String] {
        order.map(\.rawValue)
    }

    /// 儲存用的識別碼，依 `order` 排序（結果固定，方便比對）
    public var storedHidden: [String] {
        order.filter(hidden.contains).map(\.rawValue)
    }

    /// 顯示中的工具，依選單列的順序
    public var visibleTools: [Tool] {
        order.filter { !hidden.contains($0) }
    }

    public func isVisible(_ tool: Tool) -> Bool {
        !hidden.contains(tool)
    }

    /// 是否允許隱藏：最後一個顯示中的工具不能隱藏
    public func canHide(_ tool: Tool) -> Bool {
        !isVisible(tool) || visibleTools.count > 1
    }

    public mutating func setVisible(_ tool: Tool, _ visible: Bool) {
        if visible {
            hidden.remove(tool)
        } else if canHide(tool) {
            hidden.insert(tool)
        }
    }

    /// 把 `source` 位置的工具移到 `destination` 之前（語意同 SwiftUI 的 `onMove`：`destination` 是移動前的位置，可以等於 `order.count`）
    public mutating func move(from source: Int, to destination: Int) {
        guard order.indices.contains(source), (order.startIndex ... order.endIndex).contains(destination) else {
            return
        }
        let tool = order.remove(at: source)
        order.insert(tool, at: destination > source ? destination - 1 : destination)
    }
}
