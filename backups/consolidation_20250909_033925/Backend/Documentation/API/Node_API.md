# Node.js Express API Documentation

## Overview
The Node.js Express API serves as the primary gateway for the AFL Fantasy iOS app, providing comprehensive data aggregation, business logic, and real-time communication capabilities.

**Base URL**: `http://localhost:3000`

## Architecture
- **Framework**: Express.js with TypeScript
- **Real-time**: WebSocket support for live updates  
- **Monitoring**: Prometheus metrics collection
- **Security**: CORS, rate limiting, input validation

## Authentication
JWT-based authentication with refresh tokens (implementation varies by endpoint).

---

## Core Endpoints

### Health Check & Monitoring

#### `GET /api/health`
Returns comprehensive health status and system metrics.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-12-06T11:40:51.244Z",
  "uptime": 17.123726875,
  "memory": {
    "rss": 218726400,
    "heapTotal": 183730176,
    "heapUsed": 88024000,
    "external": 7201956,
    "arrayBuffers": 3350820
  },
  "version": "1.0.0",
  "environment": "development",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "scrapers": "healthy"
  }
}
```

#### `GET /metrics`
Returns Prometheus-formatted metrics for monitoring.

---

## Player Data

### `GET /api/players`
Retrieve player data with optional filtering and search capabilities.

**Query Parameters:**
- `q` (string): Search query for player name or team
- `position` (string): Filter by position (DEF, MID, RUC, FWD)
- `season` (string): Season filter (defaults to current)
- `limit` (number): Limit results (default: 100)

**Response:**
```json
[
  {
    "id": 1,
    "name": "Marcus Bontempelli",
    "team": "WBD",
    "position": "MID",
    "price": 1180000,
    "averagePoints": 115.2,
    "breakeven": 108,
    "priceChange": 25000,
    "selectedBy": 45.2,
    "projectedScore": 118,
    "fixtures": [
      {
        "round": 14,
        "opponent": "COL",
        "venue": "MCG",
        "difficulty": 3.2
      }
    ]
  }
]
```

### `GET /api/players/:id`
Get detailed information for a specific player.

**Response:**
```json
{
  "id": 1,
  "name": "Marcus Bontempelli",
  "team": "WBD",
  "position": "MID",
  "price": 1180000,
  "averagePoints": 115.2,
  "breakeven": 108,
  "priceChange": 25000,
  "selectedBy": 45.2,
  "projectedScore": 118,
  "stats": {
    "kicks": 22.1,
    "handballs": 12.4,
    "disposals": 34.5,
    "marks": 6.8,
    "tackles": 4.2
  },
  "fixtures": [...],
  "recentScores": [120, 98, 135, 89, 112],
  "priceHistory": [
    {"round": 10, "price": 1155000},
    {"round": 11, "price": 1167000}
  ]
}
```

---

## Dashboard Data

### `GET /api/dashboard`
Aggregated dashboard data for the main app screen.

**Response:**
```json
{
  "teamValue": {
    "total": 15800000,
    "playerCount": 30,
    "remainingSalary": 200000,
    "formatted": "$15.8M"
  },
  "teamScore": {
    "total": 2156,
    "captainScore": 240,
    "changeFromLastRound": 45
  },
  "overallRank": {
    "current": 12547,
    "formatted": "12,547",
    "changeFromLastRound": -234
  },
  "captain": {
    "score": 120,
    "ownershipPercentage": 67.8,
    "playerName": "Sam Docherty"
  },
  "upcomingMatchups": [
    {
      "round": 14,
      "date": "2024-06-28",
      "matches": [
        {
          "home": "COL",
          "away": "RIC", 
          "venue": "MCG",
          "difficulty": {
            "DEF": 2.1,
            "MID": 4.2,
            "RUC": 3.1,
            "FWD": 3.8
          }
        }
      ]
    }
  ],
  "lastUpdated": "2024-12-06T11:45:00.000Z"
}
```

---

## Trade Analysis

### `POST /api/trade_score`
Proxy endpoint that delegates to Python Flask API for trade analysis.

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
Same as Python Flask API, but includes fallback calculation if Python service is unavailable.

---

## Fantasy Tools

### Role Analysis
#### `POST /api/role-tools/analyze`
Analyze player roles and position changes.

### Captain Selection  
#### `GET /api/captains/recommendations`
Get captain recommendations based on fixtures and form.

#### `POST /api/captains/analyze`
Analyze captain choice for specific round.

### Price Analysis
#### `GET /api/price-tools/trends`
Get price trend analysis for players.

#### `POST /api/price-tools/projections`
Calculate price projections based on projected scores.

### Fixture Analysis
#### `GET /api/fixture/difficulty`
Get fixture difficulty ratings by position.

#### `GET /api/fixture/matchups/:round`
Get detailed matchup analysis for specific round.

### Context Analysis
#### `GET /api/context/bye-optimization`
Bye round planning and optimization.

#### `GET /api/context/venue-bias`
Venue performance analysis.

---

## Statistics & Data Integration

### Stats API
#### `GET /api/stats/footywire`
FootyWire statistics integration.

#### `GET /api/stats/champion-data`
Champion Data statistics integration.

### AFL Fantasy Integration
#### `GET /api/afl-data/live-scores`
Live AFL Fantasy scoring data.

#### `POST /api/integration/sync`
Sync authenticated AFL Fantasy user data.

---

## Advanced Analytics

### Algorithm Routes
#### `POST /api/algorithms/price-predictor`
Advanced price prediction algorithms.

#### `POST /api/algorithms/score-projection`
Player score projection based on multiple factors.

### Score Projection
#### `GET /api/score-projection/players/:id`
Detailed score projections for specific player.

#### `POST /api/score-projection/batch`
Batch score projections for multiple players.

---

## Team Management

### `POST /api/team/upload`
Upload team data from CSV or Excel file.

**Request:**
- Multipart form data with team file

**Response:**
```json
{
  "status": "success",
  "playersProcessed": 30,
  "teamValue": 15800000,
  "warnings": [],
  "errors": []
}
```

### `GET /api/team/:id`
Get team information and player lineup.

---

## Real-time Features

### WebSocket Connection
**Endpoint**: `ws://localhost:3000/ws`

