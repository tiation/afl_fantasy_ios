#!/bin/bash

echo "🏈 Testing AFL Fantasy iOS App"
echo "=============================="

# Check if API server is running
if curl -s http://localhost:4000/health > /dev/null 2>&1; then
    echo "✅ API server is running"
    echo "📊 API Health Status:"
    curl -s http://localhost:4000/health | python3 -m json.tool 2>/dev/null || echo "   Unable to parse JSON response"
else
    echo "❌ API server is not running"
    echo "💡 Start with: ./start_api.sh"
    echo ""
fi

echo ""
echo "🔨 Building iOS app..."

# Build the iOS app
if xcodebuild -project "AFL Fantasy.xcodeproj" -scheme "AFL Fantasy" -sdk iphonesimulator build -quiet; then
    echo "✅ iOS app builds successfully"
    echo ""
    
    # Try to launch the app in simulator
    echo "📱 Launching app in simulator..."
    echo "   1. Open 'AFL Fantasy.xcodeproj' in Xcode"
    echo "   2. Select 'AFL Fantasy' scheme"
    echo "   3. Choose an iOS Simulator (iPhone 15 recommended)"
    echo "   4. Press ⌘+R to run"
    echo ""
    echo "🔍 If the app shows a blank screen, check these:"
    echo "   • API server running at http://localhost:4000"
    echo "   • Console output for any Swift errors"
    echo "   • Network connectivity between app and API"
    
else
    echo "❌ iOS app build failed"
    echo ""
    echo "🔍 Common issues:"
    echo "   • Missing dependencies in Xcode project"
    echo "   • Swift syntax errors"
    echo "   • Missing files referenced in project"
    echo ""
    echo "🛠️  To debug:"
    echo "   1. Open project in Xcode"
    echo "   2. Check Build Issues navigator"
    echo "   3. Resolve any red errors"
fi

echo ""
echo "📋 Quick Status Summary:"
echo "========================"
python3 -c "
import subprocess
import json

try:
    result = subprocess.run(['curl', '-s', 'http://localhost:4000/health'], capture_output=True, text=True)
    if result.returncode == 0:
        data = json.loads(result.stdout)
        print(f'✅ API: {data[\"players_cached\"]} players cached')
        print(f'   Last updated: {data[\"last_cache_update\"][:19]}')
    else:
        print('❌ API: Not responding')
except:
    print('❌ API: Not accessible')

print('📱 iOS: Build the app in Xcode to test')
"

echo ""
echo "System check complete! 🎉"
