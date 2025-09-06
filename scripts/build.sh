#!/bin/bash
# 🏗️ AFL Fantasy iOS Build Script
# Fast and beautiful build process for AFL Fantasy Intelligence Platform

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="AFLFantasy"
PROJECT_PATH="ios/${PROJECT_NAME}.xcodeproj"
SCHEME="${PROJECT_NAME}"
DESTINATION="platform=iOS Simulator,name=Any iOS Simulator Device"
DERIVED_DATA_PATH="build/DerivedData"

echo -e "${PURPLE}🏆 AFL Fantasy Intelligence Platform - Build Script${NC}"
echo -e "${CYAN}=================================================${NC}"

# Check prerequisites
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ xcodebuild not found. Please install Xcode Command Line Tools.${NC}"
    exit 1
fi

if [ ! -f "$PROJECT_PATH/project.pbxproj" ]; then
    echo -e "${RED}❌ Project file not found at $PROJECT_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check complete${NC}"

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf build/
mkdir -p build

# Show available simulators (for debugging)
echo -e "${BLUE}📱 Available iOS Simulators:${NC}"
xcrun simctl list devices available | grep "iPhone" | head -5

# Build the project
echo -e "${BLUE}🔨 Building AFL Fantasy for iOS Simulator...${NC}"
echo -e "${YELLOW}Project: $PROJECT_NAME${NC}"
echo -e "${YELLOW}Scheme: $SCHEME${NC}"
echo -e "${YELLOW}Destination: $DESTINATION${NC}"

xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -configuration Debug \
    -quiet \
    clean build

echo -e "${GREEN}✅ Build completed successfully!${NC}"

# Run unit tests
echo -e "${BLUE}🧪 Running unit tests...${NC}"
xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    -configuration Debug \
    -quiet \
    test

echo -e "${GREEN}✅ All tests passed!${NC}"

# Display build summary
echo -e "${CYAN}=================================================${NC}"
echo -e "${GREEN}🎉 AFL Fantasy iOS Build Complete!${NC}"
echo -e "${BLUE}📊 Build Summary:${NC}"
echo -e "  • Project: AFL Fantasy Intelligence Platform"
echo -e "  • Target: iOS 17.0+"
echo -e "  • Architecture: SwiftUI + Combine"
echo -e "  • Build Configuration: Debug"
echo -e "  • Tests: ✅ Passed"

echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo -e "  • Run: ${CYAN}open ios/${PROJECT_NAME}.xcodeproj${NC} to open in Xcode"
echo -e "  • Run: ${CYAN}./scripts/run-simulator.sh${NC} to launch in simulator"
echo -e "  • Run: ${CYAN}./scripts/run-tests.sh${NC} to run tests only"

echo -e "${PURPLE}Built with ⚡ fast and beautiful tech stack${NC}"
