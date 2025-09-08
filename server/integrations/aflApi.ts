import axios from 'axios'
import type { NewsItem } from '../types'
import { logger } from '../lib/logger'
import { redis } from '../lib/redis'

const API_KEY = process.env.AFL_API_KEY
const API_BASE = 'https://api.afl.com.au/v1'

/**
 * AFL API Integration
 * 
 * Provides access to official AFL data including:
 * - Fixtures
 * - Team data
 * - Venue information
 * - Live scores
 */
class AFLAPI {
  private static instance: AFLAPI
  private readonly CACHE_TTL = 3600 // 1 hour
  
  private constructor() {}
  
  public static getInstance(): AFLAPI {
    if (!AFLAPI.instance) {
      AFLAPI.instance = new AFLAPI()
    }
    return AFLAPI.instance
  }

  /**
   * Get fixture list for a specific round
   */
  public async getRoundFixtures(
    round: number
  ): Promise<any[]> {
    try {
      const cacheKey = `fixtures:${round}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/fixtures`,
        {
          params: { round },
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      await redis.set(
        cacheKey,
        JSON.stringify(response.data),
        'EX',
        this.CACHE_TTL
      )

      return response.data
    } catch (error) {
      logger.error('Error getting round fixtures', error)
      return []
    }
  }

  /**
   * Get venue information
   */
  public async getVenueInfo(
    venueId: string
  ): Promise<{
    id: string
    name: string
    latitude: number
    longitude: number
    capacity: number
  } | null> {
    try {
      const cacheKey = `venue:${venueId}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/venues/${venueId}`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const venue = {
        id: response.data.id,
        name: response.data.name,
        latitude: response.data.latitude,
        longitude: response.data.longitude,
        capacity: response.data.capacity
      }

      await redis.set(
        cacheKey,
        JSON.stringify(venue),
        'EX',
        this.CACHE_TTL * 24 // 24 hours
      )

      return venue
    } catch (error) {
      logger.error('Error getting venue info', error)
      return null
    }
  }

  /**
   * Get live scores for current games
   */
  public async getLiveScores(): Promise<{
    games: {
      id: string
      homeTeam: string
      awayTeam: string
      homeScore: number
      awayScore: number
      quarter: number
      timeLeft?: string
      isComplete: boolean
    }[]
  }> {
    try {
      const response = await axios.get(
        `${API_BASE}/live/scores`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      return {
        games: response.data.map((game: any) => ({
          id: game.id,
          homeTeam: game.homeTeam.id,
          awayTeam: game.awayTeam.id,
          homeScore: game.homeTeam.score,
          awayScore: game.awayTeam.score,
          quarter: game.quarter,
          timeLeft: game.timeLeft,
          isComplete: game.status === 'COMPLETE'
        }))
      }
    } catch (error) {
      logger.error('Error getting live scores', error)
      return { games: [] }
    }
  }

  /**
   * Get team list
   */
  public async getTeams(): Promise<{
    id: string
    name: string
    shortName: string
    venue: string
  }[]> {
    try {
      const cacheKey = 'teams'
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/teams`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const teams = response.data.map((team: any) => ({
        id: team.id,
        name: team.name,
        shortName: team.shortName,
        venue: team.venue
      }))

      await redis.set(
        cacheKey,
        JSON.stringify(teams),
        'EX',
        this.CACHE_TTL * 24 // 24 hours
      )

      return teams
    } catch (error) {
      logger.error('Error getting teams', error)
      return []
    }
  }

  /**
   * Get team injuries
   */
  public async getTeamInjuries(
    teamId: string
  ): Promise<{
    playerId: string
    injury: string
    estimatedReturn: string | null
    updated: string
  }[]> {
    try {
      const cacheKey = `injuries:${teamId}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/teams/${teamId}/injuries`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const injuries = response.data.map((injury: any) => ({
        playerId: injury.player.id,
        injury: injury.description,
        estimatedReturn: injury.estimatedReturn,
        updated: injury.lastUpdated
      }))

      await redis.set(
        cacheKey,
        JSON.stringify(injuries),
        'EX',
        this.CACHE_TTL
      )

      return injuries
    } catch (error) {
      logger.error('Error getting team injuries', error)
      return []
    }
  }

  /**
   * Get venue historical stats
   */
  public async getVenueStats(
    venueId: string,
    season?: number
  ): Promise<{
    gamesPlayed: number
    averageScore: number
    averageDisposal: number
    weatherImpact: number
  } | null> {
    try {
      const cacheKey = `venue_stats:${venueId}:${season || 'all'}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/venues/${venueId}/stats${season ? `/${season}` : ''}`,
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const stats = {
        gamesPlayed: response.data.gamesPlayed,
        averageScore: response.data.averageScore,
        averageDisposal: response.data.averageDisposals,
        weatherImpact: response.data.weatherImpact
      }

      await redis.set(
        cacheKey,
        JSON.stringify(stats),
        'EX',
        this.CACHE_TTL * 24 // 24 hours
      )

      return stats
    } catch (error) {
      logger.error('Error getting venue stats', error)
      return null
    }
  }
}

export const aflApi = AFLAPI.getInstance()
