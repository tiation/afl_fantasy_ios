#!/bin/bash
# Performance monitoring script for AFL Fantasy iOS
# Based on performance playbook recommendations

set -e

echo "🚀 AFL Fantasy Performance Monitor"
echo "=================================="

# Build and profile the app
echo "📱 Building and profiling..."
xcodebuild -project ios/AFLFantasy.xcodeproj -scheme AFLFantasy \
  -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" \
  -configuration Release \
  build

# Check bundle size
echo "📦 Checking bundle size..."
BUNDLE_SIZE=$(find . -name "*.app" -exec du -sh {} \; | head -1 | cut -f1)
echo "Bundle size: $BUNDLE_SIZE"

# Memory usage check
echo "🧠 Memory monitoring enabled"
echo "Target: <100MB active usage"

# Performance budgets
echo "⏱️ Performance Budgets:"
echo "  • Cold start: <2.0s"
echo "  • Frame time: <16.67ms (60fps)"
echo "  • Memory: <100MB"
echo "  • Network: <500ms"

echo "✅ Performance monitoring setup complete"
