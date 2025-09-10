import axios from 'axios'
import type { NewsItem } from '../types'
import { logger } from '../lib/logger'
import { redis } from '../lib/redis'

const API_KEY = process.env.AFL_NEWS_API_KEY
const API_BASE = 'https://api.afl.com.au/news/v1'

/**
 * News API Integration
 * 
 * Provides access to AFL news and updates, including:
 * - Breaking news
 * - Injury updates
 * - Team changes
 * - Late changes
 */
class NewsAPI {
  private static instance: NewsAPI
  private readonly CACHE_TTL = 300 // 5 minutes
  
  private constructor() {}
  
  public static getInstance(): NewsAPI {
    if (!NewsAPI.instance) {
      NewsAPI.instance = new NewsAPI()
    }
    return NewsAPI.instance
  }

  /**
   * Get latest news items
   */
  public async getLatestNews(
    playerId?: string,
    limit: number = 20
  ): Promise<NewsItem[]> {
    try {
      const cacheKey = `news:${playerId || 'all'}:${limit}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/news`,
        {
          params: {
            player: playerId,
            limit,
            sortBy: 'published',
            order: 'desc'
          },
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const news = response.data.map(this.mapNewsItem)

      await redis.set(
        cacheKey,
        JSON.stringify(news),
        'EX',
        this.CACHE_TTL
      )

      return news
    } catch (error) {
      logger.error('Error getting latest news', error)
      return []
    }
  }

  /**
   * Get injury news
   */
  public async getInjuryNews(
    teamId?: string
  ): Promise<NewsItem[]> {
    try {
      const cacheKey = `injury_news:${teamId || 'all'}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/news/injury`,
        {
          params: { team: teamId },
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const news = response.data.map(this.mapNewsItem)

      await redis.set(
        cacheKey,
        JSON.stringify(news),
        'EX',
        this.CACHE_TTL
      )

      return news
    } catch (error) {
      logger.error('Error getting injury news', error)
      return []
    }
  }

  /**
   * Get late changes for a round
   */
  public async getLateChanges(
    round: number
  ): Promise<NewsItem[]> {
    try {
      const cacheKey = `late_changes:${round}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/news/late-changes`,
        {
          params: { round },
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const news = response.data.map(this.mapNewsItem)

      await redis.set(
        cacheKey,
        JSON.stringify(news),
        'EX',
        this.CACHE_TTL
      )

      return news
    } catch (error) {
      logger.error('Error getting late changes', error)
      return []
    }
  }

  /**
   * Get role changes
   */
  public async getRoleChanges(
    playerId?: string
  ): Promise<NewsItem[]> {
    try {
      const cacheKey = `role_changes:${playerId || 'all'}`
      const cached = await redis.get(cacheKey)
      if (cached) {
        return JSON.parse(cached)
      }

      const response = await axios.get(
        `${API_BASE}/news/role-changes`,
        {
          params: { player: playerId },
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      const news = response.data.map(this.mapNewsItem)

      await redis.set(
        cacheKey,
        JSON.stringify(news),
        'EX',
        this.CACHE_TTL
      )

      return news
    } catch (error) {
      logger.error('Error getting role changes', error)
      return []
    }
  }

  /**
   * Search news articles
   */
  public async searchNews(
    query: string,
    limit: number = 20
  ): Promise<NewsItem[]> {
    try {
      // Don't cache search results
      const response = await axios.get(
        `${API_BASE}/news/search`,
        {
          params: {
            q: query,
            limit
          },
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      return response.data.map(this.mapNewsItem)
    } catch (error) {
      logger.error('Error searching news', error)
      return []
    }
  }

  /**
   * Subscribe to news alerts
   */
  public async subscribeToAlerts(
    endpoint: string,
    topics: string[]
  ): Promise<{
    success: boolean
    subscriptionId?: string
  }> {
    try {
      const response = await axios.post(
        `${API_BASE}/notifications/subscribe`,
        {
          endpoint,
          topics
        },
        {
          headers: {
            'Authorization': `Bearer ${API_KEY}`
          }
        }
      )

      return {
        success: true,
        subscriptionId: response.data.subscriptionId
      }
    } catch (error) {
      logger.error('Error subscribing to alerts', error)
      return { success: false }
    }
  }

  // Helper Methods

  private mapNewsItem(item: any): NewsItem {
    return {
      id: item.id,
      timestamp: item.published,
      title: item.title,
      content: item.content,
      type: item.type,
      priority: item.priority,
      playerId: item.player?.id,
      teamId: item.team?.id
    }
  }
}

export const newsApi = NewsAPI.getInstance()
