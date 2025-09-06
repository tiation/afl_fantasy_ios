# Rookie Price Curve Model Data Mapping

## Component: Rookie Price Curve
**Location**: `client/src/components/tools/cash/rookie-price-curve.tsx`

## Data Requirements

### API Endpoint
- **Query Key**: `/api/fantasy/tools/cash/rookie_price_curve_model`
- **Backend Endpoint**: `/api/cash/rookie-curve`
- **Method**: GET
- **Response Format**: JSON with rookies array

### Input Data Structure
```typescript
type RookieProjection = {
  player: string;                  // Rookie player name
  price: number;                  // Current player price
  l3_avg: number;                 // Last 3 games average score
  price_projection_next_3: number; // Projected price after next 3 rounds
}
```

### Required Authentic Data Sources

#### Rookie Player Identification
- **Price Threshold**: Players under $400,000 typically classified as rookies
- **Experience Level**: First or second year players
- **Playing Status**: Regular senior team selection
- **Source**: AFL Fantasy player database with debut year information

#### Performance Tracking
- **Recent Scores**: Last 3 round performance for trend analysis
- **Breakeven Analysis**: Score required to maintain/increase price
- **Seasonal Progression**: Round-by-round improvement patterns
- **Source**: Individual player scoring history from AFL Fantasy

#### Price Projection Modeling
- **Growth Curve Analysis**: Historical rookie price progression patterns
- **Performance Sustainability**: Likelihood of continued improvement
- **Market Correction**: Price adjustment timing and magnitude
- **Peak Price Estimation**: Maximum expected value for each rookie

### Calculation Logic

#### Price Projection Formula
1. **Recent Form Weight**: Last 3 games heavily weighted in projections
2. **Improvement Rate**: Calculate rate of scoring increase over time
3. **Price Change Mechanism**: Apply AFL Fantasy price change formula
4. **Curve Modeling**: Project future price based on historical rookie patterns

#### Projected Gain Calculation
- **Current Price**: Starting point for gain calculation
- **Projected Price**: Expected price after 3 rounds
- **Percentage Gain**: (Projected - Current) / Current × 100
- **Cash Generation**: Absolute dollar increase potential

### Missing Data Elements

#### Current Gaps
1. **Individual Round Scores**: Complete scoring history needed for accurate projections
2. **Debut Information**: Player experience level and career trajectory
3. **Playing Time Trends**: Minutes played and role development
4. **Historical Rookie Data**: Past rookie price curves for model validation

#### Authentication Requirements
- **AFL Fantasy Access**: Official rookie pricing and performance data
- **Player Career Data**: Debut years and experience tracking
- **Live Performance**: Real-time scoring impact on projections

### Frontend Display Features

#### Table Structure
- Player name with rookie identification
- Current price with currency formatting
- Last 3 games average performance
- Projected price after 3 rounds
- Calculated projected gain (derived field)

#### Interactive Features
- **Search Functionality**: Filter rookies by player name
- **Column Sorting**: Sort by any metric (player, price, average, projection, gain)
- **Sort Direction**: Ascending/descending toggle for each column
- **Visual Indicators**: Trend arrows for price movement direction

#### Visual Elements
- **Price Trend Icons**: Up/down arrows for projected movements
- **Gain Highlighting**: Color coding for high/low gain potential
- **Performance Context**: Visual cues for form and sustainability
- **Rookie Badges**: Clear identification of rookie status

### Backend Implementation Status
- **API Endpoint**: Available at `/api/cash/rookie-curve`
- **Data Processing**: Rookie identification and projection algorithms
- **Response Structure**: Formatted JSON with projection data
- **Integration**: Ready for authentic AFL Fantasy rookie data

### Rookie Classification Criteria
- **Price Range**: Typically under $400,000 at season start
- **Experience**: First or second year AFL players
- **Opportunity**: Regular senior team selection
- **Potential**: Demonstrated scoring ability and role security

### Data Integrity Requirements
- **Authentic Performance**: Only use actual rookie scoring data
- **Official Pricing**: AFL Fantasy official price information
- **Real Projections**: Mathematical models based on historical patterns
- **No Estimates**: Clear error states when projection data unavailable

### Next Implementation Steps
1. **Rookie Database**: Build comprehensive rookie player identification system
2. **Historical Modeling**: Analyze past rookie price curve patterns
3. **Performance Tracking**: Individual round score integration
4. **Live Updates**: Real-time projection adjustments during rounds