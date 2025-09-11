import fs from 'fs';
import path from 'path';

export interface FixtureMatch {
  round: number;
  teams: string;
  date: string;
  time: string;
}

export interface TeamFixture {
  team: string;
  opponent: string;
  round: number;
  date: string;
  time: string;
}

export class FixtureProcessor {
  private fixtures: FixtureMatch[] = [];
  private teamFixtures: Map<string, TeamFixture[]> = new Map();

  constructor() {
    this.loadFixtures();
    this.processTeamFixtures();
  }

  private loadFixtures() {
    try {
      const fixturePath = path.join(process.cwd(), 'assets/production/afl_fixture_2025_1753111987231.json');
      const rawData = fs.readFileSync(fixturePath, 'utf8');
      this.fixtures = JSON.parse(rawData);
      console.log(`Loaded ${this.fixtures.length} fixture matches`);
    } catch (error) {
      console.error('Error loading fixture data:', error);
      this.fixtures = [];
    }
  }

  private processTeamFixtures() {
    // Process each fixture and create team-specific fixture lists
    this.fixtures.forEach(match => {
      const teams = match.teams.split(' vs ');
      if (teams.length === 2) {
        const [team1, team2] = teams;
        
        // Add fixture for team1
        if (!this.teamFixtures.has(team1)) {
          this.teamFixtures.set(team1, []);
        }
        this.teamFixtures.get(team1)?.push({
          team: team1,
          opponent: team2,
          round: match.round,
          date: match.date,
          time: match.time
        });

        // Add fixture for team2
        if (!this.teamFixtures.has(team2)) {
          this.teamFixtures.set(team2, []);
        }
        this.teamFixtures.get(team2)?.push({
          team: team2,
          opponent: team1,
          round: match.round,
          date: match.date,
          time: match.time
        });
      }
    });

    console.log(`Processed fixtures for ${this.teamFixtures.size} teams`);
  }

  public getNextOpponent(team: string, currentRound: number = 20): string | null {
    const teamFixtures = this.teamFixtures.get(team);
    if (!teamFixtures) return null;

    const nextFixture = teamFixtures.find(fixture => fixture.round >= currentRound);
    return nextFixture ? nextFixture.opponent : null;
  }

  public getUpcomingFixtures(team: string, currentRound: number = 20, count: number = 5): TeamFixture[] {
    const teamFixtures = this.teamFixtures.get(team);
    if (!teamFixtures) return [];

    return teamFixtures
      .filter(fixture => fixture.round >= currentRound)
      .slice(0, count);
  }

  public getCurrentRound(): number {
    // Since we just completed Round 19, current round for projections is 20
    return 20;
  }

  public getAllTeams(): string[] {
    return Array.from(this.teamFixtures.keys());
  }

  // Map team abbreviations from player data to fixture team names
  private teamMapping: Record<string, string> = {
    'ADE': 'ADE', 'BRL': 'BRI', 'CAR': 'CAR', 'COL': 'COL', 
    'ESS': 'ESS', 'FRE': 'FRE', 'GEE': 'GEE', 'GCS': 'GCS',
    'GWS': 'GWS', 'HAW': 'HAW', 'MEL': 'MEL', 'NTH': 'NTH',
    'PTA': 'PTA', 'RIC': 'RIC', 'STK': 'STK', 'SYD': 'SYD',
    'WBD': 'WBD', 'WCE': 'WCE'
  };

  public mapTeamToFixture(playerTeam: string): string {
    return this.teamMapping[playerTeam] || playerTeam;
  }
}