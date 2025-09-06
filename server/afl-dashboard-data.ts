/**
 * AFL Fantasy Dashboard Data Service
 * 
 * Fetches specific data for each dashboard card based on exact requirements
 */

interface DashboardData {
  teamValue: {
    playerPricesSum: number;
    remainingSalary: number;
    totalValue: number;
  };
  teamScore: {
    roundScore: number;
    captainScore: number;
    emergencyScores: { [position: string]: number };
    bestEighteenDuringByes: number[];
  };
  overallRank: {
    currentRank: number;
    totalPlayers: number;
  };
  captainScore: {
    captainScore: number;
    captainName: string;
    captainPopularity: number;
    weekBeforeStats: number;
  };
  performanceChart: {
    roundScores: number[];
    projectedScores: number[];
    lineupHistory: any[];
    captainHistory: string[];
  };
  teamStructure: {
    byPosition: {
      defenders: PositionBreakdown;
      midfielders: PositionBreakdown;
      rucks: PositionBreakdown;
      forwards: PositionBreakdown;
    };
    totalSpentByPosition: {
      defenders: number;
      midfielders: number; 
      rucks: number;
      forwards: number;
    };
  };
}

interface PositionBreakdown {
  cashCows: number; // < $449,000
  midPricers: number; // $450,000-$799,000
  underpricedPremiums: number; // $800,000-$999,999
  premiums: number; // > $1,000,000
}

class AFLDashboardDataService {
  private baseUrl = 'https://fantasy.afl.com.au';
  private authHeaders: Record<string, string> = {};

  constructor() {
    if (process.env.AFL_FANTASY_AUTH_TOKEN) {
      this.authHeaders['Authorization'] = `Bearer ${process.env.AFL_FANTASY_AUTH_TOKEN}`;
    }
    if (process.env.AFL_FANTASY_SESSION_TOKEN) {
      this.authHeaders['Cookie'] = process.env.AFL_FANTASY_SESSION_TOKEN;
    }
  }

  /**
   * 1. Team Value Card Data
   */
  async getTeamValueData(): Promise<DashboardData['teamValue'] | null> {
    try {
      // Fetch user's complete team with prices
      const teamResponse = await this.authenticatedFetch('/api/classic/team');
      if (!teamResponse) return null;

      const players = this.extractAllPlayers(teamResponse);
      const playerPricesSum = players.reduce((sum, player) => sum + (player.price || 0), 0);
      
      // Fetch remaining salary
      const balanceResponse = await this.authenticatedFetch('/api/user/balance');
      const remainingSalary = balanceResponse?.remainingSalary || 0;

      return {
        playerPricesSum,
        remainingSalary,
        totalValue: playerPricesSum + remainingSalary
      };
    } catch (error) {
      console.error('Error fetching team value data:', error);
      return null;
    }
  }

  /**
   * 2. Team Score Card Data
   */
  async getTeamScoreData(round?: number): Promise<DashboardData['teamScore'] | null> {
    try {
      // Get current lineup (18 on-field players)
      const lineupResponse = await this.authenticatedFetch(`/api/classic/lineup${round ? `?round=${round}` : ''}`);
      if (!lineupResponse) return null;

      // Get individual player scores for current round
      const scoresResponse = await this.authenticatedFetch(`/api/scores/round${round ? `/${round}` : '/current'}`);
      
      // Get captain selection
      const captainResponse = await this.authenticatedFetch(`/api/classic/captain${round ? `?round=${round}` : ''}`);
      
      const onFieldPlayers = lineupResponse.onField || [];
      const playerScores = scoresResponse?.scores || {};
      const captainId = captainResponse?.captainId;

      let roundScore = 0;
      let captainScore = 0;
      const emergencyScores: { [position: string]: number } = {};

      // Calculate scores with captain doubling and emergency logic
      onFieldPlayers.forEach((player: any) => {
        const score = playerScores[player.id] || 0;
        
        if (player.id === captainId) {
          captainScore = score;
          roundScore += score * 2; // Captain gets doubled
        } else {
          roundScore += score;
        }

        // Handle emergency scores if player scored 0
        if (score === 0 && lineupResponse.emergencies) {
          const emergency = lineupResponse.emergencies.find((e: any) => e.position === player.position);
          if (emergency) {
            const emergencyScore = playerScores[emergency.id] || 0;
            emergencyScores[player.position] = emergencyScore;
            roundScore += emergencyScore;
          }
        }
      });

      return {
        roundScore,
        captainScore,
        emergencyScores,
        bestEighteenDuringByes: [] // Will implement bye round logic
      };
    } catch (error) {
      console.error('Error fetching team score data:', error);
      return null;
    }
  }

