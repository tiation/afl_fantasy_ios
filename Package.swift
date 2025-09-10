// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AFLFantasy",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "AFLFantasy",
            targets: ["AFLFantasy"]
        )
    ],
    dependencies: [
        // Testing
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AFLFantasy",
            dependencies: [],
            path: "Sources"
        ),
        .executableTarget(
            name: "AFLFantasyIntelligence",
            dependencies: [],
            path: "AFLFantasyIntelligence/Sources"
        ),
        .testTarget(
            name: "AFLFantasyIntelligenceTests",
            dependencies: [
                "AFLFantasyIntelligence",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "AFLFantasyIntelligence/Tests"
        )
    ]
)
