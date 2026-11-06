import BarrrCore
import ServiceManagement

/// 以 `SMAppService.mainApp` 設定登入時開啟（出現在系統設定的「登入項目」）
struct LiveLoginItemController: LoginItemController, Sendable {
    func isEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) throws(LoginItemError) {
        if enabled {
            do {
                try SMAppService.mainApp.register()
            } catch {
                throw .registerFailed
            }
        } else {
            do {
                try SMAppService.mainApp.unregister()
            } catch {
                throw .unregisterFailed
            }
        }
    }
}
