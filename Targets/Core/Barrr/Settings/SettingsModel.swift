/// 管理視窗的狀態與操作：工具的順序與顯示、登入時開啟
@MainActor
public struct SettingsModel {
    public private(set) var layout: ToolLayout
    public private(set) var launchesAtLogin: Bool
    /// 最近一次設定登入時開啟失敗的原因；成功後清掉
    public private(set) var failure: LoginItemError?

    private let loginItem: any LoginItemController
    private let layoutStorage: any ToolLayoutStorage

    public init(loginItem: any LoginItemController, layoutStorage: any ToolLayoutStorage) {
        self.loginItem = loginItem
        self.layoutStorage = layoutStorage
        layout = layoutStorage.load() ?? ToolLayout()
        launchesAtLogin = loginItem.isEnabled()
    }

    public mutating func setVisible(_ tool: Tool, _ visible: Bool) {
        layout.setVisible(tool, visible)
        layoutStorage.save(layout)
    }

    public mutating func moveTool(from source: Int, to destination: Int) {
        layout.move(from: source, to: destination)
        layoutStorage.save(layout)
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
