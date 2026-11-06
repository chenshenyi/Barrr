// swift-tools-version: 6.2
import PackageDescription

/// App 以外的 Swift module：每個功能一個純物件 module（Targets/Core/<功能>/）；App 本身由 project.yml（XcodeGen）定義
let package = Package(
    name: "BarrrModules",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "BarrrCore", targets: ["BarrrCore"]),
        .library(name: "NoSleepCore", targets: ["NoSleepCore"]),
    ],
    targets: [
        // App 共用的設定（登入時開啟）；只用 Swift 標準函式庫，碰系統的部分只透過 protocol
        .target(
            name: "BarrrCore",
            path: "Targets/Core/Barrr",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        // 不休眠；只用 Swift 標準函式庫，碰系統的部分只透過 AwakeController
        .target(
            name: "NoSleepCore",
            path: "Targets/Core/NoSleep",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        // 以 swift test 執行，不需要 build App
        .testTarget(
            name: "BarrrCoreTests",
            dependencies: ["BarrrCore"],
            path: "Targets/Tests/BarrrCoreTests",
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
