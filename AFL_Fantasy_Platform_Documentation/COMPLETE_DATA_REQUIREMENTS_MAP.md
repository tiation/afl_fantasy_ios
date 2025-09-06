# AFL Fantasy Intelligence Platform - Complete Data Requirements Map

## Overview
This document maps every component in the AFL Fantasy platform to its exact data requirements, API endpoints, and expected data formats. This ensures any AI assistant can understand what data each component needs to function properly.

## Core Data Sources

### 1. Player Database
**File**: `player_data_stats_enhanced_20250720_205845.json`
**Contains**: 630 players with authentic Round 13 AFL Fantasy data
**Required Fields**:
```json
{
  "name": "string",
  "team": "string (3-letter code: ADE, BRL, CAR, etc.)",
  "position": "string (MID, FWD, DEF, RUC or combinations: Mid,Def)",
  "price": "number (in dollars: 1062000)",
  "averagePoints": "number (season average)",
  "breakEven": "number", 
  "last1": "number (last game score)",
  "last2": "number (2 games ago)",
  "last3": "number (3 games ago)",
  "l3Average": "number (last 3 games average)",
  "projScore": "number (projected score from v3.4.4 algorithm)",
  "ownership": "string (percentage)"
}
```

### 2. DVP Matchup Data  
**File**: `attached_assets/DFS_DVP_Matchup_Tables_FIXED_1753016059835.xlsx`
**Sheets**: FWD Matchups, MID Matchups, DEF Matchups, RUCK Matchups
**Required Fields**:
```json
{
  "team": "string (3-letter code)",
  "rounds": {
    "20": "number (0-10 difficulty scale)",
    "21": "number",
    "22": "number", 
    "23": "number",
    "24": "number"
  }
}
```

### 3. Fixture Data
**File**: `attached_assets/afl_fixture_2025_1753111987231.json`
**Contains**: 203 fixture matches with teams and rounds
**Required Fields**:
```json
{
  "round": "string (R20, R21, etc.)",
  "homeTeam": "string",
  "awayTeam": "string",
  "date": "string"
}
```

## Component Data Requirements

### Dashboard Components

#### 1. Team Summary (`client/src/components/lineup/team-summary.tsx`)
**API Endpoints**:
- `GET /api/team/data` - User's current team composition
- `GET /api/teams/user/{userId}` - Team metadata

**Required Data Format**:
```json
{
  "defenders": [PlayerObject],
  "midfielders": [PlayerObject], 
  "forwards": [PlayerObject],
  "rucks": [PlayerObject],
  "bench": [PlayerObject]
}
```

**Player Object Requirements**:
```json
{
  "id": "number",
  "name": "string",
  "position": "string", 
  "team": "string",
  "price": "number",
  "averagePoints": "number",
  "projScore": "number",
  "liveScore": "number|null",
  "isOnBench": "boolean",
  "isCaptain": "boolean"
}
```

#### 2. Player Stats Table (`client/src/components/player-stats/player-table.tsx`)
**API Endpoints**:
- `GET /api/stats/combined-stats` - All player statistics
- `GET /api/score-projection/all-players` - Projected scores for all players

**Required Data Format**:
```json
[
  {
    "name": "string",
    "position": "string",
    "team": "string", 
    "price": "number",
    "averagePoints": "number",
    "breakEven": "number",
    "last1": "number",
    "last2": "number", 
    "last3": "number",
    "projScore": "number",
    "ownership": "string"
  }
]
```

**Filtering Requirements**:
- Position filter: "all" | "MID" | "FWD" | "DEF" | "RUCK"
- Team filter: Team 3-letter codes
- Search: Name substring matching
- Price range: Min/max price filtering

### Player Detail Modal (`client/src/components/player-stats/player-detail-modal.tsx`)

**API Endpoints**:
- `GET /api/stats-tools/stats/team-fixtures/{team}/{position}` - Fixture difficulty
- `GET /api/score-projection/player/{playerName}?round={round}` - Round projections

