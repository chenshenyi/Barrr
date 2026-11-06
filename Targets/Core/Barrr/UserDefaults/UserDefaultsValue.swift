/// 可以存進 UserDefaults 的值；每種型別決定怎麼經由 `UserDefaultsStorage` 讀寫（目前只需要字串陣列）
public protocol UserDefaultsValue: Sendable {
    /// 沒有存過或存的不是這個型別時為 nil
    static func read(_ name: String, from storage: any UserDefaultsStorage) -> Self?
    func write(_ name: String, to storage: any UserDefaultsStorage)
}

extension [String]: UserDefaultsValue {
    public static func read(_ name: String, from storage: any UserDefaultsStorage) -> Self? {
        storage.stringArray(forKey: name)
    }

    public func write(_ name: String, to storage: any UserDefaultsStorage) {
        storage.set(self, forKey: name)
    }
}
