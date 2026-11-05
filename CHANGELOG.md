# Changelog

本專案的所有重要變更都記錄在這份檔案。

格式依循 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/)，
版本號依循 [Semantic Versioning](https://semver.org/lang/zh-TW/)。

## [Unreleased]

### Added

- SwiftBar plugin：選單列圖示顯示目前是否休眠，選單可切換「不休眠（螢幕保持亮）」、「不休眠（螢幕可關閉）」與恢復休眠；以 launchd 管理的 `caffeinate` 實作，不需要 sudo，登出或重開機後自動恢復。
