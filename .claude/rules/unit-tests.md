---
paths:
  - "Targets/Tests/**/*.swift"
---

# 單元測試規則

適用於 `Targets/Tests/NoSleepCoreTests/`（`Package.swift` 的 `NoSleepCoreTests`，以 `swift test` 執行）的測試。新增或修改測試時遵守以下規則。

## F.I.R.S.T. 原則

- **Fast（快速）**：單一測試應在毫秒內完成。不碰網路、不讀寫真實檔案系統、不呼叫 `sleep`／`Task.sleep` 等待真實時間；需要時間的邏輯改注入時鐘（`any Clock`）或可控的時間來源。
- **Independent（獨立）**：測試之間不共享可變狀態、不依賴執行順序。每個測試自行建立受測物件；Swift Testing 預設平行執行，不要假設先後。不使用 singleton 或全域狀態，必要時透過 protocol 注入替身。
  - 替身之間、受測物件之間也不共享可變狀態。要驗證「寫進去、之後讀得回來」（例如存檔後重開 App）時，不讓兩個實例共用同一份可變的 storage，而是把來回拆成兩半，中間的資料由測試明確傳遞：
    1. 寫入：注入記錄呼叫的替身，取得寫入後的內容；
    2. 讀取：用這份內容建立只讀固定內容的新替身，再建立新的受測物件讀回。
  - 覺得需要共享狀態（因而需要 class）時，先檢查是不是測試的寫法造成的；通常拆成「記錄輸出」與「給定輸入」兩種 struct 替身就不需要共享。
- **Repeatable（可重複）**：在任何機器、任何時區、任何時間跑都得到相同結果。不依賴 `Date()`、`UUID()`、亂數、`Locale.current`、`TimeZone.current` 的真實值；改用注入或固定值。
- **Self-validating（自我驗證）**：結果只由 `#expect`／`#require` 判定，不靠 `print` 或人工看 log。每個測試至少有一個斷言。
- **Timely（適時）**：與受測程式碼一起撰寫或修改。修 bug 時先寫出能重現問題的失敗測試，再修正。

## 撰寫慣例

- 使用 Swift Testing（`import Testing`、`@Test`、`#expect`、`#require`），不使用 XCTest。
- 以 `@testable import NoSleepCore` 匯入受測模組。
- 一個測試檔對應一個受測型別，檔名為 `<受測型別>Tests.swift`，測試型別為 `struct <受測型別>Tests`；每個檔案只有一個根層級型別。
- 測試函式名稱描述「情境與預期結果」，例如 `toggleOtherModeReleasesCurrentFirst()`、`failedHoldKeepsSleepAllowedAndReportsFailure()`；必要時以 `@Test("…")` 補上可讀描述。
- 測試內容依 Arrange／Act／Assert 分段，段落間空一行，不另加註解標示。
- 一個測試只驗證一個行為；同一行為的多組輸入用參數化測試 `@Test(arguments:)`，不要寫迴圈或複製貼上。
- 預期必定存在的值用 `try #require(...)` 解包，不使用 `!` 強制解包。
- 預期拋錯用 `#expect(throws: ...)`；非同步程式碼直接寫成 `async` 測試並 `await`。
- 測試檔依受測型別在 `Targets/NoSleepCore/` 的位置對應；App 的 View 與 live 實作不寫單元測試（碰真的 IOKit、登入項目），改以 `mise run install` 後實際點選確認。
- 共用的測試資料與替身（stub／fake）放在 `Targets/Tests/NoSleepCoreTests/Support/`，不要在多個測試檔重複定義。替身是 struct：`RecordingAwakeController` 以 `init(holdError:releaseError:)` 設定失敗，測試用 `await awake.recordedCalls()` 取得依序的呼叫並比對整串；`FixedLoginItemController` 回傳給定的狀態。`NoSleepModel` 是 `@MainActor`，測試型別也標 `@MainActor`。
- 只測公開行為與結果，不為了測試而把 `private` 改成 `internal`，也不驗證實作細節。

## 完成前

- 執行 `mise run lint` 與 `mise run format:check`。
- 執行 `mise run test`（有 pueue 時自動排隊）。
