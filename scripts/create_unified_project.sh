#!/usr/bin/env bash
set -euo pipefail

echo "🏗️ Creating unified Xcode project..."

UNIFIED_DIR="AFL_Fantasy_Unified"
PROJECT_NAME="AFLFantasy"

cd "$UNIFIED_DIR"

# Create Swift Package Manager project structure
cat > Package.swift << 'EOF'
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
EOF

# Create feature flag system
mkdir -p "Sources/Free" "Sources/Pro"

cat > "Sources/Free/FeatureFlags.swift" << 'EOF'
import Foundation

public enum FeatureFlags {
    public static let isPro = false
    public static let hasAdvancedAnalytics = false
    public static let hasAIRecommendations = false
    public static let hasCashCowAnalyzer = false
    public static let hasWidgetSupport = false
    public static let maxSavedLines = 3
}
EOF

cat > "Sources/Pro/FeatureFlags.swift" << 'EOF'
import Foundation

public enum FeatureFlags {
    public static let isPro = true
    public static let hasAdvancedAnalytics = true
    public static let hasAIRecommendations = true
    public static let hasCashCowAnalyzer = true
    public static let hasWidgetSupport = true
    public static let maxSavedLines = -1 // unlimited
}
EOF

# Create main app files for each target
cat > "Sources/Free/AFLFantasyFreeApp.swift" << 'EOF'
import SwiftUI

@main
struct AFLFantasyFreeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF

cat > "Sources/Pro/AFLFantasyProApp.swift" << 'EOF'
import SwiftUI

@main
struct AFLFantasyProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
EOF

echo "✅ Unified project structure created"
echo "📦 Swift Package Manager setup complete"

cd ..

echo "🎯 Next: Create Xcode project files"
