# AFL Fantasy iOS Backend - Actual API Endpoints

## ✅ Verified Multi-Platform Architecture Review

Based on the actual code in the repository, this project supports **BOTH** web and iOS applications with a unified backend. Here's the complete architecture:

### 🌐 **Web Application** (React + Express)
- **Frontend**: React app with TypeScript (`/client/src/`)
- **Backend**: Express.js server (`/server/`)
- **Port**: 5000 (default) - serves both API and web app

### 📱 **iOS Application** 
- **App Code**: Swift/SwiftUI (`/ios/`)
- **Backend APIs**: Same Express server + specialized Python services
- **Integration**: RESTful API consumption

### 🔄 **Unified Backend Services**
The backend serves both platforms simultaneously:

## Node.js Express API (Primary Service)

**Port**: Default 5000 (configured via `PORT` env var in index.ts) ⚠️ Note: The code shows port fallback to 5000, but environment typically uses 3000

### Core API Endpoints
- **GET** `/api/health` - Health check with metrics (from middleware)
- **GET** `/metrics` - Prometheus-style metrics endpoint

### Player Data Endpoints  
- **GET** `/api/scraped-players` - Player data from JSON scrapers
  - Query parameters: `?q={search_term}&position={position}`
  - Sources: `player_data_backup_20250501_201717.json` or `player_data.json`

### Dashboard Endpoints
- **GET** `/api/afl-fantasy/dashboard-data` - AFL Fantasy dashboard data
  - Executes Python scraper: `afl_fantasy_authenticated_scraper.py`
  - Returns team value, team score, overall rank, captain data

### Trade Analysis Endpoints
- **POST** `/api/trade_score` - Trade score calculation
  - Proxies to Python API (`http://localhost:5001/api/trade_score`)
  - Falls back to Node.js implementation if Python unavailable
  - Request body: `player_in`, `player_out`, `round_number`, `team_value`, `league_avg_value`

### Fantasy Tools API Routes
Multiple API route groups registered:
- **Router** `/api/role-tools` - Role analysis tools
- **Router** `/api/captains` - Captain selection tools  
- **Router** `/api/price-tools` - Price analysis tools
- **Router** `/api/fixture` - Fixture analysis tools
- **Router** `/api/context` - Context analysis tools
- **Router** `/api/team` - Team management tools
- **Router** `/api/stats` - FootyWire and DFS Australia data
- **Router** `/api/afl-data` - Real AFL Fantasy player data
- **Router** `/api/integration` - Authenticated AFL Fantasy access
- **Router** `/api/champion-data` - Champion Data AFL Sports API
- **Router** `/api/stats-tools` - Stats and analysis tools
- **Router** `/api/algorithms` - Price predictor and projected score algorithms
- **Router** `/api/score-projection` - Score projection algorithms (v3.4.4)

## Python Flask API (Specialized Service)

**Port**: 5000 (hardcoded in `if __name__ == '__main__'`)

### Core Endpoints
- **GET** `/health` - Health check endpoint
  - Returns: `{"status": "healthy", "service": "AFL Fantasy Trade API"}`

### Trade Analysis Endpoints  
- **POST** `/api/trade_score` - Advanced trade scoring algorithm
  - Request body: `player_in`, `player_out`, `round_number`, `team_value`, `league_avg_value`
  - Returns comprehensive trade analysis with scoring breakdown

## File Structure Summary

```
ios/Backend/
├── Node/                          # Express API (Port 5000/3000)
│   ├── index.ts                  # Main server entry point
│   ├── routes.ts                 # Route registration & proxy endpoints
│   ├── package.json              # ✅ Now created
│   ├── tsconfig.json            # ✅ Now created  
│   ├── routes/                   # Individual API route modules
│   ├── services/                # Business logic services
│   ├── middleware/              # Express middleware (metrics)
│   ├── utils/                   # Utility functions
│   ├── types/                   # TypeScript definitions
│   └── fantasy-tools/           # Fantasy analysis tools
│
├── Python/                       # Flask API (Port 5000)
│   ├── api/
│   │   └── trade_api.py         # Main Flask application
│   ├── requirements.txt         # ✅ Now created
│   ├── scrapers/                # Data scraping services
│   └── scripts/                 # Utility scripts
│
├── Shared/                       # Configuration
│   ├── .env                     # Environment variables 
│   ├── .env.example            # Environment template
│   ├── package.json            # Shared dependencies
│   └── tsconfig.json           # Shared TypeScript config
│
└── Documentation/                # ✅ Complete documentation
    ├── README.md               # Main documentation
    ├── DEPLOYMENT.md          # Deployment guide  
    ├── IOS_INTEGRATION.md     # iOS integration guide
    ├── ACTUAL_ENDPOINTS.md    # This file - endpoint reference
    └── API/
        ├── Python_API.md      # Python API docs
        └── Node_API.md        # Node.js API docs
```

## Development Scripts

**✅ Created and available:**
- `setup_development.sh` - Full environment setup
- `run_python_dev.sh` - Python API only
- `run_node_dev.sh` - Node.js API only  
- `run_dev_servers.sh` - Both APIs together
- `stop_dev_servers.sh` - Stop all services
- `health_check.sh` - Health monitoring

## Port Configuration Notes

⚠️ **Important Port Information:**
- **Node.js server**: Defaults to port `5000` (with fallback logic in index.ts: `const port = process.env.PORT ? parseInt(process.env.PORT) : 5000`)
- **Python Flask**: Hardcoded to port `5000` in development mode  
- **Trade score proxy**: Node.js proxies to Python at `http://localhost:5001` (but Python runs on 5000)

**Recommendation**: 
- Set `PORT=3000` in `.env` for Node.js to avoid port conflict with Python
- Python keeps port 5000
- Update proxy URL in routes.ts from 5001 to 5000

## Key Implementation Details

1. **Trade Score Logic**: Comprehensive algorithm in Python with Node.js fallback
2. **Player Data**: JSON-file based with backup data files
3. **Dashboard Data**: Real-time scraping via Python subprocess
4. **Fantasy Tools**: Extensive microservice-style route organization
5. **Environment**: Flexible development/staging/production configuration

## Integration Recommendations for iOS

1. **Primary API**: Use Node.js API as main entry point (port 3000/5000)
2. **Player Data**: Use `/api/scraped-players` with search/filter capabilities
3. **Dashboard**: Use `/api/afl-fantasy/dashboard-data` for team overview
4. **Trade Analysis**: Use `/api/trade_score` (automatically handles Python fallback)
5. **Health Monitoring**: Use `/api/health` and `/metrics` endpoints

## Documentation Status

✅ **Complete Documentation Package:**
- Full API integration guide with Swift code examples
- Comprehensive deployment instructions (development → production)
- Complete file structure documentation matching actual code
- Development environment setup automation
- Production deployment options (Docker, cloud platforms)
- Security, testing, and monitoring guidance

---

*This document reflects the actual codebase as of December 6, 2024*
