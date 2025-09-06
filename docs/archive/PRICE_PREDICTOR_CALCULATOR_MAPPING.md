# Price Predictor Calculator Data Mapping

## Component: Price Predictor Calculator
**Location**: `client/src/components/tools/cash/price-predictor-calculator.tsx`

## Data Requirements

### API Integration
- **Service Call**: `calculatePricePredictor()` from cashService
- **Player Data**: `fetchPlayerData()` for player selection
- **Backend Endpoint**: `/api/cash/price-predictor`
- **Method**: POST with player and score parameters

### Input Data Structure
```typescript
type Player = {
  name: string;        // Player name
  team: string;        // Team abbreviation
  price: number;       // Current AFL Fantasy price
  breakeven: number;   // Current breakeven score
  position: string;    // Player position
  l3_avg: number;      // Last 3 games average
  avg: number;         // Season average
  games: number;       // Games played
}

type PricePrediction = {
  player: string;              // Player name
  starting_price: number;      // Current price
  starting_breakeven: number;  // Current breakeven
  price_changes: {
    round: number;            // Round number
    score: number;            // Projected score
    price_change: number;     // Price change amount
    new_price: number;        // Updated price
  }[];
  final_price: number;        // Final projected price
}
```

### Required Authentic Data Sources

#### Player Database
- **Complete Player List**: All AFL Fantasy players with current statistics
- **Live Pricing**: Official AFL Fantasy current prices and breakevens
- **Performance Data**: Recent form and season averages
- **Source**: AFL Fantasy official player database

#### Price Calculation Engine
- **AFL Fantasy Formula**: Official price change calculation methodology
- **Magic Number**: Price calculation constant (9750)
- **Rolling Averages**: 3-round average scoring calculations
- **Source**: AFL Fantasy pricing documentation

#### Score Projection Input
- **User-Defined Scores**: Manual input of projected future scores
- **Realistic Ranges**: Historical performance bounds for validation
- **Multiple Round Planning**: Support for 3-5 round projections
- **Source**: User input with historical validation

### Calculation Logic

#### Price Prediction Algorithm
1. **Starting Position**: Current price and breakeven as baseline
2. **Score Input**: User-provided projected scores for future rounds
3. **Price Calculation**: Apply AFL Fantasy formula for each round
4. **Cumulative Effect**: Track price changes round by round
5. **Final Projection**: Calculate total price movement over period

#### Round-by-Round Processing
- **Score Application**: Use projected score for round calculation
- **Breakeven Update**: Recalculate breakeven after each price change
- **Price Adjustment**: Apply rounding and minimum price rules
- **Chain Effect**: Each round affects subsequent calculations

### Missing Data Elements

#### Current Gaps
1. **Historical Validation**: Player performance ranges for realistic score validation
2. **Contextual Factors**: Opponent difficulty and venue impacts on projections
3. **Injury Intelligence**: Risk factors affecting score projections
4. **Advanced Scenarios**: Multiple projection scenarios (optimistic/pessimistic)

#### Authentication Requirements
- **AFL Fantasy Access**: Official player pricing and statistics
- **Live Updates**: Current round impact on starting positions
- **Historical Data**: Performance validation ranges

### Frontend Display Features

#### Player Selection Interface
- **Search Functionality**: Filter players by name or team
- **Player Details**: Display current price, breakeven, and recent form
- **Position Filtering**: Filter by player positions
- **Quick Select**: Recently viewed or bookmarked players

#### Projection Input
- **Score Input Fields**: Manual entry for projected scores (Round 1-5)
- **Historical Context**: Show player's typical scoring range
- **Validation**: Warn for unrealistic score projections
- **Preset Scenarios**: Quick selection of conservative/aggressive projections

#### Results Visualization
- **Round-by-Round Table**: Show score, price change, and new price for each round
- **Summary Cards**: Starting price, final price, and total movement
- **Trend Indicators**: Visual cues for price increases/decreases
- **Export Options**: Save projections for reference

### Backend Implementation Status
- **API Endpoint**: Available at `/api/cash/price-predictor`
- **Calculation Engine**: Price prediction algorithms implemented
- **Player Database**: Integration ready for authentic player data
- **Response Format**: Structured JSON with detailed price progression

### Strategic Use Cases
- **Trade Planning**: Calculate exact price outcomes before executing trades
- **Cash Management**: Plan cash generation with specific price targets
- **Timing Analysis**: Determine optimal trade timing based on price projections
- **Risk Assessment**: Evaluate price volatility and potential outcomes

### Data Integrity Requirements
- **Authentic Pricing**: Only use official AFL Fantasy current prices
- **Real Performance**: Historical performance for projection validation
- **Official Formula**: Verified AFL Fantasy price calculation methodology
- **Live Accuracy**: Current round performance integration

### Next Implementation Steps
1. **Player Database Integration**: Connect to authentic AFL Fantasy player data
2. **Historical Validation**: Add performance range checking for realistic projections
3. **Live Price Updates**: Real-time current price and breakeven integration
4. **Enhanced Scenarios**: Multiple projection scenarios with confidence levels