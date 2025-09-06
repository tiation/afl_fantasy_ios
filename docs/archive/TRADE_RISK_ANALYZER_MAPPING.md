# Trade Risk Analyzer Data Mapping

## Component: Trade Risk Analyzer
**Location**: `client/src/components/tools/trade/trade-risk-analyzer.tsx`

## Data Requirements

### Component Structure
- **Interactive Risk Calculator**: User input-driven risk assessment tool
- **Real-time Metrics**: Dynamic risk calculations based on team status
- **Visual Risk Indicators**: Progress bars and color-coded risk levels

### Input Data Structure
```typescript
interface TradeRiskInputs {
  tradesUsed: number[];      // Trades used per round (slider input)
  injuryRisk: number[];      // Team injury risk level (1-5 scale)
  benchCoverage: number[];   // Bench coverage adequacy (1-10 scale)
  totalTrades: number;       // Remaining trades available
  roundsRemaining: number;   // Rounds left in season
}
```

### Required Authentic Data Sources

#### User Trade History
- **Trades Remaining**: Official AFL Fantasy trade count from user account
- **Trade History**: Round-by-round trade usage patterns
- **Season Progress**: Current round and remaining fixtures
- **Source**: AFL Fantasy user account data

#### Team Risk Assessment
- **Injury Intelligence**: Current player injury status and likelihood
- **Player Availability**: Red dot status and late-out risks
- **Bench Strength**: Emergency player coverage analysis
- **Source**: AFL Fantasy team data + injury intelligence feeds

#### League Context
- **Average Trade Usage**: League-wide trade utilization patterns
- **Seasonal Trends**: Historical trade timing and effectiveness
- **Risk Benchmarks**: Comparative risk assessment standards
- **Source**: AFL Fantasy league statistics

### Calculation Logic

#### Risk Metrics Calculation
1. **Trade Burn Rate**: Percentage of total trades used per round
2. **Trade Utilization**: Percentage of season trades already consumed
3. **Trade Flexibility**: Available trades per remaining round
4. **Injury Risk Factor**: Team vulnerability to player unavailability
5. **Overall Risk Score**: Weighted combination scaled 0-100

#### Risk Categories
- **0-20**: Very Low Risk - Conservative trade management
- **21-40**: Low Risk - Sustainable trade usage
- **41-60**: Medium Risk - Balanced approach
- **61-80**: High Risk - Aggressive trade strategy
- **81-100**: Very High Risk - Unsustainable patterns

### Missing Data Elements

#### Current Gaps
1. **Official Trade Count**: Need AFL Fantasy account integration for actual trade data
2. **Injury Intelligence**: Real-time player availability and risk assessment
3. **Historical Patterns**: User's past trade success/failure analysis
4. **League Benchmarks**: Comparative risk assessment against other teams

#### Authentication Requirements
- **AFL Fantasy Access**: Official trade count and team composition
- **Injury Feeds**: Professional injury reporting and availability data
- **Historical Data**: Multi-season trade effectiveness tracking

### Frontend Display Features

#### Interactive Controls
- **Trade Usage Slider**: Adjust trades used per round for scenario modeling
- **Injury Risk Slider**: Set team injury vulnerability level
- **Bench Coverage Slider**: Assess emergency player adequacy
- **Trade Count Input**: Manual override for remaining trades

#### Visual Risk Indicators
- **Risk Score Display**: Large prominent risk percentage
- **Progress Bars**: Visual representation of risk metrics
- **Color Coding**: Green/yellow/red risk level indication
- **Risk Category Labels**: Clear risk level descriptions

#### Metric Breakdown
- **Burn Rate**: Trade usage velocity analysis
- **Utilization Rate**: Season trade consumption tracking
- **Flexibility Score**: Trade availability per round
- **Comparative Analysis**: Risk relative to league averages

### Backend Integration Requirements
- **Trade Tracking**: Integration with AFL Fantasy trade history
- **Risk Algorithms**: Sophisticated risk calculation engines
- **League Data**: Comparative risk assessment capabilities
- **Live Updates**: Real-time risk adjustment based on current events

### Data Integrity Requirements
- **Authentic Trade Data**: Only use official AFL Fantasy trade information
- **Real Injury Status**: Verified player availability information
- **Official League Stats**: Authentic comparative benchmarks
- **Live Accuracy**: Current round and season progress integration

### Strategic Use Cases
- **Trade Planning**: Assess risk before executing trades
- **Season Management**: Monitor trade usage sustainability
- **Risk Mitigation**: Identify and address high-risk scenarios
- **Comparative Analysis**: Benchmark against successful trade strategies

### Next Implementation Steps
1. **AFL Fantasy Integration**: Connect to official trade count data
2. **Injury Intelligence**: Integrate professional injury reporting feeds
3. **Historical Analysis**: Build trade effectiveness tracking database
4. **Live Risk Monitoring**: Real-time risk adjustment capabilities