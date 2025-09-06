# Fixture Difficulty Scanner Data Mapping

## Component: Fixture Difficulty Scanner
**Location**: `client/src/components/tools/fixture/fixture-difficulty-scanner.tsx`

## Data Requirements

### API Integration
- **Service Call**: `fetchFixtureDifficulty()` from fixtureService
- **Backend Endpoint**: `/api/fixture/difficulty-scanner`
- **Method**: GET
- **Response Format**: JSON with team fixture difficulty data

### Input Data Structure
```typescript
type TeamFixture = {
  round: number;        // AFL round number
  opponent: string;     // Opposing team name
  is_home: boolean;     // Home/away designation
  difficulty: number;   // Difficulty rating (1-10 scale)
}

type TeamDifficulty = {
  team: string;             // AFL team name
  fixtures: TeamFixture[]; // Array of upcoming fixtures
  avg_difficulty: number;   // Average difficulty rating
}
```

### Required Authentic Data Sources

#### AFL Fixture Data
- **Official Fixtures**: Complete AFL season fixture list with dates and venues
- **Round Scheduling**: Accurate round numbers and match progression
- **Home/Away Status**: Venue designations for each match
- **Source**: AFL official fixture data or Champion Data API

#### Team Strength Analysis
- **Defensive Rankings**: Team defensive capabilities by position
- **Form Analysis**: Recent team performance and momentum
- **Historical Matchups**: Head-to-head performance patterns
- **Source**: AFL statistics and DFS Australia defensive data

#### Difficulty Calculation
- **Opponent Strength**: Statistical analysis of defensive capabilities
- **Venue Impact**: Home ground advantage and travel factors
- **Recent Form**: Current team performance trends
- **Historical Context**: Long-term matchup difficulty patterns

### Calculation Logic

#### Difficulty Rating Scale (1-10)
1. **1-3**: Easy matchups - weak defensive opponents
2. **4-6**: Medium difficulty - average defensive strength
3. **7-8**: Hard matchups - strong defensive teams
4. **9-10**: Very difficult - elite defensive opponents

#### Factors in Difficulty Assessment
1. **Opponent DVP Rankings**: Defense vs Position effectiveness
2. **Home/Away Impact**: Venue advantage considerations
3. **Recent Form**: Current team defensive performance
4. **Fixture Congestion**: Impact of travel and short breaks

### Missing Data Elements

#### Current Gaps
1. **Live DVP Data**: Real-time defensive vs position statistics
2. **Venue Analytics**: Specific ground advantages and scoring patterns
3. **Injury Impact**: Key player availability affecting team strength
4. **Weather Conditions**: Environmental factors affecting gameplay

#### Authentication Requirements
- **AFL Fixture Access**: Official season fixture list
- **Statistical Data**: Comprehensive team defensive statistics
- **Historical Records**: Multi-season matchup analysis

### Frontend Display Features

#### Team Selection Interface
- **Team List**: All AFL teams with expandable fixture details
- **Difficulty Overview**: Color-coded difficulty ratings
- **Average Ratings**: Overall fixture difficulty for each team
- **Time Period Filter**: Focus on specific round ranges

#### Fixture Detail View
- **Round-by-Round**: Individual match difficulty breakdown
- **Opponent Analysis**: Specific matchup difficulty reasoning
- **Home/Away Indicators**: Venue impact on difficulty rating
- **Visual Coding**: Color schemes for easy difficulty identification

#### Difficulty Color Coding
- **Green**: Easy fixtures (1-3 rating)
- **Yellow**: Medium difficulty (4-6 rating)  
- **Orange**: Hard fixtures (7-8 rating)
- **Red**: Very difficult (9-10 rating)

### Backend Implementation Status
- **API Endpoint**: Available with fixture difficulty analysis
- **Data Processing**: Team strength and matchup analysis algorithms
- **Response Structure**: Formatted JSON with difficulty breakdowns
- **Integration**: Ready for authentic AFL fixture and team data

### Data Integrity Requirements
- **Authentic Fixtures**: Only use official AFL season fixture data
- **Real Team Stats**: Actual defensive performance statistics
- **Official Scheduling**: Verified round numbers and match dates
- **Live Updates**: Current season fixture and form integration

### Strategic Use Cases
- **Player Selection**: Choose players with favorable upcoming fixtures
- **Trade Timing**: Plan trades around difficult fixture periods
- **Captain Selection**: Avoid captaining players with tough matchups
- **Long-term Planning**: Build team around fixture advantages

### Next Implementation Steps
1. **AFL Fixture Integration**: Connect to official season fixture data
2. **DVP Enhancement**: Integrate detailed defensive vs position statistics
3. **Live Form Updates**: Real-time team performance and injury data
4. **Advanced Analytics**: Venue-specific and weather-adjusted difficulty ratings