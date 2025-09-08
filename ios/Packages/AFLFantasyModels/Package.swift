// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AFLFantasyModels",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AFLFantasyModels",
            targets: ["AFLFantasyModels"]
        )
    ],
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
