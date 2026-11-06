# Changelog

本專案的所有重要變更都記錄在這份檔案。

格式依循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/)，
版本號依循 [Semantic Versioning](https://semver.org/lang/zh-TW/)。

## [Unreleased]

### Changed

- 改名為 Barrr（個人的選單列工具箱），不休眠是其中一個功能；bundle id 改為 `com.chenshenyi.Barrr`。
- 不休眠的選單只剩兩種方式（勾選中的再點一次即恢復休眠），「登入時開啟」與「結束」移到管理視窗。

### Added

- 管理視窗：Barrr 執行中時從 Finder 或 Spotlight 再開一次就會出現，可設定登入時開啟、結束 Barrr。
- 選單列 App：圖示顯示目前是否休眠，選單可切換「不休眠（螢幕保持亮）」、「不休眠（螢幕可關閉）」與恢復休眠；以 IOKit 的 power assertion 實作，不需要 sudo，結束 App 時自動恢復。

### Removed

- SwiftBar plugin（`nosleep` 執行檔）：改為獨立的 App，不再依賴 SwiftBar。
