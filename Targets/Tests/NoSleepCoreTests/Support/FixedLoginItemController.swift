import NoSleepCore

/// 固定狀態的替身：`isEnabled` 一律回傳建立時給定的值，`setEnabled` 在 `error` 不為 nil 時拋出它
struct FixedLoginItemController: LoginItemController {
    private let enabled: Bool
    private let error: LoginItemError?

    init(enabled: Bool = false, error: LoginItemError? = nil) {
        self.enabled = enabled
        self.error = error
    }

    func isEnabled() -> Bool {
        enabled
    }

    func setEnabled(_: Bool) throws(LoginItemError) {
        if let error {
            throw error
        }
    }
}
