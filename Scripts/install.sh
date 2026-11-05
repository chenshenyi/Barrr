#!/usr/bin/env bash
# 把 release build 的 nosleep 複製進 SwiftBar 的 plugin 資料夾（mise run install，build 由 task 的 depends 先完成）
#
# 環境變數：
#   NOSLEEP_PLUGIN_DIR  SwiftBar 的 plugin 資料夾；未設定時讀 SwiftBar 偏好設定的 PluginDirectory
set -euo pipefail

cd "$NOSLEEP_ROOT"

PLUGIN_DIR="${NOSLEEP_PLUGIN_DIR:-}"
if [ -z "$PLUGIN_DIR" ]; then
    if ! PLUGIN_DIR="$(defaults read "$NOSLEEP_SWIFTBAR_DEFAULTS_DOMAIN" PluginDirectory 2>/dev/null)"; then
        echo "install: 找不到 SwiftBar 的 plugin 資料夾；請先開啟 SwiftBar 選好資料夾，或在 mise.local.toml 設定 NOSLEEP_PLUGIN_DIR" >&2
        exit 1
    fi
fi
PLUGIN_DIR="${PLUGIN_DIR/#\~/$HOME}"

BIN_DIR="$(swift build -c release --show-bin-path)"
install -m 755 "$BIN_DIR/$NOSLEEP_PRODUCT" "$PLUGIN_DIR/$NOSLEEP_PLUGIN_FILE"
echo "install: 已安裝到 $PLUGIN_DIR/$NOSLEEP_PLUGIN_FILE"

# SwiftBar 執行中時請它重新載入 plugin
if pgrep -xq SwiftBar; then
    open -g "swiftbar://refreshallplugins"
fi
