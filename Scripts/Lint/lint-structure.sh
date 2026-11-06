#!/usr/bin/env bash
# 檢查目錄分層：根目錄以外，每個目錄的直接內容（檔案與子目錄）不可超過 MAX_ENTRIES 個
#
# 用法：lint-structure.sh [--staged]
#   --staged  只看 git index（pre-commit 用）；預設也包含未被 ignore 的未追蹤檔案
set -euo pipefail

MAX_ENTRIES=12

cd "$BARRR_ROOT"

LS_FILES_ARGS=(--cached --others --exclude-standard)
if [ "${1:-}" = "--staged" ]; then
    LS_FILES_ARGS=(--cached)
fi

# 統計每個目錄底下的直接內容
violations="$(git ls-files "${LS_FILES_ARGS[@]}" \
    | awk -F/ 'NF > 1 {
        path = $1
        for (i = 2; i <= NF; i++) {
            child = path "/" $i
            if (!seen[child]++) count[path]++
            path = child
        }
    }
    END { for (dir in count) if (count[dir] > max) print count[dir] "\t" dir }' max="$MAX_ENTRIES" \
    | sort -rn)"

if [ -n "$violations" ]; then
    while IFS=$'\t' read -r count dir; do
        echo "lint-structure: $dir 有 $count 個內容（上限 ${MAX_ENTRIES}），請分層" >&2
    done <<<"$violations"
    exit 1
fi
