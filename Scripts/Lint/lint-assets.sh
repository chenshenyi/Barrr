#!/usr/bin/env bash
# 檢查資源檔：Targets/App/ 底下只有 Resources/ 放資料，其餘只放 Swift；Resources/ 只有 StringCatalog/，不放 Swift；
# String Catalog 的每個 key 都要有 catalog 用到的所有語言（不翻譯的 key 也要填，否則執行期找不到而顯示 key 本身）
set -euo pipefail

# 訊息中的路徑以 repo 根目錄為基準
relative() {
    echo "${1#"$BARRR_ROOT"/}"
}

status=0
while IFS= read -r -d '' file; do
    echo "lint-assets: $(relative "$file") 不是 Swift 檔，資料請移到 $(relative "$BARRR_RESOURCES")/ 底下" >&2
    status=1
done < <(find "$BARRR_APP" -path "$BARRR_RESOURCES" -prune -o -type f ! -name '*.swift' ! -name '.DS_Store' -print0)

while IFS= read -r -d '' entry; do
    case "$entry" in
        "$BARRR_STRING_CATALOGS" | */.DS_Store) ;;
        *)
            echo "lint-assets: $(relative "$entry") 不該在 $(relative "$BARRR_RESOURCES")/ 底下；只能有" \
                "$(basename "$BARRR_STRING_CATALOGS")/" >&2
            status=1
            ;;
    esac
done < <(find "$BARRR_RESOURCES" -mindepth 1 -maxdepth 1 -print0)

while IFS= read -r -d '' entry; do
    echo "lint-assets: $(relative "$entry") 不是 String Catalog，$(basename "$BARRR_STRING_CATALOGS")/ 只放 *.xcstrings" >&2
    status=1
done < <(find "$BARRR_STRING_CATALOGS" -mindepth 1 ! -name '*.xcstrings' ! -name '.DS_Store' -print0)

while IFS= read -r -d '' catalog; do
    missing="$(jq -r '
        .strings as $strings
        | ([$strings[] | .localizations // {} | keys[]] | unique) as $languages
        | $strings | to_entries[]
        | (($languages - ((.value.localizations // {}) | keys)) | join("、")) as $absent
        | select($absent != "") | "\(.key)（缺 \($absent)）"
    ' "$catalog")"
    if [ -n "$missing" ]; then
        while IFS= read -r line; do
            echo "lint-assets: $(relative "$catalog") 的 ${line}；不翻譯的 key 也要填入各語言（值與來源語言相同）" >&2
        done <<<"$missing"
        status=1
    fi
done < <(find "$BARRR_STRING_CATALOGS" -name '*.xcstrings' -print0)

exit "$status"
