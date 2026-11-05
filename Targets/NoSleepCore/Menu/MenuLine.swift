/// 選單內容的一行：項目或分隔線
public enum MenuLine: Equatable, Sendable {
    case item(MenuItem)
    case separator
}
