/**
 * Champion Data AFL Sports API Integration
 * 
 * Official AFL statistics and match data from Champion Data
 */

interface ChampionDataCredentials {
  apiKey: string;
  clientId: string;
  secret: string;
}

class ChampionDataAPI {
  private baseUrl = 'https://api.afl.championdata.io';
  private credentials: ChampionDataCredentials;

  constructor() {
    this.credentials = {
      apiKey: process.env.CHAMPION_DATA_API_KEY || '',
      clientId: process.env.CHAMPION_DATA_CLIENT_ID || '',
      secret: process.env.CHAMPION_DATA_SECRET || ''
    };
  }

  /**
   * Check if API credentials are configured
   */
  isConfigured(): boolean {
    return !!(this.credentials.apiKey && this.credentials.clientId && this.credentials.secret);
  }

  /**
   * Get available leagues
   */
  async getLeagues() {
    try {
      const response = await fetch(`${this.baseUrl}/v1/leagues`, {
        headers: this.getAuthHeaders()
      });

      if (response.ok) {
        return await response.json();
      } else {
        console.error(`Champion Data API error: ${response.status} - ${response.statusText}`);
        return null;
      }
    } catch (error) {
      console.error('Error fetching leagues:', error);
      return null;
    }
  }

  /**
   * Get AFL league levels (like AFL, AFLW, etc.)
   */
  async getAFLLevels(leagueId = 1) {
    try {
      const response = await fetch(`${this.baseUrl}/v1/leagues/${leagueId}/levels`, {
        headers: this.getAuthHeaders()
      });

      if (response.ok) {
        return await response.json();
      } else {
        console.error(`Champion Data API error: ${response.status} - ${response.statusText}`);
        return null;
      }
    } catch (error) {
      console.error('Error fetching AFL levels:', error);
      return null;
    }
  }

  /**
   * Get player statistics for a specific match
   */
  async getMatchPlayerStats(matchId: number) {
    try {
      const response = await fetch(`${this.baseUrl}/v1/matches/${matchId}/statistics/players`, {
        headers: this.getAuthHeaders()
      });

      if (response.ok) {
        return await response.json();
      } else {
        console.error(`Champion Data API error: ${response.status} - ${response.statusText}`);
        return null;
      }
    } catch (error) {
      console.error('Error fetching match player stats:', error);
      return null;
    }
  }

  /**
   * Get match information
   */
  async getMatchInfo(matchId: number) {
    try {
      const response = await fetch(`${this.baseUrl}/v1/matches/${matchId}`, {
        headers: this.getAuthHeaders()
      });

      if (response.ok) {
        return await response.json();
      } else {
        console.error(`Champion Data API error: ${response.status} - ${response.statusText}`);
        return null;
      }
    } catch (error) {
      console.error('Error fetching match info:', error);
      return null;
    }
  }

  /**
   * Get available metrics for a match
   */
  async getMatchMetrics(matchId: number) {
    try {
      const response = await fetch(`${this.baseUrl}/v1/matches/${matchId}/metrics`, {
        headers: this.getAuthHeaders()
      });

      if (response.ok) {
        return await response.json();
      } else {
        console.error(`Champion Data API error: ${response.status} - ${response.statusText}`);
        return null;
      }
    } catch (error) {
      console.error('Error fetching match metrics:', error);
      return null;
    }
  }

  /**
   * Test API connection
   */
  async testConnection() {
    try {
      const leagues = await this.getLeagues();
      if (leagues) {
        console.log('Champion Data API connection successful');
        return { success: true, data: leagues };
      } else {
        console.log('Champion Data API connection failed');
        return { success: false, error: 'Failed to fetch leagues' };
      }
    } catch (error) {
      console.error('Champion Data API test failed:', error);
      return { success: false, error: error instanceof Error ? error.message : 'Unknown error' };
    }
  }

  /**
   * Private helper to get authentication headers
   */
  private getAuthHeaders(): Record<string, string> {
    const accessToken = process.env.CHAMPION_DATA_ACCESS_TOKEN;
    if (accessToken) {
      return {
        'Authorization': `Bearer ${accessToken}`,
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };
    }
    
    return {
      'Authorization': `Bearer ${this.credentials.apiKey}`,
      'X-Client-Id': this.credentials.clientId,
      'X-Client-Secret': this.credentials.secret,
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    };
  }
}

export const championDataAPI = new ChampionDataAPI();
export type { ChampionDataCredentials };