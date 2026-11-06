# CLAUDE.md

Barrr：個人的 macOS 選單列工具箱（SwiftUI `MenuBarExtra`），每個功能一個選單列圖示，另有一個共用的管理視窗。目前的工具：不休眠（No Sleep）、系統效能（Performance）。本檔是開發環境、setup 與專案慣例的 source of truth。開發規範沿用 [Music-Tool](https://github.com/chenshenyi/Music-Tool)。

## 環境需求

| 工具 | 版本 | 來源 |
| --- | --- | --- |
| Xcode | 26.x 以上（Swift 6.2+ toolchain，String Catalog 產生 symbol） | Mac App Store / `xcodes` |
| [mise](https://mise.jdx.dev) | 2026.10+ | 手動安裝 |
| XcodeGen | 2.46.0 | `mise.toml` |
| SwiftLint | latest | `mise.toml` |
| SwiftFormat（nicklockwood） | latest | `mise.toml` |
| Git LFS | 3.8.0 | `mise.toml` |

工具版本一律以 `mise.toml` 為準。SwiftLint 與 SwiftFormat 不鎖版本：mise 的 `latest` 只會用已安裝的最新版，要靠 `mise run tools:update`（`mise run setup` 也會執行）升級；升級後若出現新的 lint／format 差異，依新規則修正或在 `Config/` 調整設定。本機私有的覆寫放 `mise.local.toml`（已 gitignore）。

## 第一次 setup

```sh
mise trust          # 信任本 repo 的 mise.toml
mise install        # 安裝上表工具
mise run setup      # 等同下列五步
```

`mise run setup` 會依序執行：

1. `mise upgrade swiftlint swiftformat` — 把 lint／format 工具升到最新版
2. `git config core.hooksPath .githooks` — 啟用 repo 內的共用 hooks
3. `git lfs install --local` — 設定 LFS filter，並把 LFS hooks 寫進 `.githooks/`
4. `git lfs pull` — 下載 LFS 檔案
5. `xcodegen generate` — 產生 `Barrr.xcodeproj`

## 常用指令

| 指令 | 用途 |
| --- | --- |
| `mise run test` | 執行 `Targets/Core/` 各 module 的測試（`swift test`；有 pueue 時自動排隊），可附加參數（`-- --filter NoSleepModelTests`） |
| `mise run build` | 產生 Xcode 專案並以 Release 設定 build App（DerivedData 在 `.build/DerivedData`；有 pueue 時自動排隊） |
| `mise run install` | build 後把 `Barrr.app` 裝到 `/Applications`（可用 `mise.local.toml` 的 `BARRR_INSTALL_DIR` 覆寫），先結束執行中的舊版再開啟新版 |
| `mise run generate` | 改了 `project.yml` 或新增／搬移檔案後重新產生 Xcode 專案 |
| `mise run format [paths...]` | SwiftFormat 格式化（預設整個 repo） |
| `mise run format:check [paths...]` | 只檢查格式，不改檔 |
| `mise run lint [paths...]` | SwiftLint（設定檔 `strict: true`，warning 一律視為 error），並執行下面三項 |
| `mise run lint:assets` | 檢查資源檔：非 Swift 檔只能放在 `Targets/App/Resources/`，`Resources/` 只放 String Catalog；每個 key 都要有每個語言 |
| `mise run lint:structure` | 檢查目錄分層：根目錄以外，每個目錄的直接內容不可超過 12 個 |
| `mise run lint:scripts` | 檢查腳本與 git hooks：路徑一律取自 `mise.toml` 的 `[env]`（`BARRR_*`），不寫路徑字面值 |
| `mise run lint:fix` | SwiftLint 自動修正 |
| `mise run tools:update` | 把 SwiftLint、SwiftFormat 升到最新版 |
| `mise tasks` | 列出所有 task |

在 Orca 工作站上，本機任何 build 都要透過 pueue 排隊（見 `~/orca/CLAUDE.md`）；`mise run build`／`test` 已經處理，不要直接下 `swift build`／`xcodebuild`。

## 運作方式

- 沒有 Dock 圖示與 App 選單（Info.plist 的 `LSUIElement`）；每個顯示中的工具一個選單列圖示（`MenuBarExtra`），選單只放該工具最少的項目。
- **工具的排列與顯示**（`BarrrCore` 的 `Tool`、`ToolLayout`）：管理視窗拖曳排列、開關顯示，經 `UserDefaultsToolLayoutStorage` 存在 UserDefaults（`toolOrder`、`toolHidden`，存 `Tool` 的 raw value）；至少保留一個顯示中的工具。
  - 選單列的順序由資料決定，不靠系統記住的位置：`BarrrApp` 宣告與工具數量相同的「位置」（`toolSlot(_:)`），每個位置一個 `MenuBarExtra(isInserted:)`。先宣告的位置在選單列的右邊，所以第 i 個位置顯示倒數第 i 個顯示中的工具，清單的第一個在最左邊（以兩種排列實測過）。新增工具時要多宣告一個位置。
  - 隱藏不休眠時一併恢復休眠，不留下看不到的不休眠。
- **管理視窗**（`Settings/`）：工具清單、登入時開啟、結束 Barrr。用 SwiftUI 的 `Settings` scene，不用 `Window`：有 `Window` scene 時 SwiftUI 會在最後一個視窗關閉時結束 App，而以 Escape 關閉選單列的選單也算關閉視窗（Apple 的文件也建議 `MenuBarExtra` 不要和其他 scene 混用）。啟動時不顯示；App 已在執行時再從 Finder／Spotlight 開啟一次，才以 `openSettings` 顯示並切到前景。標題列的「Barrr 設定」以 `.toolbar(removing: .title)` 拿掉。
  - 外觀：整個視窗是一塊 Liquid Glass（`containerBackground(.clear, for: .window)` 拿掉視窗背景，`SettingsView` 的背景整片 `.glassEffect` 並延伸到隱藏的標題列）；放控制項的卡片（工具清單、一般設定）也各是一塊 `.glassEffect`，按鈕用 `.buttonStyle(.glass)`；就這兩層（視窗、卡片），卡片裡不再疊玻璃（例如圖示的玻璃圓圈）、不用 `GlassEffectContainer`。Apple 的設計指南把 Liquid Glass 定位在控制層，整窗玻璃是刻意的選擇。尺寸集中在 `SettingsMetrics`。
  - 「再次開啟」是 Apple Event `rapp`。AppKit 接它的方式（AppDelegate 的 `applicationShouldHandleReopen`、`NSAppleEventManager`）都需要 class，SwiftUI 沒有對應的 API；`LiveAppReopen` 改用 C API `AEInstallEventHandler` 安裝不捕捉任何值的 C 函式，只發出通知，再以 `AsyncStream` 交給 SwiftUI 以 `openWindow` 打開視窗，因此不需要 class。處理函式要在 App 啟動完成後安裝（掛在選單列圖示的 `.task`），否則會被 AppKit 的預設處理蓋掉；收到後 `openSettings()`。
  - 登入時開啟用 `SMAppService.mainApp`，會出現在系統設定的「登入項目」。
- **不休眠**（`Features/NoSleep/`）：選單只有兩種方式（「螢幕保持亮」、「螢幕可關閉」），勾選中的再點一次即恢復休眠；失敗時才多一行原因。圖示 `moon.zzz` 照系統設定休眠、`cup.and.heat.waves.fill` 不休眠。
  - 靠 IOKit 的 power assertion（與 `caffeinate` 同一個機制）：螢幕保持亮是 `PreventUserIdleDisplaySleep`，螢幕可關閉是 `PreventUserIdleSystemSleep`，名稱「No Sleep」會出現在 `pmset -g assertions`。assertion 屬於 App 的 process，App 結束（含當掉）時系統自動交還；一次只有一種方式生效（換方式時先交還目前的）。不動 `pmset` 的設定、不需要 sudo。
- **系統效能**（`Features/Performance/`）：選單列顯示 CPU 使用率，選單有 CPU、記憶體、磁碟空間、磁碟讀寫、網路上下行、電池（沒有電池的 Mac 不顯示）、系統耗電與打開活動監視器。
  - `LiveSystemMetricsReader`（`Dependencies/Live/Performance/`，每類一個 extension）：CPU 與記憶體用 Mach 的 `host_statistics`／`host_statistics64`（已使用記憶體與「活動監視器」相同算法：App 記憶體 + 聯繫 + 壓縮）；電池與耗電讀 IORegistry 的 `AppleSmartBattery`（`PowerTelemetryData.SystemLoad` 是整台 Mac 的耗電，毫瓦）；磁碟空間用開機磁碟的 URL resource values，讀寫量加總 IORegistry 的 `IOBlockStorageDriver` 統計；網路用 `getifaddrs` 的 AF_LINK 計數（不計 loopback 與點對點介面，避免 VPN 重複計算；32 位元計數繞回以溢位減法處理）。
  - 速率（磁碟、網路）由前後兩次取樣的計數差除以實際相隔的時間算出（`MetricsSample` → `PerformanceSnapshot`）。
  - `PerformanceSampler.snapshots()` 是自己寫的 `AsyncSequence`（不加 swift-async-algorithms）：每 2 秒取樣，對固定的截止時間睡（`sleep(until:tolerance:)`）不累積誤差，落後時（Mac 睡眠醒來）從現在重新對齊；時鐘是泛型（`sleep(until:)` 不能用在 `any Clock`）。圖示在選單列時才取樣（標籤的 `.task`）。
- **App 圖示**：Icon Composer 的 `Targets/App/Resources/AppIcon.icon`（`icon.json` + `Assets/bars.svg`）：藍紫漸層上三條長短不一的橫條，橫條開啟 glass；macOS 的圓角外框與陰影由系統套用。可用 Xcode 附的 Icon Composer 開啟編輯。
- **必要的轉型**：IOKit／CoreFoundation 交出的 `CFTypeRef`、CF 字典沒有型別，讀出時一定要轉型。這類轉型只能寫在 `Dependencies/Live/Bridging/UntypedValue.swift`（SwiftLint `no_type_cast` 只排除這個檔案），而且只能條件轉型 `as?`（`bridging_conditional_cast_only` 擋下 `as!`、`is`、`unsafeBitCast`），型別不符回傳 nil 再轉成具體的錯誤；其餘程式碼經由它取得具體型別。不為了避開轉型改用解析指令輸出（例如 `ioreg`）：那一樣是執行期判斷型別，還多了啟動 process 的成本與不穩定的文字格式。
- **UserDefaults**：只能透過 `UserDefaultsCenter`（`BarrrCore/UserDefaults/`），key 是帶著值型別的 `UserDefaultsKey<Value>`（`.toolOrder` 是 `UserDefaultsKey<[String]>`），讀寫的型別由 key 決定；所有存進去的名稱列在 `UserDefaultsName` enum（raw value 即名稱，編譯器保證不重複）。底層的 `UserDefaultsStorage` 由外部注入：live 是 `LiveUserDefaultsStorage`（可指定網域），測試用記憶體實作。新增設定值：`UserDefaultsName` 加 case，`UserDefaultsKey` 的 extension 宣告 key，值的型別要遵循 `UserDefaultsValue`（目前支援 `[String]`，需要其他型別時在 `UserDefaultsStorage` 加對應的讀寫）。SwiftLint `user_defaults_via_center` 擋下 Live 以外直接使用 `UserDefaults`／`@AppStorage`。
- **常駐**：SwiftUI 在啟動時會啟用 AppKit 的自動終止，沒有開著視窗的 App 會被 loginwindow（TAL）悄悄結束（約 25 秒後 exit 0、沒有 crash 記錄；log 有 `_kLSApplicationWouldBeTerminatedByTALKey=1`）。Info.plist 宣告 `NSSupportsAutomaticTermination = NO`（`project.yml` 的 `info.properties`），但只靠它擋不住，SwiftUI 之後仍會啟用；所以啟動完成後再以 `LiveApplication.keepRunning()`（`ProcessInfo.disableAutomaticTermination`，掛在選單列圖示的 `.task`）關閉，在 App 的 init 呼叫會被抵銷。
- 簽章：沒有開發者帳號，以 ad-hoc 簽章（`CODE_SIGN_IDENTITY: "-"`）。自己 build 的 App 沒有隔離標記，在自己的 Mac 上直接執行；傳給別人時對方要到「系統設定 → 隱私權與安全性」允許。

## 目錄結構

```
.
├── project.yml            # XcodeGen 專案定義（xcodeproj 不進版控）
├── Package.swift          # App 以外的 Swift module：每個功能一個純物件 module 與它的測試；App 本身由 project.yml 定義
├── mise.toml              # 工具版本、路徑（[env] 的 BARRR_*）與 task
├── Config/
│   ├── .swiftformat       # SwiftFormat 設定
│   ├── .swiftlint.yml     # SwiftLint 設定（路徑以 Config/ 為基準）
│   └── commitlint.conf    # commit 訊息規則（type、長度上限）
├── .githooks/             # 共用 git hooks（pre-commit、commit-msg、reference-transaction + Git LFS hooks）
├── Scripts/
│   ├── run-queued.sh      # 有 pueue 時排隊執行，沒有時直接執行
│   ├── build.sh           # mise run build 的實作
│   ├── test.sh            # mise run test 的實作
│   ├── install.sh         # mise run install 的實作
│   └── Lint/              # lint-assets.sh、lint-scripts.sh、lint-structure.sh
├── Targets/
│   ├── Core/              # 純物件（只用 Swift 標準函式庫），每個功能一個 module
│   │   ├── Barrr/         # BarrrCore：App 共用（Tools/ 的 Tool、ToolLayout、ToolLayoutStorage；UserDefaults/ 的 UserDefaultsCenter、UserDefaultsKey、UserDefaultsName；LoginItem/；Settings/ 的 SettingsModel）
│   │   ├── NoSleep/       # NoSleepCore：Awake/（AwakeMode、AwakeAssertion、AwakeController、AwakeControlError）、Model/NoSleepModel
│   │   └── Performance/   # PerformanceCore：CPU/、Memory/、Energy/、Disk/、Network/、Transfer/（各項數據與速率計算）、Reading/（SystemMetricsReader、MetricsSample）、Sampling/（PerformanceSampler、PerformanceSnapshots、PerformanceSnapshot）
│   ├── App/
│   │   ├── Barrr/         # App target 的原始碼
│   │   │   ├── BarrrApp.swift     # 進入點（composition root）：建立 live 依賴、選單列的位置（toolSlot）與管理視窗（Settings）
│   │   │   ├── Settings/          # SettingsView（管理視窗，Settings scene）與它的區塊、SettingsMetrics、opensSettingsOnReopen
│   │   │   ├── Tools/             # ToolLabel、ToolMenu：依工具切換選單列標籤與選單；keepsAppRunning
│   │   │   ├── Features/          # 各工具的標籤與選單：NoSleep/、Performance/
│   │   │   ├── Symbol/            # AppSymbol（SF Symbols）與 Image(_:)
│   │   │   ├── Mapping/           # LocalizedString/（顯示文字）、PerformanceFormat（百分比與記憶體的格式）
│   │   │   └── Dependencies/Live/ # IOKit、SMAppService、Apple Event、UserDefaults、NSWorkspace、NSApplication 的包裝；Performance/（系統數據）、Bridging/（UntypedValue、IORegistryProperties）
│   │   └── Resources/     # 只放資料，不放 Swift（lint:assets 檢查）
│   │       ├── StringCatalog/     # Localizable.xcstrings（en、zh-Hant）
│   │       └── AppIcon.icon       # Icon Composer 的 App 圖示
│   └── Tests/             # Swift Testing，每個 Core module 一個 test target（BarrrCoreTests、NoSleepCoreTests、PerformanceCoreTests），替身在各自的 Support/
└── .claude/
    ├── rules/             # 依路徑觸發的規則（Swift 開發原則、在地化、腳本、單元測試）
    └── skills/            # 專案 skill（decision-order：決策順序）
```

## 新增功能

1. 純邏輯：`Targets/Core/<功能>/` 新增一個 module（`Package.swift` 的 `.target` 與 `.testTarget`、`project.yml` 的 dependency），碰系統的部分宣告成 protocol。
2. `Tool` 加一個 case（raw value 是儲存用的識別碼，之後不可更改），`BarrrApp` 多宣告一個 `toolSlot(_:)`，`ToolLabel`／`ToolMenu` 補上分支（編譯器會要求）。
3. live 實作放 `Targets/App/Barrr/Dependencies/Live/`，標籤與選單放 `Targets/App/Barrr/Features/<功能>/`（選單只放最少的項目；App 共用的設定放管理視窗）。
4. 文字加進 `Localizable.xcstrings`（en、zh-Hant；工具名稱與一句話說明），圖示加進 `AppSymbol`。

## 工作流程

- **決策順序**：做設計或實作決策前先載入 `decision-order` skill（`.claude/skills/decision-order/`）：保證機制依「架構 > lint／format > 測試 > 文件／prompt」優先、用更新更簡潔更安全的做法、拆分前先算抽象成本、不提早優化，並檢查正確性／可讀性／簡化／更低成本解法。
- **實機確認**：改到選單或 live 實作時，`mise run install` 後在選單列實際點選確認；不休眠是否生效看 `pmset -g assertions` 有沒有「No Sleep」；管理視窗以 `open /Applications/Barrr.app` 再開一次確認；選單以 Escape 關閉後 App 要仍在執行（`pgrep -x Barrr`）。
- **小單位 commit**：每完成一個小單位（一個可獨立理解、可單獨 revert 的改動）就立即 commit，不要把多個不相關的改動累積到同一個 commit。
  - commit 前確認 `mise run lint`、`mise run format:check` 與 `mise run test` 通過。
  - 同一個 commit 內一併更新受影響的 `CHANGELOG.md`、`CLAUDE.md` 與 rule。

## 專案慣例

核心思想（值語意、型別安全、具體的錯誤、並行安全、副作用可替換、依賴最小）寫在 `.claude/rules/swift-principles.md` 開頭，以下各條都是它的具體規則。

- **⚠️ 最小化外部依賴（高優先，必須遵守）**：每個檔案只 import 真的用到的 module，能用更小的就不用大的。
  - `Targets/Core/` 的純物件不依賴 Foundation（需要時只能用 `FoundationEssentials`），SwiftLint `pure_type_import` 擋下；Foundation、AppKit、IOKit、CoreServices、ServiceManagement 等只在 `Dependencies/Live/` import（`Mapping/` 可 import Foundation），SwiftLint `system_framework_in_wrapper` 擋下。
  - `MemberImportVisibility`（`Package.swift`、`project.yml`）讓 import 不跨檔案外漏。
  - 細則見 `.claude/rules/swift-principles.md`。
- **Xcode 專案**：`Barrr.xcodeproj` 由 XcodeGen 產生、不進版控。專案設定只改 `project.yml`，不要在 Xcode 裡改 build settings。
- **Info.plist**：由 build setting 自動產生（`GENERATE_INFOPLIST_FILE`，`INFOPLIST_KEY_*`）。
- **不宣告 Preview**：不寫 `#Preview`／`PreviewProvider`，選單以 `mise run install` 後實際點選確認；SwiftLint `no_preview` 會擋下。
- **Swift**：Swift 6 language mode（strict concurrency），macOS 26+（`project.yml` 的 `deploymentTarget`、`Package.swift` 的 `platforms`）。
- **註解**：程式碼註解用繁體中文，只描述現況。
- **Swift 開發原則**：有副作用的 API 一律依賴注入，live 實作只放 `Targets/App/Barrr/Dependencies/Live/`；其餘型別、並行、錯誤處理原則見 `.claude/rules/swift-principles.md`。SwiftLint `side_effect_via_dependency` 會擋下直接使用。
- **字面常數**：數字與字串字面常數只能出現在具名常數的宣告處（`let`／`static let`、enum raw value、switch case 對應），不可散落在程式碼中（`0`、`1`、`""`、測試除外）；圖示是 `AppSymbol` 的 case。SwiftLint `no_magic_numbers`、`no_inline_string_literal` 會擋下。
- **只用 struct**：型別一律是 `struct`／`enum`，不用 class、actor、`@Observable`、`AnyObject` 限制與 `@StateObject`／`@ObservedObject`／`@Bindable`；各畫面的狀態是 App 以 `@State` 保存的 struct（`SettingsModel`、`NoSleepModel`、`PerformanceSnapshot`），live 實作是使用時才取得系統物件的 struct。逼不得已時先與使用者討論替代方案，再以 `swiftlint:disable` 標示並註明原因（目前沒有例外；AppKit 要求 class 的地方先找 C API 等替代，例如 `LiveAppReopen`）；SwiftLint `no_reference_type` 會擋下。
- **Sendable 與 `~Copyable`**：每個 struct／enum／protocol 都明確宣告 `Sendable`（`Error` 與標了 `@MainActor` 的型別除外），SwiftLint `explicit_sendable` 會擋下；擁有唯一資源、不可複製的型別宣告為 `~Copyable`（`AwakeAssertion` 擁有系統資源，但要存進 `@State` 必須可複製，見其 doc comment）。
- **禁止轉型**：不用 `as`／`as?`／`as!`／`is`／`unsafeBitCast`；SwiftLint `no_type_cast` 會擋下（含 `Targets/Tests/`）。
- **錯誤處理**：禁止 `try?`；`throws` 一律是 typed throws（錯誤型別是列出原因的 enum，系統 API 的錯誤在邊界轉換）；不用 `AsyncThrowingStream`；`AsyncStream` 只在 `Dependencies/` 與測試中建立。SwiftLint `no_try_optional`、`typed_throws`、`no_async_throwing_stream`、`async_stream_in_dependency` 會擋下。
- **在地化**：UI 文字只能透過 String Catalog 產生的 symbol 取得（`STRING_CATALOG_GENERATE_SYMBOLS`，`Text(.menuResume)`），catalog 放在 `Targets/App/Resources/StringCatalog/`，來源語言英文、翻譯 `zh-Hant`；細則見 `.claude/rules/localization.md`，SwiftLint `localized_string_via_symbol` 會擋下、`lint:assets` 擋下缺語言的 key。
- **SF Symbols 與顏色**：圖示只經由 `AppSymbol` 與 `Image(_:)`；不指定顏色，只用系統的語意層級（`.secondary` 等，會隨深淺色與 Liquid Glass 調整）；SwiftLint `system_image_via_extension`、`color_via_theme` 會擋下。
- **不用 unsafe 指標**、**禁止 Singleton**：SwiftLint `no_unsafe_pointer`、`no_singleton_declaration`、`no_singleton_access` 會擋下。
- **腳本路徑**：`Scripts/`、`.githooks/` 與 task 不寫路徑字面值；共用的 repo 路徑定義在 `mise.toml` 的 `[env]`（`BARRR_*`），只屬於某個工具的路徑留在 `Config/` 的該工具設定檔；git hooks 以 `mise env` 載入同一份 env。細則見 `.claude/rules/scripts.md`，`lint:scripts` 會擋下。
- **格式與 lint**：commit 時 pre-commit hook 只針對這次 staged 的 `.swift`（增量）先跑 SwiftFormat（並重新 stage）、再跑 SwiftLint；lint 不過會擋下 commit。同一檔案若同時有 staged 與 unstaged 修改，hook 會要求先全部 stage 或 stash。排版類規則交給 SwiftFormat，SwiftLint 已停用與其衝突的規則。
- **目錄分層**：根目錄以外，一個目錄的直接內容超過 5 個就要考慮依職責分出子目錄，超過 12 個一定要分層；`lint:structure`（pre-commit 也會執行）會擋下超過 12 個的目錄。
- **一檔一型別**：每個檔案只能有一個根層級的型別宣告，由 SwiftLint `one_declaration_per_file` 檢查；巢狀型別、extension、全域函式不受限。
- **Commit 訊息**：依循 [Conventional Commits](https://www.conventionalcommits.org/zh-hant/v1.0.0/)，由 `commit-msg` hook 檢查（`Config/commitlint.conf`）。
- **上 tag 前跑測試**：git 沒有 pre-tag hook，改用 `reference-transaction` hook 攔截 `git tag` 建立或移動本地 tag。
- **Git LFS**：音訊、影片、模型、設計稿、字型、zip 等由 LFS 管理（見 `.gitattributes`）。
- **單元測試**：撰寫規範（F.I.R.S.T.、Swift Testing 慣例）見 `.claude/rules/unit-tests.md`，修改 `Targets/Tests/` 時會自動載入。
- **CHANGELOG**：使用者看得到的變更都記到 `CHANGELOG.md` 的 `[Unreleased]`，格式依循 Keep a Changelog。
