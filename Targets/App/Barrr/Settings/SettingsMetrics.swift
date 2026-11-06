import CoreGraphics

/// 管理視窗共用的尺寸
enum SettingsMetrics: Sendable {
    /// 卡片（玻璃）的內距與內容間距
    static let cardPadding: CGFloat = 12
    /// 工具清單一列的高度
    static let toolRowHeight: CGFloat = 60
    /// 卡片的圓角
    static let cardCornerRadius: CGFloat = 18
    /// 區塊標題、內容與說明之間的距離
    static let sectionSpacing: CGFloat = 8
    /// 頂端 App 圖示的大小與它和名稱的距離
    static let headerIconSize: CGFloat = 64
    static let headerSpacing: CGFloat = 16
}
