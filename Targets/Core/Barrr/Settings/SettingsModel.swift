/// 管理視窗的狀態與操作：登入時開啟
@MainActor
public struct SettingsModel {
    public private(set) var launchesAtLogin: Bool
    /// 最近一次設定失敗的原因；成功後清掉
    public private(set) var failure: LoginItemError?

    private let loginItem: any LoginItemController

    public init(loginItem: any LoginItemController) {
        self.loginItem = loginItem
        launchesAtLogin = loginItem.isEnabled()
    }

    public mutating func setLaunchesAtLogin(_ enabled: Bool) {
        do throws(LoginItemError) {
            try loginItem.setEnabled(enabled)
            failure = nil
        } catch {
            failure = error
        }
        // 以系統的狀態為準（例如被使用者在系統設定關掉）
        launchesAtLogin = loginItem.isEnabled()
    }
}
