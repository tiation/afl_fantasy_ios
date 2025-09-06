#!/bin/bash

# 🧪 AFL Fantasy Platform - Test Script
echo "🧪 Running AFL Fantasy Intelligence Platform Tests"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: package.json not found. Make sure you're in the AFL Fantasy project directory.${NC}"
    exit 1
fi

echo -e "${BLUE}🔍 Running type checking...${NC}"
npm run check

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Type checking failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Type checking passed${NC}"

echo -e "${BLUE}🔍 Running linter...${NC}"
npm run lint:check

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Linting failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Linting passed${NC}"

echo -e "${BLUE}🔍 Running Prettier format check...${NC}"
npm run format:check

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Code formatting check failed${NC}"
    echo -e "${YELLOW}💡 Run 'npm run format' to fix formatting issues${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Code formatting is correct${NC}"

echo -e "${BLUE}🧪 Running unit tests...${NC}"
npm test

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Unit tests passed${NC}"

echo -e "${BLUE}🛡️ Running security audit...${NC}"
npm run audit:security

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️ Security audit found issues (this may not be critical)${NC}"
fi

echo -e "${BLUE}🏗️ Testing build process...${NC}"
npm run build > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build test failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build test passed${NC}"

echo ""
echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
echo ""
echo -e "${BLUE}Test Results Summary:${NC}"
echo -e "${GREEN}✅ Type checking${NC}"
echo -e "${GREEN}✅ Code linting${NC}"
echo -e "${GREEN}✅ Code formatting${NC}"
echo -e "${GREEN}✅ Unit tests${NC}"
echo -e "${GREEN}✅ Build process${NC}"
echo ""
echo -e "${GREEN}🚀 Your AFL Fantasy Platform is ready!${NC}"
