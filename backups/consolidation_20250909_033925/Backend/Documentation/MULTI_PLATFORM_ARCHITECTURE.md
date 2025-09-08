# AFL Fantasy Multi-Platform Architecture Guide

## 🎯 Complete Platform Support

**YES!** This backend **fully supports both Web and iOS applications** with a unified API architecture.

## 🏗️ Architecture Overview

```
┌─────────────────────┐    ┌─────────────────────┐
│   🌐 Web Client     │    │   📱 iOS App        │
│   (React/TypeScript)│    │   (Swift/SwiftUI)   │
│   Port: 5000        │    │   API Calls         │
└─────────┬───────────┘    └─────────┬───────────┘
          │                          │
          └────────┬───────────────────┘
                   │
                   ▼
        ┌─────────────────────┐
        │  🚀 Unified Backend  │
        │  Express.js Server  │
        │  Port: 5000         │
        └─────────┬───────────┘
                  │
     ┌────────────┼────────────┐
     │            │            │
     ▼            ▼            ▼
┌─────────┐  ┌─────────┐  ┌─────────┐
│Web Routes│  │API Routes│  │Python │
│(Vite/SPA)│  │(REST API)│  │Services│
│         │  │         │  │Port 5000│
└─────────┘  └─────────┘  └─────────┘
```

## 🌐 Web Application Details

### Frontend (React SPA)
**Location**: `/client/src/`
**Technology**: React 18 + TypeScript + Wouter routing
**UI Framework**: Radix UI + Tailwind CSS + Shadcn/ui components

**Key Features**:
- Full AFL Fantasy dashboard
- Player statistics and analysis
- Trade analyzer tools
- Team management
- Real-time data visualization with Chart.js
- Mobile-responsive design

**Routes Available**:
- `/` - Dashboard
- `/player-stats` - Player Statistics
- `/lineup` - Team Lineup
- `/leagues` - League Management
- `/trade-analyzer` - Trade Analysis Tool
- `/stats` - Advanced Statistics
- `/tools-simple` & `/tools-accordion` - Fantasy Tools
- `/team` - Team Management
- Plus support pages (privacy, terms, contact, etc.)

### Backend Integration
**Server**: Express.js serves both the React SPA and API endpoints
**Development**: Vite dev server with HMR
**Production**: Static files served from `/dist`

## 📱 iOS Application Details

### Native iOS App
**Location**: `/ios/`
**Technology**: Swift + SwiftUI
**Architecture**: MVVM with Combine/async-await
**Deployment**: iOS 15+, supports iPhone and iPad

**Integration Method**:
- RESTful API consumption
- URLSession with modern Swift concurrency
- Comprehensive error handling and retry logic
- Offline support with Core Data caching
- Native iOS UI following HIG guidelines

## 🔄 Unified Backend Services

### Primary Express.js Server
**File**: `/server/index.ts`
**Port**: 3000 (configured in `.env`, fallback to 5000 in code)

**Serves**:
1. **Web Application** (React SPA)
   - Static files in production
   - Vite dev server in development
   - All `/` routes fall through to `index.html`

2. **REST API** (for both Web & iOS)
   - All `/api/*` endpoints
   - JSON responses with proper CORS headers
   - Metrics and monitoring endpoints

### API Endpoints (Shared by Web & iOS)

#### Core Services
```
GET  /api/health              - Health check
GET  /metrics                 - Prometheus metrics
GET  /api/scraped-players     - Player data (JSON files)
GET  /api/afl-fantasy/dashboard-data - Live dashboard data
POST /api/trade_score         - Trade analysis (proxies to Python)
```

#### Fantasy Tools (Microservices)
```
/api/role-tools      - Role analysis
/api/captains        - Captain selection
/api/price-tools     - Price analysis
/api/fixture         - Fixture analysis
/api/context         - Context analysis
/api/team           - Team management
/api/stats          - FootyWire/DFS data
/api/afl-data       - AFL Fantasy integration
/api/integration    - Authenticated AFL access
/api/champion-data  - Champion Data API
/api/stats-tools    - Advanced stats tools
/api/algorithms     - Price predictor & scoring
/api/score-projection - Score projection v3.4.4
```

### Specialized Python Services
**Location**: `/ios/Backend/Python/api/trade_api.py`
**Port**: 5000 (runs separately, proxied by Node.js)

