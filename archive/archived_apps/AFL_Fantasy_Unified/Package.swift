// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AFLFantasy",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "AFLFantasyShared", targets: ["AFLFantasyShared"]),
        .library(name: "AFLFantasyFree", targets: ["AFLFantasyFree"]),
        .library(name: "AFLFantasyPro", targets: ["AFLFantasyPro"])
    ],
    dependencies: [
        // Add your dependencies here
    ],
    targets: [
        .target(
            name: "AFLFantasyShared",
            dependencies: [],
            path: "Sources/Shared"
        ),
        .target(
            name: "AFLFantasyFree", 
            dependencies: ["AFLFantasyShared"],
            path: "Sources/Free"
        ),
        .target(
            name: "AFLFantasyPro",
            dependencies: ["AFLFantasyShared"],
            path: "Sources/Pro"
        ),
        .testTarget(
            name: "AFLFantasyTests",
            dependencies: ["AFLFantasyShared"],
            path: "Tests"
        )
    ]
)
