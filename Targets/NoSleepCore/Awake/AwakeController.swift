/// 向系統要求與交還「不休眠」；live 實作在 App 的 `Dependencies/Live/`
public protocol AwakeController: Sendable {
    func hold(_ mode: AwakeMode) throws(AwakeControlError) -> AwakeAssertion
    func release(_ assertion: AwakeAssertion) throws(AwakeControlError)
}
