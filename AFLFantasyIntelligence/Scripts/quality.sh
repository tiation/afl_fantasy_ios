#!/usr/bin/env bash
set -euo pipefail

echo "🍏 iOS Quality Checks Starting..."
echo "=================================="

# SwiftFormat
echo "📝 Running SwiftFormat..."
if command -v swiftformat &> /dev/null; then
    swiftformat .
    echo "✅ SwiftFormat completed"
else
    echo "⚠️  SwiftFormat not found. Install with: brew install swiftformat"
fi

# SwiftLint
echo "🔍 Running SwiftLint..."
if command -v swiftlint &> /dev/null; then
    swiftlint
    echo "✅ SwiftLint completed"
else
    echo "⚠️  SwiftLint not found. Install with: brew install swiftlint"
fi

# Build check
echo "🏗️  Building project..."
if xcodebuild -project "AFL Fantasy Intelligence.xcodeproj" -scheme "AFL Fantasy Intelligence" -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15' build | xcpretty; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

echo "=================================="
echo "🎉 All quality checks passed!"
