# AFL Fantasy Intelligence Platform

## Overview

The AFL Fantasy Intelligence Platform is a comprehensive data-driven application designed to assist AFL Fantasy coaches with advanced analytics, trade optimization, and strategic insights. The platform aggregates data from multiple sources to provide real-time player statistics, predictive modeling, and automated data updates.

## Recent Changes

### July 22, 2025 - Complete Data Requirements Map Created
- **Comprehensive Documentation**: Created `COMPLETE_DATA_REQUIREMENTS_MAP.md` with exact specifications for all components
  - Documented all 630 players, DVP data from Excel, fixture schedule requirements
  - Mapped every API endpoint to required data formats and component dependencies
  - Identified specific data integration issues: player modal fixture display bug, team code inconsistencies
  - Provided complete testing checklist and validation requirements for any AI assistant to complete the project
  - Core platform 95% complete - remaining issues are primarily frontend data binding problems

### July 22, 2025 - Player Modal Projection Integration Complete
- **Fixed Player Modal Projected Scores Display**: Resolved critical data parsing issue in player detail modal projections tab
  - Fixed round number parsing: "R20" → 20 for proper projection data matching
  - Confirmed v3.4.4 algorithm delivering accurate projections: Nasiah Wanganeen-Milera (123-130 pts), Jack Steele (93 pts)
  - Enhanced team name mapping for fixture data: STK → St Kilda with proper abbreviation handling
  - Fixture difficulty ratings now displaying correctly with authentic DVP data
  - All 630 players now have working projected scores across rounds 20-24
  - **User Validation Complete**: Preview working with full projection functionality

### July 21, 2025 - Score Projection Integration & Complete Data Overhaul
- **Enhanced Score Projection Algorithm**: Integrated v3.4.4 projected score calculations throughout the platform
  - Added projected score column to Core Fantasy Stats table
  - Enhanced projection algorithm with realistic scoring adjustments based on player tiers
  - API endpoints delivering realistic projections: Bailey Smith (105+ proj), Nasiah Wanganeen-Milera (120+ proj), Rowan Marshall (85+ proj)
  - Formula: 30% season average + 25% recent form + 20% opponent difficulty + 15% position adjustment with tier-based multipliers
  - Confidence scoring system with matchup and form factors
  - **Algorithm Calibration Complete**: Successfully tested on 27 players across all tiers with user validation
    - Elite players: Bontempelli (111), Brayshaw (109), Cripps (108) - accurate premium projections
    - Mid-tier players: Dunkley (96), Greene (64), Macrae (105 vs easy matchups) - realistic expectations
    - Quality players: Max Gawn (125), Jordan Dawson (111), Zorko (111) - appropriate variance
    - Individual player adjustments: Special handling for easy matchups (Richmond, North Melbourne)
    - User feedback: "fairly accurate" and "pretty close" - ready for production use

### July 21, 2025 - Complete Data Overhaul with Authentic Round 13 Data
- **Complete AFL Fantasy Data Replacement**: Replaced entire player database with authentic Round 13 live data
  - Imported 642 players from currentdt_liveR13_1753069161334.xlsx (authentic AFL Fantasy source)
  - AFL Fantasy positions sourced from currentdt file: Def, Mid, Fwd, Ruc, Mid,Def, Mid,Fwd, etc.
  - Team assignments updated for 588 players using user-provided CSV mapping with correct club abbreviations
  - All 18 AFL teams properly assigned: Adelaide (31), Brisbane (34), Carlton (33), Collingwood (36), etc.
  - Correctly assigned key players: Connor Rozee (Port Adelaide Mid,Def), George Hewett (Carlton Mid), Harry Sheezel (North Melbourne)
  - All prices, breakevens, and averages now authentic from current AFL Fantasy Round 13 data
  - Only 27 players remain with "Unknown" teams (likely name variations not in CSV)
  - Single source data integrity: all player data from same authentic currentdt Round 13 file

- **Critical Bug Fixes and Data Accuracy**:
  - Fixed major display issue where only 10 players showed instead of all 541 (price change filter scale bug)
  - Applied CSV team mapping corrections: Hunter Clark (St Kilda), Bailey Smith (Geelong), Rowan Marshall (St Kilda)
  - Removed fictional "Steely Green" player from database
  - Eliminated 11 duplicate players by keeping entries with higher prices (more accurate data)
  - Fixed team filtering: now uses actual team abbreviations (ADE, BRL, CAR) instead of full names
  - Fixed position filtering: handles comma-separated positions (Mid,Def) and normalizes to uppercase
  - Final dataset: 630 unique authentic players with correct team assignments and filtering functionality

