# Score Predictor Integration

## Overview
The Python score prediction algorithm (v3.4.4 formula) will be integrated into the captain selection tools to provide authentic projected scores for player analysis.

## Algorithm Integration Points

### 1. Captain Score Predictor Tool
- **Endpoint**: `/api/captains/score-predictor`
- **Algorithm**: Uses v3.4.4 projected score calculation
- **Input Data Required**:
  - Player last 5 scores
  - Player last 3 scores
  - Season average
  - Ceiling score
  - Average vs opponent
  - Position-specific parameters
  - Context factors (venue, defense, form trend)

### 2. Data Requirements for v3.4.4 Formula

**Player Historical Data:**
- `last_5`: Array of last 5 round scores
- `last_3`: Array of last 3 round scores
- `season_avg`: Season average score
- `ceiling`: Highest score potential

**Matchup Data:**
- `avg_vs_opponent`: Historical performance vs current opponent
- `sample_size`: Number of games vs opponent
- `lowest_vs_opp`: Lowest score vs current opponent

**Context Factors:**
- `venue_factor`: Home/away advantage (default 1.05)
- `defensive_factor`: Opponent defensive strength
- `role_factor`: Player role impact
- `tag_factor`: Tagging likelihood (default 0.95)
- `weather_factor`: Weather conditions
- `pace_factor`: Game pace impact
- `team_dynamics`: Team performance context
- `injury_return`: Return from injury factor

**Player Attributes:**
- `position`: Player role (Inside MID, Rebound DEF, FWD High Half, RUCK)
- `experience`: Player experience level
- `confidence`: Prediction confidence (0-1)

### 3. Position-Specific Parameters

**Inside MID:**
- Floor: 95 points
- Standard deviation: 15
- Range multiplier: 0.35

**Rebound DEF:**
- Floor: 80 points
- Standard deviation: 10
- Range multiplier: 0.25

**FWD High Half:**
- Floor: 75 points
- Standard deviation: 12
- Range multiplier: 0.30

**RUCK:**
- Floor: 90 points
- Standard deviation: 20
- Range multiplier: 0.40

### 4. Output Format

```json
{
  "projected_score": 115,
  "range_low": 98,
  "range_high": 132,
  "confidence": 0.75,
  "floor_applied": false
}
```

### 5. Integration with Existing Tools

**Captain Selection Enhancement:**
- Replace simple averages with v3.4.4 projections
- Include confidence ranges in recommendations
- Factor in opponent matchups and context

**Vice-Captain Optimization:**
- Use projected scores for VC/C combinations
- Account for floor protection in selection logic
- Optimize based on confidence levels

**Form-Based Analysis:**
- Incorporate form trends from v3.4.4 calculations
- Weight recent performance appropriately
- Adjust for volatility and consistency

### 6. Data Source Mapping

**Required Authentic Data:**
- Round-by-round player scores (individual player history)
- Opponent matchup history (head-to-head records)
- Venue performance data (home/away splits)
- Team defensive statistics (DVP data from DFS Australia)
- Weather and game condition data
- Player role and position data

**Current Data Gaps:**
- Individual player round scores (only season averages available)
- Head-to-head opponent performance history
- Venue-specific performance breakdowns
- Real-time injury and tagging intelligence

This score predictor algorithm will provide sophisticated captain recommendations once the required historical data is populated through AFL Fantasy authentication or additional data scraping.