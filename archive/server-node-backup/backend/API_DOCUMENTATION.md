# AFL Fantasy Trade API Documentation

## Server Information
- **Base URL**: `http://127.0.0.1:9001`
- **Port**: `9001`
- **Protocol**: `HTTP`
- **CORS**: Enabled for all origins

## Quick Start

### Starting the Server
```bash
# Option 1: Using the startup script (Recommended)
/Users/tiaastor/workspace/10_projects/afl_fantasy_ios/backend/start_server.sh

# Option 2: Manual start
cd /Users/tiaastor/workspace/10_projects/afl_fantasy_ios/backend/python
source ../../venv/bin/activate
python api/trade_api.py
```

### Testing the Server
```bash
curl http://127.0.0.1:9001/health
```

## API Endpoints

### 1. Health Check
**GET** `/health`

Check if the server is running and healthy.

**Response:**
```json
{
  "status": "healthy",
  "service": "AFL Fantasy Trade API"
}
```

---

### 2. Trade Score Calculation
**POST** `/api/trade_score`

Evaluate a fantasy trade decision with detailed analysis.

**Request Body:**
```json
{
  "player_in": {
    "price": 1100000,
    "breakeven": 114,
    "proj_scores": [125, 122, 118, 130, 120],
    "is_red_dot": false
  },
  "player_out": {
    "price": 930000,
    "breakeven": 120,
    "proj_scores": [105, 110, 102, 108, 104],
    "is_red_dot": false
  },
  "round_number": 13,
  "team_value": 15800000,
  "league_avg_value": 15200000
}
```

**Response:**
```json
{
  "status": "ok",
  "trade_score": 85.2,
  "scoring_score": 25.0,
  "cash_score": 12500,
  "overall_score": 7.2,
  "score_breakdown": {
    "projected_score": 22.5,
    "value": 18.7,
    "breakeven": 12.1,
    "risk": 5.0,
    "scoring_weight": 70.0,
    "cash_weight": 30.0
  },
  "price_projections": {
    "player_in": [1073, 1342, 975, 1658, 1170],
    "player_out": [-975, -487, -1462, -585, -975],
    "net_gain": 12500
  },
  "projected_prices": {
    "player_in": [1101073, 1102415, 1103390, 1105048, 1106218],
    "player_out": [929025, 928538, 927076, 926491, 925516]
  },
  "flags": {
    "peaked_rookie": false,
    "upgrade_path": "upgrade",
    "season_match": true,
    "trading_peaked_player": false,
    "getting_peaked_player": false,
    "player_in_class": "premium",
    "player_out_class": "premium"
  },
  "verdict": "Solid Structure Trade",
  "explanations": [
    "Player coming in projected to score 4.0 points more per game",
    "Projected to gain $125.0k in value over 5 rounds",
    "Trading for a player with 6 lower breakeven",
    "This trade costs $170.0k immediately",
    "Round 13: Cash gain is weighted more heavily than scoring"
  ],
  "recommendation": "Highly recommend this trade"
}
```

**Parameters:**
- `player_in`: Player being traded in
- `player_out`: Player being traded out
- `round_number`: Current AFL round (1-24)
- `team_value`: Your current team value in dollars
- `league_avg_value`: League average team value in dollars

**Player Object:**
- `price`: Player's current price in dollars
- `breakeven`: Player's breakeven score
- `proj_scores`: Array of 5 projected scores for upcoming rounds
- `is_red_dot`: Boolean indicating injury/suspension status

---

### 3. AFL Fantasy Dashboard Data
**GET** `/api/afl-fantasy/dashboard-data`

Get complete dashboard data including team value, score, rank, and captain info.

**Response:**
```json
{
  "team_value": {
    "total": 12800000,
    "player_count": 22,
    "remaining_salary": 200000,
    "formatted": "$12.8M"
  },
  "team_score": {
    "total": 2156,
    "captain_score": 142,
    "change_from_last_round": 85
  },
  "overall_rank": {
    "current": 15247,
    "formatted": "15,247",
    "change_from_last_round": -1205
  },
  "captain": {
    "score": 142,
    "ownership_percentage": 23.4,
    "player_name": "Marcus Bontempelli"
  },
  "last_updated": "2025-01-06T12:30:00"
}
```

---

### 4. Team Value Data
**GET** `/api/afl-fantasy/team-value`

Get team value and salary cap information.

**Response:**
```json
{
  "total_value": 12800000,
  "remaining_salary": 200000,
  "formatted_value": "$12.8M",
  "formatted_remaining": "200K",
  "player_count": 22
}
```

---

### 5. Team Score Data
**GET** `/api/afl-fantasy/team-score`

Get team scoring information.

**Response:**
```json
{
  "total_score": 2156,
  "captain_score": 142,
  "score_change": 85
}
```

---

### 6. Overall Rank Data
**GET** `/api/afl-fantasy/rank`

Get overall ranking information.

**Response:**
```json
{
  "overall_rank": 15247,
  "formatted_rank": "15,247",
  "rank_change": -1205
}
```

