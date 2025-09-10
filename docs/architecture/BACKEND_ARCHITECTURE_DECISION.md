# Backend Architecture Decision

**Date:** 2025-01-10  
**Decision:** Hybrid Architecture - Node.js for API/Dashboard + Python for Scraping

## Architecture Overview

After analyzing the codebase, the optimal solution is a **hybrid architecture** that leverages the strengths of both platforms:

### Component Responsibilities

#### 1. **Node.js/TypeScript Backend** (Primary API Server)
**Location:** `server-node/`  
**Port:** 5000 (API), 3000 (Dashboard)  
**Responsibilities:**
- REST API endpoints for iOS app and web client
- WebSocket connections for real-time updates
- Dashboard serving and rendering
- Database operations (PostgreSQL/SQLite)
- Authentication & session management
- Trade calculations and projections
- Static file serving (team logos, etc.)

**Why Node.js for API/Dashboard:**
- Already configured with Express, TypeScript, and frontend tooling
- Excellent for real-time features (WebSocket)
- Fast JSON handling for API responses
- Single language for full-stack dashboard (React/TypeScript)
- Better ecosystem for web dashboard components

#### 2. **Python Backend** (Data Collection & Processing)
**Location:** `server-python/`  
**Port:** 8000 (Internal API)  
**Responsibilities:**
- Web scraping (Selenium, BeautifulSoup)
- DFS Australia data collection
- AFL.com.au data synchronization
- Data cleaning and transformation
- Scheduled scraping jobs
- Excel/CSV processing
- AI/ML integration (if needed)

**Why Python for Scraping:**
- Superior scraping libraries (Selenium, BeautifulSoup, Scrapy)
- Better at handling complex HTML parsing
- Pandas for data manipulation
- Already implemented scrapers work well
- Better for scheduled/batch processing

## Integration Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     iOS App                              │
└────────────────────┬───────────────────────────────────┘
                     │ HTTPS
                     ▼
┌─────────────────────────────────────────────────────────┐
│            Node.js API Server (Port 5000)                │
│  - REST endpoints (/api/players, /api/trades, etc.)     │
│  - WebSocket for live updates                            │
│  - Authentication & sessions                             │
│  - Serves dashboard on port 3000                         │
└────────────┬──────────────────────┬─────────────────────┘
             │                      │
             │ Internal API         │ Read
             ▼                      ▼
┌─────────────────────────┐  ┌─────────────────────────────┐
│  Python Scraper Service │  │   PostgreSQL/SQLite DB      │
│     (Port 8000)         │  │   - Players data            │
│  - Scheduled scraping   │──▶   - Historical stats        │
│  - Data processing      │  │   - Fixtures                │
│  - Updates DB           │  │   - User data               │
└─────────────────────────┘  └─────────────────────────────┘
             ▲
             │ Scheduled (cron)
┌─────────────────────────┐
│   External Sources      │
│  - DFS Australia        │
│  - AFL.com.au           │
│  - Champion Data        │
└─────────────────────────┘
```

## Implementation Plan

### Phase 1: Configure Integration Layer
1. Python scraper service exposes internal API on port 8000
2. Node.js server calls Python API for scraping triggers
3. Both services share database access (read/write coordination)

### Phase 2: API Consolidation
```javascript
// Node.js API server routes
app.get('/api/players', getPlayersFromDB);        // Read from DB
app.get('/api/trades', calculateTrades);          // Business logic
app.post('/api/scrape/trigger', triggerPythonScraper); // Call Python service
app.get('/api/dashboard/*', serveDashboard);      // Dashboard routes

// Python internal API
@app.route('/internal/scrape/players', methods=['POST'])
@app.route('/internal/scrape/status', methods=['GET'])
@app.route('/internal/data/process', methods=['POST'])
```

### Phase 3: Service Communication
```yaml
# docker-compose.yml for local development
version: '3.8'
services:
  node-api:
    build: ./server-node
    ports:
      - "5000:5000"  # API
      - "3000:3000"  # Dashboard
    environment:
      - PYTHON_SERVICE_URL=http://python-scraper:8000
      - DATABASE_URL=postgresql://...
    depends_on:
      - postgres
      - python-scraper

  python-scraper:
    build: ./server-python
    ports:
      - "8000:8000"  # Internal only
    environment:
      - DATABASE_URL=postgresql://...
    depends_on:
      - postgres

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=afl_fantasy
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

## Benefits of Hybrid Approach

1. **Best tool for each job**: Node for APIs/real-time, Python for scraping
2. **Scalability**: Services can scale independently
3. **Maintainability**: Clear separation of concerns
4. **Reliability**: One service failure doesn't bring down everything
5. **Development**: Teams can work independently on each service

## Migration Steps

### Immediate Actions
1. ✅ Keep both services
2. ✅ Python handles all scraping
3. ✅ Node handles all client-facing APIs
4. ✅ Share data via PostgreSQL/SQLite database

### Short Term (Week 1)
1. [ ] Standardize database schema between services
2. [ ] Create internal API in Python for scraper control
3. [ ] Update Node API to call Python service when needed
4. [ ] Set up proper logging and monitoring

### Medium Term (Week 2-3)
1. [ ] Dockerize both services
2. [ ] Set up orchestration (docker-compose for dev, K8s for prod)
3. [ ] Implement service health checks
4. [ ] Add message queue for async jobs (optional)

## Decision Rationale

**Why not consolidate to one language?**
- Scraping in Node.js is inferior to Python's ecosystem
- Dashboard/API in Python (Django/FastAPI) requires more setup than existing Node
- Current implementation already works well in both
- Microservices approach is more scalable

**Why this specific split?**
- Clear boundary: Data collection (Python) vs Data serving (Node)
- Minimizes refactoring of working code
- Allows gradual migration if needed later
- Industry standard approach for mixed workloads

## Success Metrics
- API response time < 200ms (p95)
- Scraper reliability > 99%
- Dashboard load time < 2s
- Zero data inconsistencies between services
- Developer productivity maintained or improved

---

*This architecture supports the app's current needs while providing flexibility for future growth.*
