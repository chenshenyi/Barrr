/// 帶著值型別的 key：讀寫的型別由 key 決定，`UserDefaultsCenter` 不會讀寫出別的型別
///
/// 每個 `UserDefaultsName` 只能用在一個 key；新增設定值時在 `UserDefaultsName` 加 case，再在下方的 extension 宣告 key。
public struct UserDefaultsKey<Value: UserDefaultsValue>: Sendable {
    public let name: UserDefaultsName

    init(_ name: UserDefaultsName) {
        self.name = name
    }
}

extension UserDefaultsKey where Value == [String] {
    /// generic 型別不能有 static stored property，以 computed property 提供
    static var toolOrder: Self {
        Self(.toolOrder)
    }

    static var toolHidden: Self {
        Self(.toolHidden)
    }
}
