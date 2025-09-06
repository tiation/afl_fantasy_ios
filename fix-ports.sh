#!/bin/bash

# 🔧 AFL Fantasy Platform - Port Fix Script
echo "🔧 Fixing port conflicts for AFL Fantasy Platform..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Kill any processes on common ports
echo -e "${BLUE}🔍 Checking for processes on ports 3000, 4000, 5173...${NC}"

# Port 3000
PROCESS_3000=$(lsof -ti:3000 2>/dev/null | head -1)
if [ ! -z "$PROCESS_3000" ]; then
    echo -e "${YELLOW}⚠️ Killing process $PROCESS_3000 on port 3000${NC}"
    kill -9 $PROCESS_3000 2>/dev/null || true
fi

# Port 4000  
PROCESS_4000=$(lsof -ti:4000 2>/dev/null | head -1)
if [ ! -z "$PROCESS_4000" ]; then
    echo -e "${YELLOW}⚠️ Killing process $PROCESS_4000 on port 4000${NC}"
    kill -9 $PROCESS_4000 2>/dev/null || true
fi

# Port 5173
PROCESS_5173=$(lsof -ti:5173 2>/dev/null | head -1)
if [ ! -z "$PROCESS_5173" ]; then
    echo -e "${YELLOW}⚠️ Killing process $PROCESS_5173 on port 5173${NC}"
    kill -9 $PROCESS_5173 2>/dev/null || true
fi

# Wait a moment for processes to clean up
sleep 2

echo -e "${GREEN}✅ Ports cleared${NC}"
echo -e "${BLUE}🔍 Current port status:${NC}"

# Check port status
for port in 3000 4000 5173; do
    if lsof -ti:$port >/dev/null 2>&1; then
        echo -e "${RED}❌ Port $port: In use${NC}"
    else
        echo -e "${GREEN}✅ Port $port: Available${NC}"
    fi
done

echo ""
echo -e "${GREEN}🚀 Ready to start! Run ./start.sh to launch the platform${NC}"
