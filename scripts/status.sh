#!/bin/bash

# 📊 AFL Fantasy Platform - Status Dashboard Launcher
echo "📊 Opening AFL Fantasy Platform Status Dashboard..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if status.html exists
if [ ! -f "status.html" ]; then
    echo -e "${RED}❌ Error: status.html not found${NC}"
    exit 1
fi

# Get the full path to status.html
STATUS_FILE=$(realpath status.html)

# Check if server is running and try different dashboard options
if curl -s http://localhost:5173/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}🌐 Status Dashboard: http://localhost:8080/status.html${NC}"
    echo -e "${GREEN}✅ Server is running - using live dashboard on port 8080${NC}"
    
    # Start simple HTTP server for dashboard if not running
    if ! curl -s http://localhost:8080/status.html > /dev/null 2>&1; then
        echo -e "${YELLOW}🔄 Starting dashboard server on port 8080...${NC}"
        python3 -m http.server 8080 --bind 127.0.0.1 >/dev/null 2>&1 &
        sleep 2
    fi
    
    STATUS_URL="http://localhost:8080/status.html"
else
    echo -e "${YELLOW}🌐 Status Dashboard: file://${STATUS_FILE}${NC}"
    echo -e "${YELLOW}⚠️ Server not running - using local dashboard${NC}"
    STATUS_URL="file://${STATUS_FILE}"
fi

echo -e "${BLUE}💡 This will show real-time status of your AFL Fantasy Platform${NC}"
echo ""

# Open in default browser
if command -v open >/dev/null 2>&1; then
    # macOS
    echo -e "${BLUE}🍎 Opening in default browser (macOS)...${NC}"
    open "${STATUS_URL}"
elif command -v xdg-open >/dev/null 2>&1; then
    # Linux
    echo -e "${BLUE}🐧 Opening in default browser (Linux)...${NC}"
    xdg-open "${STATUS_URL}"
elif command -v start >/dev/null 2>&1; then
    # Windows
    echo -e "${BLUE}🪟 Opening in default browser (Windows)...${NC}"
    start "${STATUS_URL}"
else
    echo -e "${YELLOW}⚠️ Could not detect browser opener${NC}"
    echo -e "${YELLOW}💡 Please open this URL manually: ${STATUS_URL}${NC}"
fi

echo ""
echo -e "${GREEN}✅ Status dashboard should now be open in your browser${NC}"
echo -e "${BLUE}📊 The dashboard will show:${NC}"
echo -e "   • Web application status"
echo -e "   • API server health"  
echo -e "   • AI & analytics status"
echo -e "   • iOS app information"
echo -e "   • Real-time logs"
echo ""
echo -e "${YELLOW}💡 The dashboard auto-refreshes every 30 seconds${NC}"
