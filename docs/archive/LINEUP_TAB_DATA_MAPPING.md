# Lineup Tab Data Mapping

## Overview
The lineup tab displays the user's actual AFL Fantasy team organized by position with detailed player information and team guernseys.

## Component: Team Lineup Display

### Player Card Requirements
Each player card displays comprehensive information requiring multiple data sources:

#### Essential Player Data
- **Current Display**: Static team data from `/api/team/data`
- **Required Data**: User's actual fantasy team composition
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/players/current`
- **Data Fields**:
  ```typescript
  interface LineupPlayer {
    id: number;
    name: string;
    team: string;
    position: "MIDFIELDER" | "FORWARD" | "DEFENDER" | "RUCK";
    price: number;
    averagePoints: number;
    breakEven: number;
    lastScore: number;
    isCaptain: boolean;
    isOnBench: boolean;
    secondaryPositions?: string[]; // DPP eligibility
    nextOpponent?: string;
    l3Average?: number; // Last 3 rounds average
    selectionPercentage?: number; // Ownership %
  }
  ```

#### Position Organization
- **Midfielders**: 8 players (6 on field + 2 bench)
- **Forwards**: 6 players (6 on field + 0 bench typically)
- **Defenders**: 6 players (6 on field + 0 bench typically)  
- **Rucks**: 2 players (1 on field + 1 bench)
- **Utility Bench**: Additional interchange players

#### Team Guernsey Integration
- **Current Display**: Team logos from `/guernseys/` directory
- **Required Data**: Team abbreviation to guernsey mapping
- **Authentic Source**: Team logo assets + team name standardization
- **Data Fields**:
  - Team name or abbreviation
  - Guernsey image URL mapping

### Captain Selection Display
- **Current Display**: Captain indicator with "C" badge
- **Required Data**: Current captain selection
- **Authentic Source**: AFL Fantasy API `/teams/{teamId}/captain`
- **Data Fields**:
  - `captainId`: number
  - `viceCaptainId`: number (optional)

### Dual Position Players (DPP)
- **Current Display**: DPP badge for eligible players
- **Required Data**: Secondary position eligibility
- **Authentic Source**: AFL Fantasy player database
- **Data Fields**:
  - `primaryPosition`: string
  - `secondaryPositions`: string[]
  - `dppEligible`: boolean

## Data Integration Requirements

### Phase 1: Core Team Data
1. **Player Selection**: Actual fantasy team composition (22 players)
2. **Position Assignment**: Players assigned to correct fantasy positions
3. **Captain Selection**: Current captain and vice-captain
4. **Bench Players**: Identification of bench vs starting players

### Phase 2: Player Statistics
1. **Pricing Data**: Current AFL Fantasy prices
2. **Performance Metrics**: Averages, last scores, break-evens
3. **Recent Form**: L3 averages, consistency metrics
4. **Fixture Information**: Next opponent, difficulty ratings

### Phase 3: Advanced Features
1. **DPP Eligibility**: Secondary position tracking
2. **Selection Percentage**: Player ownership data
3. **Team Integration**: Guernsey display, team colors
4. **Interactive Features**: Player modal integration

## Required AFL Fantasy API Endpoints

### Primary Team Data:
1. `/api/teams/{teamId}/lineup/current` - Current team selection
2. `/api/teams/{teamId}/bench` - Bench player assignments
3. `/api/teams/{teamId}/captain` - Captain/VC selection
4. `/api/players/{playerId}/dpp` - Dual position eligibility

### Supporting Data:
1. `/api/players/prices/current` - Latest player prices
2. `/api/players/stats/recent` - Last 3 rounds performance
3. `/api/players/ownership` - Selection percentages
4. `/api/fixtures/upcoming` - Next opponent data

## Current Data Sources Available:
- ✅ Player statistics (DFS Australia, FootyWire)
- ✅ Team guernsey assets
- ✅ Position color coding
- ✅ Price formatting utilities
- ❌ User's actual team selection
- ❌ Captain/bench assignments
- ❌ DPP eligibility data
- ❌ Real-time pricing updates

## Authentication Requirements:
- AFL Fantasy session authentication
- Access to user's private team data
- Real-time team composition updates
- Player transaction history

## Data Validation Needs:
1. **Team Completeness**: Verify 22 players selected
2. **Position Limits**: Enforce AFL Fantasy position requirements
3. **Captain Selection**: Ensure valid captain assignment
4. **Price Accuracy**: Validate against official AFL Fantasy prices
5. **DPP Compliance**: Verify secondary position eligibility

## Integration with Other Components:
- **Player Detail Modal**: Clicking players opens detailed statistics
- **Dashboard Sync**: Team value calculation consistency
- **Stats Tab**: Player performance data alignment
- **Tools Integration**: Trade suggestions based on actual team