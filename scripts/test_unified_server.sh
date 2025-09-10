#!/bin/bash

# Test script for unified AFL Fantasy API Server with WebSocket support

echo "========================================"
echo "🧪 AFL Fantasy Unified Server Test"
echo "========================================"

# Check if server is already running
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Port 8080 is in use - assuming server is already running"
    SERVER_ALREADY_RUNNING=true
else
    echo "📦 Installing dependencies..."
    pip install flask flask-cors pandas openpyxl websockets --quiet
    
    echo "🚀 Starting unified server..."
    python api_server_unified.py &
    SERVER_PID=$!
    echo "Server PID: $SERVER_PID"
    
    # Wait for server to start
    echo "⏳ Waiting for server to start..."
    sleep 5
fi

echo ""
echo "========================================"
echo "🔍 Testing API Endpoints"
echo "========================================"

# Test health endpoint
echo "1️⃣ Testing /health endpoint..."
curl -s http://localhost:8080/health | python -m json.tool | head -10

# Test stats summary
echo ""
echo "2️⃣ Testing /api/stats/summary..."
curl -s http://localhost:8080/api/stats/summary | python -m json.tool

# Enable live simulation
echo ""
echo "3️⃣ Enabling live simulation..."
curl -X POST http://localhost:8080/api/live/toggle \
     -H "Content-Type: application/json" \
     -d '{"enabled": true}' \
     2>/dev/null | python -m json.tool

# Send a test alert
echo ""
echo "4️⃣ Sending test alert..."
curl -X POST http://localhost:8080/api/live/alert \
     -H "Content-Type: application/json" \
     -d '{"type":"INJURY","title":"Test Injury Alert","message":"Clayton Oliver injured in warm-up","playerId":"oliver_clayton"}' \
     2>/dev/null | python -m json.tool

echo ""
echo "========================================"
echo "🔌 Testing WebSocket Connection"
echo "========================================"

# Create a simple Python WebSocket client test
cat > /tmp/test_ws_client.py << 'EOF'
import asyncio
import websockets
import json
import sys

async def test_websocket():
    uri = "ws://localhost:8081/ws/live"
    try:
        async with websockets.connect(uri) as websocket:
            print(f"✅ Connected to {uri}")
            
            # Send subscribe message
            await websocket.send(json.dumps({"type": "subscribe"}))
            print("📤 Sent subscribe message")
            
            # Listen for messages
            print("📥 Listening for messages (10 seconds)...")
            timeout = 10
            start_time = asyncio.get_event_loop().time()
            
            while asyncio.get_event_loop().time() - start_time < timeout:
                try:
                    message = await asyncio.wait_for(websocket.recv(), timeout=1.0)
                    data = json.loads(message)
                    print(f"📨 Received: {data.get('type', 'unknown')}")
                    if data.get('type') == 'live_stats':
                        stats = data.get('liveStats', {})
                        print(f"   Score: {stats.get('currentScore')} | Rank: {stats.get('rank')}")
                    elif data.get('type') == 'alert':
                        alert = data.get('alert', {})
                        print(f"   Alert: {alert.get('title')} - {alert.get('message')}")
                except asyncio.TimeoutError:
                    continue
                    
            print("✅ WebSocket test completed successfully")
            
    except Exception as e:
        print(f"❌ WebSocket error: {e}")
        sys.exit(1)

asyncio.run(test_websocket())
EOF

echo "Testing WebSocket at ws://localhost:8081/ws/live..."
python /tmp/test_ws_client.py

echo ""
echo "========================================"
echo "✅ All tests completed!"
echo "========================================"
echo ""
echo "Server endpoints:"
echo "  API: http://localhost:8080"
echo "  WebSocket: ws://localhost:8081/ws/live"
echo ""

if [ -z "$SERVER_ALREADY_RUNNING" ]; then
    echo "Stop server with: kill $SERVER_PID"
    echo ""
    echo "Press Ctrl+C to stop the server..."
    wait $SERVER_PID
fi
