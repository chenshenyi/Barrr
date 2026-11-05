/// 開關「不休眠」的系統操作；live 實作在 NoSleepPlugin 的 `Dependencies/Live/`
public protocol AwakeController: Sendable {
    /// 目前生效的方式，沒有時為 nil（恢復休眠）
    func activeMode() throws(AwakeControlError) -> AwakeMode?
    /// 以指定方式開始不休眠；呼叫前其他方式應已停止
    func start(_ mode: AwakeMode) throws(AwakeControlError)
    /// 停止所有方式，恢復休眠；沒有生效的方式時不做任何事
    func stop() throws(AwakeControlError)
}
