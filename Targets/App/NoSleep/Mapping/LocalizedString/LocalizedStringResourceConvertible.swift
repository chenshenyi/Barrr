import Foundation

/// 值對應到顯示文字（概念同 `CustomStringConvertible`），顯示時直接 `Text(value)`
protocol LocalizedStringResourceConvertible: Sendable {
    var localizedStringResource: LocalizedStringResource { get }
}
