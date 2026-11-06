/// `UserDefaultsCenter` 底層的儲存，只提供需要的型別；live 實作為 App 的 `LiveUserDefaultsStorage`（可指定網域），測試注入記憶體實作
public protocol UserDefaultsStorage: Sendable {
    /// 沒有存過或存的不是字串陣列時為 nil
    func stringArray(forKey key: String) -> [String]?
    func set(_ value: [String], forKey key: String)
    func removeObject(forKey key: String)
}
