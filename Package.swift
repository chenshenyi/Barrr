// swift-tools-version: 6.2
import PackageDescription

/// App 以外的 Swift module：狀態與操作的純物件 NoSleepCore；App 本身由 project.yml（XcodeGen）定義
let package = Package(
    name: "NoSleepModules",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "NoSleepCore", targets: ["NoSleepCore"]),
    ],
    targets: [
        // 只用 Swift 標準函式庫：碰系統的部分只透過 AwakeController、LoginItemController protocol
        .target(
            name: "NoSleepCore",
            path: "Targets/NoSleepCore",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
        // 以 swift test 執行，不需要 build App
        .testTarget(
            name: "NoSleepCoreTests",
            dependencies: ["NoSleepCore"],
            path: "Targets/Tests/NoSleepCoreTests",
            swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
        ),
    ]
)
