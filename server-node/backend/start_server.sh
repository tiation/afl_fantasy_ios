#!/bin/bash

# AFL Fantasy Trade API Server Startup Script
# This script starts the Flask server following your Warp workflow pattern

set -e

echo "🚀 Starting AFL Fantasy Trade API Server..."

# Navigate to the correct directory
cd "/Users/tiaastor/workspace/10_projects/afl_fantasy_ios/backend/python"

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source ../../venv/bin/activate

# Check if server is already running on port 9001
if lsof -Pi :9001 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Server already running on port 9001. Stopping existing process..."
    lsof -ti:9001 | xargs kill -9
    sleep 2
fi

# Start the server in background with logging
echo "🌟 Starting server on http://127.0.0.1:9001..."
nohup python api/trade_api.py > /tmp/afl_fantasy_server.log 2>&1 &

# Get the process ID
SERVER_PID=$!
echo "✅ Server started with PID: $SERVER_PID"

# Wait a moment for server to initialize
sleep 3

# Test if server is responding
echo "🔍 Testing server health..."
if curl -s --max-time 5 http://127.0.0.1:9001/health >/dev/null; then
    echo "✅ Server is healthy and responding!"
    echo "🌐 Server URL: http://127.0.0.1:9001"
    echo "📝 Logs: tail -f /tmp/afl_fantasy_server.log"
    echo ""
    echo "Available endpoints:"
    echo "  GET  /health - Health check"
    echo "  POST /api/trade_score - Trade analysis"
    echo "  GET  /api/afl-fantasy/dashboard-data - Complete dashboard data"
    echo "  GET  /api/afl-fantasy/team-value - Team value data"
    echo "  GET  /api/afl-fantasy/team-score - Team score data"
    echo "  GET  /api/afl-fantasy/rank - Overall rank data"
    echo "  GET  /api/afl-fantasy/captain - Captain data"
    echo "  POST /api/afl-fantasy/refresh - Force refresh data"
else
    echo "❌ Server failed to start or is not responding"
    echo "📝 Check logs: tail -f /tmp/afl_fantasy_server.log"
    exit 1
fi
