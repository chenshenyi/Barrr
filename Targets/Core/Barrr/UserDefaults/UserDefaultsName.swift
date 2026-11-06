/// 所有存進 UserDefaults 的值；raw value 是存進去的名稱，編譯器保證不重複，存過之後不可更改
public enum UserDefaultsName: String, CaseIterable, Sendable {
    /// 工具在選單列的順序（`Tool` 的 raw value）
    case toolOrder
    /// 隱藏的工具（`Tool` 的 raw value）
    case toolHidden
}
