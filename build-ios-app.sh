#!/bin/bash
# AFL Fantasy Intelligence iOS App Builder
# Updated for reorganized project structure

cd "$(dirname "$0")"
echo "🍏 Building AFL Fantasy Intelligence iOS App..."
echo "📁 Project root: $(pwd)"
echo "📱 iOS app location: ios/AFLFantasyIntelligence/"
echo ""

cd ios/AFLFantasyIntelligence
echo "📂 Changed to iOS app directory"
echo "🔨 Starting Xcode build..."

# Check if xcodeproj exists
if [ ! -d "AFL Fantasy Intelligence.xcodeproj" ]; then
    echo "❌ Error: AFL Fantasy Intelligence.xcodeproj not found!"
    echo "   Expected location: ios/AFLFantasyIntelligence/AFL Fantasy Intelligence.xcodeproj"
    exit 1
fi

echo "▶️ Running: xcodebuild -project \"AFL Fantasy Intelligence.xcodeproj\" -scheme \"AFL Fantasy Intelligence\" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build"
echo ""

xcodebuild -project "AFL Fantasy Intelligence.xcodeproj" -scheme "AFL Fantasy Intelligence" -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
