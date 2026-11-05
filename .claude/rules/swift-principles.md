---
paths:
  - "Targets/**/*.swift"
---

# Swift 開發原則

## 核心思想

所有規則都為了同一件事：**錯誤在編譯或 lint 時就被擋下，執行期沒有意外**。新增規則或做取捨時回到這幾條，保證機制的優先順序見 `decision-order` skill（架構 > lint／format > 測試 > 文件）。

1. **值語意**：邏輯層只有 `struct`／`enum`，不宣告 class，也不使用以 class 為底的語法。class 只出現在無可避免的系統層（`Process`、`FileHandle` 等），而且一律包在 `Dependencies/Live/` 的 struct 裡，不往外露。
2. **型別安全**：型別在編譯期確定。不轉型（`as`／`is`）、不強制解包；指令、方式等選項都是 enum，不用字串比對。
3. **具體的錯誤**：每個錯誤都有具體的型別並被處理。一律 typed throws，錯誤型別是列出原因的 enum，禁止 `try?`。
4. **並行安全**：每個型別明確宣告 `Sendable`，擁有唯一資源的型別宣告為 `~Copyable`，不用 `@unchecked Sendable` 規避檢查。
5. **副作用可替換**：副作用只經過注入的依賴，live 實作集中在 `Dependencies/Live/`，測試注入不碰系統的替身。
6. **依賴最小**：每個檔案只 import 用到的最小 module，外部套件要有明確理由才加。

## ⚠️ 最小化外部依賴（高優先，必須遵守）

**通則**：每一個檔案都要盡可能減少對外部的依賴。
- 只 import 該檔案真的用到的 framework／module，用不到就刪。
- 能用更小的 module 就不用大的；Foundation 只在 `Dependencies/Live/` import（SwiftLint `system_framework_in_wrapper` 擋下其餘位置）。
- 編譯期保證：`Package.swift` 開啟 `MemberImportVisibility`，每個檔案只能使用自己 import 的模組成員，import 不會跨檔案外漏。

### 具體案例：純物件不依賴 Foundation

**純物件**是 `Targets/NoSleepCore/` 底下的型別（指令解析、選單內容、執行流程）。NoSleepCore 是 `Package.swift` 的獨立 module，不宣告任何依賴；`NoSleepPlugin` 以 `import NoSleepCore` 使用，對外的型別、成員與 init 宣告 `public`，只給內部或測試用的維持 internal（測試以 `@testable import NoSleepCore`）。
- 只用 Swift 標準函式庫表達，不可 `import Foundation`，也不可匯入平台框架；需要 Foundation 的功能時改用 `FoundationEssentials`，遇到它也沒有的 API 時，先列出來問使用者。
- 碰系統的操作以 protocol 宣告在 NoSleepCore（`AwakeController`），live 實作放在 `Targets/NoSleepPlugin/Dependencies/Live/`（`LiveAwakeController` 以 `launchctl` 管理 `caffeinate`）。
- SwiftLint `pure_type_import` 會擋下純物件檔案中不允許的 import（module 不宣告依賴擋不住 Foundation 等 SDK 模組，所以仍需要 lint）。

## 副作用一律依賴注入

會讀寫外部狀態、或結果每次不同的東西都是副作用，必須由外部注入，不可在使用處直接取用：

| 類別 | 禁止直接使用 | 注入方式 |
| --- | --- | --- |
| 時間 | `Date()`、`Date.now` | 注入 `@Sendable () -> Date` 或 provider |
| 計時／等待 | `Task.sleep`、`ContinuousClock()`、`SuspendingClock()` | 注入 `any Clock<Duration>` |
| 識別碼 | `UUID()` | 注入 `@Sendable () -> UUID` |
| 亂數 | `.random(…)`、`.randomElement()`、`.shuffled()`、`SystemRandomNumberGenerator` | 注入 `RandomNumberGenerator` |
| UserDefaults | `UserDefaults`、`@AppStorage` | 注入 |
| Keychain | `SecItemAdd`／`SecItemCopyMatching`／`SecItemUpdate`／`SecItemDelete` | 注入 keychain 存取型別 |
| 檔案系統 | `FileManager.default` | 注入 |
| 網路 | `URLSession.shared` | 注入 |
| 地區設定 | `Locale.current`、`TimeZone.current`、`Calendar.current` | 注入 |
| 通知 | `NotificationCenter.default` | 注入 |