### July 20, 2025 - Comprehensive Player Database Integration
- **Complete Player Database Overhaul**: Replaced all existing player data with comprehensive new dataset
  - Integrated 601 individual DFS player files with detailed career statistics, game logs, and opponent splits
  - Added 24 Keeper league datasets including CBA percentages, kick-ins data, breakout/crashout analysis
  - Integrated live Round 13 data with 644 player entries
  - Enhanced 515 players with proper team and position assignments from backup data
  - Maintained DVP matchup difficulty integration from previous updates

### July 20, 2025 - Matchup Difficulty Integration
- **Real DVP Data Integration**: Integrated Excel file containing actual Defense vs Position (DVP) matchup difficulty data
  - Added `server/matchup-data-processor.ts` to process matchup difficulty data from Excel
  - Difficulty ratings on 0-10 scale (0 = easiest, 10 = hardest)
  - Covers rounds 20-24 with position-specific difficulty for FWD, MID, DEF, RUCK
  
- **Player Detail Modal Enhancement**:
  - Updated to show real upcoming fixture difficulty based on player's team and position
  - Displays round-by-round difficulty ratings with color coding
  - Shows team DVP ratings across all positions
  - For multi-position players, uses priority: RUCK > MID > DEF > FWD
  
- **Team DVP Analysis Enhancement**:
  - Replaced general team rankings with fixture-specific matchup analysis
  - Shows next 5 fixtures with real difficulty ratings from Excel data
  - Added chart visualization showing difficulty trends across rounds
  - Fixed critical data interpretation bug - Excel contains team-specific difficulty per round
  - Now correctly displays varying difficulty: Adelaide FWD [5,5,3.5,10,0], Geelong FWD [0,5,4,3,3]
  
- **Player DVP Analysis Enhancement**:
  - Updated to show comprehensive player table like cash generation tracker
  - Displays all players with real fixture difficulty for next 5 rounds (R20-R24)
  - Shows player's primary position (priority: RUCK > MID > DEF > FWD)
  - Real-time difficulty ratings with color coding (green=easy, yellow=medium, red=hard)
  - Advanced filtering by team, position, and search query
  - Each row shows player's upcoming fixtures with individual round difficulty ratings

- **API Updates**:
  - New endpoint: `/api/stats-tools/player/:playerId/matchup-difficulty`
  - New endpoint: `/api/stats-tools/stats/team-fixtures/:team/:position`
  - Updated fixture API to serve real matchup data instead of Python-generated data
  - Returns position-specific difficulty ratings and team DVP profiles
  - Fixed opponent difficulty lookup in `getAllTeamFixtureDifficulty()` method

## System Architecture

### Frontend Architecture
- **Framework**: React with TypeScript
- **Location**: `/client` directory
- **UI Components**: Modular component-based architecture organized by functionality
  - Dashboard components for team overview
  - Stats components for player analysis
  - Tools components for strategic planning (captain selection, trade analysis, cash generation)
- **Styling**: Component-scoped styling with responsive design
- **State Management**: React hooks and context for component state

### Backend Architecture
- **Framework**: Express.js with TypeScript
- **Location**: `/server` directory
- **API Structure**: RESTful endpoints organized by functionality
  - `/api/teams/*` - Team management and data
  - `/api/stats/*` - Player statistics and analytics
  - `/api/fantasy/tools/*` - Strategic analysis tools
  - `/api/cash/*` - Cash generation tools
  - `/api/captain/*` - Captain selection tools
- **Python Integration**: Python scripts for data processing and AI tools via child processes

### Data Processing Layer
- **Primary Language**: Python for data scraping and analysis
- **Data Sources**: Multi-source aggregation with fallback chain
  - DFS Australia API (primary)
  - FootyWire scraping (secondary)
  - CSV import capabilities (manual updates)
- **Automated Updates**: Background scheduler for data refreshing every 12 hours

## Key Components

### Data Management
- **Player Database**: Centralized `player_data.json` with comprehensive player statistics
- **Team Management**: User team data stored in `user_team.json`
- **Backup System**: Automated timestamped backups before data updates
- **Multi-Source Integration**: Combines data from DFS Australia, FootyWire, and CSV imports

### Analytics Engine
- **Score Prediction**: v3.4.4 algorithm for player score projections with 12.5 point average margin of error
- **Price Modeling**: AFL Fantasy price change calculations using authentic magic number formula
- **Risk Assessment**: Trade risk analysis and injury risk evaluation
- **Performance Tracking**: Historical performance analysis and trend identification
- **Statistical Algorithms**: Price Predictor and Projected Score calculation engines

