import * as XLSX from 'xlsx';
import fs from 'fs';
import path from 'path';

export interface TeamDVPRating {
  Team: string;
  FWD: number;
  MID: number;
  DEF: number;
  RUCK: number;
}

export interface TeamFixture {
  team: string;
  rounds: { [round: string]: string }; // round number -> opponent
}

export interface PositionMatchup {
  team: string;
  rounds: { [round: string]: number }; // round number -> difficulty rating
}

export interface MatchupData {
  dvpRatings: TeamDVPRating[];
  fixtures: TeamFixture[];
  fwdMatchups: PositionMatchup[];
  midMatchups: PositionMatchup[];
  defMatchups: PositionMatchup[];
  ruckMatchups: PositionMatchup[];
}

export class MatchupDataProcessor {
  private matchupData: MatchupData | null = null;
  private filePath = path.join(process.cwd(), 'assets/production', 'DFS_DVP_Matchup_Tables_FIXED_1753016059835.xlsx');
  
  // Team abbreviation to full name mapping
  private teamMapping: { [key: string]: string } = {
    'ADE': 'Adelaide',
    'BRL': 'Brisbane', 
    'CAR': 'Carlton',
    'COL': 'Collingwood',
    'ESS': 'Essendon',
    'FRE': 'Fremantle',
    'GEE': 'Geelong',
    'GCS': 'Gold Coast',
    'GWS': 'GWS',
    'HAW': 'Hawthorn',
    'MEL': 'Melbourne',
    'NTH': 'North Melbourne',
    'PTA': 'Port Adelaide',
    'RIC': 'Richmond',
    'STK': 'St Kilda',
    'SYD': 'Sydney',
    'WBD': 'Western Bulldogs',
    'WCE': 'West Coast'
  };

  async loadMatchupData(): Promise<MatchupData> {
    if (this.matchupData) {
      return this.matchupData;
    }

    try {
      // Check if file exists
      if (!fs.existsSync(this.filePath)) {
        throw new Error(`Excel file not found at ${this.filePath}`);
      }

      console.log('Loading matchup data from:', this.filePath);
      
      // Dynamically import and use XLSX
      const XLSXModule = await import('xlsx');
      const XLSX = XLSXModule.default;
      const workbook = XLSX.readFile(this.filePath);
      
      console.log('Available sheets:', workbook.SheetNames);
      
      // Process DVP Difficulty Ratings
      const dvpSheet = workbook.Sheets['DVP Difficulty Ratings'];
      const dvpData = XLSX.utils.sheet_to_json<TeamDVPRating>(dvpSheet);
      
      // Process Fixture Matrix
      const fixtureSheet = workbook.Sheets['Fixture Matrix'];
      const fixtureRawData = XLSX.utils.sheet_to_json<any>(fixtureSheet);
      const fixtures = fixtureRawData.map(row => ({
        team: row.Team,
        rounds: {
          '20': row['20'],
          '21': row['21'],
          '22': row['22'],
          '23': row['23'],
          '24': row['24']
        }
      }));
      
      // Process position-specific matchups
      const processPositionSheet = (sheetName: string): PositionMatchup[] => {
        const sheet = workbook.Sheets[sheetName];
        const rawData = XLSX.utils.sheet_to_json<any>(sheet);
        return rawData.map(row => ({
          team: row.Team,
          rounds: {
            '20': parseFloat(row['20']) || 0,
            '21': parseFloat(row['21']) || 0,
            '22': parseFloat(row['22']) || 0,
            '23': parseFloat(row['23']) || 0,
            '24': parseFloat(row['24']) || 0
          }
        }));
      };
      
      const ruckMatchups = processPositionSheet('RUCK Matchups');
      console.log('Sample RUCK matchup data:', JSON.stringify(ruckMatchups.slice(0, 3), null, 2));
      
      // Check for Melbourne specifically
      const melbourneRuck = ruckMatchups.find(r => r.team.toUpperCase().includes('MEL'));
      console.log('Melbourne RUCK data:', JSON.stringify(melbourneRuck, null, 2));
      
      this.matchupData = {
        dvpRatings: dvpData,
        fixtures: fixtures,
        fwdMatchups: processPositionSheet('FWD Matchups'),
        midMatchups: processPositionSheet('MID Matchups'),
        defMatchups: processPositionSheet('DEF Matchups'),
        ruckMatchups: ruckMatchups
      };
      
      return this.matchupData;
    } catch (error) {
      console.error('Error loading matchup data:', error);
      throw new Error('Failed to load matchup data');
    }
  }

