# Changelog

本專案的所有重要變更都記錄在這份檔案。

格式依循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/)，
版本號依循 [Semantic Versioning](https://semver.org/lang/zh-TW/)。

## [Unreleased]

### Fixed

- Barrr 啟動約 25 秒後被系統自動終止，或以 Escape 關閉選單時結束（選單列圖示消失）。

### Changed

- 改名為 Barrr（個人的選單列工具箱），不休眠是其中一個功能；bundle id 改為 `com.chenshenyi.Barrr`。
- 不休眠的選單只剩兩種方式（勾選中的再點一次即恢復休眠），「登入時開啟」與「結束」移到管理視窗。
- 管理視窗重新設計：整個視窗是一塊 Liquid Glass，工具清單與一般設定是放在上面的玻璃卡片。

### Added

- App 圖示（Icon Composer，Liquid Glass 分層圖示）。
- 系統效能工具：選單列顯示 CPU 使用率，選單有 CPU、記憶體、磁碟空間與讀寫、網路上下行、電池、系統耗電與打開活動監視器。
- 管理視窗可拖曳排列工具在選單列的順序、開關是否顯示（至少保留一個）。
- 管理視窗：Barrr 執行中時從 Finder 或 Spotlight 再開一次就會出現，可設定登入時開啟、結束 Barrr。
- 選單列 App：圖示顯示目前是否休眠，選單可切換「不休眠（螢幕保持亮）」、「不休眠（螢幕可關閉）」與恢復休眠；以 IOKit 的 power assertion 實作，不需要 sudo，結束 App 時自動恢復。

### Removed

- SwiftBar plugin（`nosleep` 執行檔）：改為獨立的 App，不再依賴 SwiftBar。