  /**
   * 3. Overall Rank Card Data
   */
  async getOverallRankData(): Promise<DashboardData['overallRank'] | null> {
    try {
      const rankResponse = await this.authenticatedFetch('/api/user/rank');
      if (!rankResponse) return null;

      return {
        currentRank: rankResponse.overallRank || 0,
        totalPlayers: rankResponse.totalPlayers || 0
      };
    } catch (error) {
      console.error('Error fetching rank data:', error);
      return null;
    }
  }

  /**
   * 4. Captain Score Card Data
   */
  async getCaptainScoreData(): Promise<DashboardData['captainScore'] | null> {
    try {
      const captainResponse = await this.authenticatedFetch('/api/classic/captain');
      const captainStatsResponse = await this.authenticatedFetch('/api/captain-stats');
      
      if (!captainResponse) return null;

      const captainId = captainResponse.captainId;
      const captainName = captainResponse.captainName;
      
      // Get captain's score
      const scoresResponse = await this.authenticatedFetch('/api/scores/round/current');
      const captainScore = scoresResponse?.scores?.[captainId] || 0;
      
      // Get captain popularity stats
      const popularityData = captainStatsResponse?.popularity?.[captainId] || {};

      return {
        captainScore,
        captainName,
        captainPopularity: popularityData.currentWeek || 0,
        weekBeforeStats: popularityData.previousWeek || 0
      };
    } catch (error) {
      console.error('Error fetching captain data:', error);
      return null;
    }
  }

  /**
   * 5. Performance Chart Data
   */
  async getPerformanceChartData(): Promise<DashboardData['performanceChart'] | null> {
    try {
      const historyResponse = await this.authenticatedFetch('/api/user/season-history');
      const projectionsResponse = await this.authenticatedFetch('/api/projections');
      
      if (!historyResponse) return null;

      return {
        roundScores: historyResponse.roundScores || [],
        projectedScores: projectionsResponse?.projectedScores || [],
        lineupHistory: historyResponse.lineupHistory || [],
        captainHistory: historyResponse.captainHistory || []
      };
    } catch (error) {
      console.error('Error fetching performance chart data:', error);
      return null;
    }
  }

  /**
   * 6. Team Structure Card Data
   */
  async getTeamStructureData(): Promise<DashboardData['teamStructure'] | null> {
    try {
      const teamResponse = await this.authenticatedFetch('/api/classic/team');
      if (!teamResponse) return null;

      const allPlayers = this.extractAllPlayers(teamResponse);
      
      const structure = {
        byPosition: {
          defenders: this.calculatePositionBreakdown(allPlayers, 'DEF'),
          midfielders: this.calculatePositionBreakdown(allPlayers, 'MID'),
          rucks: this.calculatePositionBreakdown(allPlayers, 'RUC'), 
          forwards: this.calculatePositionBreakdown(allPlayers, 'FWD')
        },
        totalSpentByPosition: {
          defenders: this.calculatePositionSpending(allPlayers, 'DEF'),
          midfielders: this.calculatePositionSpending(allPlayers, 'MID'),
          rucks: this.calculatePositionSpending(allPlayers, 'RUC'),
          forwards: this.calculatePositionSpending(allPlayers, 'FWD')
        }
      };

      return structure;
    } catch (error) {
      console.error('Error fetching team structure data:', error);
      return null;
    }
  }

  /**
   * Helper Methods
   */
  private async authenticatedFetch(endpoint: string): Promise<any> {
    try {
      const response = await fetch(`${this.baseUrl}${endpoint}`, {
        headers: {
          'Accept': 'application/json',
          ...this.authHeaders
        }
      });

      if (response.ok) {
        return await response.json();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  private extractAllPlayers(teamData: any): any[] {
    const players = [];
    
    // Extract on-field players
    if (teamData.onField) players.push(...teamData.onField);
    if (teamData.lineup) players.push(...teamData.lineup);
    
    // Extract bench players
    if (teamData.bench) players.push(...teamData.bench);
    
    return players;
  }

  private calculatePositionBreakdown(players: any[], position: string): PositionBreakdown {
    const positionPlayers = players.filter(p => p.position === position);
    
    return {
      cashCows: positionPlayers.filter(p => p.price < 449000).length,
      midPricers: positionPlayers.filter(p => p.price >= 450000 && p.price <= 799000).length,
      underpricedPremiums: positionPlayers.filter(p => p.price >= 800000 && p.price <= 999999).length,
      premiums: positionPlayers.filter(p => p.price >= 1000000).length
    };
  }

  private calculatePositionSpending(players: any[], position: string): number {
    return players
      .filter(p => p.position === position)
      .reduce((sum, p) => sum + (p.price || 0), 0);
  }
}

export const aflDashboardData = new AFLDashboardDataService();
export type { DashboardData };