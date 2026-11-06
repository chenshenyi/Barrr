# Barrr

個人的 macOS 選單列工具箱：每個功能一個選單列圖示，另有一個共用的管理視窗。

## 功能

- **不休眠**：點開選單選「螢幕保持亮」或「螢幕可關閉」，勾選中的再點一次就恢復照系統設定休眠；結束 Barrr 也會自動恢復。不改 `pmset`、不需要 sudo。
- **系統效能**：選單列顯示 CPU 使用率，點開看 CPU、記憶體，或打開活動監視器。

## 管理視窗

Barrr 執行中時，從 Finder 或 Spotlight 再開一次 Barrr 就會出現：拖曳排列工具在選單列的順序、開關是否顯示，設定登入時開啟、結束 Barrr。

## 安裝

```sh
mise trust       # 信任本 repo 的 mise.toml
mise install     # 安裝 xcodegen、swiftlint、swiftformat、git-lfs
mise run setup   # 啟用 git hooks、Git LFS，並產生 Barrr.xcodeproj
mise run install # build 並裝到 /Applications，開啟後出現在選單列
```

沒有開發者帳號也能用：App 以 ad-hoc 簽章，自己 build 的不會被 Gatekeeper 擋。

- 平台：macOS 26+
- 技術：Swift 6、SwiftUI（`MenuBarExtra`）

開發環境、指令、目錄結構與慣例詳見 [CLAUDE.md](CLAUDE.md)。

## 變更紀錄

見 [CHANGELOG.md](CHANGELOG.md)。
