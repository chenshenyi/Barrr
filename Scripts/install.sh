#!/usr/bin/env bash
# 把 Release build 的 App 裝到 $BARRR_INSTALL_DIR 並重新開啟（mise run install，build 由 task 的 depends 先完成）
set -euo pipefail

cd "$BARRR_ROOT"

APP="$BARRR_APP_NAME.app"
BUILT="$BARRR_DERIVED_DATA/Build/Products/Release/$APP"
INSTALLED="$BARRR_INSTALL_DIR/$APP"

if [ ! -d "$BUILT" ]; then
    echo "install: 找不到 ${BUILT#"$BARRR_ROOT"/}，請先 mise run build" >&2
    exit 1
fi

# 執行中的舊版先結束（不休眠會一併交還），換掉後再開新版
if pgrep -xq "$BARRR_APP_NAME"; then
    osascript -e "quit app \"$BARRR_APP_NAME\""
    while pgrep -xq "$BARRR_APP_NAME"; do
        sleep 0.2
    done
fi

rm -rf "$INSTALLED"
ditto "$BUILT" "$INSTALLED"
echo "install: 已安裝到 $INSTALLED"
open "$INSTALLED"
