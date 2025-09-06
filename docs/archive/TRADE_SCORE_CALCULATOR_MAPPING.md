# Trade Score Calculator Data Mapping

## Component: Trade Score Calculator
**Location**: `client/src/components/tools/trade/trade-score-calculator.tsx`

## Data Requirements

### API Integration
- **Backend Endpoint**: `/api/fantasy/tools/trade_score_calculator`
- **Method**: POST
- **Service**: Trade scoring algorithm with comprehensive analysis

### Input Data Structure
```typescript
interface TradeCalculationInput {
  player_in: {
    name: string;
    price: number;
    breakeven: number;
    projectedScore: number;
    projectedScores: number[];   // Future round projections
  };
  player_out: {
    name: string;
    price: number;
    breakeven: number;
    projectedScore: number;
    projectedScores: number[];   // Future round projections
  };
  round_number: number;          // Current AFL round
  team_value: number;           // User's current team value
  league_avg_value: number;     // League average team value
}
```

### Required Authentic Data Sources

#### Player Performance Data
- **Current Prices**: Live AFL Fantasy pricing for both players
- **Breakeven Scores**: Official breakeven calculations from AFL Fantasy
- **Projected Scores**: Using v3.4.4 algorithm for realistic projections
- **Source**: AFL Fantasy official data + projection algorithms

#### Team Context Data
- **User Team Value**: Authentic current team value from database
- **League Averages**: Real league average team values
- **Round Information**: Current AFL round number
- **Source**: User team database + league statistics

#### Trade Analysis Requirements
- **Price Impact**: Immediate cost/savings of trade
- **Scoring Impact**: Points difference analysis over multiple rounds
- **Cash Generation**: Price change projections using authentic formulas
- **Risk Assessment**: Player classification and peaked player detection

### Calculation Components

#### Trade Score Algorithm
1. **Scoring Analysis**: Compare projected points over 5-round period
2. **Cash Analysis**: Price change projections using breakeven formulas
3. **Round Weighting**: Adjust scoring vs cash importance by round
4. **Team Value Context**: Factor user's team value vs league average
5. **Overall Score**: Weighted combination scaled to 0-100 range

#### Risk Factors
- **Player Classification**: Premium, mid-price, rookie categories
- **Peaked Analysis**: Players performing below breakeven consistently
- **Injury Risk**: Red dot status and availability concerns
- **Upgrade/Downgrade Path**: Strategic trade direction assessment

### Missing Data Elements

#### Current Gaps
1. **Player Search Interface**: Selection mechanism for trade participants
2. **Live Player Data**: Real-time pricing and projection integration
3. **Historical Validation**: Trade outcome tracking for algorithm improvement
4. **Advanced Context**: Fixture difficulty and opponent analysis

#### Authentication Requirements
- **AFL Fantasy Access**: Official player pricing and statistics
- **Team Data**: User's actual team composition and value
- **League Data**: Real league averages and benchmarks

### Frontend Display Features

#### Input Interface
- **Player Selection**: Search and select players for trade analysis
- **Auto-Population**: Fetch current prices and breakevens automatically
- **Projection Input**: Override projected scores if desired
- **Context Settings**: Round number and team value validation

#### Results Display
- **Trade Score**: Primary 0-100 recommendation score
- **Score Breakdown**: Detailed analysis of scoring vs cash components
- **Price Projections**: Round-by-round price change forecasts
- **Risk Flags**: Warnings about peaked players or risky trades
- **Recommendation**: Clear guidance on trade viability

### Backend Implementation Status
- **API Endpoint**: Available with comprehensive trade analysis
- **Calculation Engine**: Advanced scoring algorithm implemented
- **Response Format**: Detailed JSON with all analysis components
- **Integration**: Ready for authentic player and team data

### Data Integrity Requirements
- **Authentic Pricing**: Only use official AFL Fantasy current prices
- **Real Projections**: Score projections using validated algorithms
- **Official Formulas**: Verified AFL Fantasy price calculation methods
- **Live Context**: Current round and team value accuracy

### Strategic Use Cases
- **Trade Evaluation**: Comprehensive analysis before executing trades
- **Timing Optimization**: Determine best round for specific trades
- **Risk Management**: Identify and avoid problematic trades
- **Strategic Planning**: Long-term team building guidance

### Next Implementation Steps
1. **Player Search Integration**: Build player selection interface
2. **Live Data Connection**: Integrate authentic AFL Fantasy data
3. **Algorithm Enhancement**: Refine trade scoring based on real outcomes
4. **User Interface**: Complete interactive trade analysis interface