// swift-tools-version: 6.2
import PackageDescription

/// SwiftBar plugin：在選單列快速關閉／恢復 Mac 的休眠
let package = Package(
    name: "NoSleep",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "nosleep", targets: ["NoSleepPlugin"]),
    ],
    targets: [
        // 只用 Swift 標準函式庫：指令解析、選單內容與流程，碰系統的部分只透過 AwakeController protocol
        .target(
            name: "NoSleepCore",
            path: "Targets/NoSleepCore",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        // 進入點（composition root）與 live 實作（launchctl）
        .executableTarget(
            name: "NoSleepPlugin",
            dependencies: ["NoSleepCore"],
            path: "Targets/NoSleepPlugin",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        .testTarget(
            name: "NoSleepCoreTests",
            dependencies: ["NoSleepCore"],
            path: "Targets/Tests/NoSleepCoreTests",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
    ]
)