  private mapTeamName(team: string): string {
    // First try to get the full name from abbreviation mapping
    const fullName = this.teamMapping[team.toUpperCase()];
    if (fullName) return fullName;
    
    // If not found, return the original team name (might already be full name)
    return team;
  }

  async getTeamDVPRating(team: string): Promise<TeamDVPRating | undefined> {
    const data = await this.loadMatchupData();
    const fullTeamName = this.mapTeamName(team);
    return data.dvpRatings.find(r => r.Team.toUpperCase() === fullTeamName.toUpperCase());
  }

  async getTeamFixtures(team: string): Promise<TeamFixture | undefined> {
    const data = await this.loadMatchupData();
    const fullTeamName = this.mapTeamName(team);
    return data.fixtures.find(f => f.team.toUpperCase() === fullTeamName.toUpperCase());
  }

  async getPlayerMatchupDifficulty(playerTeam: string, position: string, round: string): Promise<number | undefined> {
    const data = await this.loadMatchupData();
    
    // Map team abbreviation to full name
    const fullTeamName = this.mapTeamName(playerTeam);
    
    // Get the player's team fixture to find opponent
    const teamFixtures = data.fixtures.find(f => f.team.toUpperCase() === fullTeamName.toUpperCase());
    if (!teamFixtures) return undefined;
    
    const opponent = teamFixtures.rounds[round];
    if (!opponent) return undefined;
    
    // Normalize position to handle multiple positions
    const primaryPosition = this.getPrimaryPosition(position);
    
    let matchupData: PositionMatchup[] = [];
    switch (primaryPosition) {
      case 'FWD':
        matchupData = data.fwdMatchups;
        break;
      case 'MID':
        matchupData = data.midMatchups;
        break;
      case 'DEF':
        matchupData = data.defMatchups;
        break;
      case 'RUCK':
      case 'RUC':
        matchupData = data.ruckMatchups;
        break;
    }
    
    // The Excel data structure shows difficulty ratings per round for each team
    // So we need to look up the player's team data, not the opponent's data
    const teamMatchup = matchupData.find(m => m.team.toUpperCase() === fullTeamName.toUpperCase());
    
    // Debug logging for RUCK position
    if (primaryPosition === 'RUC' || primaryPosition === 'RUCK') {
      console.log(`RUCK Debug - Team: ${playerTeam}, Full: ${fullTeamName}, Position: ${position}, Primary: ${primaryPosition}, Round: ${round}`);
      console.log(`Found team matchup:`, teamMatchup);
      console.log(`Difficulty for round ${round}:`, teamMatchup?.rounds[round]);
    }
    
    return teamMatchup?.rounds[round];
  }

  async getUpcomingFixtureDifficulty(playerTeam: string, position: string, rounds: string[]): Promise<{ round: string; opponent: string; difficulty: number }[]> {
    const data = await this.loadMatchupData();
    const fullTeamName = this.mapTeamName(playerTeam);
    const fixtures = await this.getTeamFixtures(playerTeam);
    
    if (!fixtures) return [];
    
    const results = [];
    for (const round of rounds) {
      const opponent = fixtures.rounds[round];
      if (opponent) {
        const difficulty = await this.getPlayerMatchupDifficulty(playerTeam, position, round) || 5;
        results.push({ round, opponent, difficulty });
      }
    }
    
    return results;
  }