- 依賴一律以 `init` 參數注入。
- 依賴的型別用 protocol 或 `@Sendable` closure 表達，方便測試替換成固定值的替身。
- 真正觸碰系統的 live 實作只能放在 `Targets/NoSleepPlugin/Dependencies/Live/`，在進入點（`NoSleepPlugin.swift`，composition root）建立後交給 `Runner`。
- 測試一律注入固定值或替身（`RecordingAwakeController`），符合 F.I.R.S.T. 的 Repeatable。
- SwiftLint `side_effect_via_dependency` 會擋下上表的直接使用（`Targets/NoSleepPlugin/Dependencies/Live/` 除外）。

## 禁止 Singleton

- 不可宣告任何 singleton：`static let shared`、`static var instance`、全域可變實體等一律禁止；需要共用的實體在 composition root 建立一次後以依賴注入往下傳。
- 不可直接取用系統 singleton（`UIApplication.shared`、`UIDevice.current`、`UIScreen.main`、`Bundle.main`、`ProcessInfo.processInfo`、`URLSession.shared`、`FileManager.default`、`UserDefaults.standard`、`NotificationCenter.default` 等）；需要時在 `Targets/NoSleepPlugin/Dependencies/Live/` 包成可注入的 live 實作。
- SwiftLint `no_singleton_declaration` 與 `no_singleton_access` 會擋下（後者 `Targets/NoSleepPlugin/Dependencies/Live/` 除外）；其他無法以 regex 偵測的形式（例如全域 `let` 的 class 實體）同樣禁止。

## 字面常數與 Magic Number

- 數字與字串字面常數不可散落在程式碼中，只能出現在具名常數的宣告處：`let`／`static let`、enum case raw value、switch case 的對應值。
- 允許的例外：數字 `0`、`1`、空字串 `""`、註解、`Targets/Tests/` 底下的測試資料。
- 共用的常數集中在語意化的型別中，不要在各處重複宣告同一個值；選單文字與圖示集中在 `MenuText`，SwiftBar 的語法常數在 `Menu+SwiftBar.swift`。
- SwiftLint `no_magic_numbers` 與 `no_inline_string_literal` 會擋下。

## 型別與狀態

- **只用 struct**：`Targets/` 的型別一律是 `struct`／`enum`。參考型別都不用，包含隱藏在語法後面的：`class`、`actor`、`@Observable`（巨集產生 class）、protocol 的 `AnyObject` 限制。
- 包裝系統物件（`Process` 等）的 live 實作也是 struct：使用時才建立系統物件，方法不改變自己；需要記住的狀態先找能從系統讀出的替代（例如 `LiveAwakeController` 以 launchd job 是否存在判斷狀態，不寫 pid 檔）。
- 想用參考型別的理由幾乎都是「多個實例要看到同一份可變資料」。先確認是否真的需要共用：常見的情況是寫法造成的，例如測試讓兩個實例共用 storage，可以改成由一方輸出值、另一方以這個值建立（見 `.claude/rules/unit-tests.md` 的 Independent）。
- 逼不得已要用參考型別時，先與使用者討論有沒有替代方案；確定要用時一律 `final class`，在 doc comment 註明原因並以 `// swiftlint:disable:this no_reference_type` 標示。目前沒有例外。
- **系統的 class 一律包裝**：`Foundation`、`AppKit`、`Dispatch` 等提供 class 的系統框架，只能在 `Dependencies/Live/` import；包裝它們的型別本身是 struct，對外只露出 protocol 與值型別。SwiftLint `system_framework_in_wrapper` 會擋下其餘位置的 import。
- 不用 Foundation 的 class 編解碼器（`JSONDecoder`／`JSONEncoder` 等）與 `Encodable`／`Codable`；需要 JSON 時先與使用者討論（Music-Tool 用 swift-json）。SwiftLint `no_foundation_coder` 會擋下。
- SwiftLint `no_reference_type` 會擋下上述寫法。`Targets/Tests/` 也適用：記錄呼叫的替身（`RecordingAwakeController`）是 struct，把呼叫 yield 進 `AsyncStream`，測試以 `recordedCalls()` 取得依序的呼叫。
- **禁止轉型**：不用 `as`、`as?`、`as!`、`is` 與 `unsafeBitCast`／`unsafeDowncast`，型別一律在編譯期確定。需要依型別分流時改用泛型、protocol、enum 的 associated value；`catch` 需要具體的錯誤型別時用 typed throws（`throws(AwakeControlError)`、`do throws(AwakeControlError) { … } catch { … }`）；字面值的型別用型別標註或 `init` 指定。SwiftLint `no_type_cast` 會擋下，範圍包含 `Targets/Tests/`。
- **不用 unsafe 指標**：連續記憶體用 `Span`／`MutableSpan` 或 `Array`，不用 `withUnsafeBufferPointer`、`UnsafePointer` 系列與 `Unmanaged`；系統 API 交出的指標只在 `Dependencies/Live/` 轉成 `Array`。SwiftLint `no_unsafe_pointer` 會擋下。
- **效能優化先量測**：先寫清楚、安全的版本，量測證明是瓶頸才換寫法。
- 存取控制從最小開始：預設 `private`，需要時再放寬。
- 優先 `let`，只有確實會變的才用 `var`。
- protocol 只用在邊界（依賴、可替換的實作），不為只有一個實作的型別硬加抽象。

