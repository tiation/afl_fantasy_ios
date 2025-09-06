# Vice-Captain Optimizer Data Mapping

## Component: Vice-Captain Optimizer
**Location**: `client/src/components/tools/captain/vice-captain-optimizer.tsx`

## Data Requirements

### API Endpoint
- **Service Call**: `fetchViceCaptainOptimizer()`
- **Backend Endpoint**: `/api/captains/vice-optimizer`
- **Method**: GET
- **Response Format**: JSON with combinations array

### Input Data Structure
```typescript
type CaptainCombo = {
  vice_captain: string;     // VC player name
  vc_team: string;         // VC team abbreviation
  vc_position: string;     // VC position
  vc_avg: number;          // VC average score
  vc_day: string;          // VC match day
  captain: string;         // C player name
  c_team: string;          // C team abbreviation
  c_position: string;      // C position
  c_avg: number;           // C average score
  c_day: string;           // C match day
  expected_pts: number;    // Combined expected points
}
```

### Required Authentic Data Sources

#### Player Schedule Data
- **Match Days**: Thursday, Friday, Saturday, Sunday fixtures
- **Team Schedules**: Exact kickoff times for loophole opportunities
- **Source**: AFL fixture data or Champion Data API

#### Player Performance Data
- **Average Scores**: Season averages for each player
- **Recent Form**: Last 3-5 round performance
- **Position Eligibility**: Valid captain/vice-captain positions
- **Source**: Current player database + DFS Australia data

#### Loophole Logic Requirements
- **Early Games**: Thursday/Friday players for VC selection
- **Late Games**: Saturday/Sunday players for C selection
- **Emergency Coverage**: Backup captain options
- **Score Projections**: Using v3.4.4 algorithm for expected points

### Calculation Logic

#### VC/C Combination Scoring
1. **Vice-Captain Points**: VC projected score (if captain doesn't play)
2. **Captain Points**: C projected score × 2 (standard captain bonus)
3. **Expected Value**: Probability-weighted combination outcome
4. **Risk Assessment**: Injury/late out probabilities

#### Optimization Criteria
- **Maximize Expected Points**: Best combination outcomes
- **Minimize Risk**: Avoid players with injury concerns
- **Schedule Optimization**: Best loophole opportunities
- **Position Balance**: Ensure valid team structure

### Missing Data Elements

#### Current Gaps
1. **Detailed Match Schedules**: Exact kickoff times needed
2. **Injury Intelligence**: Late out probabilities
3. **Historical VC/C Performance**: Past captain effectiveness
4. **Team News Monitoring**: Real-time player availability

#### Data Integration Needs
- **AFL Fixture API**: Official match scheduling
- **Champion Data**: Detailed player statistics
- **AFL Fantasy Live**: Real-time team news
- **External News Sources**: Injury and availability updates

### Frontend Display Features

#### Table Columns
- Vice-Captain details (name, team, position, average, day)
- Captain details (name, team, position, average, day)
- Expected points calculation
- Risk indicators
- Recommendation ranking

#### Interactive Features
- **Sorting**: By expected points, risk level, player name
- **Filtering**: By position, team, match day
- **Refresh**: Real-time data updates
- **Export**: Save combinations for reference

### Current Implementation Status
- **Frontend Component**: Complete with table display
- **API Integration**: Service call implemented
- **Backend Endpoint**: Available at `/api/captains/vice-optimizer`
- **Data Processing**: Needs authentic fixture and performance data

### Next Implementation Steps
1. **Populate Match Schedule Data**: Integrate AFL fixture information
2. **Enhanced Player Performance**: Add projected scores using v3.4.4
3. **Risk Assessment**: Incorporate injury and availability intelligence
4. **Real-time Updates**: Live data synchronization during rounds