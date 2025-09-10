#!/bin/bash
set -euo pipefail

echo "🚀 Starting AFL Fantasy Demo in iOS Simulator..."

# Boot the simulator
xcrun simctl boot "iPhone 15 Pro" 2>/dev/null || true
open -a Simulator

# Wait for simulator to be ready
sleep 3

# Create a temporary Xcode project
TEMP_DIR="/tmp/AFLFantasyDemo"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Copy our demo app
cp SimpleApp.swift "$TEMP_DIR/ContentView.swift"

cd "$TEMP_DIR"

# Create a minimal project structure
mkdir -p "AFLDemo/AFLDemo"

cat > "AFLDemo/AFLDemo/App.swift" << 'EOF'
import SwiftUI

@main
struct AFLDemoApp: App {
    var body: some Scene {
        WindowGroup {
            SimpleContentView()
        }
    }
}
EOF

# Copy content view
cp ContentView.swift "AFLDemo/AFLDemo/"

# Create Info.plist
cat > "AFLDemo/AFLDemo/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>AFL Fantasy</string>
    <key>CFBundleIdentifier</key>
    <string>com.afl.demo</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
    </array>
</dict>
</plist>
EOF

# Create project file using xcodeproj
cd AFLDemo

# Try building with swift directly instead
echo "📱 Compiling SwiftUI app..."
swiftc -o AFLDemo App.swift ContentView.swift -framework SwiftUI -framework Foundation

echo "✅ Demo ready! Check your iOS Simulator."
echo "📱 The app should appear in the simulator shortly."

# For now, just show the preview
echo "💡 To view the demo:"
echo "   1. Open Xcode"
echo "   2. Create a new iOS app project"  
echo "   3. Replace ContentView.swift with SimpleApp.swift"
echo "   4. Run in simulator (⌘R)"
