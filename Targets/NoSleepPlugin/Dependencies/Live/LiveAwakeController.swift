import Foundation
import NoSleepCore

/// 以 launchd 管理的 `caffeinate` 保持不休眠：每種方式一個 launchd job，job 存在就是生效中
///
/// 交給 launchd 而不是自己 spawn，是因為 SwiftBar 執行完 plugin 就結束，`caffeinate` 要活得比 plugin 久；
/// `launchctl submit` 的 job 不寫進磁碟，登出或重開機後自動消失，恢復照系統設定休眠。
struct LiveAwakeController: AwakeController, Sendable {
    private static let launchctl = URL(filePath: "/bin/launchctl")
    private static let caffeinate = "/usr/bin/caffeinate"
    private static let labelPrefix = "tw.chenshenyi.nosleep."
    private static let list = "list"
    private static let submit = "submit"
    private static let remove = "remove"
    private static let labelOption = "-l"
    private static let endOfOptions = "--"
    /// `launchctl list <label>` 找不到 job 時的狀態（ESRCH）
    private static let jobNotFound: Int32 = 113

    func activeMode() throws(AwakeControlError) -> AwakeMode? {
        for mode in AwakeMode.allCases where try isRunning(mode) {
            return mode
        }
        return nil
    }

    func start(_ mode: AwakeMode) throws(AwakeControlError) {
        try check(run([Self.submit, Self.labelOption, label(of: mode), Self.endOfOptions, Self.caffeinate]
                + mode.caffeinateFlags))
    }

    func stop() throws(AwakeControlError) {
        for mode in AwakeMode.allCases where try isRunning(mode) {
            try check(run([Self.remove, label(of: mode)]))
        }
    }

    private func label(of mode: AwakeMode) -> String {
        Self.labelPrefix + mode.rawValue
    }

    private func isRunning(_ mode: AwakeMode) throws(AwakeControlError) -> Bool {
        let status = try run([Self.list, label(of: mode)])
        if status == Self.jobNotFound {
            return false
        }
        try check(status)
        return true
    }

    private func check(_ status: Int32) throws(AwakeControlError) {
        guard status == 0 else {
            throw .launchctlFailed(status: status)
        }
    }

    /// 執行 launchctl，輸出一律丟棄，回傳結束狀態
    private func run(_ arguments: [String]) throws(AwakeControlError) -> Int32 {
        let process = Process()
        process.executableURL = Self.launchctl
        process.arguments = arguments
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
        } catch {
            throw .launchctlUnavailable
        }
        process.waitUntilExit()
        return process.terminationStatus
    }
}
