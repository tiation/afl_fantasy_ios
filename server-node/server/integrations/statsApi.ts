import axios from 'axios'
import type { DVPStats, PlayerGameStats } from '../types'
import { logger } from '../lib/logger'
import { redis } from '../lib/redis'

const API_KEY = process.env.AFL_STATS_API_KEY
const API_BASE = 'https://api.afl.com.au/statspro/v1'

/**
 * AFL Stats API Integration
 * 
 * Provides access to official AFL statistics and player data
 */
class StatsAPI {
  private static instance: StatsAPI
  private readonly CACHE_TTL = 3600 // 1 hour
  
  private constructor() {}
  
  public static getInstance(): StatsAPI {
    if (!StatsAPI.instance) {
      StatsAPI.instance = new StatsAPI()
    }
    return StatsAPI.instance
  }

  /**
   * Get DVP (Defense vs Position) stats for a team
   */
  public async getDVPStats(teamId: string): Promise<DVPStats | null> {
    try {
      // Try cache first
      const cached = await redis.get(`dvp:${teamId}`)
      if (cached) {
        return JSON.parse(cached)
      }

      const games = await this.getTeamGames(teamId)
      const stats: DVPStats = {
        teamId,
        positions: {
          'DEF': await this.calculateDVPForPosition(games, 'DEF'),
          'MID': await this.calculateDVPForPosition(games, 'MID'),
          'RUC': await this.calculateDVPForPosition(games, 'RUC'),
          'FWD': await this.calculateDVPForPosition(games, 'FWD')
        }
      }

      // Cache results
      await redis.set(
        `dvp:${teamId}`,
        JSON.stringify(stats),
        'EX',
        this.CACHE_TTL
      )

      return stats
    } catch (error) {
      logger.error('Error getting DVP stats', error)
      return null
    }
  }

  /**
   * Get player game history
   */
  public async getPlayerHistory(
    playerId: string,
    season?: number
  ): Promise<PlayerGameStats[]> {
    try {
      const cacheKey = `history:${playerId}:${season || 'current'}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/players/${playerId}/games${season ? `/${season}` : ''}`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const stats = response.data.map((game: any) => ({
        playerId,
        score: this.calculateFantasyScore(game.stats),
        position: game.position
      }))

      await redis.set(
        cacheKey,
        JSON.stringify(stats),
        'EX',
        this.CACHE_TTL
      )

      return stats
    } catch (error) {
      logger.error('Error getting player history', error)
      return []
    }
  }

  /**
   * Get live game statistics
   */
  public async getLiveGameStats(
    gameId: string
  ): Promise<{
    players: PlayerGameStats[]
    isComplete: boolean
  }> {
    try {
      const response = await axios.get(
        `${API_BASE}/games/${gameId}/live`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      return {
        players: response.data.players.map((p: any) => ({
          playerId: p.id,
          score: this.calculateFantasyScore(p.stats),
          position: p.position
        })),
        isComplete: response.data.status === 'COMPLETE'
      }
    } catch (error) {
      logger.error('Error getting live game stats', error)
      return {
        players: [],
        isComplete: false
      }
    }
  }

  /**
   * Get league averages by position
   */
  public async getLeagueAverages(): Promise<Record<string, number>> {
    try {
      const cacheKey = 'league_averages'
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/stats/averages`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const averages = {
        'DEF': response.data.defenders,
        'MID': response.data.midfielders,
        'RUC': response.data.rucks,
        'FWD': response.data.forwards
      }

      await redis.set(
        cacheKey,
        JSON.stringify(averages),
        'EX',
        this.CACHE_TTL * 24 // 24 hours
      )

      return averages
    } catch (error) {
      logger.error('Error getting league averages', error)
      return {
        'DEF': 75,
        'MID': 95,
        'RUC': 85,
        'FWD': 70
      }
    }
  }

  // Private Helper Methods

  private async getTeamGames(
    teamId: string,
    limit: number = 5
  ): Promise<any[]> {
    const response = await axios.get(
      `${API_BASE}/teams/${teamId}/games`,
      {
        params: { limit },
        headers: {
          'Authorization': `Bearer ${API_KEY}`
        }
      }
    )
    return response.data
  }

  private async calculateDVPForPosition(
    games: any[],
    position: string
  ): Promise<{
    pointsAllowed: number
    rankAgainst: number
    lastFiveGames: number[]
  }> {
    const scores = games.map(game => {
      const oppositionPlayers = game.playerStats.filter(
        (p: any) => 
          p.team !== game.homeTeam &&
          p.position === position
      )
      return oppositionPlayers.reduce(
        (sum: number, p: any) => sum + this.calculateFantasyScore(p.stats),
        0
      ) / oppositionPlayers.length
    })

    const pointsAllowed = scores.reduce((a, b) => a + b, 0) / scores.length

    // Calculate rank (1-18, 1 being most points allowed)
    const allTeamPoints = await this.getAllTeamPointsAllowed(position)
    const sortedPoints = Object.values(allTeamPoints).sort((a, b) => b - a)
    const rankAgainst = sortedPoints.indexOf(pointsAllowed) + 1

    return {
      pointsAllowed,
      rankAgainst,
      lastFiveGames: scores.slice(0, 5)
    }
  }

  private async getAllTeamPointsAllowed(
    position: string
  ): Promise<Record<string, number>> {
    const cacheKey = `points_allowed:${position}`
    const cached = await redis.get(cacheKey)
    if (cached) {
      return JSON.parse(cached)
    }

    // This would normally fetch all team points allowed
    // For now, return dummy data
    const points: Record<string, number> = {
      'team1': 85,
      'team2': 82,
      // ... etc
    }

    await redis.set(
      cacheKey,
      JSON.stringify(points),
      'EX',
      this.CACHE_TTL
    )

    return points
  }

  private calculateFantasyScore(stats: any): number {
    return (
      stats.kicks * 3 +
      stats.handballs * 2 +
      stats.marks * 3 +
      stats.tackles * 4 +
      stats.hitouts * 1 +
      stats.freesFor * 1 +
      stats.freesAgainst * -3 +
      stats.goals * 6 +
      stats.behinds * 1
    )
  }
}

export const statsApi = StatsAPI.getInstance()