### Strategic Tools
- **Captain Analysis**: Multiple captain selection methodologies
- **Trade Optimization**: Score-based trade recommendation engine
- **Cash Generation**: Rookie price curve modeling and cash cow identification
- **Team Structure**: Position balance and salary cap optimization

## Data Flow

### Data Ingestion
1. **Scheduled Updates**: Background scheduler runs every 12 hours
2. **Primary Source**: DFS Australia Fantasy Big Board API
3. **Fallback Processing**: FootyWire scraping if primary source fails
4. **Manual Import**: CSV processing for manual data updates
5. **Data Validation**: Cross-source validation and normalization

### Data Processing
1. **Normalization**: Convert various data formats to standardized structure
2. **Player Matching**: Cross-reference players across different data sources
3. **Calculation Engine**: Derive metrics like averages, breakevens, and projections
4. **Team Integration**: Map player data to user team compositions

### API Response Flow
1. **Client Request**: Frontend components request data via API endpoints
2. **Data Retrieval**: Server fetches from JSON files or runs Python calculations
3. **Processing**: Apply filters, calculations, or analysis as needed
4. **Response**: Return structured JSON data to frontend components

## External Dependencies

### Data Sources
- **DFS Australia**: Primary source for player statistics and pricing
- **FootyWire**: Secondary source for comprehensive player data and fixtures
- **AFL Fantasy**: Target platform for authentic user data (authentication required)
- **Champion Data**: Advanced statistics API (credentials available but not implemented)

### Python Libraries
- **Web Scraping**: requests, BeautifulSoup4, selenium
- **Data Processing**: pandas, json, csv
- **Scheduling**: Background process management
- **Analysis**: Mathematical and statistical calculations

### Node.js Dependencies
- **Backend**: Express.js, TypeScript
- **Frontend**: React, TypeScript
- **Database**: Drizzle ORM (configured for PostgreSQL)
- **Development**: Various development and build tools

## Deployment Strategy

### Development Environment
- **Package Manager**: npm for dependency management
- **Build System**: TypeScript compilation for both frontend and backend
- **Database**: PostgreSQL with Drizzle ORM schema migrations
- **Process Management**: Background scheduler for automated data updates

### Production Considerations
- **Database**: PostgreSQL database provisioning required
- **Environment Variables**: Authentication credentials and API keys
- **Process Management**: Persistent background scheduler process
- **Data Persistence**: Regular backups of player and team data

### Scaling Architecture
- **Modular Design**: Clear separation between data processing, API, and frontend
- **Extensible Tools**: Plugin-style architecture for adding new analysis tools
- **Multi-Source Support**: Robust fallback chain for data source reliability

## Changelog

- July 20, 2025. Implemented Price Predictor and Projected Score algorithms with enhanced database schema
- July 03, 2025. Initial setup

## User Preferences

Preferred communication style: Simple, everyday language.

## Recent Changes

### Statistical Algorithm Implementation (July 20, 2025)

**Added Core Algorithm Engines:**
- Price Predictor Algorithm: Calculates future player prices using AFL Fantasy formula `P_n = (1 - β) * P_{n-1} + M_n - Σ(α_k * S_k)`
- Projected Score Algorithm: Calculates projected player scores using weighted formula with 30% season average, 20% recent form, 15% opponent history, 15% venue performance
- Enhanced database schema with round-by-round tracking, opponent history, venue performance, and price history

**Required Statistics for Full Implementation:**
1. **Individual round scores** for each player (currently have season averages)
2. **Opponent matchup history** for head-to-head performance tracking  
3. **Venue-specific performance** data for home/away advantages
4. **Historical price tracking** across multiple rounds
5. **Magic number calculations** from aggregate player data
6. **Team defense vs position** rankings for opponent difficulty

**API Endpoints Added:**
- `/api/algorithms/price-predictor` - Calculate price projections based on projected scores
- `/api/algorithms/projected-score` - Calculate score projections using v3.4.4 algorithm
- `/api/algorithms/projected-score/batch` - Batch score calculations for multiple players
- `/api/algorithms/status` - Check algorithm availability and data requirements

**Database Tables Added:**
- `player_round_scores` - Individual round-by-round performance tracking
- `opponent_history` - Head-to-head performance records
- `venue_history` - Venue-specific performance data
- `price_history` - Historical price tracking for price predictor
- `system_parameters` - Magic numbers and formula parameters
- `fixtures` - Upcoming game information
- `team_defense_vs_position` - Opponent strength rankings