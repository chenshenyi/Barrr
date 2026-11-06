import Foundation
import NoSleepCore

extension AwakeControlError: LocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .holdFailed: .failureHold
        case .releaseFailed: .failureRelease
        }
    }
}
