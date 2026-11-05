#!/usr/bin/env bash
# 以 release 設定 build nosleep（mise run build）
set -euo pipefail

cd "$NOSLEEP_ROOT"
"$NOSLEEP_SCRIPTS/run-queued.sh" "cd $(printf '%q' "$NOSLEEP_ROOT") && swift build -c release --product $(printf '%q' "$NOSLEEP_PRODUCT") --quiet"
