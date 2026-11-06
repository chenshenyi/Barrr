import Foundation
import NoSleepCore

extension AwakeMode: LocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .keepDisplayOn: .modeKeepDisplayOn
        case .allowDisplaySleep: .modeAllowDisplaySleep
        }
    }
}
