import BarrrCore

/// App 用到的 SF Symbols
enum AppSymbol: String, Sendable {
    /// 不休眠：照系統設定休眠
    case sleepAllowed = "moon.zzz"
    /// 不休眠：保持清醒
    case awake = "cup.and.heat.waves.fill"
    /// 系統效能
    case performance = "gauge.with.dots.needle.50percent"
    /// 可拖曳排列
    case dragHandle = "line.3.horizontal"

    /// 管理視窗裡代表工具的圖示
    init(_ tool: Tool) {
        switch tool {
        case .noSleep: self = .awake
        case .performance: self = .performance
        }
    }
}
