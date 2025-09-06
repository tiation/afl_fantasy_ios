/**
 * AFL Fantasy Official API Integration
 * 
 * This module handles authentication and data fetching from the official AFL Fantasy website
 * to get real user data, team composition, scores, and league statistics.
 */

import axios from 'axios';

interface AFLFantasySession {
  sessionToken?: string;
  userId?: string;
  teamId?: string;
}

class AFLFantasyAPI {
  private session: AFLFantasySession = {};
  private baseURL = 'https://fantasy.afl.com.au/api';
  
  constructor() {}

  /**
   * Authenticate with AFL Fantasy using stored credentials
   */
  async authenticate(): Promise<boolean> {
    try {
      const username = process.env.AFL_FANTASY_USERNAME;
      const password = process.env.AFL_FANTASY_PASSWORD;

      if (!username || !password) {
        console.error('AFL Fantasy credentials not found in environment variables');
        return false;
      }

      // Step 1: Get initial login page to establish session
      const loginPageResponse = await axios.get('https://fantasy.afl.com.au/login');
      
      // Step 2: Submit login credentials
      const loginResponse = await axios.post('https://fantasy.afl.com.au/api/auth/login', {
        username: username,
        password: password
      }, {
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
        withCredentials: true
      });

      if (loginResponse.data && loginResponse.data.success) {
        this.session.sessionToken = loginResponse.data.token;
        this.session.userId = loginResponse.data.userId;
        this.session.teamId = loginResponse.data.teamId;
        
        console.log('Successfully authenticated with AFL Fantasy');
        return true;
      }

      return false;
    } catch (error) {
      console.error('AFL Fantasy authentication failed:', error instanceof Error ? error.message : 'Unknown error');
      return false;
    }
  }

  /**
   * Get user's current team composition
   */
  async getTeamData(): Promise<any> {
    if (!this.session.sessionToken) {
      await this.authenticate();
    }

    try {
      const response = await axios.get(`${this.baseURL}/teams/${this.session.teamId}`, {
        headers: {
          'Authorization': `Bearer ${this.session.sessionToken}`,
          'Accept': 'application/json'
        }
      });

      return response.data;
    } catch (error) {
      console.error('Failed to fetch team data:', error.message);
      return null;
    }
  }

  /**
   * Get user's league ranking and performance data
   */
  async getUserRanking(): Promise<any> {
    if (!this.session.sessionToken) {
      await this.authenticate();
    }

    try {
      const response = await axios.get(`${this.baseURL}/users/${this.session.userId}/ranking`, {
        headers: {
          'Authorization': `Bearer ${this.session.sessionToken}`,
          'Accept': 'application/json'
        }
      });

      return response.data;
    } catch (error) {
      console.error('Failed to fetch user ranking:', error.message);
      return null;
    }
  }

  /**
   * Get live scores for current round
   */
  async getLiveScores(): Promise<any> {
    try {
      const response = await axios.get(`${this.baseURL}/scores/live`, {
        headers: {
          'Accept': 'application/json'
        }
      });

      return response.data;
    } catch (error) {
      console.error('Failed to fetch live scores:', error.message);
      return null;
    }
  }

  /**
   * Get captain statistics for current round
   */
  async getCaptainStats(): Promise<any> {
    try {
      const response = await axios.get(`${this.baseURL}/stats/captains`, {
        headers: {
          'Accept': 'application/json'
        }
      });

      return response.data;
    } catch (error) {
      console.error('Failed to fetch captain stats:', error.message);
      return null;
    }
  }

  /**
   * Get all player data including prices and statistics
   */
  async getPlayerData(): Promise<any> {
    try {
      const response = await axios.get(`${this.baseURL}/players/all`, {
        headers: {
          'Accept': 'application/json'
        }
      });

      return response.data;
    } catch (error) {
      console.error('Failed to fetch player data:', error.message);
      return null;
    }
  }

  /**
   * Get historical round data for performance charts
   */
  async getRoundHistory(): Promise<any> {
    if (!this.session.sessionToken) {
      await this.authenticate();
    }

    try {
      const response = await axios.get(`${this.baseURL}/teams/${this.session.teamId}/history`, {
        headers: {
          'Authorization': `Bearer ${this.session.sessionToken}`,
          'Accept': 'application/json'
        }
      });

      return response.data;
    } catch (error) {
      console.error('Failed to fetch round history:', error.message);
      return null;
    }
  }
}

// Create singleton instance
export const aflFantasyAPI = new AFLFantasyAPI();

export default AFLFantasyAPI;