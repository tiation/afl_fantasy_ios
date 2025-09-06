#!/bin/bash

# 📱 AFL Fantasy iOS App - Simple Run Script

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 AFL Fantasy iOS App Launcher${NC}"
echo "=================================="

# Check if we're in the right directory
if [ ! -d "ios" ]; then
    echo -e "${RED}❌ ios directory not found. Please run this from the AFL Fantasy project root.${NC}"
    exit 1
fi

# Check if Xcode is available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode not found. Please install Xcode from the App Store.${NC}"
    exit 1
fi

# Check if xcodeproj exists
if [ ! -d "ios/AFLFantasy.xcodeproj" ]; then
    echo -e "${RED}❌ AFLFantasy.xcodeproj not found in ios/ directory.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Xcode detected${NC}"
echo -e "${GREEN}✅ AFLFantasy.xcodeproj found${NC}"

# Option 1: Open in Xcode
echo ""
echo -e "${BLUE}Choose how to run the iOS app:${NC}"
echo -e "${YELLOW}1.${NC} Open in Xcode (recommended for development)"
echo -e "${YELLOW}2.${NC} Build and run in simulator (command line)"
echo -e "${YELLOW}3.${NC} Just build (no run)"
echo -e "${YELLOW}4.${NC} Cancel"

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo -e "${BLUE}🚀 Opening in Xcode...${NC}"
        open ios/AFLFantasy.xcodeproj
        echo -e "${GREEN}✅ Xcode opened. Press ⌘+R to build and run in simulator${NC}"
        ;;
    2)
        echo -e "${BLUE}🔨 Building and running in simulator...${NC}"
        cd ios
        
        # List available simulators
        echo -e "${BLUE}📱 Available iOS Simulators:${NC}"
        xcrun simctl list devices iOS | grep -E "\s+(iPhone|iPad)" | grep -v unavailable
        
        # Use iPhone 15 as default
        DESTINATION="platform=iOS Simulator,name=iPhone 15"
        
        echo -e "${BLUE}🔨 Building for iPhone 15 simulator...${NC}"
        xcodebuild -scheme AFLFantasy \
                   -destination "$DESTINATION" \
                   -configuration Debug \
                   build
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Build successful!${NC}"
            
            # Try to run the app
            echo -e "${BLUE}🚀 Launching app in simulator...${NC}"
            xcodebuild -scheme AFLFantasy \
                       -destination "$DESTINATION" \
                       -configuration Debug \
                       test-without-building &
                       
            echo -e "${GREEN}✅ App launching in simulator${NC}"
        else
            echo -e "${RED}❌ Build failed. Check the output above for errors.${NC}"
            exit 1
        fi
        ;;
    3)
        echo -e "${BLUE}🔨 Building only (no run)...${NC}"
        cd ios
        xcodebuild -scheme AFLFantasy \
                   -destination "platform=iOS Simulator,name=iPhone 15" \
                   -configuration Debug \
                   build
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Build successful!${NC}"
        else
            echo -e "${RED}❌ Build failed. Check the output above for errors.${NC}"
            exit 1
        fi
        ;;
    4)
        echo -e "${YELLOW}👋 Cancelled${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}❌ Invalid choice. Please run the script again.${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}🎉 iOS app setup complete!${NC}"
echo -e "${BLUE}💡 Tips:${NC}"
echo -e "  • Make sure your API server is running on http://localhost:5173"
echo -e "  • In the iOS app, go to Settings → Sign In to configure your AFL Fantasy credentials"
echo -e "  • The app will connect to your local API server for data"
