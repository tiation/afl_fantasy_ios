// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AFLFantasyServices",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AFLFantasyServices",
            targets: ["AFLFantasyServices"]
        )
    ],
    dependencies: [
        .package(path: "../AFLFantasyModels")
    ],
    targets: [
        .target(
            name: "AFLFantasyServices",
            dependencies: [
                "AFLFantasyModels"
            ]
        ),
        .testTarget(
            name: "AFLFantasyServicesTests",
            dependencies: ["AFLFantasyServices"]
        )
    ]
)
