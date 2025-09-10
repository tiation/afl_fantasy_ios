import Redis from 'ioredis'
import { logger } from '../lib/logger'
import type { 
  PlayerStats, 
  VenueStats,
  Alert,
  NewsItem,
  TeamStructure,
  PriceProjection,
  DVPStats
} from '../types'

const REDIS_URL = process.env.REDIS_URL || 'redis://localhost:6379'

// Cache TTL Constants
const TTL = {
  SHORT: 300,    // 5 minutes
  MEDIUM: 3600,  // 1 hour
  LONG: 86400,   // 24 hours
  WEEK: 604800   // 1 week
}

/**
 * CacheService
 * 
 * Centralized caching service for:
 * - Player statistics
 * - AI predictions
 * - Price trends
 * - Team data
 * 
 * Uses Redis for fast retrieval and real-time updates
 */
class CacheService {
  private static instance: CacheService
  private redis: Redis
  private connected: boolean = false
  
  private constructor() {
    this.redis = new Redis(REDIS_URL)
    this.initialize()
  }
  
  public static getInstance(): CacheService {
    if (!CacheService.instance) {
      CacheService.instance = new CacheService()
    }
    return CacheService.instance
  }

  private async initialize() {
    try {
      // Test connection
      await this.redis.ping()
      this.connected = true
      logger.info('Redis connection established')
      
      // Setup key eviction monitoring
      this.monitorKeyEviction()
    } catch (error) {
      logger.error('Redis connection failed', error)
      throw error
    }
  }

  // Player Stats Caching

  public async cachePlayerStats(
    player: PlayerStats,
    ttl: number = TTL.MEDIUM
  ): Promise<void> {
    const key = `player:${player.id}`
    await this.set(key, player, ttl)

    // Also maintain a set of all cached player IDs
    await this.redis.sadd('cached_player_ids', player.id)
  }

  public async getPlayerStats(
    playerId: string
  ): Promise<PlayerStats | null> {
    const key = `player:${playerId}`
    return this.get<PlayerStats>(key)
  }

  public async batchGetPlayerStats(
    playerIds: string[]
  ): Promise<Record<string, PlayerStats>> {
    const pipeline = this.redis.pipeline()
    playerIds.forEach(id => {
      pipeline.get(`player:${id}`)
    })

    const results = await pipeline.exec()
    if (!results) return {}

    const players: Record<string, PlayerStats> = {}
    results.forEach((result, index) => {
      if (result[1]) {
        const player = JSON.parse(result[1] as string)
        players[playerIds[index]] = player
      }
    })

    return players
  }

  // Price Trend Caching

  public async cachePriceProjections(
    playerId: string,
    projections: PriceProjection[],
    weeks: number
  ): Promise<void> {
    const key = `price_proj:${playerId}:${weeks}`
    await this.set(key, projections, TTL.MEDIUM)
  }

  public async getPriceProjections(
    playerId: string,
    weeks: number
  ): Promise<PriceProjection[] | null> {
    const key = `price_proj:${playerId}:${weeks}`
    return this.get<PriceProjection[]>(key)
  }

  public async cacheRecentPriceChanges(
    changes: Record<string, number>
  ): Promise<void> {
    await this.set('recent_price_changes', changes, TTL.SHORT)
  }

  public async getRecentPriceChanges(): Promise<Record<string, number> | null> {
    return this.get<Record<string, number>>('recent_price_changes')
  }

  // Team Data Caching

  public async cacheTeamStructure(
    teamId: string,
    structure: TeamStructure
  ): Promise<void> {
    const key = `team:${teamId}:structure`
    await this.set(key, structure, TTL.MEDIUM)
  }

  public async getTeamStructure(
    teamId: string
  ): Promise<TeamStructure | null> {
    const key = `team:${teamId}:structure`
    return this.get<TeamStructure>(key)
  }

  public async cacheDVPStats(
    teamId: string,
    stats: DVPStats
  ): Promise<void> {
    const key = `dvp:${teamId}`
    await this.set(key, stats, TTL.LONG)
  }

  public async getDVPStats(
    teamId: string
  ): Promise<DVPStats | null> {
    const key = `dvp:${teamId}`
    return this.get<DVPStats>(key)
  }

  // Venue Stats Caching

  public async cacheVenueStats(
    venueId: string,
    stats: VenueStats
  ): Promise<void> {
    const key = `venue:${venueId}`
    await this.set(key, stats, TTL.LONG)
  }

  public async getVenueStats(
    venueId: string
  ): Promise<VenueStats | null> {
    const key = `venue:${venueId}`
    return this.get<VenueStats>(key)
  }

