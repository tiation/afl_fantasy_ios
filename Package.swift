// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AFLFantasyIntelligence",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "AFLFantasyIntelligence",
            targets: ["AFLFantasyIntelligence"]
        )
    ],
    dependencies: [
        // Testing
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AFLFantasyIntelligence",
            dependencies: [],
            path: "ios/AFLFantasyIntelligence/Sources"
        ),
        .testTarget(
            name: "AFLFantasyIntelligenceTests",
            dependencies: [
                "AFLFantasyIntelligence",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "ios/AFLFantasyIntelligence/Tests"
        )
    ]
)
