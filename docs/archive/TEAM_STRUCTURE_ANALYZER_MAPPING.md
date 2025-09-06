# Team Structure Analyzer Data Mapping

## Component: Team Structure Analyzer
**Location**: `client/src/components/tools/ai/team-structure-analyzer.tsx`

## Data Requirements

### API Integration
- **Backend Endpoint**: `/api/fantasy/tools/ai/team_structure_analyzer`
- **Method**: GET
- **Service**: AI-powered team composition analysis

### Input Data Structure
```typescript
type TeamStructure = {
  rookies: number;      // Count of rookie-priced players
  mid_pricers: number;  // Count of mid-price players
  premiums: number;     // Count of premium-priced players
}
```

### Required Authentic Data Sources

#### User Team Composition
- **Complete Squad**: All 26 players from user's AFL Fantasy team
- **Player Prices**: Current AFL Fantasy pricing for each player
- **Price Classifications**: Rookie (<$400k), Mid-price ($400-600k), Premium ($600k+)
- **Source**: User's authenticated AFL Fantasy team data

#### Position Analysis
- **Position Distribution**: DEF/MID/RUC/FWD breakdown by price tier
- **Structural Balance**: Optimal vs current team composition
- **Strategic Recommendations**: Suggested improvements for team structure
- **Source**: Team composition analysis algorithms

#### Market Context
- **League Averages**: Typical team structure distributions
- **Successful Patterns**: High-performing team composition models
- **Price Tier Performance**: Historical effectiveness by price category
- **Source**: AFL Fantasy league statistics and historical data

### Analysis Logic

#### Price Tier Classification
1. **Rookies**: Players priced under $400,000 (typically first/second year players)
2. **Mid-Pricers**: Players priced $400,000-$600,000 (established but not premium)
3. **Premiums**: Players priced over $600,000 (elite performers)

#### Structure Assessment
1. **Balance Analysis**: Evaluate distribution across price tiers
2. **Risk Assessment**: Concentration risk in specific price brackets
3. **Flexibility Analysis**: Team's ability to make strategic upgrades
4. **Performance Potential**: Scoring capacity by structure type

### Missing Data Elements

#### Current Gaps
1. **Position-Specific Analysis**: Structure breakdown by DEF/MID/RUC/FWD
2. **Performance Correlation**: Link between structure and team scoring
3. **Upgrade Pathways**: Specific recommendations for structure improvement
4. **Comparative Analysis**: Structure vs high-performing teams

#### Authentication Requirements
- **AFL Fantasy Access**: Complete user team composition
- **Historical Data**: Multi-season structural performance analysis
- **League Benchmarks**: Comparative structural analysis

### Frontend Display Features

#### Pie Chart Visualization
- **Color-Coded Segments**: Green (rookies), Blue (mid-pricers), Purple (premiums)
- **Interactive Tooltips**: Detailed breakdown on hover
- **Legend**: Clear identification of each price tier
- **Responsive Design**: Chart adapts to container size

#### Structural Metrics
- **Tier Counts**: Numerical display of players in each category
- **Balance Score**: Overall structural health rating
- **Risk Indicators**: Warnings for structural imbalances
- **Recommendations**: AI-generated improvement suggestions

### Backend Implementation Status
- **API Endpoint**: Available with team structure analysis
- **Classification Logic**: Price tier categorization implemented
- **Visualization Data**: Formatted for pie chart display
- **Integration**: Ready for authentic team composition data

### Data Integrity Requirements
- **Authentic Team Data**: Only use official AFL Fantasy team composition
- **Real Pricing**: Current AFL Fantasy player prices
- **Official Classifications**: Verified price tier boundaries
- **Live Updates**: Current team structure based on latest data

### Strategic Use Cases
- **Team Balance Assessment**: Evaluate current structural health
- **Upgrade Planning**: Identify structural improvement opportunities
- **Risk Management**: Avoid excessive concentration in single price tier
- **Comparative Analysis**: Benchmark against successful team structures

### Next Implementation Steps
1. **Complete Team Integration**: Connect to user's full 26-player squad
2. **Position Breakdown**: Add structural analysis by playing position
3. **Performance Correlation**: Link structure to historical team success
4. **Enhanced Recommendations**: AI-powered structural optimization guidance