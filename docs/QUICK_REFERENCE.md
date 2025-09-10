# 🚀 AFL Fantasy - Quick Reference Guide

## 🔥 Quick Start

### 1. Start the Server
```bash
cd /Users/tiaastor/workspace/10_projects/afl_fantasy_ios
python api_server_unified.py
```
Server runs on:
- REST API: `http://localhost:8080`
- WebSocket: `ws://localhost:8081/ws/live`

### 2. Enable Live Updates
```bash
curl -X POST http://localhost:8080/api/live/toggle -H "Content-Type: application/json" -d '{"enabled": true}'
```

### 3. Run iOS App
- Open `AFLFantasyIntelligence.xcodeproj` in Xcode
- Build & Run (⌘R)
- App connects automatically to localhost

---

## 📡 API Quick Reference

### Get All Players
```bash
curl http://localhost:8080/api/players
```

### Get Player Details
```bash
curl http://localhost:8080/api/players/bontempelli_marcus
```

### Get Cash Cows
```bash
curl http://localhost:8080/api/stats/cash-cows
```

### Get Captain Suggestions
```bash
curl -X POST http://localhost:8080/api/captain/suggestions \
     -H "Content-Type: application/json" \
     -d '{"venue": "MCG", "opponent": "Carlton"}'
```

### Send Custom Alert
```bash
curl -X POST http://localhost:8080/api/live/alert \
     -H "Content-Type: application/json" \
     -d '{"type":"INJURY","title":"Breaking News","message":"Player injured","playerId":"daicos_nick"}'
```

---

## 🔌 WebSocket Testing

### Python Test Client
```python
import asyncio
import websockets
import json

async def test():
    async with websockets.connect("ws://localhost:8081/ws/live") as ws:
        # Subscribe
        await ws.send(json.dumps({"type": "subscribe"}))
        
        # Listen for messages
        while True:
            message = await ws.recv()
            print(json.loads(message))

asyncio.run(test())
```

### JavaScript Test Client
```javascript
const ws = new WebSocket('ws://localhost:8081/ws/live');

ws.onopen = () => {
    ws.send(JSON.stringify({type: 'subscribe'}));
};

ws.onmessage = (event) => {
    console.log(JSON.parse(event.data));
};
```

---

## 📱 iOS Integration Points

### Screen → API Mapping

| iOS Screen | Primary Endpoints | WebSocket Events |
|------------|------------------|------------------|
| **Dashboard** | `/api/stats/summary`<br>`/api/stats/cash-cows` | `live_stats`<br>`alert` |
| **Players** | `/api/players`<br>`/api/players/<id>` | - |
| **Player Detail** | `/api/players/<id>` | `alert` (PRICE_CHANGE) |
| **Team** | `/api/captain/suggestions`<br>`/api/players` | - |
| **Trades** | `/api/stats/cash-cows`<br>`/api/players` | `alert` (PRICE_CHANGE) |
| **Alerts** | - | `alert` (all types) |
| **Settings** | `/health`<br>`/api/refresh`<br>`/api/live/toggle` | - |

### Key iOS Files

```
AFLFantasyIntelligence/
├── Managers/
│   ├── APIManager.swift        # REST API calls
│   ├── WebSocketManager.swift  # WebSocket connection
│   └── DataManager.swift       # Central data store
├── Models/
│   ├── Player.swift            # Player data model
│   ├── LiveStats.swift         # Live score model
│   └── Alert.swift             # Alert model
├── Views/
│   ├── DashboardView.swift     # Main dashboard
│   ├── PlayersView.swift       # Player list
│   ├── PlayerDetailView.swift  # Player details
│   ├── TeamView.swift          # Team management
│   ├── TradesView.swift        # Trade suggestions
│   └── AlertsView.swift        # Notifications
└── ViewModels/
    ├── DashboardViewModel.swift
    ├── PlayersViewModel.swift
    └── TeamViewModel.swift
```

---

## 🎯 Data Models

### Player Object
```json
{
  "id": "player_id",
  "name": "Player Name",
  "team": "TEAM",
  "position": "MID|FWD|DEF|RUC",
  "price": 500000,
  "average": 85.5,
  "projected": 82.3,
  "breakeven": -10
}
```

### Live Stats
```json
{
  "currentScore": 1247,
  "rank": 12543,
  "playersPlaying": 18,
  "playersRemaining": 4,
  "averageScore": 1156.8
}
```

### Alert Types
- `PRICE_CHANGE` - Player price movements
- `INJURY` - Injury updates
- `LATE_OUT` - Team changes
- `ROLE_CHANGE` - Position changes
- `GENERAL` - Other notifications

---

## 🛠️ Common Tasks

### Refresh Player Data Cache
```bash
curl -X POST http://localhost:8080/api/refresh
```

### Check Server Health
```bash
curl http://localhost:8080/health
```

### Monitor WebSocket Clients
```bash
curl http://localhost:8080/health | jq '.websocketClients'
```

### View Server Logs
```bash
# If running in background
tail -f server.log

# If running in foreground
# Logs appear in terminal
```

### Kill Server
```bash
# Find process
lsof -i :8080

# Kill it
kill -9 <PID>
```

---

## 🐛 Debugging

### Server Not Starting
```bash
# Check if port is in use
lsof -i :8080
lsof -i :8081

# Kill existing processes
pkill -f api_server_unified.py
```

### WebSocket Not Connecting
```bash
# Test WebSocket directly
wscat -c ws://localhost:8081/ws/live
> {"type": "subscribe"}
```

### iOS App Can't Connect
1. Check server is running: `curl http://localhost:8080/health`
2. For device testing, use your Mac's IP instead of localhost
3. Update Settings → API Endpoint in app
4. Check firewall isn't blocking ports

### No Live Updates
```bash
# Ensure simulation is enabled
curl -X POST http://localhost:8080/api/live/toggle \
     -H "Content-Type: application/json" \
     -d '{"enabled": true}'
```

---

## 📊 Performance Tips

### Server Optimization
- Cache warms up after first request (~47s initial load)
- Subsequent requests use cache (<50ms response)
- Cache TTL: 1 hour

### iOS App Optimization
- Players list uses lazy loading
- Images cached in memory
- WebSocket reconnects automatically
- Background refresh every 60s

---

## 🔗 Links

- **Full Documentation**: [DOCUMENTATION.md](DOCUMENTATION.md)
- **API Server**: [api_server_unified.py](api_server_unified.py)
- **iOS Project**: [AFLFantasyIntelligence.xcodeproj](AFLFantasyIntelligence.xcodeproj)
- **Data Folder**: [dfs_player_summary/](dfs_player_summary/)

---

## 💡 Pro Tips

1. **Testing Alerts**: Use `/api/live/alert` to test different alert types
2. **Bulk Testing**: Load test with multiple WebSocket clients
3. **Data Updates**: Place new Excel files in `dfs_player_summary/` and refresh cache
4. **Network Debugging**: Use Charles Proxy to inspect API calls
5. **Live Simulation**: Updates every 30 seconds when enabled

---

*Quick Reference v1.0 - September 2025*