## 並行

- Swift 6 strict concurrency。
- **能 Sendable 就 Sendable**：`Targets/NoSleepCore/` 與 `Targets/NoSleepPlugin/` 的每個 struct／enum／protocol 都明確宣告 `Sendable`（進入點、依賴的實作也一樣）。例外：遵循 `Error` 的型別本身就是 Sendable；標了 `@MainActor` 的型別因隔離已是 Sendable，重複宣告會被 SwiftLint `redundant_sendable` 擋下。明確宣告讓編譯器在加入非 Sendable 的成員時直接報錯，而不是默默失去推斷出的 Sendable。
  - 確實無法 Sendable 時以 `swiftlint:disable` 標示並註明原因。SwiftLint `explicit_sendable` 會擋下沒有宣告的型別。
- **能 `~Copyable` 就 `~Copyable`**：擁有唯一資源、複製會造成錯誤的型別（例如只能使用一次的 token、獨占的控制代碼）宣告為 `~Copyable`，用 `consuming`／`borrowing` 表達所有權。
  - 會放進 `Array`／`Dictionary`／`Set`、或需要 `Equatable`／`Hashable` 的型別都必須可複製，因此目前的型別都不適用；新增型別時先判斷是否擁有唯一資源。
  - 是否「能」不可複製取決於用途，lint 無法判斷，只靠本規則與 review。
- `AsyncStream` 只能在依賴實作（`Dependencies/`）與測試中建立，用來把系統的 callback 接成串流；功能程式只消費依賴回傳的串流。SwiftLint `async_stream_in_dependency` 會擋下其餘位置的建立。`AsyncStream` 是 struct（內部的 buffer 由標準函式庫以 class 管理，如同 `Array`）；swift-async-algorithms 的 `AsyncChannel` 是 class，不使用。
- 用 async/await 與 structured concurrency；不使用 completion handler、`DispatchQueue`、`Task.detached`（除非有明確理由並以 `swiftlint:disable` 註明）；SwiftLint `no_unstructured_concurrency` 會擋下。
- 不使用 `@unchecked Sendable`、`nonisolated(unsafe)` 規避檢查，SwiftLint `no_unchecked_sendable` 會擋下。包裝非 Sendable 的系統型別時不持有實例，在使用時才建立或取得（`LiveAwakeController` 每次執行 launchctl 才建立 `Process`）。

## 錯誤處理

- **不吞錯誤**：禁止 `try?`，每個錯誤都以 do-catch 具體處理；SwiftLint `no_try_optional` 會擋下（含 `Targets/Tests/`）。
- **typed throws**：`Targets/NoSleepCore/` 與 `Targets/NoSleepPlugin/` 的 `throws` 一律帶錯誤型別（`throws(AwakeControlError)`），錯誤型別是列出失敗原因的 enum，讓 `catch` 拿到具體的型別、不需要轉型。
  - 系統 API（`Process.run()` 等）的 untyped 錯誤在邊界以 do-catch 轉成自己的 case（`catch { throw .launchctlUnavailable }`）；需要保留原因供診斷時放進 associated value。
  - 必須符合 untyped 的系統要求時以 `// swiftlint:disable:this typed_throws` 標示並註明原因。SwiftLint `typed_throws` 會擋下其餘的 untyped throws。
  - 不用 `AsyncThrowingStream`（錯誤型別是 untyped）：開始前可能失敗的部分用 typed throws，串流本身用 `AsyncStream`；SwiftLint `no_async_throwing_stream` 會擋下。
- 不用強制解包（`!`、`try!`）。
