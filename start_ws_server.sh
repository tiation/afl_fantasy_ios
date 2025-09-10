#!/bin/bash

# AFL Fantasy WebSocket Server Startup Script

echo "========================================"
echo "🏈 AFL Fantasy WebSocket Server Launcher"
echo "========================================"

# Check if port 8081 is available
if lsof -Pi :8081 -sTCP:LISTEN -t >/dev/null ; then
    echo "❌ Port 8081 is already in use!"
    echo "Kill the existing process or use a different port."
    exit 1
fi

# Set port for WebSocket server (different from regular API server)
export PORT=8081

echo "📦 Installing required dependencies..."
pip install flask flask-cors flask-socketio pandas openpyxl python-socketio --quiet

echo "🚀 Starting WebSocket server on port 8081..."
echo ""

# Start the WebSocket server
python api_server_ws.py &
SERVER_PID=$!

echo "Server PID: $SERVER_PID"
echo ""

# Wait for server to start
sleep 5

# Enable live simulation via API call
echo "🔄 Enabling live simulation..."
curl -X POST http://localhost:8081/api/live/toggle \
     -H "Content-Type: application/json" \
     -d '{"enabled": true}' \
     2>/dev/null | python -m json.tool

echo ""
echo "========================================"
echo "✅ WebSocket server is running!"
echo "   HTTP API: http://localhost:8081"
echo "   WebSocket: ws://localhost:8081/socket.io/"
echo ""
echo "Test WebSocket connection with:"
echo "   python test_websocket.py"
echo ""
echo "Stop server with:"
echo "   kill $SERVER_PID"
echo "========================================"

# Keep script running
wait $SERVER_PID
