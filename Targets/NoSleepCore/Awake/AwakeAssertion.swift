/// 向系統要到的「不休眠」：持有期間系統依 `mode` 不休眠，交還後恢復
///
/// 實際上擁有唯一的系統資源，但要存進 SwiftUI 的 `@State`（需要可複製），因此不宣告 `~Copyable`；
/// 只由 `NoSleepModel` 持有，交還後就丟掉。
public struct AwakeAssertion: Equatable, Sendable {
    /// 系統給的識別碼（IOKit 的 `IOPMAssertionID`）
    public let id: UInt32
    public let mode: AwakeMode

    public init(id: UInt32, mode: AwakeMode) {
        self.id = id
        self.mode = mode
    }
}
