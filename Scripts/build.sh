#!/usr/bin/env bash
# 產生 Xcode 專案並以 Release 設定 build App（mise run build）；DerivedData 放在 $BARRR_DERIVED_DATA
set -euo pipefail

cd "$BARRR_ROOT"
xcodegen generate --quiet --spec "$BARRR_PROJECT_SPEC"
"$BARRR_SCRIPTS/run-queued.sh" "cd $(printf '%q' "$BARRR_ROOT") && xcodebuild build \
-project $(printf '%q' "$BARRR_PROJECT") -scheme $(printf '%q' "$BARRR_SCHEME") -configuration Release \
-destination 'generic/platform=macOS' -derivedDataPath $(printf '%q' "$BARRR_DERIVED_DATA") -quiet"
