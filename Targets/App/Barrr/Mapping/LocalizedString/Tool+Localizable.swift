import BarrrCore
import Foundation

extension Tool: LocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noSleep: .toolNoSleep
        case .performance: .toolPerformance
        }
    }
}
