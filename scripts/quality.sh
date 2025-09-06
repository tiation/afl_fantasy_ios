#!/usr/bin/env bash
# Enterprise Quality Script for AFL Fantasy iOS
# Runs all code quality checks locally before commit

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PROJECT_NAME="AFLFantasy"
SCHEME="AFLFantasy"
DESTINATION="platform=iOS Simulator,name=iPhone 15,OS=18.6"

echo -e "${PURPLE}🏆 AFL Fantasy iOS - Quality Gate${NC}"
echo -e "${CYAN}====================================${NC}"

# Track failures
FAILED_CHECKS=()

# Function to run a check and track failures
run_check() {
    local check_name="$1"
    local check_command="$2"
    
    echo -e "${BLUE}🔍 $check_name${NC}"
    
    if eval "$check_command"; then
        echo -e "${GREEN}✅ $check_name passed${NC}"
        echo ""
    else
        echo -e "${RED}❌ $check_name failed${NC}"
        FAILED_CHECKS+=("$check_name")
        echo ""
    fi
}

# 1. Check if required tools are installed
echo -e "${BLUE}📋 Checking prerequisites...${NC}"

check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${YELLOW}⚠️  $1 not found. Installing...${NC}"
        if [[ "$1" == "swiftlint" || "$1" == "swiftformat" ]]; then
            brew install "$1"
        fi
    else
        echo -e "${GREEN}✅ $1 found${NC}"
    fi
}

check_tool swiftformat
check_tool swiftlint
echo ""

# 2. SwiftFormat check
run_check "SwiftFormat" "swiftformat --lint . | grep -q 'would have been formatted' && exit 1 || exit 0"

# 3. SwiftLint check
run_check "SwiftLint" "swiftlint --quiet --reporter json | jq -e 'length == 0' > /dev/null 2>&1 || (echo 'SwiftLint violations:' && swiftlint)"

# 4. TODO/FIXME check
run_check "TODO/FIXME Check" "! grep -r 'TODO\|FIXME' ios/AFLFantasy --include='*.swift' --exclude-dir=build"

# 5. Secrets check
run_check "Hardcoded Secrets Check" "! grep -r 'api_key\|password\|secret\|token' ios/AFLFantasy --include='*.swift' | grep -v '// Test' | grep -v '// Mock'"

# 6. Build check
echo -e "${BLUE}🔨 Building project...${NC}"
BUILD_START_TIME=$(date +%s)

if xcodebuild \
    -project "ios/$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    -quiet \
    clean build; then
    
    BUILD_END_TIME=$(date +%s)
    BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
    echo -e "${GREEN}✅ Build completed in ${BUILD_DURATION}s${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    FAILED_CHECKS+=("Build")
fi
echo ""

# 7. Unit tests
echo -e "${BLUE}🧪 Running unit tests...${NC}"
TEST_START_TIME=$(date +%s)

if xcodebuild \
    -project "ios/$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -configuration Debug \
    -enableCodeCoverage YES \
    -quiet \
    test; then
    
    TEST_END_TIME=$(date +%s)
    TEST_DURATION=$((TEST_END_TIME - TEST_START_TIME))
    echo -e "${GREEN}✅ Tests completed in ${TEST_DURATION}s${NC}"
else
    echo -e "${RED}❌ Tests failed${NC}"
    FAILED_CHECKS+=("Tests")
fi
echo ""

# 8. Coverage check
if [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
    echo -e "${BLUE}📊 Checking code coverage...${NC}"
    if ./scripts/coverage_gate.sh 80; then
        echo -e "${GREEN}✅ Coverage gate passed${NC}"
    else
        echo -e "${RED}❌ Coverage gate failed${NC}"
        FAILED_CHECKS+=("Coverage")
    fi
    echo ""
fi

# 9. File size check
echo -e "${BLUE}📏 Checking file sizes...${NC}"
LARGE_FILES=$(find ios/AFLFantasy -name "*.swift" -exec wc -l {} + | awk '$1 > 400 {print $2 " (" $1 " lines)"}')

if [ -n "$LARGE_FILES" ]; then
    echo -e "${YELLOW}⚠️  Large files found (>400 lines):${NC}"
    echo "$LARGE_FILES"
    echo -e "${YELLOW}💡 Consider splitting these files${NC}"
else
    echo -e "${GREEN}✅ All files within size limits${NC}"
fi
echo ""

# 10. Architecture check
echo -e "${BLUE}🏗️ Checking architecture compliance...${NC}"

# Check for MVVM pattern compliance
VIEWS_WITHOUT_VIEWMODEL=$(grep -r "class.*View\|struct.*View" ios/AFLFantasy --include="*.swift" | grep -v "ViewModel\|Preview" | wc -l)
if [ "$VIEWS_WITHOUT_VIEWMODEL" -gt 5 ]; then
    echo -e "${YELLOW}⚠️  Many views without ViewModels detected${NC}"
    echo -e "${YELLOW}💡 Consider implementing MVVM pattern${NC}"
else
    echo -e "${GREEN}✅ Architecture looks good${NC}"
fi
echo ""

# Summary
echo -e "${CYAN}=====================================${NC}"
echo -e "${PURPLE}🎯 Quality Gate Summary${NC}"
echo -e "${CYAN}=====================================${NC}"

if [ ${#FAILED_CHECKS[@]} -eq 0 ]; then
    echo -e "${GREEN}🎉 All quality checks passed!${NC}"
    echo -e "${GREEN}✅ Ready to commit${NC}"
    echo ""
    echo -e "${BLUE}📊 Performance Summary:${NC}"
    echo -e "  • Build time: ${BUILD_DURATION:-0}s"
    echo -e "  • Test time:  ${TEST_DURATION:-0}s"
    echo ""
    echo -e "${YELLOW}🚀 Next steps:${NC}"
    echo -e "  • git add ."
    echo -e "  • git commit -m 'feat: your changes'"
    echo -e "  • git push"
    exit 0
else
    echo -e "${RED}❌ ${#FAILED_CHECKS[@]} quality check(s) failed:${NC}"
    for check in "${FAILED_CHECKS[@]}"; do
        echo -e "  • ${RED}$check${NC}"
    done
    echo ""
    echo -e "${YELLOW}💡 Fix the issues above before committing${NC}"
    echo ""
    echo -e "${BLUE}📚 Quick fixes:${NC}"
    echo -e "  • SwiftFormat: ${CYAN}swiftformat .${NC}"
    echo -e "  • SwiftLint:   ${CYAN}swiftlint --fix${NC}"
    echo -e "  • TODOs:       Move to GitHub issues"
    echo -e "  • Tests:       Fix failing tests"
    echo -e "  • Coverage:    Add more unit tests"
    exit 1
fi
