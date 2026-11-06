# No Sleep

在 macOS 選單列快速關閉／恢復休眠的小 App。

- 兩種方式：**螢幕保持亮**（系統與螢幕都不睡）與**螢幕可關閉**（系統不睡、螢幕照設定關）
- 點已勾選的方式或「恢復休眠」就回到系統設定；結束 App 也會自動恢復
- 可設定登入時開啟
- 不改 `pmset`、不需要 sudo，也不依賴其他 App
- 平台：macOS 26+；技術：Swift 6、SwiftUI（`MenuBarExtra`）、IOKit power assertion

## 安裝

```sh
mise trust       # 信任本 repo 的 mise.toml
mise install     # 安裝 xcodegen、swiftlint、swiftformat、git-lfs
mise run setup   # 啟用 git hooks、Git LFS，並產生 NoSleep.xcodeproj
mise run install # build 並裝到 /Applications，開啟後出現在選單列
```

沒有開發者帳號也能用：App 以 ad-hoc 簽章，自己 build 的不會被 Gatekeeper 擋。

開發環境、指令、目錄結構與慣例詳見 [CLAUDE.md](CLAUDE.md)。

## 變更紀錄

見 [CHANGELOG.md](CHANGELOG.md)。
