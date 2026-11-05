---
paths:
  - "Scripts/**"
  - ".githooks/**"
  - "mise.toml"
  - "Config/**"
---

# 腳本與路徑規則

適用於 `Scripts/` 的腳本、`.githooks/` 的 git hooks 與 `mise.toml` 的 task。

## 路徑一律抽成設定

- 腳本、hook、task 不寫路徑字面值（`Targets/…`、`Config/…`、`.build/…`、`Package.swift` 等），一律引用設定好的值。路徑放哪裡依用途決定：
  - **多個腳本、task、hook 共用的 repo 路徑**：定義在 `mise.toml` 的 `[env]`，名稱為 `NOSLEEP_*`，以 `{{env.…}}` 由上層組出下層（`NOSLEEP_LINT_SCRIPTS = "{{env.NOSLEEP_SCRIPTS}}/Lint"`），搬資料夾時只改一處。
  - **只屬於某個工具自身設定的路徑**：留在 `Config/` 裡該工具的設定檔，由工具自己讀，例如 SwiftLint 的 `included`／`excluded`（`Config/.swiftlint.yml`）。
- 錯誤訊息要顯示路徑時，用 env 的值去掉 `$NOSLEEP_ROOT/` 前綴，顯示相對路徑。
- `lint:scripts`（`Scripts/Lint/lint-scripts.sh`，`mise run lint` 與 pre-commit 都會執行）會擋下 `Scripts/` 與 `.githooks/` 中含 repo 頂層檔案或資料夾名稱的非註解行。

## 執行環境

- 腳本透過 `mise run <task>` 執行，env 由 mise 載入；直接執行時缺少 `NOSLEEP_*`，`set -u` 會讓腳本立即失敗。
- git hooks 不經過 mise，開頭先檢查有沒有 mise，再以 `eval "$(mise env --shell bash)"` 載入同一份 env 與工具。
- 會 build 或跑測試的腳本經 `Scripts/run-queued.sh`：有 pueue daemon 時排進 pueue（Orca 工作站的 build 都要排隊，見 `~/orca/CLAUDE.md`），沒有時直接執行。
