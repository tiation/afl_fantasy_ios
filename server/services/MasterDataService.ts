import type { 
  PlayerStats, 
  VenueStats, 
  TeamStructure, 
  WeatherForecast,
  PriceProjection,
  DVPStats,
  InjuryReport,
  NewsItem
} from '../types'
import { redis } from '../lib/redis'
import { db } from '../lib/db'
import { logger } from '../lib/logger'
import { weatherApi } from '../lib/weather'
import { statsApi } from '../lib/afl-stats'
import { newsApi } from '../lib/news'

/**
 * MasterDataService
 * 
 * Central data management service that provides a single source of truth
 * for all AFL Fantasy data. Handles caching, updates, and data integration
 * from multiple sources.
 */
export class MasterDataService {
  private static instance: MasterDataService
  private updateInterval: NodeJS.Timer | null = null
  private readonly CACHE_TTL = 300 // 5 minutes
  private readonly LONG_CACHE_TTL = 3600 // 1 hour
  
  private constructor() {
    this.initializeService()
  }

  public static getInstance(): MasterDataService {
    if (!MasterDataService.instance) {
      MasterDataService.instance = new MasterDataService()
    }
    return MasterDataService.instance
  }

  private async initializeService() {
    try {
      // Initial data load
      await this.refreshAllData()
      
      // Setup update interval (every 5 minutes)
      this.updateInterval = setInterval(() => {
        this.refreshAllData()
      }, 300000)
      
      logger.info('MasterDataService initialized successfully')
    } catch (error) {
      logger.error('Failed to initialize MasterDataService', error)
    }
  }

  private async refreshAllData() {
    try {
      await Promise.all([
        this.refreshPlayerStats(),
        this.refreshVenueStats(),
        this.refreshWeatherData(),
        this.refreshNewsData(),
        this.refreshInjuryReports(),
        this.refreshDVPStats()
      ])
    } catch (error) {
      logger.error('Error refreshing data', error)
    }
  }

  // Player Stats Methods

  public async getPlayerStats(playerId: string): Promise<PlayerStats | null> {
    try {
      // Try cache first
      const cached = await redis.get(`player:${playerId}`)
      if (cached) {
        return JSON.parse(cached)
      }

      // Fetch from database
      const player = await db.player.findUnique({
        where: { id: playerId },
        include: {
          recentGames: true,
          projections: true,
          injuryHistory: true
        }
      })

      if (!player) return null

      // Add enriched data
      const enriched = await this.enrichPlayerData(player)
      
      // Cache result
      await redis.set(
        `player:${playerId}`, 
        JSON.stringify(enriched), 
        'EX', 
        this.CACHE_TTL
      )

      return enriched
    } catch (error) {
      logger.error('Error getting player stats', error)
      return null
    }
  }

  private async enrichPlayerData(player: any): Promise<PlayerStats> {
    // Add venue performance data
    const venueStats = await this.getPlayerVenueStats(player.id)
    
    // Add consistency score
    const consistency = this.calculateConsistencyScore(player.recentGames)
    
    // Add form factor
    const formFactor = this.calculateFormFactor(player.recentGames)
    
    // Add DVP impact
    const dvpImpact = await this.calculateDVPImpact(player)
    
    return {
      ...player,
      venueStats,
      consistency,
      formFactor,
      dvpImpact
    }
  }

  // Venue Statistics Methods

  public async getVenueStats(venueId: string): Promise<VenueStats | null> {
    try {
      const cached = await redis.get(`venue:${venueId}`)
      if (cached) {
        return JSON.parse(cached)
      }

      const venue = await db.venue.findUnique({
        where: { id: venueId },
        include: {
          games: {
            take: 20,
            orderBy: { date: 'desc' }
          }
        }
      })

      if (!venue) return null

      // Calculate position bias
      const positionBias = this.calculatePositionBias(venue.games)
      
      // Get weather impact
      const weatherImpact = await this.calculateWeatherImpact(venue)
      
      const stats: VenueStats = {
        ...venue,
        positionBias,
        weatherImpact
      }

      await redis.set(
        `venue:${venueId}`,
        JSON.stringify(stats),
        'EX',
        this.LONG_CACHE_TTL
      )

      return stats
    } catch (error) {
      logger.error('Error getting venue stats', error)
      return null
    }
  }

  // Price Prediction Methods

  public async getPriceProjections(
    playerIds: string[], 
    weeks: number
  ): Promise<Record<string, PriceProjection[]>> {
    try {
      const projections: Record<string, PriceProjection[]> = {}
      
      await Promise.all(playerIds.map(async (playerId) => {
        const cached = await redis.get(`price_proj:${playerId}:${weeks}`)
        if (cached) {
          projections[playerId] = JSON.parse(cached)
          return
        }

        const playerStats = await this.getPlayerStats(playerId)
        if (!playerStats) return

        const projection = this.calculatePriceProjection(playerStats, weeks)
        projections[playerId] = projection

        await redis.set(
          `price_proj:${playerId}:${weeks}`,
          JSON.stringify(projection),
          'EX',
          this.CACHE_TTL
        )
      }))

      return projections
    } catch (error) {
      logger.error('Error getting price projections', error)
      return {}
    }
  }

  // Team Analysis Methods

  public async analyzeTeamStructure(
    playerIds: string[]
  ): Promise<TeamStructure> {
    try {
      const players = await Promise.all(
        playerIds.map(id => this.getPlayerStats(id))
      )

      const validPlayers = players.filter((p): p is PlayerStats => p !== null)

      const structure: TeamStructure = {
        totalValue: validPlayers.reduce((sum, p) => sum + p.price, 0),
        bankBalance: 0, // Set by caller
        positionBalance: this.calculatePositionBalance(validPlayers),
        premiumCount: validPlayers.filter(p => p.price >= 600000).length,
        midPriceCount: validPlayers.filter(p => p.price >= 300000 && p.price < 600000).length,
        rookieCount: validPlayers.filter(p => p.price < 300000).length
      }

      return structure
    } catch (error) {
      logger.error('Error analyzing team structure', error)
      throw error
    }
  }

