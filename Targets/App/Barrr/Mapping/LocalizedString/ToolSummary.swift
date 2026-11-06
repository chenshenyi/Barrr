import BarrrCore
import Foundation

/// 工具的一句話說明；工具名稱以外的第二種文字，包成獨立的型別才能沿用 `LocalizedStringResourceConvertible`
struct ToolSummary: LocalizedStringResourceConvertible, Sendable {
    let tool: Tool

    var localizedStringResource: LocalizedStringResource {
        switch tool {
        case .noSleep: .toolNoSleepSummary
        case .performance: .toolPerformanceSummary
        }
    }
}
