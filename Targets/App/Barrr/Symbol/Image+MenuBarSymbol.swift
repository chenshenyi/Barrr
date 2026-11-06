import SwiftUI

extension Image {
    /// SF Symbol 只能經由這裡以 `MenuBarSymbol` 建立（SwiftLint `system_image_via_extension`）
    init(_ symbol: MenuBarSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}