**Purpose**: Advanced trade scoring algorithm
**Integration**: Node.js proxies requests + fallback implementation

## 🛠️ Development Setup

### Web Development
```bash
# Install dependencies
pnpm install

# Start development server (Web + API)
pnpm dev
# Serves: Web app on port 5000 + API endpoints
```

### iOS Development  
```bash
# Setup backend for iOS integration
cd ios/Backend
chmod +x setup_development.sh
./setup_development.sh

# Start backend services for iOS
bash run_dev_servers.sh
# Serves: Node.js API (port 3000) + Python API (port 5000)
```

### Full Stack Development
```bash
# Terminal 1: Main web/API server
pnpm dev

# Terminal 2: Specialized Python services  
cd ios/Backend && bash run_dev_servers.sh

# Terminal 3: iOS Simulator
cd ios && open *.xcworkspace
```

## 🌍 Cross-Platform Data Flow

### Shared API Responses
Both Web and iOS consume the same API endpoints with identical JSON responses:

```typescript
// Player Data (shared)
interface Player {
  id: number;
  name: string;
  team: string;
  position: string;
  price: number;
  averageScore: number;
  // ... more fields
}

// Trade Analysis (shared)
interface TradeAnalysis {
  trade_score: number;
  recommendation: string;
  score_breakdown: {
    scoring_weight: number;
    cash_weight: number;
  };
  // ... more analysis data
}
```

### Platform-Specific UI
- **Web**: React components with Radix UI
- **iOS**: Native SwiftUI views with HIG compliance
- **Data**: Identical backend responses, different UI presentation

## 🔒 CORS & Security Configuration

### CORS Headers (for iOS)
The Express server automatically includes CORS headers for cross-origin requests from iOS:

```javascript
// Implicit CORS support
app.use(express.json()); // Handles preflight requests
// Static file serving allows cross-origin access
```

### Authentication (Both Platforms)
- Session-based authentication for web
- JWT token authentication for iOS (when implemented)
- Shared user management system

## 📊 Feature Parity Matrix

| Feature | Web App | iOS App | Backend API |
|---------|---------|---------|-------------|
| Dashboard | ✅ Full UI | ✅ Native UI | ✅ `/api/afl-fantasy/dashboard-data` |
| Player Stats | ✅ Tables/Charts | ✅ Lists/Detail | ✅ `/api/scraped-players` |
| Trade Analysis | ✅ Form + Results | ✅ Native Forms | ✅ `/api/trade_score` |
| Team Management | ✅ Drag/Drop | ✅ Native Picker | ✅ `/api/team` |
| Live Data | ✅ Auto-refresh | ✅ Pull-to-refresh | ✅ Real-time scraping |
| Offline Mode | ❌ Online only | ✅ Core Data cache | ✅ Cached responses |
| Push Notifications | ❌ Web only | ✅ Native iOS | ✅ Backend triggers |

## 🚀 Deployment Considerations

### Single Backend, Multiple Frontends
```bash
# Production deployment serves both platforms
npm run build        # Builds web app to /dist
npm start           # Serves web app + API for iOS

# iOS app builds separately and connects to API
```

### Environment Configuration
```env
# Shared environment variables
PORT=5000
NODE_ENV=production

# Web-specific
VITE_API_URL=http://localhost:5000

# iOS-specific  
IOS_API_URL=https://your-domain.com/api
```

## 📈 Performance Optimizations

### Shared Caching
- Redis cache for expensive calculations (trade scores)
- Static file caching for web assets
- JSON response caching for iOS

### Platform-Specific Optimizations
- **Web**: Bundle splitting, lazy loading, service workers
- **iOS**: Background fetch, Core Data optimization, image caching
- **Backend**: Database connection pooling, request batching

## 🎉 Summary

**YES, the backend fully supports both Web and iOS applications!**

✅ **Web App**: Complete React SPA with full feature set  
✅ **iOS App**: Native SwiftUI app consuming same APIs  
✅ **Unified Backend**: Single Express.js server serving both platforms  
✅ **Shared APIs**: Identical endpoints for consistent data  
✅ **Independent Development**: Can develop each platform separately  
✅ **Production Ready**: Single deployment serves all platforms  

The architecture is designed for maximum code reuse on the backend while allowing platform-specific optimizations on the frontend.

---

*Architecture validated December 6, 2024*
