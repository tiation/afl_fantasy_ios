#!/bin/bash

# 🚀 AFL Fantasy Platform - Simple Start Script
echo "🏆 Starting AFL Fantasy Intelligence Platform..."

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

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    if command -v pnpm >/dev/null 2>&1; then
        pnpm install --frozen-lockfile 2>/dev/null || pnpm install
    else
        npm install
    fi
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚙️ Setting up environment file...${NC}"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created .env from .env.example${NC}"
        echo -e "${YELLOW}💡 Please edit .env with your actual API keys and database credentials${NC}"
    else
        echo -e "${YELLOW}⚠️ No .env.example found. You may need to create .env manually${NC}"
    fi
fi

echo -e "${BLUE}🔄 Starting development servers...${NC}"
echo -e "${GREEN}📊 Web Dashboard will be available at: http://localhost:5173${NC}"
echo -e "${GREEN}🔌 API will be available at: http://localhost:5173/api${NC}"
echo -e "${GREEN}📊 Health Check: http://localhost:5173/api/health${NC}"
echo ""
echo -e "${YELLOW}💡 Press Ctrl+C to stop the servers${NC}"
echo -e "${YELLOW}💡 The server may take 10-15 seconds to fully start${NC}"
echo ""

# Start the development server
echo -e "${BLUE}🚀 Starting AFL Fantasy Platform...${NC}"
echo -e "${YELLOW}📊 Status dashboard will open automatically after startup${NC}"
echo ""

# Start the development server
npm run dev &

# Wait a moment for server to start, then open dashboard
sleep 5
echo -e "${GREEN}📊 Opening status dashboard...${NC}"

# Start dashboard server if needed
if ! curl -s http://localhost:8080/status.html > /dev/null 2>&1; then
    python3 -m http.server 8080 --bind 127.0.0.1 >/dev/null 2>&1 &
    sleep 2
fi

if command -v open >/dev/null 2>&1; then
    open "http://localhost:8080/status.html" || open "file://$(pwd)/status.html"
fi

echo -e "${GREEN}🎯 Live Status Dashboard: http://localhost:8080/status.html${NC}"

# Keep the server running in foreground
wait