**Events:**
- `price_update`: Live price changes
- `score_update`: Live scoring updates
- `trade_opportunity`: Real-time trade alerts
- `injury_update`: Player injury notifications

**Example:**
```javascript
const ws = new WebSocket('ws://localhost:3000/ws');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  
  switch(data.type) {
    case 'price_update':
      updatePlayerPrice(data.playerId, data.newPrice);
      break;
    case 'score_update':
      updateLiveScores(data.scores);
      break;
  }
};
```

---

## Error Handling

### Standard Error Response
```json
{
  "error": "Error type",
  "message": "Detailed error message",
  "timestamp": "2024-12-06T11:45:00.000Z",
  "requestId": "uuid-here"
}
```

### HTTP Status Codes
- **200**: Success
- **400**: Bad Request (validation errors)
- **401**: Unauthorized
- **403**: Forbidden
- **404**: Not Found
- **429**: Rate Limit Exceeded
- **500**: Internal Server Error
- **503**: Service Unavailable

---

## Rate Limiting

### Default Limits
- **General API**: 1000 requests per hour per IP
- **Trade Analysis**: 100 requests per hour per IP
- **WebSocket**: 10 connections per IP

### Headers
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1609459200
```

---

## Monitoring & Metrics

### Available Metrics
- `http_requests_total`: Total HTTP requests
- `http_request_duration_seconds`: Request latency
- `active_connections`: Current active connections
- `scraper_errors_total`: Scraper error count
- `data_freshness_seconds`: Data age in seconds
- `database_connections_active`: Active DB connections

### Custom Metrics for AFL Fantasy
- `trade_calculations_total`: Number of trade calculations
- `player_price_updates`: Price update frequency
- `user_sessions_active`: Active user sessions

---

## Development

### Running the Server
```bash
cd ios/Backend/Node
pnpm install
pnpm build
pnpm start
```

### Development Mode
```bash
pnpm dev  # Runs with hot reloading
```

### Testing
```bash
pnpm test            # Run all tests
pnpm test:coverage   # Run with coverage
pnpm test:watch      # Watch mode
```

### Linting & Type Checking
```bash
pnpm lint           # ESLint
pnpm typecheck      # TypeScript compilation check
pnpm format         # Prettier formatting
```

---

## Environment Configuration

### Required Environment Variables
```bash
# Server
NODE_ENV=development
PORT=3000

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/afl_fantasy
REDIS_URL=redis://localhost:6379

# Security
JWT_SECRET=your-jwt-secret-here
SESSION_SECRET=your-session-secret-here

# External APIs
AFL_FANTASY_USERNAME=your_username
AFL_FANTASY_PASSWORD=your_password
OPENAI_API_KEY=your_openai_key
```

### Optional Environment Variables
```bash
# Monitoring
PROMETHEUS_ENABLED=true
LOG_LEVEL=info

# Features
WEBSOCKET_ENABLED=true
RATE_LIMITING_ENABLED=true
```

---

## Docker Support

### Dockerfile
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build
EXPOSE 3000
CMD ["pnpm", "start"]
```

### Docker Compose
```yaml
services:
  node-api:
    build: ./ios/Backend/Node
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@postgres:5432/afl_fantasy
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
```

---

## Future Enhancements

1. **GraphQL Support**: Alternative to REST for mobile optimization
2. **Event Sourcing**: Event-driven architecture for data consistency
3. **Microservices**: Split into smaller, focused services
4. **API Versioning**: Support multiple API versions
5. **Advanced Caching**: Multi-layer caching strategy
6. **Message Queues**: Async processing with Redis/RabbitMQ
7. **API Gateway**: Centralized routing and security

---

*Last updated: December 6, 2024*
