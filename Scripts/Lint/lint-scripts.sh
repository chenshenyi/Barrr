#!/usr/bin/env bash
# 檢查腳本與 git hooks 不寫路徑字面值：repo 內的路徑一律取自 mise.toml 的 [env]（NOSLEEP_*）
# 偵測的名稱是 repo 頂層的檔案與資料夾（由 git 列出）以及 build 資料夾；註解行不檢查
set -euo pipefail

cd "$NOSLEEP_ROOT"

names="$( (git ls-files | cut -d/ -f1; basename "$NOSLEEP_BUILD") | sort -u)"
alternatives="$(printf '%s\n' "$names" | sed 's/[.]/\\./g' | paste -sd'|' -)"
# 名稱前面不能接英數字或 $ { _ . -，避免誤判 NoSleepCoreTests 這類識別字與變數名稱
PATTERN="(^|[^[:alnum:]_.\$\{-])($alternatives)(/|[^[:alnum:]_.-]|$)"

status=0
while IFS= read -r -d '' file; do
    while IFS= read -r match; do
        echo "lint-scripts: ${file#"$NOSLEEP_ROOT"/}:$match" >&2
        echo "  路徑請在 ${NOSLEEP_MISE_CONFIG#"$NOSLEEP_ROOT"/} 的 [env] 定義成 NOSLEEP_* 後引用" >&2
        status=1
    done < <(grep -nE "$PATTERN" "$file" | grep -vE '^[0-9]+:[[:space:]]*#' || true)
done < <(find "$NOSLEEP_SCRIPTS" "$NOSLEEP_GIT_HOOKS" -type f ! -name '*.lock' ! -name '.DS_Store' -print0)

exit "$status"
