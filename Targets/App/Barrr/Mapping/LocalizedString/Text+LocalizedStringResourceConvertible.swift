import SwiftUI

extension Text {
    init(_ value: some LocalizedStringResourceConvertible) {
        self.init(value.localizedStringResource)
    }
}
