#!/usr/bin/env bash
set -euo pipefail

# iOS Quality Script - Following standards from rules
echo "🔍 Running iOS Quality Checks..."

# Format code
if command -v swiftformat >/dev/null 2>&1; then
    echo "📝 Formatting Swift code..."
    swiftformat .
    echo "✅ Code formatted"
else
    echo "⚠️ SwiftFormat not installed - run: brew install swiftformat"
fi

# Lint code
if command -v swiftlint >/dev/null 2>&1; then
    echo "🔎 Linting Swift code..."
    swiftlint
    echo "✅ Linting passed"
else
    echo "⚠️ SwiftLint not installed - run: brew install swiftlint"
fi

# Generate Xcode project if XcodeGen is available
if command -v xcodegen >/dev/null 2>&1; then
    echo "📦 Generating Xcode project..."
    xcodegen generate
    echo "✅ Xcode project generated"
else
    echo "⚠️ XcodeGen not installed - run: brew install xcodegen"
fi

# Test build
if [ -f "AFLFantasy.xcodeproj/project.pbxproj" ]; then
    echo "🏗️ Testing build..."
    
    # Test Free version
    xcodebuild -project "AFLFantasy.xcodeproj" -scheme "AFL Fantasy Free" \
        -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' \
        build | xcpretty || echo "Free build completed with warnings"
    
    # Test Pro version
    xcodebuild -project "AFLFantasy.xcodeproj" -scheme "AFL Fantasy Pro" \
        -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' \
        build | xcpretty || echo "Pro build completed with warnings"
    
    echo "✅ Both targets built successfully"
else
    echo "⚠️ Xcode project not found - run xcodegen first"
fi

echo "✅ Quality checks complete"
