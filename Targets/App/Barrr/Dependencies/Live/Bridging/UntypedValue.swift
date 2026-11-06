import Foundation

/// 讀出系統交出的 untyped 值（IOKit／CoreFoundation 的 `CFTypeRef`、CF 字典裡的值）
///
/// 這些 API 沒有型別，讀出時必須轉型；這是專案唯一允許轉型的檔案（SwiftLint `no_type_cast` 只排除本檔），
/// 其餘程式碼一律經由這裡取得具體型別。只做條件轉型（`as?`），型別不符時回傳 nil，由呼叫端轉成具體的錯誤；
/// 不用 `as!`、`unsafeBitCast`。
enum UntypedValue: Sendable {
    /// CF 字典轉成以字串為 key 的字典
    static func dictionary(_ value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }

    static func integer(_ value: Any?) -> Int? {
        (value as? NSNumber)?.intValue
    }

    static func unsignedInteger(_ value: Any?) -> UInt64? {
        (value as? NSNumber)?.uint64Value
    }

    /// CFBoolean 以 NSNumber 橋接
    static func boolean(_ value: Any?) -> Bool? {
        (value as? NSNumber)?.boolValue
    }
}
