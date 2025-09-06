# Cash Generation Tracker Data Mapping

## Component: Cash Generation Tracker
**Location**: `client/src/components/tools/cash/cash-generation-tracker.tsx`

## Data Requirements

### API Endpoint
- **Query Key**: `/api/fantasy/tools/cash_generation_tracker`
- **Backend Endpoint**: `/api/cash/generation-tracker`
- **Method**: GET
- **Response Format**: JSON with players array

### Input Data Structure
```typescript
type CashGenPlayer = {
  player: string;          // Player name
  team: string;           // Team abbreviation
  price: number;          // Current player price
  breakeven: number;      // Breakeven score for price maintenance
  "3_game_avg": number;   // Last 3 games average score
  price_change_est: number; // Estimated price change
}
```

### Required Authentic Data Sources

#### Player Pricing Data
- **Current Prices**: Live AFL Fantasy player prices
- **Price History**: Historical price movements for trend analysis
- **Breakeven Calculations**: Score needed to maintain current price
- **Source**: AFL Fantasy official pricing data

#### Performance Metrics
- **Last 3 Game Average**: Recent scoring form for cash generation assessment
- **Season Averages**: Baseline performance comparison
- **Scoring Trends**: Performance direction indicators
- **Source**: Individual player round scores from AFL Fantasy

#### Price Change Calculations
- **Magic Number**: AFL Fantasy price change formula (typically 9750)
- **Score vs Breakeven**: Performance above/below breakeven threshold
- **Price Change Estimation**: Projected price movements based on form
- **Formula**: (Average Score - Breakeven) × (Magic Number / 100)

### Calculation Logic

#### Price Change Estimation
1. **Performance Analysis**: Compare recent scores to breakeven
2. **Trend Weighting**: Emphasize recent form over season averages
3. **Price Movement Prediction**: Calculate expected price changes
4. **Cash Generation Potential**: Identify players likely to increase in value

#### Filtering and Sorting
- **Search Functionality**: Filter by player name or team
- **Position Filtering**: Filter by player positions (when position data available)
- **Sorting Options**: Sort by price change estimate, breakeven, price
- **Direction Control**: Ascending/descending sort capabilities

### Missing Data Elements

#### Current Gaps
1. **Player Positions**: Position data not included in current structure
2. **Historical Price Movements**: Track actual vs predicted price changes
3. **Injury Intelligence**: Factor injury risk into cash generation assessment
4. **Ownership Percentages**: Popular vs differential player identification

#### Authentication Requirements
- **AFL Fantasy Access**: Live pricing and breakeven data
- **Historical Performance**: Round-by-round scoring records
- **Real-Time Updates**: Current round performance impact on prices

### Frontend Display Features

#### Table Structure
- Player identification (name, team)
- Current price with currency formatting
- Breakeven score requirements
- Recent form (3-game average)
- Estimated price change with trend indicators

#### Interactive Features
- **Search Bar**: Real-time filtering by player/team name
- **Column Sorting**: Click headers to sort by different metrics
- **Position Filter**: Dropdown for position-based filtering
- **Price Change Indicators**: Visual cues for positive/negative changes
- **Tooltips**: Explanatory information for metrics

#### Visual Indicators
- **Trend Icons**: Up/down arrows for price change direction
- **Color Coding**: Green for price increases, red for decreases
- **Currency Formatting**: Proper price display with thousand separators
- **Badge Systems**: Highlight high cash generation potential

### Backend Implementation Status
- **API Endpoint**: Available at `/api/cash/generation-tracker`
- **Data Processing**: Price change calculation algorithms implemented
- **Response Structure**: Formatted JSON with player cash generation data
- **Integration**: Ready for authentic AFL Fantasy pricing data

### Data Integrity Requirements
- **Authentic Pricing**: Only use official AFL Fantasy price data
- **Real Performance**: Actual player scores, not estimated values
- **Live Updates**: Current round impact on price projections
- **No Synthetic Data**: Clear error states when authentic data unavailable

### Next Implementation Steps
1. **AFL Fantasy Integration**: Connect to official pricing API
2. **Historical Data**: Build price movement tracking database
3. **Enhanced Metrics**: Add position data and injury intelligence
4. **Real-Time Processing**: Live price change calculations during rounds