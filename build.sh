#!/bin/bash

# 🏗️ AFL Fantasy Platform - Production Build Script
echo "🏆 Building AFL Fantasy Intelligence Platform for Production"
echo "=========================================================="

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

echo -e "${BLUE}🧹 Cleaning previous build...${NC}"
rm -rf dist/

echo -e "${BLUE}📦 Installing dependencies...${NC}"
npm ci --production=false

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Dependencies installed${NC}"

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
    echo -e "${YELLOW}⚠️ Linting issues found, but continuing build...${NC}"
fi

echo -e "${BLUE}🏗️ Building production bundle...${NC}"
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build completed successfully${NC}"

# Check if dist directory was created
if [ -d "dist" ]; then
    echo -e "${BLUE}📊 Build output:${NC}"
    ls -la dist/
    
    # Calculate bundle sizes
    if command -v du >/dev/null 2>&1; then
        DIST_SIZE=$(du -sh dist/ | cut -f1)
        echo -e "${GREEN}📦 Total build size: $DIST_SIZE${NC}"
    fi
    
    # Check for main files
    if [ -f "dist/index.js" ]; then
        echo -e "${GREEN}✅ Server bundle: dist/index.js${NC}"
    fi
    
    if [ -f "dist/public/index.html" ]; then
        echo -e "${GREEN}✅ Frontend bundle: dist/public/${NC}"
    fi
else
    echo -e "${RED}❌ No dist directory found after build${NC}"
    exit 1
fi

echo -e "${BLUE}🧪 Testing production build...${NC}"
echo -e "${YELLOW}💡 You can test the production build with: npm start${NC}"

echo ""
echo -e "${GREEN}🎉 Production build completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo -e "${YELLOW}1. Test the build locally: npm start${NC}"
echo -e "${YELLOW}2. Deploy the dist/ folder to your hosting platform${NC}"
echo -e "${YELLOW}3. Make sure environment variables are set in production${NC}"
echo ""
echo -e "${GREEN}🚀 Ready for deployment!${NC}"
