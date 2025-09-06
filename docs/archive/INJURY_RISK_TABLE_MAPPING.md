# Injury Risk Table Data Mapping

## Component: Injury Risk Table
**Location**: `client/src/components/tools/risk/injury-risk-table.tsx`

## Data Requirements

### API Integration
- **Service Call**: `fetchInjuryRisk()` from riskService
- **Backend Endpoint**: `/api/risk/injury-risk`
- **Method**: GET
- **Response Format**: JSON with players array containing injury risk data

### Input Data Structure
```typescript
type InjuryRiskPlayer = {
  player: string;           // Player name
  team: string;            // Team abbreviation
  risk_level: string;      // Risk classification (Low/Medium/High)
  injury_history?: string; // Optional injury history details
}
```

### Required Authentic Data Sources

#### Medical Intelligence
- **Official Injury Reports**: AFL club injury lists and medical reports
- **Player Availability**: Current fitness status and return timelines
- **Injury History**: Historical injury patterns and recurrence data
- **Source**: Official AFL club medical reports and professional injury databases

#### Performance Impact Data
- **Return Performance**: Player performance after injury returns
- **Load Management**: Training and game time restrictions
- **Durability Metrics**: Games played vs games available statistics
- **Source**: AFL club data and player management information

#### Risk Assessment Factors
- **Age and Experience**: Career stage impact on injury susceptibility
- **Position Risk**: Injury likelihood by playing position
- **Workload Analysis**: Training and match load injury correlation
- **Source**: Sports science data and medical research

### Risk Classification Logic

#### Risk Level Categories
1. **Low Risk**: Fit players with minimal injury history
2. **Medium Risk**: Recent minor injuries or age-related concerns
3. **High Risk**: Current injuries, extensive history, or red dot status

#### Assessment Factors
- **Current Status**: Active injuries or fitness concerns
- **Historical Patterns**: Previous injury frequency and severity
- **Age Factors**: Career stage and physical decline indicators
- **Position Context**: Role-specific injury susceptibility

### Missing Data Elements

#### Current Gaps
1. **Real-time Medical Data**: Professional injury intelligence feeds
2. **Predictive Analytics**: Injury probability modeling
3. **Recovery Timelines**: Expected return dates and fitness levels
4. **Load Management**: Training restrictions and rotation policies

#### Authentication Requirements
- **Medical Database Access**: Professional sports injury intelligence services
- **AFL Club Data**: Official injury reports and player availability
- **Historical Records**: Multi-season injury and performance tracking

### Frontend Display Features

#### Risk Level Indicators
- **Color-coded Badges**: Green (low), yellow (medium), red (high) risk levels
- **Risk Icons**: Warning symbols for high-risk players
- **Sorting Options**: Arrange by risk level or player name
- **Team Filtering**: Focus on specific AFL teams

#### Injury Context
- **History Details**: Brief injury history where available
- **Current Status**: Active injury or fitness concerns
- **Risk Rationale**: Explanation of risk level assignment
- **Update Frequency**: Last updated timestamp for data freshness

### Backend Implementation Status
- **API Endpoint**: Available with injury risk analysis
- **Risk Classification**: Player categorization algorithms implemented
- **Response Structure**: Nested data handling for complex injury information
- **Integration**: Ready for authentic medical and performance data

### Data Integrity Requirements
- **Authentic Medical Data**: Only use verified injury reports and medical information
- **Professional Sources**: Licensed sports injury intelligence services
- **Real-time Updates**: Current injury status and availability information
- **No Speculation**: Clear error states when authentic data unavailable

### Strategic Use Cases
- **Player Selection**: Avoid high-risk players for team stability
- **Trade Planning**: Factor injury risk into trade decisions
- **Captain Selection**: Minimize risk of captain unavailability
- **Emergency Planning**: Prepare backup options for risky players

### Next Implementation Steps
1. **Medical Data Integration**: Connect to professional injury intelligence services
2. **Predictive Modeling**: Develop injury probability algorithms
3. **Real-time Updates**: Live injury status and availability feeds
4. **Enhanced Analytics**: Historical injury impact on performance analysis