  // Helper method to determine primary position based on user's priority rules
  private getPrimaryPosition(position: string): string {
    const positions = position.split('/').map(p => p.trim());
    
    // Priority order: RUCK/RUC > MID > DEF > FWD
    const priorityOrder = ['RUCK', 'RUC', 'MID', 'DEF', 'FWD'];
    
    for (const priority of priorityOrder) {
      if (positions.includes(priority)) {
        return priority;
      }
    }
    
    // Default to first position if none match
    return positions[0] || 'MID';
  }

  async getTeamAbbreviation(fullTeamName: string): Promise<string> {
    // Map full team names to abbreviations used in the Excel file
    const teamMappings: { [key: string]: string } = {
      'Adelaide': 'ADE',
      'Adelaide Crows': 'ADE',
      'Brisbane': 'BRL',
      'Brisbane Lions': 'BRL',
      'Carlton': 'CAR',
      'Carlton Blues': 'CAR',
      'Collingwood': 'COL',
      'Collingwood Magpies': 'COL',
      'Essendon': 'ESS',
      'Essendon Bombers': 'ESS',
      'Fremantle': 'FRE',
      'Fremantle Dockers': 'FRE',
      'Geelong': 'GEE',
      'Geelong Cats': 'GEE',
      'Gold Coast': 'GCS',
      'Gold Coast Suns': 'GCS',
      'GWS': 'GWS',
      'GWS Giants': 'GWS',
      'Greater Western Sydney': 'GWS',
      'Hawthorn': 'HAW',
      'Hawthorn Hawks': 'HAW',
      'Melbourne': 'MEL',
      'Melbourne Demons': 'MEL',
      'North Melbourne': 'NTH',
      'North Melbourne Kangaroos': 'NTH',
      'Port Adelaide': 'PTA',
      'Port Adelaide Power': 'PTA',
      'Richmond': 'RIC',
      'Richmond Tigers': 'RIC',
      'St Kilda': 'STK',
      'St Kilda Saints': 'STK',
      'Sydney': 'SYD',
      'Sydney Swans': 'SYD',
      'West Coast': 'WCE',
      'West Coast Eagles': 'WCE',
      'Western Bulldogs': 'WBD',
      'Bulldogs': 'WBD'
    };
    
    return teamMappings[fullTeamName] || fullTeamName;
  }

  async getAllTeamFixtureDifficulty(): Promise<any[]> {
    const data = await this.loadMatchupData();
    const results = [];
    
    for (const fixture of data.fixtures) {
      const teamResults = {
        team: fixture.team,
        fixtures: [] as any[]
      };
      
      // Get difficulty ratings from the team's own data (Excel shows team-specific difficulty per round)
      for (const [round, opponent] of Object.entries(fixture.rounds)) {
        const fwdDiff = data.fwdMatchups.find(m => m.team === fixture.team)?.rounds[round] || 5;
        const midDiff = data.midMatchups.find(m => m.team === fixture.team)?.rounds[round] || 5;
        const defDiff = data.defMatchups.find(m => m.team === fixture.team)?.rounds[round] || 5;
        const ruckDiff = data.ruckMatchups.find(m => m.team === fixture.team)?.rounds[round] || 5;
        
        const avgDifficulty = (fwdDiff + midDiff + defDiff + ruckDiff) / 4;
        
        teamResults.fixtures.push({
          round: parseInt(round),
          opponent: opponent,
          difficulty: Math.round(avgDifficulty * 10) / 10,
          positionDifficulty: {
            FWD: fwdDiff,
            MID: midDiff,
            DEF: defDiff,
            RUCK: ruckDiff
          }
        });
      }
      
      // Sort by round
      teamResults.fixtures.sort((a, b) => a.round - b.round);
      
      // Calculate average difficulty
      const avgDifficulty = teamResults.fixtures.reduce((sum, f) => sum + f.difficulty, 0) / teamResults.fixtures.length;
      
      results.push({
        ...teamResults,
        averageDifficulty: Math.round(avgDifficulty * 10) / 10
      });
    }
    
    return results;
  }
}

export const matchupDataProcessor = new MatchupDataProcessor();