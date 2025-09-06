#!/bin/bash
# 📱 AFL Fantasy iOS Simulator Run Script
# Quick launch script for simulator testing

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}📱 AFL Fantasy Simulator Launch${NC}"

# Configuration
SIMULATOR_NAME="iPhone 15"
PROJECT_NAME="AFLFantasy"
PROJECT_PATH="ios/${PROJECT_NAME}.xcodeproj"
SCHEME="${PROJECT_NAME}"

# Boot simulator if not running
echo -e "${BLUE}🚀 Starting iOS Simulator...${NC}"
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || echo "Simulator already running"

# Open Simulator app
open -a Simulator

# Build and install app
echo -e "${BLUE}📦 Installing AFL Fantasy on simulator...${NC}"
xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$SIMULATOR_NAME" \
    -configuration Debug \
    -quiet \
    build install

echo -e "${GREEN}✅ AFL Fantasy launched in simulator!${NC}"
echo -e "🎮 Use the app in the simulator to test features"
