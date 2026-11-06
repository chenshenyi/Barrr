/// 存取 UserDefaults 的唯一入口：key 一律是 `UserDefaultsKey`，值的型別由 key 決定；底層的儲存由外部注入
public struct UserDefaultsCenter: Sendable {
    private let storage: any UserDefaultsStorage

    public init(storage: any UserDefaultsStorage) {
        self.storage = storage
    }

    /// 沒有存過時回傳 nil
    public func value<Value>(for key: UserDefaultsKey<Value>) -> Value? {
        Value.read(key.name.rawValue, from: storage)
    }

    public func setValue<Value>(_ value: Value, for key: UserDefaultsKey<Value>) {
        value.write(key.name.rawValue, to: storage)
    }

    public func removeValue(for key: UserDefaultsKey<some UserDefaultsValue>) {
        storage.removeObject(forKey: key.name.rawValue)
    }
}
