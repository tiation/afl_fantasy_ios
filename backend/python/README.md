# AFL Fantasy Backend Integration

This enhanced backend system provides comprehensive AFL Fantasy data and analysis for your iOS app.

## 🚀 Quick Start

### Start the API Server
```bash
# From this directory
./start_services.sh
```

Or manually:
```bash
# Activate virtual environment 
source ../../venv/bin/activate

# Start the API server
python api/trade_api.py
```

The API will be available at **http://127.0.0.1:9001**

### Test the API
```bash
curl http://127.0.0.1:9001/health
curl http://127.0.0.1:9001/api/players
curl http://127.0.0.1:9001/api/cash-cows
```

## 📋 Available Endpoints

### Core API Endpoints (for iOS App)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /health` | GET | Health check |
| `GET /api/players` | GET | All players summary |
| `GET /api/players/<id>` | GET | Individual player details |
| `GET /api/cash-cows` | GET | Cash cow analysis |
| `GET /api/captain-recommendations` | GET | Captain recommendations |
| `GET /api/ai-insights` | GET | AI insights for dashboard |
| `POST /api/price-projections` | POST | Price projections |
| `POST /api/trade_score` | POST | Trade analysis |

### AFL Fantasy Integration

| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /api/afl-fantasy/dashboard-data` | GET | Complete dashboard data |
| `POST /api/afl-fantasy/validate-credentials` | POST | Validate AFL Fantasy login |
| `POST /api/afl-fantasy/refresh` | POST | Force data refresh |

## 🔧 Player Data Scraper

### Your Original Scraper
Your original scraper code is now available as `run_scraper.py`:

```bash
python run_scraper.py
```

**Requirements:**
- Create `AFL_Fantasy_Player_URLs.xlsx` with columns:
  - `playerId`: Unique identifier 
  - `url`: AFL Fantasy player page URL
- Chrome/Chromium browser installed
- Required Python packages (installed automatically)

### Enhanced Scraper
The enhanced version (`scrapers/afl_player_scraper.py`) provides:
- Better error handling and logging
- API integration
- Data caching
- Structured output for iOS app consumption

## 📱 iOS App Integration

Your iOS app can now connect to these endpoints:

### Dashboard Data
```swift
// iOS Swift example
let url = URL(string: "http://127.0.0.1:9001/api/players")!
let (data, _) = try await URLSession.shared.data(from: url)
let players = try JSONDecoder().decode(PlayersResponse.self, from: data)
```

### Trade Analysis
```swift
let tradeRequest = TradeRequest(
    playerIn: PlayerData(price: 800000, breakeven: 95, projScores: [110, 105, 120, 115, 108], isRedDot: false),
    playerOut: PlayerData(price: 650000, breakeven: 105, projScores: [95, 98, 102, 89, 94], isRedDot: false),
    roundNumber: 13,
    teamValue: 15800000,
    leagueAvgValue: 15200000
)
```

## 🎯 Features

### Trade Analysis Engine
- Sophisticated scoring algorithm with 10+ factors
- Round-based weighting (early season = cash focus, late season = points focus)
- Player classification (rookie, mid-pricer, premium)
- Peak detection for cash cows
- Risk assessment and explanations

### Cash Cow Analysis
- Identifies rookie players with price growth potential
- Calculates projected cash generation
- Provides sell timing recommendations
- Confidence scoring

### Captain Recommendations  
- Analyzes matchups and form
- Considers ownership for differential plays
- Weather and venue factors
- Risk/reward assessment

### AI Insights
- Trade opportunity detection
- Injury risk monitoring
- Performance trend analysis
- Strategic recommendations

## 📊 Data Models

### Player Data Structure
```json
{
  "player_id": "string",
  "name": "string", 
  "position": "MID|DEF|FWD|RUCK",
  "team": "string",
  "price": 650000,
  "average_score": 105.2,
  "breakeven": 98,
  "last_score": 112,
  "ownership": 65.4,
  "is_cash_cow": false,
  "is_captain_candidate": true
}
```

### Trade Analysis Response
```json
{
  "status": "ok",
  "trade_score": 85.2,
  "scoring_score": 80.0,
  "cash_score": 12675.0,
  "verdict": "Perfect Timing",
  "recommendation": "Highly recommend this trade",
  "explanations": ["..."],
  "price_projections": {"..."},
  "flags": {"..."}
}
```

## 🔒 Security & Credentials

AFL Fantasy credentials are handled securely:
- Session cookies stored securely
- Credential validation endpoint
- No sensitive data in logs
- Rate limiting on scraping

## 🛠 Troubleshooting

### Common Issues

**API not starting:**
```bash
# Check if port is in use
lsof -i :9001

# Check logs
tail -f /tmp/flask_server.log
```

**Chrome driver issues:**
```bash
# Install Chrome driver
brew install chromedriver

# Or install via pip
pip install chromedriver-autoinstaller
```

**Missing packages:**
```bash
pip install flask flask-cors pandas selenium beautifulsoup4 numpy requests openpyxl
```

### Debug Mode
Start the API in debug mode:
```bash
python api/trade_api.py --debug
```

## 📈 Performance & Caching

- Response caching (5-minute default)
- Efficient data structures
- Background scraping
- Connection pooling
- Graceful error handling

## 🔄 Data Flow

1. **Player Scraper** → Extracts AFL Fantasy player data → Excel files + JSON cache
2. **Trade API** → Provides analysis endpoints → iOS App requests
3. **iOS App** → Consumes structured JSON → Beautiful UI displays

## 🎯 Next Steps

To fully integrate with your iOS app:

1. ✅ **Backend is running** - API server active on port 9001
2. ✅ **All iOS endpoints implemented** - Cash cows, captain analysis, AI insights  
3. ⏳ **Update iOS networking** - Point to `http://127.0.0.1:9001` instead of mock data
4. ⏳ **Add your Excel file** - Create `AFL_Fantasy_Player_URLs.xlsx` for real player data
5. ⏳ **Test integration** - Verify data flows correctly between backend and iOS

## 🆘 Support

If you encounter any issues:
1. Check the logs in `/tmp/flask_server.log`
2. Verify all endpoints are responding with `curl`
3. Ensure Chrome is installed for scraping
4. Check network connectivity between iOS simulator and localhost

---

🏈 **Your AFL Fantasy app now has a powerful backend!** The iOS app can display rich, real-time data instead of mock data.
