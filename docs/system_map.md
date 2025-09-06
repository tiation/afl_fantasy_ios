# AFL Fantasy Platform - System Architecture Map

## Overview
Complete mapping of all system components, their ports, environment variables, health check endpoints, and data flows.

## System Components

### Frontend Layer
| Service | Port | Tech Stack | Status Endpoint | Description |
|---------|------|------------|-----------------|-------------|
| React Dashboard | 5173 | Vite + React + TypeScript | `/` | Primary web interface |
| iOS App | - | SwiftUI + URLSession | N/A | Mobile client |

### Backend Layer
| Service | Port | Tech Stack | Health Endpoint | Description |
|---------|------|------------|-----------------|-------------|
| Express API | 5173* | Express + TypeScript | `/api/health` | Main API server |
| Python AI Service | 8080 | FastAPI + Python | `/health` | AI predictions & analysis |
| Python Scraper | 9001 | Flask + Python | `/health` | Data scraping service |

*Note: Currently Express API serves both frontend and API on same port

### Data Layer
| Service | Port | Tech Stack | Health Check | Description |
|---------|------|------------|--------------|-------------|
| PostgreSQL | 5432 | Postgres 15 | `pg_isready` | Primary database |
| Redis | 6379 | Redis 7 | `redis-cli ping` | Caching & sessions |

### Infrastructure Layer
| Service | Port | Tech Stack | Health Endpoint | Description |
|---------|------|------------|-----------------|-------------|
| Prometheus | 9090 | Prometheus | `/api/v1/status/config` | Metrics collection |
| Grafana | 3001 | Grafana | `/api/health` | Monitoring dashboards |
| Dashboard Service | 8090 | Nginx | `/` | Status dashboard |

## Environment Variables

### Shared Configuration
```bash
# Core Application
NODE_ENV=development
PORT=5173
API_PORT=4000

# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/afl_fantasy
REDIS_URL=redis://localhost:6379

# Python Services
PYTHON_SERVICE_URL=http://localhost:8080
PYTHON_SCRAPER_URL=http://localhost:9001

# iOS Integration
IOS_BUNDLE_ID=com.aflFantasy.app
IOS_API_BASE_URL=http://localhost:5173/api

# External APIs
AFL_FANTASY_TEAM_ID=
AFL_FANTASY_SESSION_COOKIE=
AFL_FANTASY_API_TOKEN=
GEMINI_API_KEY=
OPENAI_API_KEY=

# Monitoring
PROMETHEUS_URL=http://localhost:9090
GRAFANA_URL=http://localhost:3001
```

## Data Flows

### 1. Player Data Pipeline
```
External APIs (AFL.com, FootyWire, DFS Australia)
    ↓ [Python Scrapers]
Redis Cache + PostgreSQL
    ↓ [Express API]
React Dashboard + iOS App
```

### 2. Fantasy Tool Calculations
```
User Input (React/iOS)
    ↓ [Express API]
Python AI Service (ML models)
    ↓ [Results]
Frontend Display
```

### 3. Real-time Updates
```
Scheduled Scrapers
    ↓ [Redis Pub/Sub]
Express API (WebSocket)
    ↓ [Real-time]
Connected Clients
```

## Service Dependencies

### Startup Order
1. **Infrastructure**: PostgreSQL, Redis
2. **Python Services**: AI Service (8080), Scraper (9001)  
3. **Backend**: Express API (5173)
4. **Frontend**: React Dev Server (embedded)
5. **iOS**: Simulator/Device (connects to Express API)
6. **Monitoring**: Prometheus, Grafana (optional)

### Critical Dependencies
- Express API depends on: PostgreSQL, Redis
- Python Services depend on: PostgreSQL, Redis
- Frontend depends on: Express API
- iOS App depends on: Express API
- Monitoring depends on: All services

## Health Check Endpoints

### API Health Checks
| Endpoint | Service | Expected Response |
|----------|---------|-------------------|
| `GET /api/health` | Express API | `{"status": "healthy"}` |
| `GET /health` | Python AI | `{"status": "ok"}` |
| `GET /health` | Python Scraper | `{"status": "ok"}` |
| `GET /api/metrics` | Express API | Detailed metrics |
| `GET /ready` | Express API | Kubernetes readiness |
| `GET /live` | Express API | Kubernetes liveness |

