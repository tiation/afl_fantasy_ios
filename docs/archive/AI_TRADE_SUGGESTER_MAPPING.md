# AI Trade Suggester Data Mapping

## Component: AI Trade Suggester
**Location**: `client/src/components/tools/ai/ai-trade-suggester.tsx`

## Data Requirements

### API Integration
- **Backend Endpoint**: `/api/fantasy/tools/ai/ai_trade_suggester`
- **Method**: GET
- **Service**: AI-powered trade recommendation engine

### Input Data Structure
```typescript
type TradeSuggestion = {
  downgrade_out: {
    name: string;        // Player to trade out
    team: string;        // Team abbreviation
    position: string;    // Player position
    price: number;       // Current price
    breakeven: number;   // Breakeven score
    average: number;     // Season average
  };
  upgrade_in: {
    name: string;        // Player to trade in
    team: string;        // Team abbreviation
    position: string;    // Player position
    price: number;       // Current price
    breakeven: number;   // Breakeven score
    average: number;     // Season average
  };
}
```

### Required Authentic Data Sources

#### User Team Analysis
- **Current Team Composition**: User's actual 26-player squad
- **Team Weaknesses**: Positions requiring improvement
- **Price Distribution**: Current team value allocation
- **Source**: User's authenticated AFL Fantasy team data

#### Market Intelligence
- **Player Performance**: Season averages and recent form
- **Price Movements**: Historical and projected price changes
- **Value Opportunities**: Underpriced performers relative to output
- **Source**: AFL Fantasy official statistics and DFS Australia data

#### AI Recommendation Engine
- **Performance Analytics**: Statistical analysis of player output
- **Value Assessment**: Price vs performance optimization
- **Strategic Planning**: Long-term team building considerations
- **Risk Evaluation**: Injury and form sustainability analysis

### Analysis Logic

#### Downgrade Target Identification
1. **Underperforming Assets**: Players scoring below their price point
2. **Cash Generation**: Players with favorable price change potential
3. **Strategic Exits**: Players with upcoming difficult fixtures
4. **Risk Mitigation**: Players with injury or form concerns

#### Upgrade Target Selection
1. **Value Opportunities**: Underpriced players with strong form
2. **Performance Upgrade**: Players likely to outscore current options
3. **Price Stability**: Players with sustainable scoring and pricing
4. **Strategic Fit**: Players addressing team structural needs

### Missing Data Elements

#### Current Gaps
1. **Complete User Team**: Full 26-player squad for comprehensive analysis
2. **Historical Performance**: Multi-season data for trend identification
3. **Fixture Intelligence**: Upcoming opponent difficulty analysis
4. **Injury Intelligence**: Real-time player availability assessment

#### Authentication Requirements
- **AFL Fantasy Access**: User's complete team composition and trade history
- **Performance Database**: Comprehensive player statistics
- **Market Data**: Live pricing and breakeven information

### Frontend Display Features

#### Trade Suggestion Card
- **Player Out Section**: Current player details with performance metrics
- **Trade Arrow**: Visual indication of trade direction
- **Player In Section**: Target player details with upgrade rationale
- **Action Buttons**: Refresh suggestion and analysis options

#### Performance Comparison
- **Price Differential**: Cost/savings of proposed trade
- **Performance Metrics**: Average scores and recent form comparison
- **Breakeven Analysis**: Price maintenance requirements
- **Value Assessment**: Performance per dollar analysis

### Backend Implementation Status
- **API Endpoint**: Available with AI recommendation logic
- **Data Processing**: Player analysis and comparison algorithms
- **Response Format**: Structured JSON with complete trade suggestion
- **Integration**: Ready for authentic team and market data

### Data Integrity Requirements
- **Authentic Team Data**: Only use official AFL Fantasy team composition
- **Real Performance**: Actual player statistics and pricing
- **Official Metrics**: Verified breakeven and average calculations
- **Live Market Data**: Current pricing and availability information

### Strategic Use Cases
- **Team Optimization**: Systematic improvement of team composition
- **Value Identification**: Discover market inefficiencies
- **Strategic Planning**: Long-term team building guidance
- **Performance Enhancement**: Upgrade team scoring potential

### Next Implementation Steps
1. **Team Data Integration**: Connect to user's complete AFL Fantasy team
2. **AI Enhancement**: Improve recommendation algorithms with more data points
3. **Market Intelligence**: Real-time pricing and performance integration
4. **User Customization**: Allow preference settings for trade recommendations