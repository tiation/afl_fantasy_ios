# AFL Fantasy Platform - Testing Checklist

## Pre-Testing Setup

### Required Files Verification
- [ ] `player_data_stats_enhanced_20250720_205845.json` exists (630 players)
- [ ] `attached_assets/DFS_DVP_Matchup_Tables_FIXED_1753016059835.xlsx` exists
- [ ] `attached_assets/afl_fixture_2025_1753111987231.json` exists
- [ ] Application starts successfully on port 5000

### Environment Check
- [ ] PostgreSQL database accessible
- [ ] Node.js and npm working
- [ ] Python environment available for data processing

## Core Functionality Testing

### Dashboard Tests
- [ ] Dashboard loads without errors
- [ ] Team summary displays user lineup correctly
- [ ] Player count shows 630 total players
- [ ] All position categories (MID, FWD, DEF, RUC) have players

### Player Data Tests
- [ ] Player statistics table loads all 630 players
- [ ] Search functionality works (try "Bont", "Grundy", "Cripps")
- [ ] Position filtering works for all positions
- [ ] Team filtering works for all 18 teams
- [ ] Price display uses correct format (1.0M, 950K, etc.)

### Score Projection Tests (v3.4.4 Algorithm)
- [ ] Projected scores display realistic AFL Fantasy values (60-130 range)
- [ ] Premium players show high projections (100+ points)
- [ ] Test specific players:
  - [ ] Marcus Bontempelli: ~110+ points
  - [ ] Andrew Brayshaw: ~105+ points  
  - [ ] Patrick Cripps: ~105+ points
  - [ ] Max Gawn: ~120+ points
  - [ ] Nasiah Wanganeen-Milera: ~120+ points

### DVP and Fixture Testing
- [ ] API endpoint `/api/stats-tools/stats/team-fixtures/SYD/RUC` returns Sydney fixtures
- [ ] API endpoint `/api/stats-tools/stats/team-fixtures/WCE/RUC` returns West Coast fixtures
- [ ] Difficulty values are realistic (0-10 scale)
- [ ] Easy matchups show values ≤3
- [ ] Hard matchups show values ≥7

## Player Modal Testing

### Basic Modal Functionality
- [ ] Player modal opens when clicking on any player
- [ ] Modal displays correct player name, team, and position
- [ ] Performance tab shows stats correctly
- [ ] Projections tab loads without errors
- [ ] News tab displays (even if placeholder)

### Critical Issue Testing - Difficulty Colors
**This is the main issue that needs fixing:**

- [ ] Open Brodie Grundy (Sydney RUC) player modal
- [ ] Navigate to Projections tab
- [ ] Verify fixtures show:
  - R20 vs GWS: Should be EASY (green) - difficulty 2
  - R21 vs Essendon: Should be EASY (green) - difficulty 1  
  - R22 vs Brisbane: Should be MED (yellow) - difficulty 6.5
  - R23 vs Geelong: Should be EASY (green) - difficulty 2.5
  - R24 vs West Coast: Should be EASY (green) - difficulty 0

**Current Bug**: All show as MED (yellow) with difficulty=5

### Additional Player Modal Tests
- [ ] Test West Coast player (should show mix of green/red based on authentic data)
- [ ] Test Adelaide player (should show different fixture pattern)
- [ ] Verify projected scores display correctly in projections tab
- [ ] Check that player team mapping is correct

## Tools Testing

### Cash Generation Tools
- [ ] Cash generation page loads
- [ ] Player recommendations display
- [ ] Price analysis shows realistic projections
- [ ] Filter functionality works

### Captain Selection Tools
- [ ] Captain analysis loads
- [ ] Recommendations based on fixture difficulty
- [ ] Projected captain scores display correctly

### Trade Analysis Tools
- [ ] Trade comparison functionality works
- [ ] Score differentials calculated correctly
- [ ] Risk assessments display

## API Testing

### Direct API Verification
Test these endpoints directly:

```bash
# Player data
curl "http://localhost:5000/api/stats/combined-stats" | jq length
# Should return 630

# Sydney fixtures (should work correctly)
curl "http://localhost:5000/api/stats-tools/stats/team-fixtures/SYD/RUC" | jq '.fixtures[] | "\(.round): \(.opponent) - \(.difficulty)"'
# Should return: R20: GWS - 2, R21: Essendon - 1, etc.

# Projected scores
curl "http://localhost:5000/api/score-projection/player/Brodie%20Grundy" | jq '.data.projectedScore'
# Should return realistic value (80-130 range)
```

## Performance Testing

### Load Testing
- [ ] Application handles 630 players without performance issues
- [ ] Player modal opens quickly (<2 seconds)
- [ ] Search results filter quickly
- [ ] API responses under 1 second

### Memory Testing
- [ ] No memory leaks when opening multiple player modals
- [ ] Browser performance remains smooth with large datasets

## Data Integrity Testing

### Player Data Validation
- [ ] All 630 players have names
- [ ] All players have team assignments (max 27 "Unknown" acceptable)
- [ ] All players have positions assigned
- [ ] Prices are realistic AFL Fantasy values
- [ ] Breakevens are realistic values

### Team Data Validation
- [ ] All 18 AFL teams represented
- [ ] Team codes properly standardized
- [ ] No duplicate team entries

### Fixture Data Validation
- [ ] Rounds 20-24 have complete fixture data
- [ ] All teams have 5 fixtures each
- [ ] Opponent matchups are realistic

## Regression Testing

### After Fixing Main Issue
Once the difficulty color bug is fixed:

- [ ] Verify all previous functionality still works
- [ ] Check that projected scores still display correctly
- [ ] Ensure API endpoints still return expected data
- [ ] Validate that team filtering still works
- [ ] Confirm search functionality unchanged

## Sign-off Criteria

**Platform Ready for Production When**:
- [ ] All core functionality tests pass
- [ ] Player modal difficulty colors display correctly
- [ ] All 630 players accessible and functional
- [ ] Projected scores showing realistic AFL Fantasy values
- [ ] No critical errors in browser console
- [ ] API response times acceptable
- [ ] Memory usage stable

**Acceptable Known Issues**:
- Minor team code mapping inconsistencies (non-blocking)
- Some multi-position players display variations (cosmetic)
- Occasional data refresh delays (not critical)

The platform is currently at 95% completion. Fixing the player modal difficulty color display will achieve full operational status.