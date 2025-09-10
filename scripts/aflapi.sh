#!/usr/bin/env bash
# Start AFL Fantasy Unified API + WebSocket server
# Usage: aflapi [--port 8080] [--ws-port 8081] [--data ./dfs_player_summary] [--no-live]

set -euo pipefail

PORT=8080
WS_PORT=8081
DATA_DIR="./dfs_player_summary"
ENABLE_LIVE=true
LOG_FILE="server_unified.log"
PY=${PYTHON:-python}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --port)
      PORT="$2"; shift 2 ;;
    --ws-port)
      WS_PORT="$2"; shift 2 ;;
    --data)
      DATA_DIR="$2"; shift 2 ;;
    --no-live)
      ENABLE_LIVE=false; shift ;;
    --log)
      LOG_FILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: aflapi [--port 8080] [--ws-port 8081] [--data ./dfs_player_summary] [--no-live] [--log server_unified.log]";
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

cd /Users/tiaastor/workspace/10_projects/afl_fantasy_ios

# Check data directory exists
if [[ ! -d "$DATA_DIR" ]]; then
  echo "❌ Data directory not found: $DATA_DIR"
  exit 1
fi

# Kill existing servers on ports if any
lsof -ti tcp:$PORT | xargs kill -9 2>/dev/null || true
lsof -ti tcp:$WS_PORT | xargs kill -9 2>/dev/null || true

# Export environment variables
export PORT="$PORT"
export WS_PORT="$WS_PORT"
export DATA_FOLDER="$DATA_DIR"

# Start server
echo "🚀 Starting AFL API (Port: $PORT) + WebSocket (Port: $WS_PORT)..."
nohup $PY api_server_unified.py > "$LOG_FILE" 2>&1 &
PID=$!

# Wait a bit
sleep 5

# Enable live simulation if requested
if [[ "$ENABLE_LIVE" == "true" ]]; then
  curl -s -X POST http://localhost:$PORT/api/live/toggle \
    -H "Content-Type: application/json" -d '{"enabled": true}' >/dev/null || true
  LIVE_STATUS="ON"
else
  LIVE_STATUS="OFF"
fi

# Print status
echo "✅ Server PID: $PID"
echo "🌐 API: http://localhost:$PORT"
echo "🔌 WS:  ws://localhost:$WS_PORT/ws/live"
echo "🔄 Live Simulation: $LIVE_STATUS"
echo "📝 Logs: tail -f $LOG_FILE"

# Show health summary
echo ""
echo "📋 Health:"
curl -s http://localhost:$PORT/health | python -m json.tool | head -20 || true

