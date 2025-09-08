#!/bin/bash

# AFL Fantasy iOS Build and Run Script
set -e

echo "🏈 AFL Fantasy iOS - Build and Run"
echo "=================================="

# Check if APIs are running
echo "\n🔍 Checking backend APIs..."
AFL_API_STATUS=$(curl -s http://127.0.0.1:5001/api/health | jq -r '.status // "offline"')
CASH_API_STATUS=$(curl -s http://127.0.0.1:5002/api/cash/health | jq -r '.status // "offline"')

echo "  • AFL Fantasy API: $AFL_API_STATUS"
echo "  • Cash Intelligence API: $CASH_API_STATUS"

if [[ "$AFL_API_STATUS" != "ok" ]] || [[ "$CASH_API_STATUS" != "ok" ]]; then
    echo "\n❌ Backend APIs not running! Please start them first:"
    echo "  cd ../backend/python/api"
    echo "  python3 afl_fantasy_api.py &"
    echo "  python3 cash_api.py &"
    exit 1
fi

echo "\n✅ Backend APIs are running"

# Build the iOS app
echo "\n🔨 Building iOS app..."
xcodebuild -project AFLFantasy.xcodeproj -scheme AFLFantasy -destination 'platform=iOS Simulator,name=iPhone 15' clean build

if [ $? -eq 0 ]; then
    echo "\n✅ Build successful!"
    
    echo "\n🚀 Launching iOS Simulator..."
    # Launch the app in simulator
    xcodebuild -project AFLFantasy.xcodeproj -scheme AFLFantasy -destination 'platform=iOS Simulator,name=iPhone 15' test-without-building
    
    echo "\n📱 App should now be running in iOS Simulator"
    echo "🎯 Navigate to the 'Cash Cow' tab to see the new Cash Intelligence feature!"
else
    echo "\n❌ Build failed!"
    exit 1
fi
