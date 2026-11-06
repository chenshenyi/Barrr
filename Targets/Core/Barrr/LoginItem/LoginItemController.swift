/// 登入時是否自動開啟 App；live 實作在 App 的 `Dependencies/Live/`
public protocol LoginItemController: Sendable {
    func isEnabled() -> Bool
    func setEnabled(_ enabled: Bool) throws(LoginItemError)
}