**Required Team Fixture Data**:
```json
{
  "team": "string",
  "fixtures": [
    {
      "round": "string (R20, R21, etc.)",
      "opponent": "string (team name)",
      "difficulty": "number (0-10 scale)"
    }
  ]
}
```

**Required Projection Data**:
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

**Critical Requirements**:
- Team mapping: Player.team must match fixture data team codes
- Position priority: RUCK > MID > DEF > FWD for multi-position players
- Difficulty color mapping: ≤3=EASY(green), 4-6=MED(yellow), ≥7=HARD(red)

### Tools Components

#### 1. Cash Generation Tools (`client/src/components/tools/cash/`)
**API Endpoints**:
- `GET /api/stats/combined-stats` - Player data with price trends
- `GET /api/cash/generation-analysis` - Cash cow analysis

**Required Data Format**:
```json
[
  {
    "name": "string",
    "team": "string",
    "position": "string", 
    "currentPrice": "number",
    "projectedIncrease": "number",
    "breakEven": "number",
    "averagePoints": "number",
    "form": "string (Rising|Falling|Stable)",
    "riskLevel": "string (Low|Medium|High)"
  }
]
```

#### 2. Captain Selection Tools (`client/src/components/tools/captain/`)
**API Endpoints**:
- `GET /api/captains/analysis` - Captain recommendations
- `GET /api/stats-tools/stats/team-fixtures/{team}/{position}` - Matchup difficulty

**Required Data Format**:
```json
[
  {
    "name": "string",
    "team": "string",
    "position": "string",
    "projectedScore": "number",
    "captainScore": "number", 
    "consistency": "number",
    "matchupDifficulty": "number",
    "recommendation": "string"
  }
]
```

#### 3. Trade Analysis Tools (`client/src/components/tools/trade/`)
**API Endpoints**:
- `GET /api/stats/combined-stats` - Current player data
- `GET /api/score-projection/player/{playerName}` - Future projections

**Required Data Format**:
```json
{
  "playerIn": "PlayerObject",
  "playerOut": "PlayerObject", 
  "scoreDifferential": "number",
  "priceDifferential": "number",
  "riskAssessment": "string",
  "recommendation": "string"
}
```

### Stats Tools Components

#### 1. DVP Analysis (`client/src/components/stats-tools/dvp-analysis.tsx`)
**API Endpoints**:
- `GET /api/stats-tools/stats/dvp-enhanced` - Enhanced DVP data with fixture difficulty

**Required Data Format**:
```json
{
  "DEF": [
    {
      "team": "string",
      "difficulty": "number",
      "nextOpponents": ["string"],
      "fixtureRatings": [number]
    }
  ],
  "MID": [...],
  "FWD": [...],
  "RUC": [...]
}
```

#### 2. Player DVP Analysis
**API Endpoints**:
- `GET /api/stats/combined-stats` - All players
- `GET /api/stats-tools/stats/team-fixtures/{team}/{position}` - Individual fixture difficulty

**Required Combined Data**:
- Player data merged with fixture difficulty for next 5 rounds
- Primary position determination for multi-position players
- Color coding based on difficulty values

## Algorithm APIs

### 1. Score Projection API (`server/routes/score-projection-routes.ts`)
**Endpoints**:
- `GET /api/score-projection/player/{playerName}?round={round}`
- `GET /api/score-projection/all-players`

**Algorithm Requirements (v3.4.4)**:
- 30% season average weight
- 25% recent form (last 3 games)
- 20% opponent difficulty from DVP data
- 15% position adjustment
- 10% venue/other factors

### 2. Price Prediction API (`server/routes/algorithm-routes.ts`)
**Endpoints**:
- `GET /api/algorithms/price-predictor`
- `GET /api/algorithms/projected-score`

**Formula Requirements**:
- AFL Fantasy price formula: `P_n = (1 - β) * P_{n-1} + M_n - Σ(α_k * S_k)`
- Magic number calculations from player data aggregation

