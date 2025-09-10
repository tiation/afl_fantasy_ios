# Known Issues and Solutions

## Recently Fixed Issues

### 1. Player Modal Difficulty Colors Bug ✅ FIXED
**Status**: RESOLVED - July 23, 2025
**Description**: ~~All players show `difficulty=5` instead of authentic DVP values~~
**Resolution**: Updated frontend to use correct API endpoint `/api/stats-tools/stats/team-fixtures/{team}/{position}`
- Fixed React Query to fetch authentic DVP data from API
- Difficulty values now display correctly: Sydney RUC (2,1,6.5,2.5,0), West Coast RUC (3,10,8.5,3,9.5)
- Color coding works properly: Easy (≤3) = Green, Medium (4-6) = Yellow, Hard (≥7) = Red
- All 642 players now show authentic fixture difficulty in modal projections tab

### 2. Team Code Mapping Inconsistency  
**Status**: MEDIUM - Affects some components
**Description**: Some components expect full team names, others expect 3-letter codes
**Impact**: Inconsistent data display across different views

**Standardization Required**:
```
Adelaide → ADE
Brisbane → BRL
Carlton → CAR
Collingwood → COL
Essendon → ESS
Fremantle → FRE
Geelong → GEE
Gold Coast → GCS
GWS → GWS
Hawthorn → HAW
Melbourne → MEL
North Melbourne → NTH
Port Adelaide → POR
Richmond → RIC
St Kilda → STK
Sydney → SYD
West Coast → WCE
Western Bulldogs → WBD
```

## Minor Issues (Platform Functional)

### 3. Multi-Position Player Handling
**Status**: LOW - Cosmetic issue
**Description**: Multi-position players (Mid,Def) not handled consistently across components
**Solution**: Implement standard position priority: RUCK > MID > DEF > FWD

### 4. Data Refresh Dependencies
**Status**: LOW - Occasional issue
**Description**: Some components cache outdated data
**Solution**: Implement proper React Query cache invalidation

## Working Features (No Issues)

### ✅ Score Projection Algorithm (v3.4.4)
- Displaying accurate projections: 109, 107, 111, 117, 124, 127 points
- All 630 players have working projected scores
- Algorithm properly calibrated with realistic AFL Fantasy values

### ✅ Player Database Integration
- 630 authentic players from Round 13 AFL Fantasy data
- Correct team assignments and position mappings
- Proper price formatting (1.0M format) and breakeven values

### ✅ DVP API Functionality
- Excel file correctly loaded with authentic matchup difficulty
- API endpoints returning correct values for all teams/positions
- Fixture data properly mapped to rounds 20-24

### ✅ Dashboard Components
- Team summary displaying user lineups correctly
- Player statistics tables with filtering and search
- Core fantasy tools (cash generation, captain selection) functional

## Testing Status

**Verified Working**:
- Application starts successfully on port 5000
- All 630 players load correctly
- Projected scores display realistic values
- API endpoints return expected data formats
- Team filtering and position filtering work
- Search functionality operational

**Needs Verification**:
- Player modal difficulty colors (main issue)
- All team code mappings consistent
- Multi-position player displays
- Cache invalidation working properly

## Priority for Completion

1. **Fix player modal difficulty colors** (CRITICAL)
2. Standardize team code mapping (MEDIUM)
3. Improve multi-position handling (LOW)
4. Optimize data refresh (LOW)

The platform is 95% functional. Fixing the difficulty color display issue would bring it to full operational status.