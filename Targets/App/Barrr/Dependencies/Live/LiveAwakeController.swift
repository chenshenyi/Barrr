import IOKit.pwr_mgt
import NoSleepCore

/// 以 IOKit 的 power assertion 保持不休眠，與 `caffeinate` 用的是同一個機制
///
/// assertion 屬於這個 process：App 結束（含當掉）時系統自動交還，恢復照系統設定休眠。
struct LiveAwakeController: AwakeController, Sendable {
    /// 顯示在 `pmset -g assertions` 的名稱
    private static let assertionName = "No Sleep"

    func hold(_ mode: AwakeMode) throws(AwakeControlError) -> AwakeAssertion {
        guard let type = Self.cfString(Self.assertionType(of: mode)),
              let name = Self.cfString(Self.assertionName)
        else {
            throw .holdFailed(code: kIOReturnBadArgument)
        }
        var id = IOPMAssertionID(kIOPMNullAssertionID)
        let result = IOPMAssertionCreateWithName(type, IOPMAssertionLevel(kIOPMAssertionLevelOn), name, &id)
        guard result == kIOReturnSuccess else {
            throw .holdFailed(code: result)
        }
        return AwakeAssertion(id: id, mode: mode)
    }

    func release(_ assertion: AwakeAssertion) throws(AwakeControlError) {
        let result = IOPMAssertionRelease(assertion.id)
        guard result == kIOReturnSuccess else {
            throw .releaseFailed(code: result)
        }
    }

    private static func assertionType(of mode: AwakeMode) -> String {
        switch mode {
        // 螢幕不關，系統因此也不睡
        case .keepDisplayOn: kIOPMAssertionTypePreventUserIdleDisplaySleep
        case .allowDisplaySleep: kIOPMAssertionTypePreventUserIdleSystemSleep
        }
    }

    /// IOKit 要 CFString；以建立的方式轉換，不用 `as` 轉型
    private static func cfString(_ string: String) -> CFString? {
        CFStringCreateWithCString(kCFAllocatorDefault, string, CFStringBuiltInEncodings.UTF8.rawValue)
    }
}
