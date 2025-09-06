# Cash Generation Ceiling/Floor Data Mapping

## Component: Cash Gen Ceiling/Floor
**Location**: `client/src/components/tools/cash/cash-gen-ceiling-floor.tsx`

## Data Requirements

### Component Structure
- **Interactive Calculator**: User input-driven price simulation tool
- **Chart Visualization**: Line chart showing price projections under different scenarios
- **Real-time Calculation**: Dynamic price updates based on input parameters

### Input Data Structure
```typescript
interface CeilingFloorInputs {
  player: string;           // Player name (user input)
  currentPrice: number;     // Current AFL Fantasy price
  last3: number[];         // Last 3 round scores array
  ceiling: number;         // Estimated ceiling score
  floor: number;           // Estimated floor score
  magicNumber: number;     // AFL Fantasy price calculation constant (9750)
}
```

### Required Authentic Data Sources

#### Player Performance Data
- **Current Price**: Live AFL Fantasy player pricing
- **Recent Scores**: Actual last 3 round performance data
- **Historical Range**: Authentic ceiling and floor scores from career history
- **Source**: AFL Fantasy individual player statistics

#### Price Calculation Constants
- **Magic Number**: Official AFL Fantasy price change formula (9750)
- **Price Methodology**: 3-round rolling average scoring calculation
- **Rounding Rules**: Standard AFL Fantasy price rounding mechanisms
- **Source**: AFL Fantasy official pricing documentation

### Calculation Logic

#### Price Simulation Algorithm
1. **Score Scenario Creation**: Generate ceiling, floor, and baseline score sequences
2. **Rolling Average**: Calculate 3-round rolling averages for each scenario
3. **Price Application**: Apply magic number formula to determine projected prices
4. **Trend Visualization**: Chart price progression over 3-round periods

#### Scenario Modeling
- **Ceiling Scenario**: Player performs at historical peak consistently
- **Floor Scenario**: Player performs at historical minimum consistently
- **Baseline Scenario**: Player maintains average expected performance
- **Mixed Scenarios**: Combinations of high/low performance periods

### Missing Data Elements

#### Current Gaps
1. **Historical Performance Range**: Need complete career scoring history for accurate ceiling/floor
2. **Position Context**: Ceiling/floor relative to position benchmarks
3. **Matchup Impact**: Opponent difficulty affecting realistic score ranges
4. **Injury Considerations**: Impact on performance ceiling assessment

#### Authentication Requirements
- **AFL Fantasy Access**: Official player pricing and scoring history
- **Career Statistics**: Multi-season performance data for range establishment
- **Live Updates**: Current round impact on price projections

### Frontend Display Features

#### Interactive Controls
- **Player Name Input**: Text field for player selection
- **Current Price Slider**: Adjustable price input with currency formatting
- **Score Arrays**: Editable last 3 scores with individual inputs
- **Ceiling/Floor Sliders**: Adjustable performance range parameters

#### Visualization Components
- **Line Chart**: Multi-line chart showing ceiling, floor, and baseline price projections
- **Price Range**: Visual representation of potential price movement span
- **Scenario Labels**: Clear identification of optimistic, pessimistic, and realistic outcomes
- **Interactive Tooltips**: Detailed information on hover for each data point

### Chart Configuration
- **X-Axis**: Round progression (Round 1, Round 2, Round 3)
- **Y-Axis**: Projected price values with currency formatting
- **Multiple Lines**: Ceiling (green), Floor (red), Baseline (blue) scenarios
- **Fill Areas**: Shaded regions between ceiling and floor for range visualization

### Backend Integration Status
- **Frontend Component**: Complete interactive calculator
- **Price Logic**: AFL Fantasy price calculation implemented
- **Chart Library**: React Chart.js integration functional
- **Data Requirements**: Needs authentic player performance data integration

### Data Integrity Requirements
- **Authentic Prices**: Only use official AFL Fantasy current prices
- **Real Performance**: Actual player scoring history for ceiling/floor establishment
- **Official Formula**: Verified AFL Fantasy price calculation methodology
- **Live Accuracy**: Current round performance integration for projections

### Strategic Use Cases
- **Trade Planning**: Assess potential price movement range for trade timing
- **Risk Assessment**: Understand downside and upside price scenarios
- **Cash Management**: Plan cash generation with realistic price expectations
- **Player Evaluation**: Compare potential price growth across different players

### Next Implementation Steps
1. **Player Database Integration**: Connect to authentic player performance data
2. **Historical Analysis**: Build ceiling/floor from actual career statistics
3. **Live Price Updates**: Real-time current price integration
4. **Enhanced Scenarios**: Add matchup and context-aware projections