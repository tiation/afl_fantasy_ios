import WebSocket from 'ws'
import http from 'http'
import type { 
  Alert, 
  AlertType,
  AlertSeverity,
  PlayerStats,
  NewsItem
} from '../types'
import { logger } from '../lib/logger'
import { masterData } from './MasterDataService'
import { aiEngine } from './AIAnalysisEngine'
import { redis } from '../lib/redis'

interface Client {
  ws: WebSocket
  id: string
  subscriptions: Set<string>
}

/**
 * RealTimeService
 * 
 * Handles real-time WebSocket connections and notifications for:
 * - Live score updates
 * - Price change alerts
 * - Breaking news alerts
 * - Team performance tracking
 */
export class RealTimeService {
  private static instance: RealTimeService
  private wss: WebSocket.Server
  private clients: Map<string, Client> = new Map()
  private updateInterval: NodeJS.Timer | null = null
  
  private constructor() {
    this.initializeService()
  }

  public static getInstance(): RealTimeService {
    if (!RealTimeService.instance) {
      RealTimeService.instance = new RealTimeService()
    }
    return RealTimeService.instance
  }

  public initialize(server: http.Server) {
    this.wss = new WebSocket.Server({ server })
    
    this.wss.on('connection', this.handleConnection.bind(this))
    
    // Setup periodic checks
    this.updateInterval = setInterval(() => {
      this.checkForUpdates()
    }, 60000) // Check every minute
    
    logger.info('RealTimeService initialized')
  }

  private initializeService() {
    // Initialize last check timestamps
    this.setLastCheckTime('price')
    this.setLastCheckTime('news')
    this.setLastCheckTime('scores')
  }

  // Connection Handling

  private handleConnection(ws: WebSocket, req: http.IncomingMessage) {
    const clientId = req.headers['sec-websocket-key'] || 
      Math.random().toString(36).substring(7)

    const client: Client = {
      ws,
      id: clientId,
      subscriptions: new Set()
    }

    this.clients.set(clientId, client)

    ws.on('message', (message: string) => {
      this.handleMessage(client, message)
    })

    ws.on('close', () => {
      this.clients.delete(clientId)
    })

    // Send initial state
    this.sendWelcomeMessage(client)
  }

  private handleMessage(client: Client, message: string) {
    try {
      const data = JSON.parse(message)
      
      switch (data.type) {
        case 'subscribe':
          this.handleSubscribe(client, data.channels)
          break
        
        case 'unsubscribe':
          this.handleUnsubscribe(client, data.channels)
          break
        
        default:
          logger.warn('Unknown message type', data)
      }
    } catch (error) {
      logger.error('Error handling message', error)
    }
  }

  // Subscription Management

  private handleSubscribe(client: Client, channels: string[]) {
    channels.forEach(channel => {
      client.subscriptions.add(channel)
    })

    // Send confirmation
    this.sendToClient(client, {
      type: 'subscribed',
      channels
    })
  }

  private handleUnsubscribe(client: Client, channels: string[]) {
    channels.forEach(channel => {
      client.subscriptions.delete(channel)
    })

    // Send confirmation
    this.sendToClient(client, {
      type: 'unsubscribed',
      channels
    })
  }

  // Update Checking

  private async checkForUpdates() {
    await Promise.all([
      this.checkPriceChanges(),
      this.checkNewsUpdates(),
      this.checkScoreUpdates()
    ])
  }

  private async checkPriceChanges() {
    try {
      const lastCheck = await this.getLastCheckTime('price')
      if (!lastCheck) return

      const changes = await this.getPriceChangesSince(lastCheck)
      
      if (changes.length > 0) {
        changes.forEach(change => {
          this.broadcastAlert({
            type: 'PRICE_CHANGE',
            severity: this.getPriceChangeSeverity(change.priceChange),
            message: this.formatPriceChangeMessage(change),
            timestamp: new Date().toISOString(),
            playerId: change.id,
            data: {
              oldPrice: change.price - change.priceChange,
              newPrice: change.price,
              priceChange: change.priceChange
            }
          })
        })
      }

      await this.setLastCheckTime('price')
    } catch (error) {
      logger.error('Error checking price changes', error)
    }
  }

  private async checkNewsUpdates() {
    try {
      const lastCheck = await this.getLastCheckTime('news')
      if (!lastCheck) return

      const news = await masterData.getLatestNews()
      const recentNews = news.filter(n => 
        new Date(n.timestamp) > new Date(lastCheck)
      )

      recentNews.forEach(newsItem => {
        this.broadcastAlert({
          type: this.mapNewsTypeToAlertType(newsItem.type),
          severity: this.mapNewsPriorityToSeverity(newsItem.priority),
          message: newsItem.title,
          timestamp: newsItem.timestamp,
          playerId: newsItem.playerId,
          teamId: newsItem.teamId,
          data: {
            content: newsItem.content
          }
        })
      })

      await this.setLastCheckTime('news')
    } catch (error) {
      logger.error('Error checking news updates', error)
    }
  }