### Database Health Checks
```bash
# PostgreSQL
pg_isready -h localhost -p 5432 -U postgres -d afl_fantasy

# Redis
redis-cli -h localhost -p 6379 ping
```

## Network Architecture

### Development (Local)
```
Frontend (5173) ←→ Express API (5173/api)
Express API ←→ Python AI (8080)
Express API ←→ Python Scraper (9001)
Express API ←→ PostgreSQL (5432)
Express API ←→ Redis (6379)
iOS Simulator ←→ Express API (5173/api)
```

### Docker Compose (Containerized)
```
Network: afl-network (172.20.0.0/16)
- api:5173 ←→ postgres:5432
- api:5173 ←→ redis:6379  
- api:5173 ←→ python-service:8080
- dashboard:8090 ←→ api:5173
- prometheus:9090 ←→ api:5173
- grafana:3001 ←→ prometheus:9090
```

## File Structure

### Core Application Files
```
/Users/tiaastor/workspace/10_projects/afl_fantasy_ios/
├── frontend/              # React dashboard
├── backend/               # Express API + TypeScript
├── scrapers/              # Python scraping services  
├── ios/                   # SwiftUI iOS app
├── server/                # Express routes & middleware
├── docs/                  # Documentation
├── scripts/               # Automation scripts
├── logs/                  # Application logs
└── data/                  # Static data files
```

### Configuration Files
```
├── package.json           # Node.js dependencies
├── docker-compose.yml     # Container orchestration
├── .env                   # Environment variables
├── .env.example          # Template for environment
├── Dockerfile            # Express API container
├── Dockerfile.python     # Python services container
└── drizzle.config.ts     # Database configuration
```

### Startup Scripts
```
├── setup.sh              # Master orchestration script
├── run_all.sh            # Legacy startup (for migration)
├── run_ios.sh            # iOS app launcher
├── status.sh             # Status dashboard opener
└── scripts/
    ├── load_env.sh       # Environment loader
    ├── health_check.sh   # System health verification
    └── cleanup.sh        # Development cleanup
```

## Integration Points

### React ↔ Express API
- REST endpoints: `/api/players`, `/api/fantasy-tools`, `/api/afl-fantasy`
- WebSocket: Real-time updates
- Authentication: Session-based

### Express ↔ Python Services  
- HTTP API calls with retry logic
- Circuit breaker pattern for reliability
- JSON data exchange

### iOS ↔ Express API
- REST API calls via URLSession
- Background sync capabilities
- Local caching with Core Data

### Express ↔ Database
- PostgreSQL via SQL queries
- Redis for caching and sessions
- Connection pooling

## Monitoring & Observability

### Logs Location
```bash
# Application logs
./logs/webapp.log          # Express API
./logs/python_ai.log       # Python AI service
./logs/python_scraper.log  # Python scraper
./logs/python_install.log  # Python dependencies

# System logs (Docker)
docker logs afl_fantasy_api
docker logs afl_fantasy_python
docker logs afl_fantasy_postgres
```

### Metrics Collection
- **Prometheus**: System metrics, custom application metrics
- **Grafana**: Visualization dashboards
- **Health endpoints**: Service status and performance data

## Security Considerations

### Secrets Management
- Environment variables in `.env` (gitignored)
- 1Password integration for production secrets
- No hardcoded API keys or passwords

### Network Security
- Local development: `127.0.0.1` binding
- Docker: Internal network isolation
- iOS: Local network entitlements for simulator

### Data Protection
- PostgreSQL: Authenticated connections
- Redis: No external exposure
- API endpoints: Input validation

## Troubleshooting Guide

### Common Issues
1. **Port conflicts**: Check `lsof -i :5173,8080,9001,5432,6379`
2. **Environment missing**: Verify `.env` file exists and is sourced
3. **Database connection**: Check PostgreSQL is running and accessible
4. **Python dependencies**: Verify `requirements.txt` packages installed
5. **iOS simulator**: Ensure Xcode command line tools installed

### Debug Commands
```bash
# Check all services
./scripts/health_check.sh

# View logs
docker compose logs -f api
docker compose logs -f python-service

# Database connection test  
psql $DATABASE_URL -c "SELECT version();"

# Redis connection test
redis-cli -u $REDIS_URL ping
```

---

**Last Updated**: `date +%Y-%m-%d`  
**Architecture Version**: 1.0.0  
**Maintainer**: AFL Fantasy Team
