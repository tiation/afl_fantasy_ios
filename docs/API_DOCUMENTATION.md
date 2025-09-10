# AFL Fantasy Platform - API Documentation

**Base URL:** `http://localhost:5000/api`  
**WebSocket URL:** `ws://localhost:5000`  
**Version:** 1.0.0  
**Last Updated:** 2025-01-10

## Table of Contents
- [Authentication](#authentication)
- [Player Endpoints](#player-endpoints)
- [Trade Endpoints](#trade-endpoints)
- [Scraper Endpoints](#scraper-endpoints)
- [Dashboard Endpoints](#dashboard-endpoints)
- [WebSocket Events](#websocket-events)
- [Data Schemas](#data-schemas)
- [Error Responses](#error-responses)

---

## Authentication

Currently using session-based authentication. JWT implementation planned.

### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "string",
  "password": "string"
}

Response: 200 OK
{
  "success": true,
  "user": {
    "id": "string",
    "username": "string",
    "role": "string"
  },
  "token": "string"  // Future: JWT token
}
```

---

## Player Endpoints

### Get All Players
```http
GET /api/players
Query Parameters:
  - position: string (DEF|MID|RUC|FWD)
  - team: string (team name)
  - min_price: number
  - max_price: number
  - sort: string (price|average|name)
  - limit: number (default: 100)
  - offset: number (default: 0)

Response: 200 OK
{
  "success": true,
  "data": [
    {
      "id": "CD_I297373",
      "name": "Marcus Bontempelli",
      "position": "MID",
      "team": "Western Bulldogs",
      "price": 750000,
      "average_score": 115.8,
      "last_score": 128,
      "projected_score": 118,
      "break_even": 82,
      "ownership": 45.2,
      "injury_status": null,
      "games_played": 22,
      "image_url": "/images/players/CD_I297373.jpg"
    }
  ],
  "pagination": {
    "total": 652,
    "limit": 100,
    "offset": 0,
    "has_more": true
  }
}
```

### Get Single Player
```http
GET /api/players/:playerId

Response: 200 OK
{
  "success": true,
  "data": {
    "id": "CD_I297373",
    "name": "Marcus Bontempelli",
    "position": "MID",
    "team": "Western Bulldogs",
    "price": 750000,
    "average_score": 115.8,
    "last_3_average": 120.3,
    "last_5_average": 117.6,
    "season_average": 115.8,
    "career_average": 108.4,
    "stats": {
      "disposals_avg": 28.5,
      "marks_avg": 5.2,
      "tackles_avg": 4.8,
      "goals_avg": 0.8
    },
    "history": [
      {
        "round": 23,
        "opponent": "Hawthorn",
        "score": 128,
        "result": "W"
      }
    ],
    "upcoming_fixtures": [
      {
        "round": 1,
        "opponent": "Melbourne",
        "venue": "MCG",
        "difficulty": 4
      }
    ]
  }
}
```

### Get Player History
```http
GET /api/players/:playerId/history
Query Parameters:
  - season: number (year)
  - limit: number (default: 10)

Response: 200 OK
{
  "success": true,
  "data": {
    "player_id": "CD_I297373",
    "games": [
      {
        "date": "2024-08-25",
        "round": 23,
        "opponent": "Hawthorn",
        "score": 128,
        "disposals": 32,
        "marks": 6,
        "tackles": 5,
        "goals": 1,
        "behinds": 2,
        "result": "W",
        "margin": 15
      }
    ]
  }
}
```

---

## Trade Endpoints

### Calculate Trade Suggestions
```http
POST /api/trades/suggest
Content-Type: application/json

{
  "budget": 100000,
  "positions_needed": ["MID", "FWD"],
  "current_team": ["CD_I297373", "CD_I298539", ...],
  "trade_targets": ["CD_I1023261"],  // Optional specific targets
  "strategy": "value"  // value|premium|balanced
}

Response: 200 OK
{
  "success": true,
  "data": {
    "suggestions": [
      {
        "out": [
          {
            "id": "CD_I297373",
            "name": "Marcus Bontempelli",
            "price": 750000
          }
        ],
        "in": [
          {
            "id": "CD_I1023261",
            "name": "Nick Daicos",
            "price": 650000
          },
          {
            "id": "CD_I1006126",
            "name": "James Rowbottom",
            "price": 450000
          }
        ],
        "cash_gain": 100000,
        "projected_points_gain": 15.5,
        "confidence": 0.85,
        "reasoning": "Daicos trending up, Rowbottom undervalued"
      }
    ]
  }
}
```

### One-Up-One-Down Trade
```http
POST /api/trades/one-up-one-down
Content-Type: application/json

{
  "downgrade_player": "CD_I297373",
  "upgrade_position": "FWD",
  "max_rookie_price": 400000
}

Response: 200 OK
{
  "success": true,
  "data": {
    "downgrade": {
      "out": "CD_I297373",
      "in": "CD_I1023482",
      "cash_released": 400000
    },
    "upgrade_options": [
      {
        "id": "CD_I298539",
        "name": "Isaac Heeney",
        "price": 650000,
        "affordable": true,
        "projected_gain": 25.3
      }
    ]
  }
}
```

---

## Scraper Endpoints

### Trigger Player Data Scrape
```http
POST /api/scraper/trigger
Content-Type: application/json
Authorization: Bearer <admin_token>

{
  "type": "players",  // players|fixtures|news
  "player_ids": ["CD_I297373"],  // Optional: specific players
  "force": false  // Override cache
}

Response: 202 Accepted
{
  "success": true,
  "job_id": "scrape_123456",
  "status": "queued",
  "estimated_time": 300  // seconds
}
```

### Get Scraper Status
```http
GET /api/scraper/status/:jobId

Response: 200 OK
{
  "success": true,
  "data": {
    "job_id": "scrape_123456",
    "status": "in_progress",  // queued|in_progress|completed|failed
    "progress": 45,  // percentage
    "players_processed": 293,
    "players_total": 652,
    "errors": [],
    "started_at": "2025-01-10T10:00:00Z",
    "estimated_completion": "2025-01-10T10:05:00Z"
  }
}
```

---

## Dashboard Endpoints

### Get Dashboard Stats
```http
GET /api/dashboard/stats

Response: 200 OK
{
  "success": true,
  "data": {
    "total_players": 652,
    "last_update": "2025-01-10T09:00:00Z",
    "next_scrape": "2025-01-10T21:00:00Z",
    "trending_players": [
      {
        "id": "CD_I1023261",
        "name": "Nick Daicos",
        "price_change": 50000,
        "ownership_change": 5.2
      }
    ],
    "system_health": {
      "api_status": "healthy",
      "scraper_status": "idle",
      "database_status": "connected",
      "cache_hit_rate": 0.87
    }
  }
}
```

### Get Performance Metrics
```http
GET /api/dashboard/metrics
Query Parameters:
  - period: string (hour|day|week|month)

Response: 200 OK
{
  "success": true,
  "data": {
    "api_requests": 15234,
    "average_response_time": 145,  // ms
    "scraper_runs": 24,
    "scraper_success_rate": 0.96,
    "cache_hits": 13250,
    "cache_misses": 1984,
    "error_rate": 0.02
  }
}
```

---

## WebSocket Events

### Connection
```javascript
const ws = new WebSocket('ws://localhost:5000');

ws.on('connect', () => {
  // Subscribe to events
  ws.send(JSON.stringify({
    type: 'subscribe',
    channels: ['players', 'trades', 'scraper']
  }));
});
```

### Player Update Event
```json
{
  "type": "player_update",
  "data": {
    "player_id": "CD_I297373",
    "changes": {
      "price": 755000,
      "ownership": 46.1
    },
    "timestamp": "2025-01-10T10:30:00Z"
  }
}
```

### Scraper Progress Event
```json
{
  "type": "scraper_progress",
  "data": {
    "job_id": "scrape_123456",
    "progress": 75,
    "message": "Processing player 489 of 652"
  }
}
```

---

## Data Schemas

### Player Schema
```typescript
interface Player {
  id: string;              // CD_I format
  name: string;
  position: 'DEF' | 'MID' | 'RUC' | 'FWD';
  team: string;
  price: number;
  average_score: number;
  last_score?: number;
  projected_score?: number;
  break_even?: number;
  ownership?: number;
  injury_status?: 'OUT' | 'TEST' | 'SORE' | null;
  games_played: number;
  image_url?: string;
}
```

### Trade Schema
```typescript
interface Trade {
  id: string;
  user_id: string;
  timestamp: string;
  trades_out: Player[];
  trades_in: Player[];
  cash_difference: number;
  points_difference: number;
  status: 'pending' | 'completed' | 'cancelled';
}
```

### Fixture Schema
```typescript
interface Fixture {
  round: number;
  home_team: string;
  away_team: string;
  venue: string;
  date: string;
  difficulty: {
    home: number;  // 1-5 scale
    away: number;
  };
}
```

---

## Error Responses

### Standard Error Format
```json
{
  "success": false,
  "error": {
    "code": "PLAYER_NOT_FOUND",
    "message": "Player with ID CD_I999999 not found",
    "details": {}
  }
}
```

### Common Error Codes
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (resource doesn't exist)
- `429` - Too Many Requests (rate limited)
- `500` - Internal Server Error
- `503` - Service Unavailable (maintenance/overload)

### Rate Limiting
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1704888000
```

---

## Python Scraper Internal API

**Base URL:** `http://localhost:8000/internal`  
**Note:** Internal use only, not exposed publicly

### Trigger Scrape
```http
POST /internal/scrape/players
Content-Type: application/json

{
  "player_ids": ["CD_I297373"],
  "force_update": false
}

Response: 200 OK
{
  "status": "started",
  "job_id": "py_scrape_123"
}
```

### Get Scraper Health
```http
GET /internal/health

Response: 200 OK
{
  "status": "healthy",
  "last_run": "2025-01-10T09:00:00Z",
  "queue_size": 0,
  "active_jobs": 0
}
```

---

## Testing Endpoints

### Postman Collection
Available at: `docs/postman/AFL_Fantasy_API.postman_collection.json`

### cURL Examples

```bash
# Get all midfielders under $600k
curl "http://localhost:5000/api/players?position=MID&max_price=600000"

# Get player details
curl "http://localhost:5000/api/players/CD_I297373"

# Trigger scraper (requires auth)
curl -X POST "http://localhost:5000/api/scraper/trigger" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"type":"players","force":false}'
```

---

*For implementation details, see `server-node/backend/API_DOCUMENTATION.md`*
