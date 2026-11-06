import Foundation

/// 系統效能數字的顯示格式；讀不到的值顯示破折號
enum PerformanceFormat: Sendable {
    private static let unavailable = "–"
    private static let wattsFractionDigits = 1

    /// 比例（0–1）顯示成整數百分比
    static func percent(_ fraction: Double?) -> String {
        guard let fraction else {
            return unavailable
        }
        return fraction.formatted(.percent.precision(.fractionLength(0)))
    }

    /// 位元組顯示成記憶體的單位（GB 等，以 1024 為進位）
    static func memory(_ count: UInt64?) -> String {
        guard let count else {
            return unavailable
        }
        return Int64(clamping: count).formatted(.byteCount(style: .memory))
    }

    /// 位元組顯示成檔案的單位（GB 等，以 1000 為進位，與 Finder 相同）
    static func file(_ count: UInt64?) -> String {
        guard let count else {
            return unavailable
        }
        return Int64(clamping: count).formatted(.byteCount(style: .file))
    }

    /// 每秒的位元組，單位同檔案（「/s」在文字裡）
    static func rate(_ bytesPerSecond: Double?) -> String {
        file(bytesPerSecond.map { UInt64(max($0, 0).rounded()) })
    }

    /// 功率（瓦），一位小數
    static func watts(_ watts: Double?) -> String {
        guard let watts else {
            return unavailable
        }
        return Measurement(value: watts, unit: UnitPower.watts).formatted(.measurement(
            width: .abbreviated,
            usage: .asProvided,
            numberFormatStyle: .number.precision(.fractionLength(wattsFractionDigits))
        ))
    }
}
