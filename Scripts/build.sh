#!/usr/bin/env bash
# 產生 Xcode 專案並以 Release 設定 build App（mise run build）；DerivedData 放在 $NOSLEEP_DERIVED_DATA
set -euo pipefail

cd "$NOSLEEP_ROOT"
xcodegen generate --quiet --spec "$NOSLEEP_PROJECT_SPEC"
"$NOSLEEP_SCRIPTS/run-queued.sh" "cd $(printf '%q' "$NOSLEEP_ROOT") && xcodebuild build \
-project $(printf '%q' "$NOSLEEP_PROJECT") -scheme $(printf '%q' "$NOSLEEP_SCHEME") -configuration Release \
-destination 'generic/platform=macOS' -derivedDataPath $(printf '%q' "$NOSLEEP_DERIVED_DATA") -quiet"
