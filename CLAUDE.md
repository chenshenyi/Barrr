# CLAUDE.md

No Sleep：在 macOS 選單列快速關閉／恢復休眠的 [SwiftBar](https://github.com/swiftbar/SwiftBar) plugin。本檔是開發環境、setup 與專案慣例的 source of truth。開發規範沿用 [Music-Tool](https://github.com/chenshenyi/Music-Tool)。

## 環境需求

| 工具 | 版本 | 來源 |
| --- | --- | --- |
| Xcode | 26.x（Swift 6.2+ toolchain） | Mac App Store / `xcodes` |
| [mise](https://mise.jdx.dev) | 2026.10+ | 手動安裝 |
| SwiftLint | latest | `mise.toml` |
| SwiftFormat（nicklockwood） | latest | `mise.toml` |
| Git LFS | 3.8.0 | `mise.toml` |
| [SwiftBar](https://github.com/swiftbar/SwiftBar) | 2.x | 手動安裝；只有使用時需要，開發與測試不需要 |

工具版本一律以 `mise.toml` 為準。SwiftLint 與 SwiftFormat 不鎖版本：mise 的 `latest` 只會用已安裝的最新版，要靠 `mise run tools:update`（`mise run setup` 也會執行）升級；升級後若出現新的 lint／format 差異，依新規則修正或在 `Config/` 調整設定。本機私有的覆寫放 `mise.local.toml`（已 gitignore）。

## 第一次 setup

```sh
mise trust          # 信任本 repo 的 mise.toml
mise install        # 安裝上表工具
mise run setup      # 等同下列四步
```

`mise run setup` 會依序執行：

1. `mise upgrade swiftlint swiftformat` — 把 lint／format 工具升到最新版
2. `git config core.hooksPath .githooks` — 啟用 repo 內的共用 hooks
3. `git lfs install --local` — 設定 LFS filter，並把 LFS hooks 寫進 `.githooks/`
4. `git lfs pull` — 下載 LFS 檔案

## 常用指令

| 指令 | 用途 |
| --- | --- |
| `mise run test` | 執行 NoSleepCore 的測試（`swift test`；有 pueue 時自動排隊），可附加參數（`-- --filter MenuTests`） |
| `mise run build` | 以 release 設定 build `nosleep`（有 pueue 時自動排隊） |
| `mise run install` | build 後把 `nosleep` 裝進 SwiftBar 的 plugin 資料夾（檔名 `nosleep.1m.bin`），SwiftBar 執行中時重新載入；資料夾讀 SwiftBar 的偏好設定，可用 `mise.local.toml` 的 `NOSLEEP_PLUGIN_DIR` 覆寫 |
| `mise run format [paths...]` | SwiftFormat 格式化（預設整個 repo） |
| `mise run format:check [paths...]` | 只檢查格式，不改檔 |
| `mise run lint [paths...]` | SwiftLint（設定檔 `strict: true`，warning 一律視為 error），並執行下面兩項 |
| `mise run lint:structure` | 檢查目錄分層：根目錄以外，每個目錄的直接內容不可超過 12 個 |
| `mise run lint:scripts` | 檢查腳本與 git hooks：路徑一律取自 `mise.toml` 的 `[env]`（`NOSLEEP_*`），不寫路徑字面值 |
| `mise run lint:fix` | SwiftLint 自動修正 |
| `mise run tools:update` | 把 SwiftLint、SwiftFormat 升到最新版 |
| `mise tasks` | 列出所有 task |

在 Orca 工作站上，本機任何 build 都要透過 pueue 排隊（見 `~/orca/CLAUDE.md`）；`mise run build`／`test` 已經處理，不要直接下 `swift build`。

## 運作方式

- SwiftBar 每分鐘（檔名的 `1m`）執行一次 `nosleep`，沒有參數時輸出選單：選單列的圖示（`moon.zzz` 照系統設定休眠、`cup.and.heat.waves.fill` 不休眠、`exclamationmark.triangle` 讀不到狀態）與兩種方式、恢復休眠。
- 點選項目時 SwiftBar 以 `nosleep start <display|system>` 或 `nosleep stop` 重新執行自己（`terminal=false refresh=true`），執行完立即重新整理選單。點已勾選的方式等於恢復休眠。
- 不休眠靠 `caffeinate`：每種方式（`AwakeMode`）一個 launchd job（`launchctl submit -l tw.chenshenyi.nosleep.<方式>`），job 存在就是生效中。交給 launchd 是因為 plugin 執行完就結束，`caffeinate` 要活得比它久；submit 的 job 不寫進磁碟，登出或重開機後自動消失。一次只有一種方式生效（`start` 先 `stop`）。
- 不動 `pmset` 的設定、不需要 sudo。

## 目錄結構

```
.
├── Package.swift          # SwiftPM：NoSleepCore、NoSleepPlugin（product nosleep）、NoSleepCoreTests
├── mise.toml              # 工具版本、路徑（[env] 的 NOSLEEP_*）與 task
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
│   └── Lint/              # lint-scripts.sh、lint-structure.sh
├── Targets/
│   ├── NoSleepCore/       # 純物件（只用 Swift 標準函式庫）
│   │   ├── Awake/         # AwakeMode（方式與 caffeinate 參數）、AwakeController protocol、AwakeControlError
│   │   ├── Command/       # Command（指令列參數 ⇄ 動作）、CommandError
│   │   ├── Menu/          # MenuState、Menu（狀態 → 選單內容）、MenuItem、MenuLine、MenuText（文字與圖示）、Menu+SwiftBar（SwiftBar 輸出格式）
│   │   └── Runner/        # Runner（參數 → 動作 → 輸出）、RunOutput
│   ├── NoSleepPlugin/     # executable target
│   │   ├── NoSleepPlugin.swift  # 進入點（composition root）
│   │   └── Dependencies/Live/   # LiveAwakeController（launchctl）、LiveTerminal（輸出與結束狀態）
│   └── Tests/
│       └── NoSleepCoreTests/    # Swift Testing；替身在 Support/
└── .claude/
    ├── rules/             # 依路徑觸發的規則（Swift 開發原則、腳本、單元測試）
    └── skills/            # 專案 skill（decision-order：決策順序）
```

## 工作流程

- **決策順序**：做設計或實作決策前先載入 `decision-order` skill（`.claude/skills/decision-order/`）：保證機制依「架構 > lint／format > 測試 > 文件／prompt」優先、用更新更簡潔更安全的做法、拆分前先算抽象成本、不提早優化，並檢查正確性／可讀性／簡化／更低成本解法。
- **實機確認**：改到選單或 live 實作時，`mise run install` 後在選單列實際點選確認。
- **小單位 commit**：每完成一個小單位（一個可獨立理解、可單獨 revert 的改動）就立即 commit，不要把多個不相關的改動累積到同一個 commit。
  - commit 前確認 `mise run lint`、`mise run format:check` 與 `mise run test` 通過。
  - 同一個 commit 內一併更新受影響的 `CHANGELOG.md`、`CLAUDE.md` 與 rule。

## 專案慣例

核心思想（值語意、型別安全、具體的錯誤、並行安全、副作用可替換、依賴最小）寫在 `.claude/rules/swift-principles.md` 開頭，以下各條都是它的具體規則。

- **⚠️ 最小化外部依賴（高優先，必須遵守）**：每個檔案只 import 真的用到的 module，能用更小的就不用大的。
  - `Targets/NoSleepCore/` 的純物件不依賴 Foundation（需要時只能用 `FoundationEssentials`），SwiftLint `pure_type_import` 擋下；Foundation 只在 `Dependencies/Live/` import，SwiftLint `system_framework_in_wrapper` 擋下。
  - `MemberImportVisibility`（`Package.swift`）讓 import 不跨檔案外漏。
  - 細則見 `.claude/rules/swift-principles.md`。
- **Swift**：Swift 6 language mode（strict concurrency），macOS 26+（`Package.swift` 的 `platforms`）。
- **註解**：程式碼註解用繁體中文，只描述現況。
- **Swift 開發原則**：有副作用的 API 一律依賴注入，live 實作只放 `Targets/NoSleepPlugin/Dependencies/Live/`；其餘型別、並行、錯誤處理原則見 `.claude/rules/swift-principles.md`。SwiftLint `side_effect_via_dependency` 會擋下直接使用。
- **字面常數**：數字與字串字面常數只能出現在具名常數的宣告處（`let`／`static let`、enum raw value、switch case 對應），不可散落在程式碼中（`0`、`1`、`""`、測試除外）；選單文字與圖示集中在 `MenuText`。SwiftLint `no_magic_numbers`、`no_inline_string_literal` 會擋下。
- **只用 struct**：型別一律是 `struct`／`enum`，不用 class、actor、`@Observable`、`AnyObject` 限制；live 實作是使用時才建立系統物件的 struct。逼不得已時先與使用者討論替代方案，再以 `swiftlint:disable` 標示並註明原因（目前沒有例外）；SwiftLint `no_reference_type` 會擋下。
- **Sendable 與 `~Copyable`**：每個 struct／enum／protocol 都明確宣告 `Sendable`（`Error` 除外），SwiftLint `explicit_sendable` 會擋下；擁有唯一資源、不可複製的型別宣告為 `~Copyable`（目前沒有適用的型別）。
- **禁止轉型**：不用 `as`／`as?`／`as!`／`is`／`unsafeBitCast`；SwiftLint `no_type_cast` 會擋下（含 `Targets/Tests/`）。
- **錯誤處理**：禁止 `try?`；`throws` 一律是 typed throws（錯誤型別是列出原因的 enum，系統 API 的錯誤在邊界轉換）；不用 `AsyncThrowingStream`；`AsyncStream` 只在 `Dependencies/` 與測試中建立。SwiftLint `no_try_optional`、`typed_throws`、`no_async_throwing_stream`、`async_stream_in_dependency` 會擋下。
- **不用 unsafe 指標**、**禁止 Singleton**：SwiftLint `no_unsafe_pointer`、`no_singleton_declaration`、`no_singleton_access` 會擋下。
- **腳本路徑**：`Scripts/`、`.githooks/` 與 task 不寫路徑字面值；共用的 repo 路徑定義在 `mise.toml` 的 `[env]`（`NOSLEEP_*`），只屬於某個工具的路徑留在 `Config/` 的該工具設定檔；git hooks 以 `mise env` 載入同一份 env。細則見 `.claude/rules/scripts.md`，`lint:scripts` 會擋下。
- **格式與 lint**：commit 時 pre-commit hook 只針對這次 staged 的 `.swift`（增量）先跑 SwiftFormat（並重新 stage）、再跑 SwiftLint；lint 不過會擋下 commit。同一檔案若同時有 staged 與 unstaged 修改，hook 會要求先全部 stage 或 stash。排版類規則交給 SwiftFormat，SwiftLint 已停用與其衝突的規則。
- **目錄分層**：根目錄以外，一個目錄的直接內容超過 5 個就要考慮依職責分出子目錄，超過 12 個一定要分層；`lint:structure`（pre-commit 也會執行）會擋下超過 12 個的目錄。
- **一檔一型別**：每個檔案只能有一個根層級的型別宣告，由 SwiftLint `one_declaration_per_file` 檢查；巢狀型別、extension、全域函式不受限。
- **Commit 訊息**：依循 [Conventional Commits](https://www.conventionalcommits.org/zh-hant/v1.0.0/)，由 `commit-msg` hook 檢查（`Config/commitlint.conf`）。
- **上 tag 前跑測試**：git 沒有 pre-tag hook，改用 `reference-transaction` hook 攔截 `git tag` 建立或移動本地 tag。
- **Git LFS**：音訊、影片、模型、設計稿、字型、zip 等由 LFS 管理（見 `.gitattributes`）。
- **單元測試**：撰寫規範（F.I.R.S.T.、Swift Testing 慣例）見 `.claude/rules/unit-tests.md`，修改 `Targets/Tests/` 時會自動載入。
- **CHANGELOG**：使用者看得到的變更都記到 `CHANGELOG.md` 的 `[Unreleased]`，格式依循 Keep a Changelog。
