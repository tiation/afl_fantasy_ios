# AFL Fantasy Platform - API Documentation

## API Overview

The AFL Fantasy Platform provides a comprehensive REST API for accessing player statistics, team data, and analytical tools. All endpoints return JSON responses and support standard HTTP methods.

## Base URL
```
Production: https://your-domain.com/api
Development: http://localhost:5000/api
```

## Authentication

Most endpoints are publicly accessible. API keys enhance functionality but are not required for basic operations.

### Optional API Keys
```bash
# Environment variables for enhanced features
AFL_FANTASY_USERNAME=your_username
AFL_FANTASY_PASSWORD=your_password
DFS_AUSTRALIA_API_KEY=your_api_key
OPENAI_API_KEY=your_openai_key
```

## Core Endpoints

### Health & Status

#### GET /health
Application health check
```json
{
  "status": "healthy",
  "timestamp": "2025-07-23T10:00:00Z",
  "uptime": 3600,
  "memory": {
    "rss": 123456789,
    "heapTotal": 98765432,
    "heapUsed": 87654321
  },
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "scrapers": "healthy"
  }
}
```

#### GET /metrics
Prometheus metrics endpoint for monitoring

### Player Data

#### GET /stats/combined-stats
Get all player statistics with comprehensive data
```json
[
  {
    "id": 1,
    "name": "Marcus Bontempelli",
    "position": "Mid",
    "team": "Western Bulldogs",
    "price": 735000,
    "averageScore": 107.5,
    "projectedScore": 115.2,
    "breakeven": 45,
    "priceChange": 15000,
    "ownership": 67.8,
    "form": [89, 134, 101, 97, 125],
    "fixtures": [
      {
        "round": 20,
        "opponent": "Richmond",
        "difficulty": 2.5,
        "venue": "MCG"
      }
    ]
  }
]
```

#### GET /stats/player/:id
Get detailed player information
```json
{
  "id": 1,
  "name": "Marcus Bontempelli",
  "position": "Mid",
  "team": "Western Bulldogs",
  "price": 735000,
  "averageScore": 107.5,
  "totalPoints": 1290,
  "games": 12,
  "statistics": {
    "kicks": 18.2,
    "handballs": 12.3,
    "disposals": 30.5,
    "marks": 5.8,
    "tackles": 4.2,
    "goals": 0.8
  },
  "projections": {
    "nextRound": 115.2,
    "confidence": 0.78
  }
}
```

#### GET /stats/footywire
FootyWire data source integration
```json
[
  {
    "name": "Marcus Bontempelli",
    "position": "Mid",
    "team": "Western Bulldogs",
    "price": 735000,
    "averageScore": 107.5,
    "lastScore": 134,
    "externalId": "footywire_12345"
  }
]
```

#### GET /stats/dfs-australia
DFS Australia data source integration
```json
[
  {
    "name": "Marcus Bontempelli",
    "position": "Mid",
    "team": "Western Bulldogs",
    "price": 735000,
    "consistency": 85.2,
    "ceiling": 165,
    "floor": 75,
    "valueScore": 4.2,
    "ownership": 67.8
  }
]
```

### Team Management

#### GET /team/data
Get user team composition
```json
{
  "status": "ok",
  "data": {
    "defenders": [
      {
        "name": "Harry Sheezel",
        "position": "Def",
        "team": "North Melbourne",
        "price": 598000,
        "averageScore": 89.5
      }
    ],
    "midfielders": [...],
    "forwards": [...],
    "rucks": [...],
    "bench": [...],
    "emergencies": [...]
  }
}
```

#### GET /teams/user/:userId
Get specific user's team details
```json
{
  "userId": 1,
  "name": "Bont's Brigade",
  "value": 14850000,
  "remainingSalary": 150000,
  "totalScore": 2847,
  "captain": "Marcus Bontempelli",
  "viceCaptain": "Patrick Cripps"
}
```

#### GET /teams/:teamId/performances
Get team performance history
```json
[
  {
    "teamId": 1,
    "round": 19,
    "score": 2025,
    "rank": 123456,
    "captainScore": 134
  }
]
```

### Fantasy Tools

#### GET /fantasy/tools/captain-analysis
Captain selection analysis
```json
{
  "recommendations": [
    {
      "playerId": 1,
      "name": "Marcus Bontempelli",
      "projectedScore": 115.2,
      "confidence": 0.78,
      "ownership": 67.8,
      "reasoning": "Strong form against weak opposition"
    }
  ],
  "considerations": [
    "Weather conditions favorable",
    "Key defender out for opposition"
  ]
}
```

