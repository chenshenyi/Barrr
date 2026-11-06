import Foundation
import NoSleepCore

extension NoSleepFailure: LocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .awake(.holdFailed): .failureHold
        case .awake(.releaseFailed): .failureRelease
        case .loginItem: .failureLoginItem
        }
    }
}
