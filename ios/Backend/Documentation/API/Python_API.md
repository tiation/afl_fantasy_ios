# Python Flask API Documentation

## Overview
The Python Flask API provides advanced AFL Fantasy analysis capabilities, focusing on trade evaluation, player analysis, and predictive modeling.

**Base URL**: `http://localhost:5000`

## Authentication
Currently, most endpoints are public. Future versions will implement JWT-based authentication.

## Endpoints

### Health Check

#### `GET /health`
Returns the health status of the Flask API service.

**Response:**
```json
{
  "status": "healthy",
  "service": "AFL Fantasy Trade API"
}
```

---

### Trade Analysis

#### `POST /api/trade_score`
Evaluates a fantasy trade and returns a comprehensive analysis score.

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
  "scoring_score": 75.0,
  "cash_score": 12500,
  "overall_score": 18.7,
  "score_breakdown": {
    "projected_score": 22.5,
    "value": 18.2,
    "breakeven": 12.8,
    "risk": 5.0,
    "scoring_weight": 70.0,
    "cash_weight": 30.0
  },
  "price_projections": {
    "player_in": [1072, 877, 974, 1267, 1170],
    "player_out": [-487, -975, -1754, -1170, -1560],
    "net_gain": 12500
  },
  "projected_prices": {
    "player_in": [1101072, 1100195, 1101169, 1102436, 1103606],
    "player_out": [929513, 928538, 926784, 925614, 924054]
  },
  "projected_scores": {
    "player_in": [125, 122, 118, 130, 120],
    "player_out": [105, 110, 102, 108, 104]
  },
  "flags": {
    "peaked_rookie": false,
    "trading_peaked_player": false,
    "getting_peaked_player": false,
    "player_in_class": "premium",
    "player_out_class": "premium",
    "upgrade_path": "upgrade",
    "season_match": false
  },
  "verdict": "Perfect Timing",
  "explanations": [
    "Player coming in projected to score 18.0 points more per game",
    "Projected to gain $125.0k in value over 5 rounds",
    "Trading for a player with 6 lower breakeven",
    "This trade costs $170.0k immediately",
    "Round 13: Scoring is weighted more heavily than cash gain"
  ],
  "recommendation": "Highly recommend this trade"
}
```

**Trade Score Explanation:**
- **0-39**: Not recommended
- **40-59**: Neutral trade, consider alternatives
- **60-79**: Good trade opportunity
- **80-100**: Highly recommend this trade

---

### Player Classification

#### Internal Function: `classify_player_by_price(price)`
Classifies players based on their price:
- **rookie**: < $450,000
- **midpricer**: $450,000 - $799,999  
- **underpriced_premium**: $800,000 - $999,999
- **premium**: $1,000,000+

#### Internal Function: `is_player_peaked(proj_scores, breakeven)`
Determines if a player has peaked in value based on projected scores vs breakeven.

---

## Error Handling

### Error Response Format
```json
{
  "status": "error",
  "message": "Error description here"
}
```

### Common Error Codes
- **400 Bad Request**: Missing required fields or invalid data
- **500 Internal Server Error**: Server processing error

### Example Errors
```json
{
  "status": "error",
  "message": "Missing required fields"
}
```

```json
{
  "status": "error",
  "message": "player_in proj_scores must be a list of 5 values"
}
```

---

## Trade Score Algorithm

### Factors Considered
1. **Projected Score Difference**: Sum of projected scores over 5 rounds
2. **Price Change Trends**: Based on the magic number formula
3. **Round Weighting**: Different weights based on season timing
4. **Team Value Context**: Adjustments based on team value vs league average
5. **Risk Assessment**: Red dot (injury/suspension) considerations

### Round-based Weighting
- **Rounds 1-2**: 50% scoring, 50% cash
- **Rounds 3-7**: 30% scoring, 70% cash (cash generation phase)
- **Rounds 8-11**: 50% scoring, 50% cash
- **Rounds 12-14**: 70% scoring, 30% cash (premium upgrade phase)
- **Rounds 15-17**: 60% scoring, 40% cash
- **Rounds 18+**: 100% scoring, 0% cash (finals)

### Team Value Adjustments
- **Below average team** (< 95% of league average): Prioritize cash generation
- **Above average team** (> 105% of league average): Prioritize scoring

---

## Data Models

### Player Model
```typescript
interface Player {
  price: number;          // Player price in dollars
  breakeven: number;      // Breakeven score for price maintenance
  proj_scores: number[];  // Array of 5 projected scores
  is_red_dot: boolean;    // Injury/suspension flag
}
```

### Trade Request Model
```typescript
interface TradeRequest {
  player_in: Player;         // Player being traded in
  player_out: Player;        // Player being traded out
  round_number: number;      // Current AFL round
  team_value: number;        // Current team value
  league_avg_value: number;  // League average team value
}
```

---

## Performance Notes

- **Response Time**: Typically < 100ms for trade calculations
- **Concurrency**: Supports multiple simultaneous requests
- **Caching**: No caching currently implemented (stateless calculations)
- **Rate Limiting**: Not implemented (consider for production)

---

## Examples

### Basic Trade Evaluation
```bash
curl -X POST http://localhost:5000/api/trade_score \
  -H "Content-Type: application/json" \
  -d '{
    "player_in": {
      "price": 1200000,
      "breakeven": 110,
      "proj_scores": [130, 125, 135, 128, 132],
      "is_red_dot": false
    },
    "player_out": {
      "price": 800000,
      "breakeven": 125,
      "proj_scores": [100, 95, 105, 98, 102],
      "is_red_dot": true
    },
    "round_number": 8,
    "team_value": 15200000,
    "league_avg_value": 15000000
  }'
```

### Health Check
```bash
curl http://localhost:5000/health
```

---

## Development & Testing

### Running the Service
```bash
cd ios/Backend/Python
source venv/bin/activate
python api/trade_api.py
```

### Running Tests
```bash
cd ios/Backend/Python
pytest tests/ -v --coverage
```

### Environment Variables
```bash
FLASK_ENV=development
FLASK_DEBUG=1
PORT=5000
```

---

## Future Enhancements

1. **Authentication**: JWT-based user authentication
2. **Player Data API**: Endpoints for player statistics and information
3. **Historical Data**: Trade performance tracking over time
4. **Batch Processing**: Multiple trade evaluations in single request
5. **Caching**: Redis-based response caching
6. **Rate Limiting**: API abuse prevention
7. **Webhooks**: Real-time notifications for trade opportunities

---

*Last updated: December 6, 2024*
