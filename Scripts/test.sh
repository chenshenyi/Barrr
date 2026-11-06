#!/usr/bin/env bash
# 執行 Targets/Core/ 各 module 的測試（mise run test）；可附加 swift test 的參數（例如 --filter NoSleepModelTests）
set -euo pipefail

cd "$BARRR_ROOT"
"$BARRR_SCRIPTS/run-queued.sh" "cd $(printf '%q' "$BARRR_ROOT") && swift test --quiet ${*:+$(printf '%q ' "$@")}"
