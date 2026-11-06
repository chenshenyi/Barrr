/// 不休眠選單的狀態與操作：目前持有的不休眠與最近一次的失敗
///
/// 狀態只在 App 內：App 結束時系統會自動交還它持有的不休眠。
@MainActor
public struct NoSleepModel {
    public private(set) var assertion: AwakeAssertion?
    /// 最近一次操作失敗的原因；下一次操作時清掉
    public private(set) var failure: AwakeControlError?

    private let awake: any AwakeController

    public init(awake: any AwakeController) {
        self.awake = awake
    }

    /// 生效中的方式；nil 表示照系統設定休眠
    public var activeMode: AwakeMode? {
        assertion?.mode
    }

    /// 選了生效中的方式就恢復休眠，否則換成這個方式（一次只有一種方式生效）
    public mutating func toggle(_ mode: AwakeMode) {
        failure = nil
        let isActive = activeMode == mode
        if let assertion {
            do throws(AwakeControlError) {
                try awake.release(assertion)
                self.assertion = nil
            } catch {
                // 交還失敗時保留目前的，不再要求新的
                failure = error
                return
            }
        }
        guard !isActive else {
            return
        }
        do throws(AwakeControlError) {
            assertion = try awake.hold(mode)
        } catch {
            failure = error
        }
    }

    /// 恢復照系統設定休眠（例如隱藏這個工具時，不留下看不到的不休眠）
    public mutating func allowSleep() {
        if let activeMode {
            toggle(activeMode)
        }
    }
}
