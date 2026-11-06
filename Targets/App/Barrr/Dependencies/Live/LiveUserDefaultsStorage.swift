import BarrrCore
import Foundation

/// 以 `UserDefaults` 實作的儲存；`suiteName` 為 nil 時是 App 的預設網域
///
/// `UserDefaults` 不是 Sendable，因此不持有實例，每次讀寫建立新的實例（底層的快取由系統共用）
struct LiveUserDefaultsStorage: UserDefaultsStorage, Sendable {
    private let suiteName: String?

    init(suiteName: String? = nil) {
        self.suiteName = suiteName
    }

    func stringArray(forKey key: String) -> [String]? {
        defaults().stringArray(forKey: key)
    }

    func set(_ value: [String], forKey key: String) {
        defaults().set(value, forKey: key)
    }

    func removeObject(forKey key: String) {
        defaults().removeObject(forKey: key)
    }

    private func defaults() -> UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? UserDefaults()
    }
}
