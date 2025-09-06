# Dashboard Tab Data Mapping

## Overview
The dashboard tab contains 4 main components that require authentic AFL Fantasy data sources.

## Component 1: Score Cards (4 cards)

### Card 1: Team Score
- **Current Display**: "1,817" (static sample data)
- **Required Data**: User's current round fantasy score
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/scores/current`
- **Data Fields**:
  - `currentRoundScore`: number
  - `lastRoundScore`: number (for change calculation)
  - `scoreChange`: number (positive/negative)

### Card 2: Overall Rank  
- **Current Display**: "5,489" (static sample data)
- **Required Data**: User's current overall rank
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/rank`
- **Data Fields**:
  - `overallRank`: number
  - `previousRank`: number (for change calculation)
  - `rankChange`: number (positive/negative)

### Card 3: Team Value
- **Current Display**: "21.82M" (calculated from player prices)
- **Required Data**: Sum of all player prices in team
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/players` + player price data
- **Data Fields**:
  - `totalTeamValue`: number
  - `valueChange`: number (weekly change)
  - `players`: Array of player objects with `price` field

### Card 4: Captain Score
- **Current Display**: "122" (captain's last score)
- **Required Data**: Current captain's last round score
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/captain`
- **Data Fields**:
  - `captainId`: number
  - `captainName`: string
  - `lastScore`: number
  - `averageScore`: number

## Component 2: Performance Chart

### Chart Data Requirements
- **Current Display**: Static sample data for 8 rounds
- **Required Data**: Season performance history
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/performance/season`
- **Data Fields**:
  ```typescript
  interface RoundPerformance {
    round: number;
    actualScore: number;
    projectedScore: number;  // From prediction algorithm
    rank: number;
    teamValue: number;
    date: string;
  }
  ```

### Chart Types (3 views)
1. **Score View**: Actual vs Projected scores per round
2. **Rank View**: Overall rank progression
3. **Value View**: Team value changes over season

## Component 3: Team Structure Analysis

### Position Breakdown Requirements
- **Current Display**: Static player type counts
- **Required Data**: Player categorization by price tier
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/players` + price analysis
- **Data Fields**:
  ```typescript
  interface PositionStructure {
    defense: {
      premium: { count: number, totalValue: number };
      midPricer: { count: number, totalValue: number };
      rookie: { count: number, totalValue: number };
    };
    midfield: { /* same structure */ };
    ruck: { /* same structure */ };
    forward: { /* same structure */ };
  }
  ```

### Price Tier Definitions
- **Premium**: Players > $600k
- **Mid-Pricer**: Players $350k - $600k  
- **Rookie**: Players < $350k

## Component 4: Recent Performance (within Team Structure)

### Performance History
- **Current Display**: Last 4 rounds performance
- **Required Data**: Recent round scores and rank changes
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/performance/recent`
- **Data Fields**:
  ```typescript
  interface RecentPerformance {
    round: number;
    score: number;
    rank: number;
    rankChange: number; // vs previous round
  }
  ```

## Data Integration Priority

### Phase 1: Core Score Cards
1. Team Score (highest priority - user's main metric)
2. Overall Rank (second priority - competitive ranking)
3. Team Value (calculated from existing player data)
4. Captain Score (derived from captain selection)

### Phase 2: Performance Visualization
1. Historical round scores (8+ rounds of data)
2. Rank progression tracking
3. Team value tracking over time

### Phase 3: Advanced Analytics
1. Player type categorization by price
2. Position-based team structure analysis
3. Recent performance trends

## Required AFL Fantasy API Endpoints

### Primary Endpoints Needed:
1. `/api/teams/{teamId}/current` - Current team state
2. `/api/teams/{teamId}/performance/season` - Full season data
3. `/api/teams/{teamId}/players/detailed` - Player prices and positions
4. `/api/teams/{teamId}/scores/history` - Round-by-round scores
5. `/api/teams/{teamId}/rank/history` - Rank progression

### Authentication Requirements:
- AFL Fantasy session token
- User team ID
- Access to private team data

## Current Data Sources Available:
- ✅ Player price data (from DFS Australia)
- ✅ Player stats and positions
- ✅ Team structure calculation logic
- ❌ User's actual fantasy scores
- ❌ User's rank progression
- ❌ Historical performance data

## Next Steps:
1. Implement AFL Fantasy authentication
2. Create API endpoints for user team data
3. Replace static sample data with authentic sources
4. Add error handling for missing data