/**
 * AFL Fantasy Data Integration Service
 * 
 * This service handles fetching authentic AFL Fantasy data once proper
 * authentication tokens are provided. It transforms the data into the
 * format expected by the dashboard components.
 */

interface AFLFantasyPlayer {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  averagePoints: number;
  lastScore: number;
  breakeven: number;
  games: number;
  status: string;
}

interface AFLFantasyTeam {
  id: number;
  name: string;
  totalValue: number;
  players: AFLFantasyPlayer[];
  captain: AFLFantasyPlayer;
  viceCaptain: AFLFantasyPlayer;
}

interface AFLFantasyUserData {
  userId: number;
  team: AFLFantasyTeam;
  currentRank: number;
  totalScore: number;
  roundScores: number[];
}

class AFLFantasyIntegration {
  private baseUrl = 'https://fantasy.afl.com.au';
  private authHeaders: Record<string, string> = {};

  constructor() {
    // Initialize with environment authentication tokens when available
    if (process.env.AFL_FANTASY_AUTH_TOKEN) {
      this.authHeaders['Authorization'] = `Bearer ${process.env.AFL_FANTASY_AUTH_TOKEN}`;
    }
    if (process.env.AFL_FANTASY_SESSION_TOKEN) {
      this.authHeaders['Cookie'] = process.env.AFL_FANTASY_SESSION_TOKEN;
    }
    if (process.env.AFL_FANTASY_API_KEY) {
      this.authHeaders['X-API-Key'] = process.env.AFL_FANTASY_API_KEY;
    }
  }

  /**
   * Check if authentication is properly configured
   */
  isAuthenticated(): boolean {
    return Object.keys(this.authHeaders).length > 0;
  }

  /**
   * Fetch user's team data from AFL Fantasy
   */
  async fetchUserTeam(): Promise<AFLFantasyTeam | null> {
    if (!this.isAuthenticated()) {
      console.log('AFL Fantasy authentication required for team data');
      return null;
    }

    try {
      // Try multiple potential endpoints for team data
      const endpoints = [
        '/api/classic/team',
        '/api/classic/my-team',
        '/api/user/team',
        '/api/teams/me'
      ];

      for (const endpoint of endpoints) {
        try {
          const response = await fetch(`${this.baseUrl}${endpoint}`, {
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'AFL-Fantasy-Dashboard/1.0',
              ...this.authHeaders
            }
          });

          if (response.ok) {
            const data = await response.json();
            
            // Check if this looks like team data
            if (this.isValidTeamData(data)) {
              return this.transformTeamData(data);
            }
          }
        } catch (error) {
          console.log(`Failed to fetch from ${endpoint}:`, error);
          continue;
        }
      }

      return null;
    } catch (error) {
      console.error('Error fetching team data:', error);
      return null;
    }
  }

  /**
   * Fetch user's performance data
   */
  async fetchUserPerformance(): Promise<AFLFantasyUserData | null> {
    if (!this.isAuthenticated()) {
      return null;
    }

    try {
      const endpoints = [
        '/api/user/profile',
        '/api/classic/stats',
        '/api/user/performance'
      ];

      for (const endpoint of endpoints) {
        try {
          const response = await fetch(`${this.baseUrl}${endpoint}`, {
            headers: {
              'Accept': 'application/json',
              ...this.authHeaders
            }
          });

          if (response.ok) {
            const data = await response.json();
            if (this.isValidUserData(data)) {
              return this.transformUserData(data);
            }
          }
        } catch (error) {
          continue;
        }
      }

      return null;
    } catch (error) {
      console.error('Error fetching user performance:', error);
      return null;
    }
  }

  /**
   * Fetch current player prices and stats
   */
  async fetchPlayerData(): Promise<AFLFantasyPlayer[] | null> {
    // This might be available without authentication
    try {
      const endpoints = [
        '/api/players',
        '/api/classic/players',
        '/api/player-stats'
      ];

      for (const endpoint of endpoints) {
        try {
          const response = await fetch(`${this.baseUrl}${endpoint}`, {
            headers: {
              'Accept': 'application/json',
              ...this.authHeaders
            }
          });

          if (response.ok) {
            const data = await response.json();
            if (Array.isArray(data) && data.length > 0) {
              return this.transformPlayerData(data);
            }
          }
        } catch (error) {
          continue;
        }
      }

      return null;
    } catch (error) {
      console.error('Error fetching player data:', error);
      return null;
    }
  }

  /**
   * Validate if response contains team data
   */
  private isValidTeamData(data: any): boolean {
    return data && (
      data.players || 
      data.team || 
      data.lineup ||
      (Array.isArray(data) && data.some(item => item.name && item.position))
    );
  }

  /**
   * Validate if response contains user performance data
   */
  private isValidUserData(data: any): boolean {
    return data && (
      data.rank || 
      data.totalScore || 
      data.scores ||
      data.performance
    );
  }

  /**
   * Transform AFL Fantasy team data to dashboard format
   */
  private transformTeamData(rawData: any): AFLFantasyTeam {
    // Transform based on actual AFL Fantasy API response format
    // This will be updated once we see the real API structure
    
    const players = rawData.players || rawData.lineup || [];
    const transformedPlayers = players.map((player: any) => ({
      id: player.id || 0,
      name: player.name || '',
      position: player.position || '',
      team: player.team || '',
      price: player.price || 0,
      averagePoints: player.averagePoints || player.avg || 0,
      lastScore: player.lastScore || player.score || 0,
      breakeven: player.breakeven || player.be || 0,
      games: player.games || 0,
      status: player.status || 'Available'
    }));

    return {
      id: rawData.id || 0,
      name: rawData.name || 'My Team',
      totalValue: rawData.totalValue || transformedPlayers.reduce((sum, p) => sum + p.price, 0),
      players: transformedPlayers,
      captain: transformedPlayers.find(p => p.id === rawData.captainId) || transformedPlayers[0],
      viceCaptain: transformedPlayers.find(p => p.id === rawData.viceCaptainId) || transformedPlayers[1]
    };
  }

  /**
   * Transform AFL Fantasy user data to dashboard format
   */
  private transformUserData(rawData: any): AFLFantasyUserData {
    return {
      userId: rawData.userId || rawData.id || 0,
      team: rawData.team || {} as AFLFantasyTeam,
      currentRank: rawData.rank || rawData.currentRank || 0,
      totalScore: rawData.totalScore || rawData.score || 0,
      roundScores: rawData.roundScores || rawData.scores || []
    };
  }

  /**
   * Transform AFL Fantasy player data to dashboard format
   */
  private transformPlayerData(rawData: any[]): AFLFantasyPlayer[] {
    return rawData.map(player => ({
      id: player.id || 0,
      name: player.name || '',
      position: player.position || '',
      team: player.team || '',
      price: player.price || 0,
      averagePoints: player.averagePoints || player.avg || 0,
      lastScore: player.lastScore || player.score || 0,
      breakeven: player.breakeven || player.be || 0,
      games: player.games || 0,
      status: player.status || 'Available'
    }));
  }
}

// Export singleton instance
export const aflFantasyIntegration = new AFLFantasyIntegration();

// Export types for use in other modules
export type { AFLFantasyPlayer, AFLFantasyTeam, AFLFantasyUserData };