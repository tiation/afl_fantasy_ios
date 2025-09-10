#!/bin/bash
# AFL Fantasy WebSocket Server Starter
# Updated for reorganized project structure

cd "$(dirname "$0")"
echo "🏈 Starting AFL Fantasy WebSocket Server..."
echo "📁 Project root: $(pwd)"
echo "🔌 WebSocket server location: server-python/"
echo ""

cd server-python
echo "📂 Changed to server-python directory"
echo "🚀 Starting WebSocket server..."

# Check if virtual environment exists
if [ -d "../venv" ]; then
    echo "🔧 Activating virtual environment..."
    source ../venv/bin/activate
fi

# Install websockets if not present
if ! python -c "import websockets" 2>/dev/null; then
    echo "📦 Installing websockets module..."
    pip install websockets
fi

# Check if port 8081 is available
if lsof -Pi :8081 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "❌ Port 8081 is already in use!"
    echo "Kill the existing process or use a different port."
    exit 1
fi

# Set port for WebSocket server 
export PORT=8081

echo "▶️ Running WebSocket server on port 8081..."
echo "📡 WebSocket endpoint: ws://localhost:8081/ws/live"
echo ""

# Start the WebSocket-focused server if it exists, otherwise main server
if [ -f "api_server_ws.py" ]; then
    echo "Using dedicated WebSocket server (api_server_ws.py)"
    python api_server_ws.py
else
    echo "Using main API server with WebSocket support (api_server.py)"
    python api_server.py
fi
