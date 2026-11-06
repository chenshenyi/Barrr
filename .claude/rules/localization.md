---
paths:
  - "Targets/App/NoSleep/**/*.swift"
  - "Targets/App/Resources/StringCatalog/**"
---

# 在地化規則

UI 文字一律透過 String Catalog 產生的 symbol 取得，編譯期就能發現打錯或遺漏的 key。

- catalog 放在 `Targets/App/Resources/StringCatalog/`（只放 catalog，不放 Swift），一個文案分類一個 `.xcstrings`；`Localizable.xcstrings` 是預設 table，目前只有這一個。
- 開啟 `STRING_CATALOG_GENERATE_SYMBOLS`，關閉自動抽取（`SWIFT_EMIT_LOC_STRINGS: NO`），catalog 內每個字串都是手動管理（`"extractionState" : "manual"`）。
- 產生的 symbol 是 `LocalizedStringResource` 的 static 成員：`Text(.menuResume)`；其他 table 帶 table 名（`Settings.xcstrings` → `Text(.Settings.xxx)`）。
- key 用 lowerCamelCase，以「畫面／功能 + 用途」命名（例如 `menuResume`、`modeKeepDisplayOn`、`failureHold`），不要用英文原文當 key。
- 新增文字：在對應 catalog 新增 key，填入 `en` 與 `zh-Hant`（state 為 `translated`）；不需翻譯的專有名詞設 `"shouldTranslate" : false`，但仍要填入每個語言（值與 `en` 相同）：只有 `en` 時，`zh-Hant` 環境在執行期找不到這個 key，畫面會直接顯示 key 本身（例如 `menuQuit`）。`lint:assets` 會擋下缺少任一語言的 key。
- 傳遞要顯示的文字時用 `LocalizedStringResource`，不用 `String`。
- 型別對應到顯示文字的 mapping 寫成遵循 `LocalizedStringResourceConvertible`（`var localizedStringResource`）的 extension，放在 `Targets/App/NoSleep/Mapping/LocalizedString/`，檔名 `<型別>+Localizable.swift`；顯示時直接 `Text(value)`；不寫在型別本體（見 `.claude/rules/swift-principles.md` 的「最小化外部依賴」）。
- 禁止以字串字面值當 UI 文字（`Text("…")`、`Button("…")`、`.navigationTitle("…")`、`String(localized:)` 等）；不需在地化的內容（數字、使用者輸入）用 `Text(verbatim:)`。SwiftLint `localized_string_via_symbol` 會擋下。
