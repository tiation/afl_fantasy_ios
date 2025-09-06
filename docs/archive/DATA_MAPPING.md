# AFL Fantasy App - Data Mapping Requirements

## Dashboard Cards Data Sources

### 1. Team Value Card
**Required Data:**
- Sum of all user's player prices (26 players: 18 on-field + 8 bench)
- User's remaining salary cap amount
- Total = Player prices + Remaining salary

**AFL Fantasy API Sources Needed:**
- User's complete team lineup with current prices
- Remaining salary balance from user account

### 2. Team Score Card
**Required Data:**
- Total AFL Fantasy score of all players on user's field for current round
- Captain's score doubled (2x multiplier)
- Emergency player scores count if on-field player scores 0
- During bye rounds: best 18 scores on field count only

**AFL Fantasy API Sources Needed:**
- User's current round lineup (18 on-field players)
- Individual player scores for current round
- Captain selection for current round
- Emergency player designations and scores

### 3. Overall Rank Card
**Required Data:**
- User's live rank out of all AFL Fantasy players
- Current position in overall leaderboard

**AFL Fantasy API Sources Needed:**
- User's current overall ranking from authenticated account data

### 4. Captain Score Card
**Required Data:**
- User's captain score for current round
- How many people captained that player the week before
- Captain popularity statistics

**AFL Fantasy API Sources Needed:**
- User's captain selection for current round
- Captain's individual score
- League-wide captain selection statistics

### 5. Season Performance Chart
**Required Data:**
- Projected score of all players on field for user
- User's field selections for current and previous rounds
- User's captain selections for each round
- Historical round scores and projections

**AFL Fantasy API Sources Needed:**
- User's lineup history for each completed round
- User's captain selections per round
- Player projected scores for upcoming rounds
- User's actual scores per round

### 6. Team Structure Card
**Required Data:**
- Prices of all players user owns categorized by:
  - Cash cows/rookies: < $449,000
  - Mid pricers: $450,000-$799,000  
  - Underpriced premiums: $800,000-$999,999
  - Premiums: > $1,000,000
- Count of each price range player by position (DEF, MID, RUC, FWD)
- Total money spent on each position

**AFL Fantasy API Sources Needed:**
- User's complete 26-player roster with current prices
- Player position classifications
- Price tier calculations per position

## Stats Tab Data Sources

### 7. Player Stats Table
**Required Data:**
- All player statistics (scores, averages, prices, etc.)
- Breakeven calculations
- Form indicators (L3, L5 averages)

### 8. Visualization Cards (DVP Analysis, Value Trends, etc.)
**Required Data:**
- Defense vs Position statistics
- Player value trend data
- Injury status information
- Consistency metrics

## Tools Tab Data Sources

### 9. Trade Tools
**Required Data:**
- Player price predictions
- Breakeven calculations
- Trade impact analysis
- Value change tracking

### 10. Captain Tools
**Required Data:**
- Player scoring predictions
- Fixture difficulty
- Historical captain performance
- Loop opportunity analysis

### 11. Risk Tools
**Required Data:**
- Tag likelihood statistics
- Injury risk factors
- Late-out probability
- Score volatility metrics

## Key Data Integration Points

1. **AFL Fantasy Official API** - Primary source for:
   - Live scores
   - Player prices
   - Rankings
   - Team compositions
   - **Authentication Required:** Session tokens from logged-in browser

2. **Statistical Analysis Data** - Currently available from:
   - DFS Australia scraper (player_data.json)
   - DVP matrix data (dvp_matrix.json)
   - Fixture data from FootyWire

3. **User-Specific Data** - Requires authentication:
   - Team composition (your actual 26 players)
   - Trade history
   - Personal rankings
   - Captain selections

## Current Data Status

### ✅ Available (No Authentication Needed)
- Player statistics from scraped sources
- DVP analysis data
- Fixture information
- General player performance metrics

### 🔒 Requires Authentication
- Your actual team composition (26 players)
- Real AFL Fantasy prices for accurate team value
- Personal ranking and score history
- Live team performance data

### 📊 Current Team Value Issue
- **Expected:** $22.8M (your actual team)
- **Current:** $16.3M (with estimates for missing players)
- **Gap:** 9 missing players without proper AFL Fantasy prices

## Authentication Integration Framework

```javascript
// Data service structure ready for AFL Fantasy API
const aflFantasyService = {
  // Ready for authentication tokens
  headers: {
    'Authorization': process.env.AFL_FANTASY_AUTH_TOKEN,
    'Cookie': process.env.AFL_FANTASY_SESSION_TOKEN
  },
  
  // Endpoints identified for your team data
  endpoints: {
    userTeam: '/api/classic/team',
    playerPrices: '/api/players',
    liveScores: '/api/scores/live'
  },
  
  // Data transformation ready
  transformTeamData: (rawData) => {
    // Convert AFL Fantasy format to app format
  }
}
```

## Next Steps for Complete Integration

1. **Obtain AFL Fantasy authentication tokens** from browser session
2. **Implement authenticated data fetching** for user-specific data
3. **Replace estimated prices** with real AFL Fantasy values
4. **Sync team composition** with actual 26-player lineup
5. **Enable live data updates** for real-time scoring