  // Weather Integration Methods

  public async getWeatherForecast(venueId: string): Promise<WeatherForecast | null> {
    try {
      const venue = await db.venue.findUnique({
        where: { id: venueId },
        select: { 
          latitude: true, 
          longitude: true 
        }
      })

      if (!venue) return null

      const forecast = await weatherApi.getForecast(
        venue.latitude,
        venue.longitude
      )

      return forecast
    } catch (error) {
      logger.error('Error getting weather forecast', error)
      return null
    }
  }

  // News & Updates Methods

  public async getLatestNews(playerId?: string): Promise<NewsItem[]> {
    try {
      if (playerId) {
        const cached = await redis.get(`news:player:${playerId}`)
        if (cached) {
          return JSON.parse(cached)
        }
      }

      const news = await newsApi.getLatestNews(playerId)
      
      if (playerId) {
        await redis.set(
          `news:player:${playerId}`,
          JSON.stringify(news),
          'EX',
          300 // 5 minutes
        )
      }

      return news
    } catch (error) {
      logger.error('Error getting latest news', error)
      return []
    }
  }

  // Injury Tracking Methods

  public async getInjuryReport(playerId: string): Promise<InjuryReport | null> {
    try {
      const cached = await redis.get(`injury:${playerId}`)
      if (cached) {
        return JSON.parse(cached)
      }

      const report = await db.injuryReport.findFirst({
        where: { playerId },
        orderBy: { timestamp: 'desc' }
      })

      if (report) {
        await redis.set(
          `injury:${playerId}`,
          JSON.stringify(report),
          'EX',
          1800 // 30 minutes
        )
      }

      return report
    } catch (error) {
      logger.error('Error getting injury report', error)
      return null
    }
  }

  // DVP (Defense vs Position) Analysis Methods

  public async getDVPStats(teamId: string): Promise<DVPStats | null> {
    try {
      const cached = await redis.get(`dvp:${teamId}`)
      if (cached) {
        return JSON.parse(cached)
      }

      const stats = await statsApi.getDVPStats(teamId)
      
      if (stats) {
        await redis.set(
          `dvp:${teamId}`,
          JSON.stringify(stats),
          'EX',
          this.LONG_CACHE_TTL
        )
      }

      return stats
    } catch (error) {
      logger.error('Error getting DVP stats', error)
      return null
    }
  }

  // Utility Methods

  private calculateConsistencyScore(games: any[]): string {
    const scores = games.map(g => g.score)
    const avg = scores.reduce((a, b) => a + b, 0) / scores.length
    const variance = scores.reduce((a, b) => a + Math.pow(b - avg, 2), 0) / scores.length
    const stdDev = Math.sqrt(variance)

    if (stdDev <= 10) return 'A'
    if (stdDev <= 15) return 'B'
    if (stdDev <= 20) return 'C'
    return 'D'
  }

  private calculateFormFactor(games: any[]): number {
    // Weight recent games more heavily
    const weights = [1.0, 0.8, 0.6, 0.4, 0.2]
    let weightedSum = 0
    let weightSum = 0

    games.slice(0, 5).forEach((game, i) => {
      weightedSum += game.score * weights[i]
      weightSum += weights[i]
    })

    return weightedSum / weightSum
  }

  private calculatePositionBias(games: any[]): Record<string, number> {
    // Calculate how each position performs relative to average at this venue
    const positions = ['DEF', 'MID', 'RUC', 'FWD']
    const bias: Record<string, number> = {}

    positions.forEach(pos => {
      const posScores = games.flatMap(g => 
        g.playerStats
          .filter((p: any) => p.position === pos)
          .map((p: any) => p.score)
      )
      
      const posAvg = posScores.reduce((a, b) => a + b, 0) / posScores.length
      const leagueAvg = this.getLeagueAverageForPosition(pos)
      
      bias[pos] = posAvg / leagueAvg
    })

    return bias
  }

  private async calculateWeatherImpact(venue: any): Promise<number> {
    const forecast = await this.getWeatherForecast(venue.id)
    if (!forecast) return 0

    // Calculate impact based on rain probability and wind speed
    const rainImpact = -0.1 * forecast.rainProbability
    const windImpact = -0.05 * (forecast.windSpeed > 20 ? forecast.windSpeed - 20 : 0)

    return rainImpact + windImpact
  }

  private getLeagueAverageForPosition(position: string): number {
    // Hardcoded for now - should be calculated from database
    const averages: Record<string, number> = {
      'DEF': 75,
      'MID': 95,
      'RUC': 85,
      'FWD': 70
    }
    return averages[position] || 80
  }

  private calculatePriceProjection(
    player: PlayerStats,
    weeks: number
  ): PriceProjection[] {
    const projections: PriceProjection[] = []
    let currentPrice = player.price
    let currentBE = player.breakeven

    for (let i = 1; i <= weeks; i++) {
      const projected = player.projected
      const priceChange = (projected - currentBE) * 5000
      currentPrice += priceChange
      
      // Adjust breakeven based on new price
      currentBE = Math.round(currentPrice / 5000)

      projections.push({
        round: i,
        price: currentPrice,
        confidence: Math.max(0, 100 - (i * 5)) // Confidence decreases with time
      })
    }

    return projections
  }

  public destroy() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval)
    }
  }
}

export const masterData = MasterDataService.getInstance()
