#!/usr/bin/env bash
# Enterprise Coverage Gate Script for AFL Fantasy iOS
# Ensures minimum code coverage threshold is met

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

THRESHOLD=${1:-80}
PROJECT_NAME="AFLFantasy"

echo -e "${BLUE}📊 Coverage Gate - AFL Fantasy iOS${NC}"
echo -e "${BLUE}===================================${NC}"

# Find the most recent profdata file
PROFDATA_FILE=$(find . -name "*.profdata" -type f | head -1)

if [ -z "$PROFDATA_FILE" ]; then
    echo -e "${RED}❌ No profdata file found. Make sure tests ran with code coverage enabled.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Using profdata: $PROFDATA_FILE${NC}"

# Find the binary
BINARY_PATH=$(find . -name "$PROJECT_NAME" -type f | grep -E "(Debug|Release)" | head -1)

if [ -z "$BINARY_PATH" ]; then
    echo -e "${RED}❌ No binary found at expected path${NC}"
    exit 1
fi

echo -e "${YELLOW}🔍 Using binary: $BINARY_PATH${NC}"

# Generate coverage report
echo -e "${BLUE}📈 Generating coverage report...${NC}"

COVERAGE_REPORT=$(xcrun llvm-cov report \
    -instr-profile="$PROFDATA_FILE" \
    "$BINARY_PATH" \
    2>/dev/null)

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to generate coverage report${NC}"
    exit 1
fi

echo "$COVERAGE_REPORT"

# Extract overall coverage percentage
FOUND=$(echo "$COVERAGE_REPORT" | grep "TOTAL" | awk '{print int($4)}' | head -1)

if [ -z "$FOUND" ]; then
    echo -e "${RED}❌ Could not parse coverage percentage from report${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}🎯 Coverage Analysis:${NC}"
echo -e "  • Threshold: ${YELLOW}${THRESHOLD}%${NC}"
echo -e "  • Actual:    ${YELLOW}${FOUND}%${NC}"

# Check if coverage meets threshold
if [ "$FOUND" -lt "$THRESHOLD" ]; then
    echo ""
    echo -e "${RED}❌ Coverage gate failed!${NC}"
    echo -e "${RED}   Coverage ${FOUND}% < ${THRESHOLD}% threshold${NC}"
    echo ""
    echo -e "${YELLOW}💡 To improve coverage:${NC}"
    echo -e "   • Add unit tests for untested functions"
    echo -e "   • Test error handling paths"
    echo -e "   • Add integration tests for complex flows"
    echo ""
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ Coverage gate passed!${NC}"
    echo -e "${GREEN}   Coverage ${FOUND}% ≥ ${THRESHOLD}% threshold${NC}"
    echo ""
fi

# Generate detailed coverage by file (optional)
if [ "${2:-}" = "--detailed" ]; then
    echo -e "${BLUE}📋 Detailed Coverage by File:${NC}"
    xcrun llvm-cov show \
        -instr-profile="$PROFDATA_FILE" \
        "$BINARY_PATH" \
        -format=text \
        2>/dev/null | head -50
fi

echo -e "${GREEN}🎉 Coverage analysis complete${NC}"
