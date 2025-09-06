# Downgrade Target Finder Data Mapping

## Component: Downgrade Target Finder
**Location**: `client/src/components/tools/cash/downgrade-target-finder.tsx`

## Data Requirements

### API Endpoint
- **Query Key**: `/api/fantasy/tools/cash/downgrade_target_finder`
- **Backend Endpoint**: `/api/cash/downgrade-targets`
- **Method**: GET
- **Response Format**: JSON with downgrade targets array

### Input Data Structure
```typescript
type DowngradeTarget = {
  name: string;        // Player name
  team: string;        // Team abbreviation
  price: number;       // Current player price
  breakeven: number;   // Score needed to maintain price
  l3_avg: number;      // Last 3 games average score
  games: number;       // Games played this season
  position: string;    // Player position
}
```

### Required Authentic Data Sources

#### Player Performance Data
- **Recent Form**: Last 3 games scoring average for current performance assessment
- **Breakeven Analysis**: Score required to maintain current price level
- **Games Played**: Season participation for reliability assessment
- **Source**: AFL Fantasy individual player statistics

#### Pricing Intelligence
- **Current Prices**: Live player pricing from AFL Fantasy
- **Price Stability**: Players with low breakevens indicating price maintenance
- **Value Identification**: Players offering good scoring at lower price points
- **Source**: Official AFL Fantasy pricing data

#### Position Classification
- **Primary Positions**: DEF, MID, RUC, FWD classifications
- **Multi-Position Eligibility**: Players eligible for multiple positions
- **Strategic Value**: Position scarcity and team structure considerations
- **Source**: AFL Fantasy player position data

### Selection Criteria Logic

#### Downgrade Target Identification
1. **Low Breakeven**: Players with manageable score requirements
2. **Consistent Scoring**: Reliable recent performance (L3 average)
3. **Price Point**: Lower cost options for cash generation trades
4. **Playing Time**: Regular selection ensuring ongoing scoring

#### Filtering and Sorting
- **Position Filter**: Filter by specific positions for team structure needs
- **Price Sorting**: Ascending sort to find cheapest reliable options
- **Performance Sorting**: Sort by L3 average or breakeven scores
- **Search Functionality**: Find specific players by name or team

### Missing Data Elements

#### Current Gaps
1. **Role Security**: Information about player role stability and future selection
2. **Injury History**: Player durability and injury risk assessment
3. **Fixture Difficulty**: Upcoming opponent strength analysis
4. **Advanced Metrics**: Ceiling/floor scoring patterns for risk assessment

#### Authentication Requirements
- **AFL Fantasy Access**: Official player pricing and performance data
- **Team Selection Data**: Regular vs fringe player classification
- **Historical Performance**: Long-term reliability assessment

### Frontend Display Features

#### Table Structure
- Player identification (name, team, position)
- Current price with currency formatting
- Breakeven score requirements
- Recent form (L3 average)
- Games played for reliability context

#### Interactive Features
- **Search Bar**: Filter by player name or team
- **Position Filter**: Dropdown for position-specific filtering
- **Column Sorting**: Sort by any metric with direction toggle
- **Price Highlighting**: Visual indicators for value opportunities

#### Visual Indicators
- **Low Breakeven Badges**: Highlight players with easy price maintenance
- **Form Indicators**: Color coding for recent performance levels
- **Value Alerts**: Special highlighting for exceptional downgrade options
- **Games Played**: Reliability indicators based on season participation

### Backend Implementation Status
- **API Endpoint**: Available at `/api/cash/downgrade-targets`
- **Data Processing**: Downgrade target identification algorithms
- **Response Structure**: Formatted JSON with target player data
- **Integration**: Ready for authentic AFL Fantasy player data

### Strategic Use Cases
- **Cash Generation**: Identify cheap players for trade-down strategies
- **Emergency Coverage**: Find reliable bench options
- **Position Flexibility**: Multi-position players for team structure
- **Budget Constraints**: Value options when salary cap limited

### Data Integrity Requirements
- **Authentic Performance**: Only use actual player scoring data
- **Official Pricing**: AFL Fantasy official price information
- **Real Selection Data**: Actual team selection history, not estimates
- **Live Updates**: Current round impact on downgrade viability

### Next Implementation Steps
1. **Player Database Enhancement**: Complete position and role data
2. **Selection Tracking**: Monitor regular vs fringe player status
3. **Advanced Metrics**: Add ceiling/floor and consistency measures
4. **Live Integration**: Real-time price and performance updates