  private async checkScoreUpdates() {
    try {
      const lastCheck = await this.getLastCheckTime('scores')
      if (!lastCheck) return

      // Get live game scores since last check
      // This would integrate with the AFL live scores API
      const liveScores = await this.getLiveScores()
      
      if (liveScores.length > 0) {
        this.broadcastToChannel('scores', {
          type: 'LIVE_SCORES',
          scores: liveScores
        })
      }

      await this.setLastCheckTime('scores')
    } catch (error) {
      logger.error('Error checking score updates', error)
    }
  }

  // Helper Methods

  private async getPriceChangesSince(
    timestamp: string
  ): Promise<PlayerStats[]> {
    const players = await redis.get('recent_price_changes')
    if (!players) return []
    
    return JSON.parse(players).filter((p: PlayerStats) => 
      p.priceChange !== 0
    )
  }

  private getPriceChangeSeverity(change: number): AlertSeverity {
    const absChange = Math.abs(change)
    if (absChange > 50000) return 'CRITICAL'
    if (absChange > 30000) return 'HIGH'
    if (absChange > 15000) return 'MEDIUM'
    return 'LOW'
  }

  private formatPriceChangeMessage(player: PlayerStats): string {
    const direction = player.priceChange > 0 ? 'up' : 'down'
    const amount = Math.abs(player.priceChange).toLocaleString()
    return `${player.name} price ${direction} $${amount}`
  }

  private mapNewsTypeToAlertType(
    newsType: string
  ): AlertType {
    const mapping: Record<string, AlertType> = {
      'INJURY': 'INJURY_UPDATE',
      'LATE_OUT': 'LATE_OUT',
      'ROLE_CHANGE': 'ROLE_CHANGE',
      'GENERAL': 'BREAKING_NEWS'
    }
    return mapping[newsType] || 'BREAKING_NEWS'
  }

  private mapNewsPriorityToSeverity(
    priority: string
  ): AlertSeverity {
    const mapping: Record<string, AlertSeverity> = {
      'CRITICAL': 'CRITICAL',
      'HIGH': 'HIGH',
      'MEDIUM': 'MEDIUM',
      'LOW': 'LOW'
    }
    return mapping[priority] || 'LOW'
  }

  private async getLiveScores() {
    // This would integrate with AFL's live scores API
    // For now, return empty array
    return []
  }

  // Broadcasting Methods

  private broadcastAlert(alert: Alert) {
    this.broadcastToChannel('alerts', {
      type: 'ALERT',
      alert
    })

    // Also broadcast to specific channels if relevant
    if (alert.playerId) {
      this.broadcastToChannel(`player:${alert.playerId}`, {
        type: 'ALERT',
        alert
      })
    }
    if (alert.teamId) {
      this.broadcastToChannel(`team:${alert.teamId}`, {
        type: 'ALERT',
        alert
      })
    }
  }

  private broadcastToChannel(channel: string, data: any) {
    const message = JSON.stringify(data)
    
    this.clients.forEach(client => {
      if (client.subscriptions.has(channel)) {
        this.sendToClient(client, message)
      }
    })
  }

  private sendToClient(client: Client, data: any) {
    const message = typeof data === 'string' ? 
      data : JSON.stringify(data)

    if (client.ws.readyState === WebSocket.OPEN) {
      client.ws.send(message)
    }
  }

  private async sendWelcomeMessage(client: Client) {
    // Send recent alerts from cache
    const recentAlerts = await this.getRecentAlerts()
    if (recentAlerts.length > 0) {
      this.sendToClient(client, {
        type: 'RECENT_ALERTS',
        alerts: recentAlerts
      })
    }
  }

  // Cache Management

  private async getLastCheckTime(type: string): Promise<string | null> {
    return redis.get(`last_check:${type}`)
  }

  private async setLastCheckTime(type: string) {
    await redis.set(
      `last_check:${type}`,
      new Date().toISOString(),
      'EX',
      3600 // 1 hour expiry
    )
  }

  private async getRecentAlerts(): Promise<Alert[]> {
    const alerts = await redis.get('recent_alerts')
    return alerts ? JSON.parse(alerts) : []
  }

  private async cacheAlert(alert: Alert) {
    const alerts = await this.getRecentAlerts()
    alerts.unshift(alert)
    
    // Keep last 100 alerts
    while (alerts.length > 100) {
      alerts.pop()
    }

    await redis.set(
      'recent_alerts',
      JSON.stringify(alerts),
      'EX',
      86400 // 24 hours
    )
  }

  public destroy() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval)
    }
    
    this.wss?.clients.forEach(client => {
      client.close()
    })
    
    this.wss?.close()
  }
}

export const realTime = RealTimeService.getInstance()
