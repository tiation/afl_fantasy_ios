#!/usr/bin/env bash

# AFL Fantasy Intelligence - Quality Check Script
# Runs all quality checks before committing/pushing

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 AFL Fantasy Intelligence - Quality Checks"
echo "=========================================="

# Run SwiftFormat
echo -e "\n${YELLOW}📏 Running SwiftFormat...${NC}"
if command -v swiftformat &> /dev/null; then
    swiftformat .
    echo -e "${GREEN}✅ SwiftFormat completed${NC}"
else
    echo -e "${RED}❌ SwiftFormat not installed. Install with: brew install swiftformat${NC}"
    exit 1
fi

# Run SwiftLint
echo -e "\n${YELLOW}🧹 Running SwiftLint...${NC}"
if command -v swiftlint &> /dev/null; then
    swiftlint
    echo -e "${GREEN}✅ SwiftLint completed${NC}"
else
    echo -e "${RED}❌ SwiftLint not installed. Install with: brew install swiftlint${NC}"
    exit 1
fi

# Build the project
echo -e "\n${YELLOW}🔨 Building project...${NC}"
xcodebuild -scheme "AFL Fantasy Intelligence" \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -configuration Debug \
    build-for-testing | xcpretty

echo -e "${GREEN}✅ Build successful${NC}"

# Run tests if they exist
echo -e "\n${YELLOW}🧪 Running tests...${NC}"
if xcodebuild -list -project "AFL Fantasy Intelligence.xcodeproj" 2>/dev/null | grep -q "AFL Fantasy IntelligenceTests"; then
    xcodebuild -scheme "AFL Fantasy Intelligence" \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 15' \
        -enableCodeCoverage YES \
        test | xcpretty
    
    # Check coverage
    bash Scripts/coverage_gate.sh 80
else
    echo -e "${YELLOW}⚠️  No tests found. Consider adding tests for better quality assurance.${NC}"
fi

echo -e "\n${GREEN}✅ All quality checks passed!${NC}"
echo "=========================================="
echo "Ready to commit your changes! 🎉"

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
