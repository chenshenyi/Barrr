# No Sleep

在 macOS 選單列快速關閉／恢復休眠的 [SwiftBar](https://github.com/swiftbar/SwiftBar) plugin。

- 兩種方式：**螢幕保持亮**（`caffeinate -dis`）與**螢幕可關閉**（`caffeinate -is`，系統不睡、螢幕照設定關）
- 點已勾選的方式或「恢復休眠」就回到系統設定
- 不改 `pmset`、不需要 sudo；登出或重開機後自動恢復
- 平台：macOS 26+；技術：Swift 6

## 安裝

1. 安裝 [SwiftBar](https://github.com/swiftbar/SwiftBar/releases)，開啟後選一個 plugin 資料夾
2. 在本 repo 執行：

```sh
mise trust       # 信任本 repo 的 mise.toml
mise install     # 安裝 swiftlint、swiftformat、git-lfs
mise run setup   # 啟用 git hooks、Git LFS
mise run install # build 並裝進 SwiftBar 的 plugin 資料夾
```

開發環境、指令、目錄結構與慣例詳見 [CLAUDE.md](CLAUDE.md)。

## 變更紀錄

見 [CHANGELOG.md](CHANGELOG.md)。
