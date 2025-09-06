#!/bin/bash
# 🧪 AFL Fantasy iOS Test Runner
# Runs unit and UI tests only

set -e

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🧪 AFL Fantasy Test Suite${NC}"

# Configuration
PROJECT_NAME="AFLFantasy"
PROJECT_PATH="ios/${PROJECT_NAME}.xcodeproj"
SCHEME="${PROJECT_NAME}"
DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=latest"

echo -e "${BLUE}📋 Running unit tests...${NC}"
xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    -only-testing:"${PROJECT_NAME}Tests" \
    test

echo -e "${BLUE}🖼️  Running UI tests...${NC}"
xcodebuild \
    -project "$PROJECT_PATH" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    -only-testing:"${PROJECT_NAME}UITests" \
    test

echo -e "${GREEN}✅ All tests completed successfully!${NC}"
echo -e "${YELLOW}📊 Test coverage available in Xcode or build reports${NC}"