## Data Integration Layer

### 1. File Loading Requirements
**Critical Files Must Exist**:
- `player_data_stats_enhanced_20250720_205845.json` - Primary player database
- `attached_assets/DFS_DVP_Matchup_Tables_FIXED_1753016059835.xlsx` - DVP data
- `attached_assets/afl_fixture_2025_1753111987231.json` - Fixture schedule

### 2. Team Mapping Requirements
**Team Code Standardization**:
```json
{
  "Adelaide": "ADE",
  "Brisbane": "BRL", 
  "Carlton": "CAR",
  "Collingwood": "COL",
  "Essendon": "ESS",
  "Fremantle": "FRE",
  "Geelong": "GEE", 
  "Gold Coast": "GCS",
  "GWS": "GWS",
  "Hawthorn": "HAW",
  "Melbourne": "MEL",
  "North Melbourne": "NTH",
  "Port Adelaide": "POR",
  "Richmond": "RIC",
  "St Kilda": "STK",
  "Sydney": "SYD",
  "West Coast": "WCE",
  "Western Bulldogs": "WBD"
}
```

### 3. Position Mapping Requirements
**Position Standardization**:
- Single positions: "MID", "FWD", "DEF", "RUC"
- Multi-positions: "Mid,Def", "Mid,Fwd", etc.
- Priority for DVP: RUCK > MID > DEF > FWD

## Known Issues That Need Resolution

### 1. Player Modal Fixture Display Bug
**Problem**: All players show `difficulty=5` instead of authentic DVP values
**Root Cause**: Frontend not receiving correct API fixture data
**Required Fix**: Debug React Query cache and team mapping in player modal

### 2. Team Code Inconsistency
**Problem**: Some components expect full team names, others expect 3-letter codes
**Required Fix**: Standardize all components to use 3-letter codes with display name mapping

### 3. Position Handling Inconsistency  
**Problem**: Multi-position players not handled consistently across components
**Required Fix**: Implement standard position priority logic in all components

### 4. Data Refresh Dependencies
**Problem**: Some components cache outdated data
**Required Fix**: Implement proper cache invalidation strategies

## Testing Data Requirements

### Minimum Test Dataset
To verify all components work correctly, you need:
1. **10 players minimum** representing all positions
2. **3 teams minimum** with complete fixture data
3. **DVP data** for all position/team combinations
4. **Complete Round 20-24** projection data

### Validation Checklist
- [ ] All 630 players load correctly
- [ ] All 18 teams have fixture data
- [ ] DVP difficulty values range 0-10 correctly
- [ ] Projected scores show realistic AFL Fantasy values (60-130 points)
- [ ] Team codes map consistently across all components
- [ ] Multi-position players display correctly
- [ ] Difficulty colors show green/yellow/red based on values
- [ ] All API endpoints return expected data formats

## Component Dependencies Summary

```
Dashboard
├── Team Summary → /api/team/data, /api/teams/user/{id}
├── Player Stats → /api/stats/combined-stats, /api/score-projection/all-players
└── Player Modal → /api/stats-tools/stats/team-fixtures/{team}/{pos}, /api/score-projection/player/{name}

Tools
├── Cash Generation → /api/stats/combined-stats, /api/cash/generation-analysis  
├── Captain Selection → /api/captains/analysis, /api/stats-tools/stats/team-fixtures
├── Trade Analysis → /api/stats/combined-stats, /api/score-projection/player
└── DVP Analysis → /api/stats-tools/stats/dvp-enhanced

APIs
├── Score Projection → player_data_stats_enhanced_20250720_205845.json + DVP data
├── Fixture Analysis → afl_fixture_2025_1753111987231.json + DVP Excel
└── Stats Aggregation → All player data sources combined
```

This complete mapping ensures any AI assistant can understand exactly what data each component requires and how it should be formatted.