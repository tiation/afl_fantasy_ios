# Stats Tab Data Mapping

## Overview
The stats tab displays a comprehensive player database with advanced filtering, searching, and detailed player analytics across multiple statistical categories.

## Component 1: Player Statistics Table

### Core Player Data Requirements
- **Current Display**: Combined data from DFS Australia and FootyWire APIs
- **Required Data**: Comprehensive AFL player statistics
- **Authentic Sources**: Multiple APIs for complete coverage
- **Data Fields**:
  ```typescript
  interface StatsPlayer {
    id: string | number;
    name: string;
    team: string;
    position: string;
    price: number;
    averagePoints: number;
    lastScore: number;
    l3Average: number;
    l5Average: number;
    breakEven: number;
    priceChange: number;
    pricePerPoint: number;
    totalPoints: number;
    selectionPercentage: number;
    // Advanced match statistics
    kicks?: number;
    handballs?: number;
    disposals?: number;
    marks?: number;
    tackles?: number;
    hitouts?: number;
    freeKicksFor?: number;
    freeKicksAgainst?: number;
    clearances?: number;
    cba?: number;
    kickIns?: number;
    contestedMarks?: number;
    uncontestedMarks?: number;
    contestedDisposals?: number;
    uncontestedDisposals?: number;
  }
  ```

## Component 2: Statistical Categories

### Core Fantasy Stats
- **Purpose**: Primary fantasy football metrics
- **Required Data**: Fantasy scoring and performance data
- **Authentic Source**: AFL Fantasy API + DFS Australia
- **Fields**: avg, last, l3, l5, breakeven, total, selection%

### Price & Movement Analysis
- **Purpose**: Player pricing and value tracking
- **Required Data**: Historical pricing and value metrics
- **Authentic Source**: AFL Fantasy pricing API
- **Fields**: price, priceChange, pricePerPoint, value rating

### Match Statistics
- **Purpose**: Detailed game performance metrics
- **Required Data**: Official AFL match statistics
- **Authentic Source**: AFL Stats API or Champion Data
- **Fields**: kicks, handballs, disposals, marks, tackles, hitouts

### Role Statistics  
- **Purpose**: Player role and usage patterns
- **Required Data**: Advanced positional analytics
- **Authentic Source**: Champion Data advanced metrics
- **Fields**: CBA%, kick-ins, TOG%, possession type, inside/outside

### Volatility Analysis
- **Purpose**: Consistency and risk assessment
- **Required Data**: Score variance and ceiling/floor analysis
- **Authentic Source**: Historical performance calculation
- **Fields**: consistency, volatility, ceiling, floor

### Fixture & Matchups
- **Purpose**: Upcoming opponent analysis
- **Required Data**: Fixture difficulty and venue analysis
- **Authentic Source**: AFL fixture data + DVP matrix
- **Fields**: next 3 opponents, venues, difficulty ratings

## Component 3: Player Detail Modal

### Comprehensive Player Profile
- **Current Display**: Extended player information with multiple tabs
- **Required Data**: Complete player analytics package
- **Authentic Sources**: Multiple integrated APIs

#### Overview Tab Requirements:
```typescript
interface PlayerOverview {
  // Basic Information
  name: string;
  team: string;
  position: string;
  price: number;
  ownership: number;
  
  // Performance Metrics
  projectedScore: number;
  averagePoints: number;
  lastScore: number;
  l3Average: number;
  l5Average: number;
  
  // Value Analysis
  breakEven: number;
  priceChange: number;
  valueRating: number;
  
  // Role Information
  gameTime: number;
  positionRole: string;
  consistencyRating: number;
}
```

#### Statistics Tab Requirements:
```typescript
interface PlayerStatistics {
  // Match Statistics
  disposals: number;
  kicks: number;
  handballs: number;
  marks: number;
  tackles: number;
  hitouts: number;
  
  // Advanced Metrics
  disposalEfficiency: number;
  contestedPossessions: number;
  uncontestedPossessions: number;
  groundBallGets: number;
  interceptions: number;
  
  // Scoring Breakdown
  goals: number;
  behinds: number;
  goalAccuracy: number;
}
```

#### Projections Tab Requirements:
```typescript
interface PlayerProjections {
  // Future Fixtures (5 games)
  upcomingFixtures: Array<{
    round: number;
    opponent: string;
    venue: string;
    difficulty: number;
    projectedScore: number;
  }>;
  
  // Historical Performance vs Teams
  opponentHistory: Array<{
    opponent: string;
    averageScore: number;
    gamesPlayed: number;
    lastScore: number;
  }>;
}
```

## Required Data Sources

### Primary APIs Needed:
1. **AFL Fantasy Official API**
   - Player prices and ownership
   - Fantasy scores and breakevens
   - Team selections and transfers

2. **Champion Data API** 
   - Advanced player statistics
   - Role-based analytics
   - Historical performance data

3. **AFL Stats API**
   - Official match statistics
   - Detailed game-by-game data
   - Team and player records

4. **DFS Australia API** (Currently Active)
   - Player pricing data
   - Consensus rankings
   - Value assessments

5. **FootyWire API** (Currently Active)
   - Additional player statistics
   - Historical data backup
   - Consistency metrics

### Fixture and Analysis Data:
1. **AFL Fixture API**
   - Season fixture list
   - Venue information
   - Game scheduling

2. **DVP Matrix Data**
   - Defense vs Position analytics
   - Team strength ratings
   - Matchup difficulty scores

## Current Implementation Status:

### ✅ Currently Working:
- DFS Australia player data integration
- FootyWire statistics supplementation
- Basic player search and filtering
- Team guernsey display
- Position-based filtering
- Price and performance sorting

### ❌ Missing Authentic Data:
- Real-time AFL Fantasy pricing
- Official ownership percentages
- Advanced Champion Data metrics
- Live scoring updates
- Detailed role statistics
- Accurate fixture difficulty ratings

## Authentication Requirements:

### Champion Data API:
- Client ID and Secret (Available in secrets)
- OAuth2 authentication flow
- Access token management

### AFL Fantasy API:
- User session authentication
- Team access permissions
- Real-time data access

## Data Validation Needs:

1. **Price Accuracy**: Validate against multiple sources
2. **Score Verification**: Cross-reference official AFL data
3. **Ownership Tracking**: Ensure current selection percentages
4. **Position Eligibility**: Verify DPP and position changes
5. **Team Updates**: Handle trades and delistings

## Integration Priority:

### Phase 1: Core Data Enhancement
1. Implement Champion Data authentication
2. Add real-time AFL Fantasy pricing
3. Enhance player statistics accuracy

### Phase 2: Advanced Analytics
1. Add role-based statistics
2. Implement volatility calculations
3. Create fixture difficulty scoring

### Phase 3: Real-time Features
1. Live score updates during games
2. Ownership tracking
3. Price change notifications

## Component Dependencies:
- **Player Detail Modal**: Requires complete player profiles
- **Search/Filter System**: Needs comprehensive data indexing
- **Statistical Categories**: Depends on authentic metric sources
- **Team Integration**: Requires accurate team/player associations