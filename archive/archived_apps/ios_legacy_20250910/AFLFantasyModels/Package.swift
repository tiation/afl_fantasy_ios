// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "AFLFantasyModels",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AFLFantasyModels",
            targets: ["AFLFantasyModels"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AFLFantasyModels",
            dependencies: []
        ),
        .testTarget(
            name: "AFLFantasyModelsTests",
            dependencies: ["AFLFantasyModels"]
        )
    ]
)
