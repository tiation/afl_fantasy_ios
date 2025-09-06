#!/bin/bash

# 📊 AFL Fantasy Platform - Quick Status Check
echo "📊 AFL Fantasy Platform Status Check"
echo "==================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌐 Web Application Status:${NC}"
if curl -s http://localhost:5173 > /dev/null; then
    echo -e "   ${GREEN}✅ Web App: Online at http://localhost:5173${NC}"
else
    echo -e "   ${RED}❌ Web App: Offline${NC}"
fi

echo ""
echo -e "${BLUE}🔌 API Server Status:${NC}"
if curl -s http://localhost:5173/api/health > /dev/null; then
    echo -e "   ${GREEN}✅ API Server: Online at http://localhost:5173/api${NC}"
    
    # Get health details
    health_data=$(curl -s http://localhost:5173/api/health)
    echo -e "   ${BLUE}📊 Health Details:${NC}"
    echo "$health_data" | jq -r '. | "      Status: \(.status)\n      Uptime: \(.uptime)s\n      Environment: \(.environment)"' 2>/dev/null || echo "      $health_data"
else
    echo -e "   ${RED}❌ API Server: Offline${NC}"
fi

echo ""
echo -e "${BLUE}🔗 Quick Links:${NC}"
echo -e "   Web Dashboard: ${BLUE}http://localhost:5173${NC}"
echo -e "   API Health:    ${BLUE}http://localhost:5173/api/health${NC}"
if curl -s http://localhost:5173/api/health > /dev/null 2>&1; then
    # Start dashboard server if needed
    if ! curl -s http://localhost:8080/status.html > /dev/null 2>&1; then
        python3 -m http.server 8080 --bind 127.0.0.1 >/dev/null 2>&1 &
        sleep 1
    fi
    echo -e "   Status Dashboard: ${BLUE}http://localhost:8080/status.html${NC} (Live)"
else
    echo -e "   Status Dashboard: ${BLUE}file://$(pwd)/status.html${NC} (Local)"
fi

echo ""
echo -e "${BLUE}💡 Troubleshooting:${NC}"
echo "   - If services are offline, run: ./start.sh"
echo "   - If ports are blocked, run: ./fix-ports.sh"
echo "   - For logs, check the Status Dashboard above"