#### GET /fantasy/tools/trade-analyzer
Trade recommendation engine
```json
{
  "recommendations": [
    {
      "tradeOut": "Player A",
      "tradeIn": "Player B",
      "costDifference": 50000,
      "projectedGain": 15.5,
      "riskLevel": "medium"
    }
  ]
}
```

#### GET /cash/generation-tracker
Cash generation analysis
```json
{
  "rookies": [
    {
      "name": "Rookie Player",
      "currentPrice": 215000,
      "projectedPeak": 350000,
      "cashGeneration": 135000,
      "timeToTarget": 4
    }
  ]
}
```

### Statistics & Analytics

#### GET /stats-tools/player/:playerId/matchup-difficulty
Player-specific matchup difficulty
```json
{
  "playerId": 1,
  "name": "Marcus Bontempelli",
  "upcomingFixtures": [
    {
      "round": 20,
      "opponent": "Richmond",
      "difficulty": 2.5,
      "description": "Very Easy"
    }
  ]
}
```

#### GET /stats-tools/stats/team-fixtures/:team/:position
Team DVP analysis
```json
{
  "team": "Western Bulldogs",
  "position": "Mid",
  "fixtures": [
    {
      "round": 20,
      "opponent": "Richmond",
      "difficulty": 2.5,
      "venue": "MCG"
    }
  ]
}
```

### Advanced Analytics

#### POST /algorithms/projected-score
Calculate projected scores for players
```json
{
  "playerId": 1,
  "factors": {
    "recentForm": 0.25,
    "seasonAverage": 0.30,
    "opponentDifficulty": 0.20,
    "venuePerformance": 0.15,
    "positionAdjustment": 0.10
  }
}
```

Response:
```json
{
  "playerId": 1,
  "projectedScore": 115.2,
  "confidence": 0.78,
  "breakdown": {
    "baseScore": 107.5,
    "formAdjustment": 5.2,
    "opponentAdjustment": 2.5
  }
}
```

#### POST /algorithms/price-predictor
Predict future player prices
```json
{
  "playerId": 1,
  "rounds": 3
}
```

Response:
```json
{
  "playerId": 1,
  "currentPrice": 735000,
  "projectedPrices": [
    { "round": 20, "price": 750000 },
    { "round": 21, "price": 765000 },
    { "round": 22, "price": 780000 }
  ]
}
```

### Data Integration

#### GET /data-integration/team/integrated
Integrated team data with authentication priority
```json
{
  "source": "afl_fantasy_api",
  "authenticated": true,
  "data": {
    "teamValue": 14850000,
    "totalScore": 2847,
    "overallRank": 123456
  }
}
```

#### GET /data-integration/players/integrated
Integrated player data with price updates
```json
{
  "source": "multiple",
  "lastUpdate": "2025-07-23T10:00:00Z",
  "players": [...]
}
```

## Error Handling

### Standard Error Format
```json
{
  "error": "Error description",
  "code": "ERROR_CODE",
  "details": "Additional error information",
  "timestamp": "2025-07-23T10:00:00Z"
}
```

### HTTP Status Codes
- `200` - Success
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `500` - Internal Server Error
- `503` - Service Unavailable

## Rate Limiting

- **Default**: 1000 requests per hour per IP
- **Authenticated**: 5000 requests per hour with API key
- **Enterprise**: Custom limits available

## Data Freshness

- **Real-time**: Health and status endpoints
- **12 hours**: Player statistics and scores
- **24 hours**: Team compositions and ownership
- **Weekly**: Historical analysis and trends

## SDK and Client Libraries

### JavaScript/TypeScript
```typescript
import { AFLFantasyAPI } from 'afl-fantasy-sdk';

const api = new AFLFantasyAPI('http://localhost:5000/api');
const players = await api.getPlayers();
```

### Python
```python
from afl_fantasy import AFLFantasyClient

client = AFLFantasyClient('http://localhost:5000/api')
players = client.get_players()
```

## Webhook Support

### Player Updates
Register for player statistic updates
```json
{
  "webhook_url": "https://your-app.com/webhooks/players",
  "events": ["player_updated", "scores_updated"]
}
```

### Team Changes
Register for team composition changes
```json
{
  "webhook_url": "https://your-app.com/webhooks/teams",
  "events": ["team_updated", "trades_made"]
}
```

## Testing

### Health Check
```bash
curl -X GET http://localhost:5000/api/health
```

### Get All Players
```bash
curl -X GET http://localhost:5000/api/stats/combined-stats
```

### Player Search
```bash
curl -X GET "http://localhost:5000/api/stats/combined-stats?search=Bontempelli"
```

---

**For additional API documentation and examples, see the enterprise technical documentation.**