// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "AFLFantasyApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15)
    ],
    products: [
        .executable(
            name: "AFLFantasyApp",
            targets: ["AFLFantasyApp"]
        )
    ],
    dependencies: [
        // Networking
        .package(url: "https://github.com/kean/Nuke", from: "12.0.0"),
        
        // Testing
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "AFLFantasyApp",
            dependencies: [
                "Nuke"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "AFLFantasyAppTests",
            dependencies: [
                "AFLFantasyApp",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/AFLFantasyAppTests"
        )
    ]
)
