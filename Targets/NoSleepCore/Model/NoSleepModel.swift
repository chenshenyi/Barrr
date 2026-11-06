/// 選單的狀態與操作：目前持有的不休眠、登入時開啟、最近一次的失敗
///
/// 狀態只在 App 內：系統不提供「目前誰在阻止休眠」以外的查詢，App 結束時系統會自動交還它持有的不休眠。
@MainActor
public struct NoSleepModel {
    public private(set) var assertion: AwakeAssertion?
    public private(set) var launchesAtLogin: Bool
    public private(set) var failure: NoSleepFailure?

    private let awake: any AwakeController
    private let loginItem: any LoginItemController

    public init(awake: any AwakeController, loginItem: any LoginItemController) {
        self.awake = awake
        self.loginItem = loginItem
        launchesAtLogin = loginItem.isEnabled()
    }

    /// 生效中的方式；nil 表示照系統設定休眠
    public var activeMode: AwakeMode? {
        assertion?.mode
    }

    /// 選了生效中的方式就恢復休眠，否則換成這個方式（一次只有一種方式生效）
    public mutating func toggle(_ mode: AwakeMode) {
        let isActive = activeMode == mode
        guard releaseCurrent(), !isActive else {
            return
        }
        do throws(AwakeControlError) {
            assertion = try awake.hold(mode)
        } catch {
            failure = .awake(error)
        }
    }

    /// 恢復照系統設定休眠
    public mutating func resume() {
        releaseCurrent()
    }

    public mutating func setLaunchesAtLogin(_ enabled: Bool) {
        do throws(LoginItemError) {
            try loginItem.setEnabled(enabled)
            failure = nil
        } catch {
            failure = .loginItem(error)
        }
        // 以系統的狀態為準（例如被使用者在系統設定關掉）
        launchesAtLogin = loginItem.isEnabled()
    }

    /// 交還目前持有的不休眠；失敗時保留它並記下原因，回傳是否成功
    @discardableResult
    private mutating func releaseCurrent() -> Bool {
        failure = nil
        guard let assertion else {
            return true
        }
        do throws(AwakeControlError) {
            try awake.release(assertion)
            self.assertion = nil
            return true
        } catch {
            failure = .awake(error)
            return false
        }
    }
}
