# AFL Fantasy Platform - API Endpoints Documentation

## Core Data APIs

### Player Data
- `GET /api/stats/combined-stats` - All 630 players with complete statistics
- `GET /api/stats/dfs-australia` - DFS Australia player data
- `GET /api/stats/footywire` - FootyWire player data

### Team Management
- `GET /api/team/data` - User's current team composition
- `GET /api/teams/user/{userId}` - Team metadata
- `GET /api/teams/{teamId}/performances` - Team performance history

### Score Projections (v3.4.4 Algorithm)
- `GET /api/score-projection/player/{playerName}?round={round}` - Individual player projections
- `GET /api/score-projection/all-players` - Batch projections for all players

### DVP and Fixture Analysis
- `GET /api/stats-tools/stats/team-fixtures/{team}/{position}` - Team fixture difficulty
- `GET /api/stats-tools/stats/dvp-enhanced` - Enhanced DVP analysis

### Fantasy Tools
- `GET /api/captains/analysis` - Captain selection recommendations
- `GET /api/cash/generation-analysis` - Cash generation tools
- `GET /api/algorithms/price-predictor` - Price prediction algorithm

## Data Formats

### Player Object
```json
{
  "name": "string",
  "team": "string (3-letter code)",
  "position": "string",
  "price": "number",
  "averagePoints": "number",
  "breakEven": "number",
  "projScore": "number",
  "last1": "number",
  "last2": "number",
  "last3": "number",
  "l3Average": "number"
}
```

### Fixture Difficulty Object
```json
{
  "team": "string",
  "fixtures": [
    {
      "round": "string (R20, R21, etc.)",
      "opponent": "string",
      "difficulty": "number (0-10 scale)"
    }
  ]
}
```

### Projection Object
```json
{
  "success": "boolean",
  "data": {
    "projectedScore": "number",
    "confidence": "number",
    "factors": "object"
  }
}
```

## Authentication
Most endpoints require user authentication. The platform supports:
- Session-based authentication
- AFL Fantasy integration (when credentials available)

## Rate Limiting
- Standard endpoints: No specific limits
- Score projection endpoints: Optimized for batch processing
- External data sources: Respectful scraping intervals

## Error Handling
All endpoints return standard HTTP status codes:
- 200: Success
- 304: Not Modified (cached)
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 500: Server Error

## Known API Issues
1. **Team Code Mapping**: Some endpoints expect full team names vs 3-letter codes
2. **Position Handling**: Multi-position players not standardized across all endpoints
3. **Cache Invalidation**: Some endpoints return stale data

## Testing Endpoints
Use these endpoints to verify platform functionality:
- `GET /api/stats/combined-stats` - Should return 630 players
- `GET /api/score-projection/player/Brodie%20Grundy` - Should return realistic projection
- `GET /api/stats-tools/stats/team-fixtures/SYD/RUC` - Should return Sydney fixtures with difficulty values