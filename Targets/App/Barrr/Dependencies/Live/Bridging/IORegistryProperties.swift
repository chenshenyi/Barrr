import Foundation
import IOKit

/// 讀出 IORegistry 項目的所有屬性
enum IORegistryProperties: Sendable {
    /// 讀不到或不是字典時為 nil
    static func read(_ entry: io_registry_entry_t) -> [String: Any]? {
        var properties: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0) == KERN_SUCCESS else {
            return nil
        }
        return UntypedValue.dictionary(properties?.takeRetainedValue())
    }
}