---

### 7. Captain Data
**GET** `/api/afl-fantasy/captain`

Get captain selection and performance data.

**Response:**
```json
{
  "captain_score": 142,
  "captain_name": "Marcus Bontempelli",
  "ownership_percentage": 23.4,
  "formatted_ownership": "23.4% of teams"
}
```

---

### 8. Force Data Refresh
**POST** `/api/afl-fantasy/refresh`

Force refresh of AFL Fantasy data by running scrapers.

**Response:**
```json
{
  "message": "AFL Fantasy data refreshed successfully",
  "data": { /* refreshed data */ },
  "timestamp": "2025-01-06T12:35:00"
}
```

**Error Response:**
```json
{
  "error": "Failed to refresh AFL Fantasy data"
}
```

---

## Error Responses

### Common Error Format
```json
{
  "error": "Error message",
  "message": "Detailed error description"
}
```

### HTTP Status Codes
- `200`: Success
- `400`: Bad Request (validation errors)
- `500`: Internal Server Error

### AFL Fantasy Endpoint Errors
When scraper data is unavailable:
```json
{
  "error": "No AFL Fantasy data available"
}
```

---

## Environment Variables

Create a `.env` file in the project root with:

```env
# AFL Fantasy API Configuration
AFL_FANTASY_TEAM_ID=your_team_id_here
AFL_FANTASY_SESSION_COOKIE=your_session_cookie_here
AFL_FANTASY_API_TOKEN=your_api_token_here

# Server Configuration
FLASK_ENV=development
FLASK_DEBUG=false
FLASK_HOST=127.0.0.1
FLASK_PORT=9001

# Cache Configuration
CACHE_DURATION=300

# Scraper Configuration
SCRAPER_TIMEOUT=120
SCRAPER_USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
```

---

## Logging

Server logs are written to `/tmp/afl_fantasy_server.log`

View logs in real-time:
```bash
tail -f /tmp/afl_fantasy_server.log
```

---

## Dependencies

- Python 3.13+
- Flask 3.1.0
- Flask-CORS 5.0.0
- NumPy 1.26+
- Requests 2.31.0
- BeautifulSoup4 4.12.3
- Selenium 4.25.0

---

## Project Structure

```
backend/
├── python/
│   ├── api/
│   │   └── trade_api.py          # Main Flask server
│   ├── scrapers/
│   │   ├── afl_fantasy_authenticated_scraper.py
│   │   ├── afl_fantasy_data_service.py
│   │   └── ...                   # Other scrapers
│   ├── tools/                    # Analysis tools
│   └── scripts/                  # Utility scripts
├── fantasy-tools/                # TypeScript utilities
├── services/                     # Processing services
├── utils/                        # Shared utilities
├── start_server.sh              # Server startup script
└── setup_env.sh                 # Environment setup script
```

---

## Usage Examples

### JavaScript/Fetch
```javascript
// Health check
const health = await fetch('http://127.0.0.1:9001/health');
const healthData = await health.json();

// Trade analysis
const tradeData = {
  player_in: { price: 1100000, breakeven: 114, proj_scores: [125, 122, 118, 130, 120], is_red_dot: false },
  player_out: { price: 930000, breakeven: 120, proj_scores: [105, 110, 102, 108, 104], is_red_dot: false },
  round_number: 13,
  team_value: 15800000,
  league_avg_value: 15200000
};

const tradeResponse = await fetch('http://127.0.0.1:9001/api/trade_score', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(tradeData)
});
const tradeResult = await tradeResponse.json();
```

### Python/Requests
```python
import requests

# Health check
response = requests.get('http://127.0.0.1:9001/health')
print(response.json())

# Trade analysis
trade_data = {
    "player_in": {"price": 1100000, "breakeven": 114, "proj_scores": [125, 122, 118, 130, 120], "is_red_dot": False},
    "player_out": {"price": 930000, "breakeven": 120, "proj_scores": [105, 110, 102, 108, 104], "is_red_dot": False},
    "round_number": 13,
    "team_value": 15800000,
    "league_avg_value": 15200000
}

response = requests.post('http://127.0.0.1:9001/api/trade_score', json=trade_data)
print(response.json())
```

### cURL Examples
```bash
# Health check
curl http://127.0.0.1:9001/health

# Trade score
curl -X POST http://127.0.0.1:9001/api/trade_score \
  -H "Content-Type: application/json" \
  -d '{
    "player_in": {"price": 1100000, "breakeven": 114, "proj_scores": [125, 122, 118, 130, 120], "is_red_dot": false},
    "player_out": {"price": 930000, "breakeven": 120, "proj_scores": [105, 110, 102, 108, 104], "is_red_dot": false},
    "round_number": 13,
    "team_value": 15800000,
    "league_avg_value": 15200000
  }'

# Dashboard data
curl http://127.0.0.1:9001/api/afl-fantasy/dashboard-data

# Refresh data
curl -X POST http://127.0.0.1:9001/api/afl-fantasy/refresh
```
