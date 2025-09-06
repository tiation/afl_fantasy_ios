# Stats and Tools Tab Data Mapping

## Overview
This document maps the exact data requirements for each component in the Stats and Tools tabs, specifying the data sources, API endpoints, and data structures needed.

## Stats Tab Components

### 1. Player Performance Matrix
**Purpose**: Shows individual player stats across multiple rounds
**Data Requirements**:
- Player basic info (name, team, position, price)
- Round-by-round scores (R1-R7+)
- Average scores (season, last 3 rounds)
- Breakeven values
- Price changes

**Current Data Sources**:
- `player_data.json` - Contains base player data
- User team data from `/api/teams/user/:id`
- Performance data from `/api/teams/:id/performances`

**Missing Data Elements**:
- Individual round scores for each player
- Detailed match statistics (kicks, marks, tackles, etc.)
- Opponent team for each round
- Venue information

### 2. Team Structure Analysis
**Purpose**: Breakdown of team composition by position and price tiers
**Data Requirements**:
- Player positions (DEF, MID, RUC, FWD)
- Player prices grouped into tiers (Premium $600k+, Mid-price $400-600k, Rookie <$400k)
- Salary cap usage and remaining budget
- Position balance ratios

**Current Data Sources**:
- User team composition from `/api/teams/user/:id`
- Player price data from `player_data.json`

### 3. DVP (Defense vs Position) Matrix
**Purpose**: Shows how teams defend against each position
**Data Requirements**:
- Team defensive rankings by position (DEF, MID, RUC, FWD)
- Points conceded averages
- Recent form (last 3 rounds)
- Season averages

**Current Data Sources**:
- `dvp_matrix.json` - Pre-scraped DVP data
- DVP scraper from `dvp_matrix_scraper.py`

### 4. Fixture Analysis
**Purpose**: Upcoming match difficulty and player schedules
**Data Requirements**:
- Fixture data (teams, venues, dates)
- Opponent strength ratings
- Player availability status
- Bye round scheduling

**Current Data Sources**:
- Fixture tools from `fixture_tools.py`
- Team schedule data

## Tools Tab Components

### 1. Captain Selection Tools
**Purpose**: AI-powered captain recommendations
**Data Requirements**:
- Player form analysis (L3 average scores)
- Matchup favorability ratings
- Opponent DVP data
- Player ownership percentages
- Loophole opportunities (player schedules)

**Current API Endpoints**:
- `/api/captain/score-predictor` - Top 5 captain candidates
- `/api/captain/vice-optimizer` - VC/C combinations
- `/api/captain/loophole-detector` - Schedule-based opportunities
- `/api/captain/form-analyzer` - Multi-timeframe form analysis
- `/api/captain/matchup-advisor` - Opponent-based recommendations

### 2. Trade Analysis Tools
**Purpose**: Trade recommendations and impact analysis
**Data Requirements**:
- Player price trends and predictions
- Breakeven calculations
- Cash generation potential
- Trade target identification
- Team balance optimization

**Current API Endpoints**:
- `/api/cash/generation-tracker` - Price change estimates
- `/api/cash/rookie-curve` - Rookie price projections
- `/api/cash/downgrade-targets` - Low breakeven players
- `/api/cash/ceiling-floor` - Price range estimates
- `/api/cash/price-predictor` - Future price calculations

### 3. Risk Management Tools
**Purpose**: Identify and manage team risks
**Data Requirements**:
- Player injury status and history
- Ownership risk analysis
- Price volatility metrics
- Performance consistency ratings
- Late-season form patterns

**Current API Endpoints**:
- `/api/risk/*` - Risk analysis tools (multiple endpoints)
- Context tools for seasonal patterns

### 4. AI Strategy Tools
**Purpose**: Advanced AI-powered insights
**Data Requirements**:
- Multi-factor player analysis
- Team structure optimization
- Market efficiency identification
- Contrarian play opportunities
- Long-term strategy planning

**Current API Endpoints**:
- `/api/ai/*` - AI analysis tools
- Integration with all player and team data

## Data Integration Requirements

### Priority 1: Complete Player Statistics
**Need**: Individual player round-by-round scores and detailed match statistics
**Solution**: 
- Enhance existing data scrapers to capture more detailed stats
- Integrate with AFL Fantasy official data when authentication is resolved
- Store historical performance data in database

### Priority 2: Real-time Pricing Data
**Need**: Live player prices and breakeven calculations
**Solution**:
- Automated price scraping from AFL Fantasy
- Real-time breakeven calculations based on recent scores
- Price prediction algorithms

### Priority 3: Enhanced DVP and Fixture Data
**Need**: More detailed opponent analysis and fixture information
**Solution**:
- Expand DVP matrix to include more metrics
- Integrate fixture data with difficulty ratings
- Add venue and weather considerations

### Priority 4: Advanced Analytics Integration
**Need**: Sophisticated statistical analysis and AI insights
**Solution**:
- Machine learning models for player performance prediction
- Advanced team optimization algorithms
- Market trend analysis

## Implementation Status

### ✅ Completed
- Basic player data structure
- Captain selection tool APIs
- Cash generation tool APIs
- User team management
- DVP matrix data structure

### 🚧 In Progress
- Champion Data API integration
- Real-time data synchronization
- Advanced statistical calculations

### 📋 Planned
- Individual player round scores
- Enhanced fixture analysis
- Advanced AI recommendations
- Risk management improvements
- Performance prediction models

## Data Source Priority

1. **AFL Fantasy Official API** (when authentication resolved)
   - Live player prices
   - Official team compositions
   - Round-by-round scores

2. **Champion Data Sports API** (when authentication resolved)
   - Detailed match statistics
   - Advanced player metrics
   - Historical performance data

3. **Existing Scraped Data**
   - DVP matrix
   - Basic player information
   - Team structures

4. **User Input Data**
   - Team compositions
   - Personal preferences
   - Strategy settings