  // AI Predictions Caching

  public async cacheAIPrediction(
    type: string,
    key: string,
    prediction: any,
    ttl: number = TTL.MEDIUM
  ): Promise<void> {
    const cacheKey = `ai_pred:${type}:${key}`
    await this.set(cacheKey, prediction, ttl)
  }

  public async getAIPrediction(
    type: string,
    key: string
  ): Promise<any> {
    const cacheKey = `ai_pred:${type}:${key}`
    return this.get(cacheKey)
  }

  // News & Alerts Caching

  public async cacheNewsItems(
    items: NewsItem[],
    category?: string
  ): Promise<void> {
    const key = `news:${category || 'all'}`
    await this.set(key, items, TTL.SHORT)

    // Maintain news item IDs by category
    const newsIds = items.map(item => item.id)
    if (category) {
      await this.redis.sadd(`news_ids:${category}`, ...newsIds)
    }
  }

  public async getNewsItems(
    category?: string
  ): Promise<NewsItem[] | null> {
    const key = `news:${category || 'all'}`
    return this.get<NewsItem[]>(key)
  }

  public async cacheAlert(
    alert: Alert
  ): Promise<void> {
    // Add to recent alerts list
    const recentAlerts = await this.getRecentAlerts()
    recentAlerts.unshift(alert)
    
    // Keep last 100 alerts
    if (recentAlerts.length > 100) {
      recentAlerts.pop()
    }

    await this.set('recent_alerts', recentAlerts, TTL.LONG)
  }

  public async getRecentAlerts(): Promise<Alert[]> {
    const alerts = await this.get<Alert[]>('recent_alerts')
    return alerts || []
  }

  // Cache Management

  public async clearCache(
    pattern: string
  ): Promise<number> {
    try {
      const keys = await this.redis.keys(pattern)
      if (keys.length > 0) {
        const pipeline = this.redis.pipeline()
        keys.forEach(key => {
          pipeline.del(key)
        })
        await pipeline.exec()
      }
      return keys.length
    } catch (error) {
      logger.error('Error clearing cache', error)
      return 0
    }
  }

  public async getCacheSize(
    pattern?: string
  ): Promise<{
    keys: number
    memory: number  // in bytes
  }> {
    try {
      const keys = pattern ?
        await this.redis.keys(pattern) :
        await this.redis.dbsize()
      
      const info = await this.redis.info('memory')
      const memoryMatch = info.match(/used_memory:(\d+)/)
      const memory = memoryMatch ? parseInt(memoryMatch[1]) : 0

      return {
        keys: typeof keys === 'number' ? keys : keys.length,
        memory
      }
    } catch (error) {
      logger.error('Error getting cache size', error)
      return { keys: 0, memory: 0 }
    }
  }

  public async getCacheStats(): Promise<{
    hits: number
    misses: number
    evicted: number
  }> {
    try {
      const info = await this.redis.info('stats')
      const stats = {
        hits: 0,
        misses: 0,
        evicted: 0
      }

      const hitMatch = info.match(/keyspace_hits:(\d+)/)
      if (hitMatch) stats.hits = parseInt(hitMatch[1])

      const missMatch = info.match(/keyspace_misses:(\d+)/)
      if (missMatch) stats.misses = parseInt(missMatch[1])

      const evictedMatch = info.match(/evicted_keys:(\d+)/)
      if (evictedMatch) stats.evicted = parseInt(evictedMatch[1])

      return stats
    } catch (error) {
      logger.error('Error getting cache stats', error)
      return { hits: 0, misses: 0, evicted: 0 }
    }
  }

  // Private Helper Methods

  private async set(
    key: string,
    value: any,
    ttl: number
  ): Promise<void> {
    try {
      await this.redis.set(
        key,
        JSON.stringify(value),
        'EX',
        ttl
      )
    } catch (error) {
      logger.error('Error setting cache value', error)
    }
  }

  private async get<T>(key: string): Promise<T | null> {
    try {
      const value = await this.redis.get(key)
      return value ? JSON.parse(value) : null
    } catch (error) {
      logger.error('Error getting cache value', error)
      return null
    }
  }

  private monitorKeyEviction() {
    const monitor = new Redis(REDIS_URL)
    monitor.subscribe('__keyevent@0__:expired')
    monitor.on('message', (channel, key) => {
      logger.info(`Cache key expired: ${key}`)
    })
  }

  public destroy() {
    if (this.connected) {
      this.redis.quit()
      this.connected = false
    }
  }
}

export const cacheService = CacheService.getInstance()
