#!/usr/bin/env bash

# Test script to verify AFL Fantasy app is working

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing AFL Fantasy Application${NC}"
echo "=================================="

# Kill any existing processes on port 5173
if lsof -ti:5173 &>/dev/null; then
    echo "Killing existing process on port 5173..."
    lsof -ti:5173 | xargs kill -9 2>/dev/null || true
    sleep 2
fi

echo "Starting application..."
npm run dev &
APP_PID=$!

echo "Application PID: $APP_PID"

# Wait for application to start
echo "Waiting for application to start..."
sleep 5

# Test if the application is responsive
echo "Testing endpoints..."

# Test main page
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200"; then
    echo -e "${GREEN}✅ Main page (/) - Working${NC}"
else
    echo -e "${RED}❌ Main page (/) - Failed${NC}"
fi

# Test health endpoint
if curl -s http://localhost:5173/api/health | grep -q "healthy"; then
    echo -e "${GREEN}✅ Health endpoint (/api/health) - Working${NC}"
    echo "Health response:"
    curl -s http://localhost:5173/api/health | jq '.' 2>/dev/null || curl -s http://localhost:5173/api/health
else
    echo -e "${RED}❌ Health endpoint (/api/health) - Failed${NC}"
fi

# Test fantasy tools endpoint
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/api/fantasy-tools | grep -q "200"; then
    echo -e "${GREEN}✅ Fantasy tools endpoint (/api/fantasy-tools) - Working${NC}"
else
    echo -e "${RED}❌ Fantasy tools endpoint (/api/fantasy-tools) - Failed${NC}"
fi

echo ""
echo -e "${BLUE}🌐 Application URLs:${NC}"
echo "  Main app:     http://localhost:5173"
echo "  Health check: http://localhost:5173/api/health"
echo "  API docs:     http://localhost:5173/api/fantasy-tools"
echo "  Dashboard:    http://localhost:5173/dashboard"

echo ""
echo -e "${BLUE}Press Ctrl+C to stop the application${NC}"

# Wait for Ctrl+C
wait $APP_PID
