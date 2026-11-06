import BarrrCore
import Foundation

extension LoginItemError: LocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .registerFailed: .failureRegisterLoginItem
        case .unregisterFailed: .failureUnregisterLoginItem
        }
    }
}
