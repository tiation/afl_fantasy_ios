// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AFLFantasy",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    dependencies: [
        .package(path: "Packages/AFLFantasyModels")
    ],
    targets: [
        .target(
            name: "AFLFantasy",
            dependencies: ["AFLFantasyModels"],
            path: "AFLFantasy"
        ),
        .testTarget(
            name: "AFLFantasyTests",
            dependencies: ["AFLFantasy"],
            path: "AFLFantasyTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
