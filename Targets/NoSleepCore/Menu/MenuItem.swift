/// 選單的一行
public struct MenuItem: Equatable, Sendable {
    public let title: String
    /// SF Symbol 名稱
    public let symbol: String?
    /// 點選時以這個指令重新執行自己；nil 時只顯示文字
    public let command: Command?
    public let isChecked: Bool

    public init(title: String, symbol: String? = nil, command: Command? = nil, isChecked: Bool = false) {
        self.title = title
        self.symbol = symbol
        self.command = command
        self.isChecked = isChecked
    }
}
