# Form-Based Captain Analyzer Data Mapping

## Component: Form-Based Captain Analyzer
**Location**: `client/src/components/tools/captain/form-based-captain-analyzer.tsx`

## Data Requirements

### API Endpoint
- **Service Call**: `fetchFormBasedCaptainAnalyzer()`
- **Backend Endpoint**: `/api/captains/form-analyzer`
- **Method**: GET
- **Response Format**: JSON with players array

### Input Data Structure
```typescript
type FormPlayer = {
  player: string;          // Player name
  team: string;           // Team abbreviation
  position: string;       // Player position
  last_3_form: number;    // Last 3 rounds average
  last_5_form: number | string; // Last 5 rounds average
  season_form: number;    // Season average
  trend: string;          // Form trend (improving/declining)
  recommendation: string; // Captain recommendation level
}
```

### Required Authentic Data Sources

#### Historical Performance Data
- **Round-by-Round Scores**: Individual player scores for trend analysis
- **Last 3 Rounds**: Recent form calculation
- **Last 5 Rounds**: Medium-term form analysis
- **Season Average**: Full season performance baseline
- **Source**: AFL Fantasy player data + DFS Australia statistics

#### Form Trend Analysis
- **Trend Calculation**: Statistical analysis of score progression
- **Performance Patterns**: Consistency vs volatility metrics
- **Peak Performance**: Identification of scoring peaks and troughs
- **Momentum Indicators**: Recent performance direction

#### Recommendation Logic
- **Form Weighting**: Prioritize recent performance over season averages
- **Consistency Factors**: Reward reliable performers
- **Upward Trends**: Identify players hitting form
- **Risk Assessment**: Flag declining or volatile performers

### Calculation Requirements

#### Form Metrics
1. **Last 3 Average**: Simple average of most recent 3 scores
2. **Last 5 Average**: Simple average of most recent 5 scores  
3. **Season Average**: Total points divided by games played
4. **Trend Direction**: Linear regression on recent scores
5. **Form Rating**: Weighted combination favoring recent performance

#### Recommendation Categories
- **Highly Recommended**: Excellent recent form + upward trend
- **Recommended**: Good form with consistent scoring
- **Consider**: Mixed signals, moderate recommendation
- **Avoid**: Poor recent form or declining trend

### Missing Data Elements

#### Current Gaps
1. **Individual Round Scores**: Need complete scoring history per player
2. **Game-by-Game Context**: Opponent difficulty, venue, conditions
3. **Position-Specific Benchmarks**: Form relative to position averages
4. **Advanced Metrics**: Ceiling games, floor protection, consistency scores

#### Authentication Requirements
- **AFL Fantasy Login**: Access to detailed player round scores
- **Historical Data**: Multiple seasons for trend establishment
- **Real-Time Updates**: Current round performance integration

### Frontend Display Features

#### Table Structure
- Player identification (name, team, position)
- Form metrics (L3, L5, season averages)
- Trend indicators with visual cues
- Recommendation badges with color coding
- Sortable columns for analysis

#### Visual Indicators
- **Trend Arrows**: Up/down/neutral trend symbols
- **Form Heat Map**: Color-coded performance levels
- **Recommendation Badges**: Green/yellow/red recommendation levels
- **Consistency Indicators**: Volatility and reliability metrics

### Backend Implementation Status
- **API Endpoint**: `/api/captains/form-analyzer` available
- **Data Processing**: Form calculation algorithms implemented
- **Response Format**: Structured JSON with form analysis
- **Integration**: Ready for authentic player score data

### Data Integration Priority
1. **Round Score History**: Complete player performance records
2. **Form Calculation Engine**: Statistical analysis of trends
3. **Contextual Factors**: Opponent, venue, and condition impacts
4. **Real-Time Processing**: Live form updates during rounds