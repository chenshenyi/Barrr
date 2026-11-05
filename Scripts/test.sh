#!/usr/bin/env bash
# 執行 NoSleepCore 的測試（mise run test）；可附加 swift test 的參數（例如 --filter MenuTests）
set -euo pipefail

cd "$NOSLEEP_ROOT"
"$NOSLEEP_SCRIPTS/run-queued.sh" "cd $(printf '%q' "$NOSLEEP_ROOT") && swift test --quiet ${*:+$(printf '%q ' "$@")}"
