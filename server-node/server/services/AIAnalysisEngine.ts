import type { 
  PlayerStats,
  VenueStats, 
  TeamStructure,
  CaptainSuggestion,
  CashCowAnalysis,
  TeamWeakness,
  UpgradePathway,
  DVPStats,
  WeatherForecast
} from '../types'
import { masterData } from './MasterDataService'
import { logger } from '../lib/logger'

/**
 * AI Analysis Engine
 * 
 * Provides advanced analytics and AI-powered recommendations for:
 * - Captain selection
 * - Cash cow identification
 * - Team structure optimization
 * - Price predictions
 * - Risk assessment
 */
export class AIAnalysisEngine {
  private static instance: AIAnalysisEngine
  
  private constructor() {}

  public static getInstance(): AIAnalysisEngine {
    if (!AIAnalysisEngine.instance) {
      AIAnalysisEngine.instance = new AIAnalysisEngine()
    }
    return AIAnalysisEngine.instance
  }

  // Captain Selection Algorithm

  public async analyzeCaptainOptions(
    teamPlayers: string[],
    venue: string,
    opponent: string,
    considerationFactors: string[]
  ): Promise<CaptainSuggestion[]> {
    try {
      const players = await Promise.all(
        teamPlayers.map(id => masterData.getPlayerStats(id))
      )
      const validPlayers = players.filter((p): p is PlayerStats => p !== null)

      const venueStats = await masterData.getVenueStats(venue)
      const opponentDVP = await masterData.getDVPStats(opponent)
      const weather = await masterData.getWeatherForecast(venue)

      const suggestions = await Promise.all(
        validPlayers.map(async player => {
          const analysis = await this.analyzeCaptainCandidate(
            player,
            venueStats,
            opponentDVP,
            weather,
            considerationFactors
          )
          return analysis
        })
      )

      // Sort by confidence and projected points
      return suggestions
        .sort((a, b) => {
          const scoreDiff = b.projectedPoints - a.projectedPoints
          if (scoreDiff !== 0) return scoreDiff
          return b.confidence - a.confidence
        })
        .slice(0, 3) // Return top 3 suggestions
    } catch (error) {
      logger.error('Error analyzing captain options', error)
      return []
    }
  }

  private async analyzeCaptainCandidate(
    player: PlayerStats,
    venue: VenueStats | null,
    opponentDVP: DVPStats | null,
    weather: WeatherForecast | null,
    factors: string[]
  ): Promise<CaptainSuggestion> {
    const baseConfidence = 70 // Start with base confidence

    // Form factor (0-30 points)
    const formImpact = this.calculateFormImpact(player)
    
    // Venue bias (-10 to +10 points)
    const venueImpact = venue ? 
      this.calculateVenueImpact(player, venue) : 0

    // DVP impact (-10 to +10 points)
    const dvpImpact = opponentDVP ?
      this.calculateDVPImpact(player, opponentDVP) : 0

    // Weather impact (-20 to 0 points)
    const weatherImpact = weather ?
      this.calculateWeatherImpact(player, weather) : 0

    // Calculate final confidence
    let confidence = baseConfidence
    if (factors.includes('RECENT_FORM')) confidence += formImpact
    if (factors.includes('VENUE_BIAS')) confidence += venueImpact
    if (factors.includes('OPPONENT_DVP')) confidence += dvpImpact
    if (factors.includes('WEATHER')) confidence += weatherImpact

    // Adjust projected points based on impacts
    const baseProjection = player.projected
    const projectedPoints = Math.round(baseProjection * (1 + 
      (formImpact / 100) +
      (venueImpact / 100) +
      (dvpImpact / 100) +
      (weatherImpact / 100)
    ))

    // Generate reasoning array
    const reasoning: string[] = []
    if (formImpact > 0) reasoning.push(`Strong recent form (+${formImpact}% confidence)`)
    if (venueImpact > 0) reasoning.push(`Historical venue success (+${venueImpact}% confidence)`)
    if (dvpImpact > 0) reasoning.push(`Favorable matchup (+${dvpImpact}% confidence)`)
    if (weatherImpact < 0) reasoning.push(`Weather concerns (${weatherImpact}% confidence)`)

    return {
      player,
      confidence: Math.max(0, Math.min(100, confidence)),
      reasoning,
      projectedPoints,
      formFactor: formImpact,
      venueBias: venueImpact,
      weatherImpact
    }
  }

  // Cash Cow Analysis

  public async analyzeCashCows(
    allPlayers: string[],
    minConfidence: number = 70
  ): Promise<CashCowAnalysis[]> {
    try {
      const players = await Promise.all(
        allPlayers.map(id => masterData.getPlayerStats(id))
      )
      const validPlayers = players.filter((p): p is PlayerStats => p !== null)
      
      // Filter potential cash cows (players under $300k)
      const rookies = validPlayers.filter(p => p.price < 300000)
      
      const analyses = await Promise.all(
        rookies.map(async rookie => {
          const analysis = await this.analyzeCashCowPotential(rookie)
          return analysis
        })
      )

      // Filter by confidence and sort by projected generation
      return analyses
        .filter(a => a.confidence >= minConfidence)
        .sort((a, b) => b.projectedGeneration - a.projectedGeneration)
    } catch (error) {
      logger.error('Error analyzing cash cows', error)
      return []
    }
  }

  private async analyzeCashCowPotential(
    player: PlayerStats
  ): Promise<CashCowAnalysis> {
    // Start with base confidence based on consistency
    const baseConfidence = {
      'A': 90,
      'B': 80,
      'C': 70,
      'D': 60
    }[player.consistency]

    // Adjust confidence based on role security
    const roleAdjustment = await this.analyzeRoleSecurity(player)
    
    // Calculate optimal sell week
    const projectedPrices = await this.projectPrices(player, 8) // Look ahead 8 weeks
    const sellWeek = this.findOptimalSellWeek(projectedPrices)
    
    // Calculate projected generation
    const maxPrice = Math.max(...projectedPrices.map(p => p.price))
    const projectedGeneration = maxPrice - player.price
    
    // Generate confidence score
    let confidence = baseConfidence + roleAdjustment

    // Adjust for injury risk
    if (player.injuryStatus === 'QUESTIONABLE') confidence -= 20
    
    return {
      player,
      generated: 0, // Will be populated by actual gains
      projectedGeneration,
      sellWeek,
      confidence: Math.max(0, Math.min(100, confidence)),
      priceTrajectory: projectedPrices.map((price, i) => ({
        round: i + 1,
        price: price.price,
        confidence: price.confidence
      }))
    }
  }

  // Team Structure Analysis

  public async analyzeTeamStructure(
    playerIds: string[]
  ): Promise<{
    structure: TeamStructure
    weaknesses: TeamWeakness[]
    upgradePathways: UpgradePathway[]
  }> {
    try {
      const structure = await masterData.analyzeTeamStructure(playerIds)
      
      // Analyze structural weaknesses
      const weaknesses = this.identifyWeaknesses(structure)
      
      // Find upgrade pathways
      const upgradePathways = await this.findUpgradePathways(
        playerIds,
        structure,
        weaknesses
      )

      return {
        structure,
        weaknesses,
        upgradePathways
      }
    } catch (error) {
      logger.error('Error analyzing team structure', error)
      throw error
    }
  }

  // Risk Assessment

  public async assessPlayerRisk(
    player: PlayerStats
  ): Promise<{
    overall: number // 0-100, higher = riskier
    factors: {
      injury: number
      role: number
      form: number
      price: number
    }
    recommendations: string[]
  }> {
    const injuryRisk = await this.calculateInjuryRisk(player)
    const roleRisk = await this.calculateRoleRisk(player)
    const formRisk = this.calculateFormRisk(player)
    const priceRisk = this.calculatePriceRisk(player)

    const overall = Math.round(
      (injuryRisk * 0.4) + 
      (roleRisk * 0.3) + 
      (formRisk * 0.2) + 
      (priceRisk * 0.1)
    )

    const recommendations: string[] = []
    if (injuryRisk > 60) recommendations.push('High injury risk - consider trading')
    if (roleRisk > 60) recommendations.push('Role security concerns')
    if (formRisk > 60) recommendations.push('Poor recent form')
    if (priceRisk > 60) recommendations.push('High price volatility risk')

    return {
      overall,
      factors: {
        injury: injuryRisk,
        role: roleRisk,
        form: formRisk,
        price: priceRisk
      },
      recommendations
    }
  }

  // Private Helper Methods

  private calculateFormImpact(player: PlayerStats): number {
    if (!player.formFactor) return 0
    return Math.round((player.formFactor - player.average) * 0.5)
  }

  private calculateVenueImpact(
    player: PlayerStats,
    venue: VenueStats
  ): number {
    const positionBias = venue.positionBias[player.position] || 1
    return Math.round((positionBias - 1) * 20)
  }

  private calculateDVPImpact(
    player: PlayerStats,
    opponentDVP: DVPStats
  ): number {
    const positionStats = opponentDVP.positions[player.position]
    const recentAvg = positionStats.lastFiveGames.reduce((a, b) => a + b, 0) / 5
    const impact = ((recentAvg / player.average) - 1) * 20
    return Math.round(impact)
  }

  private calculateWeatherImpact(
    player: PlayerStats,
    weather: WeatherForecast
  ): number {
    let impact = 0

    // Rain impact
    if (weather.rainProbability > 50) {
      impact -= 10
      // Midfielders less affected by rain
      if (player.position === 'MID') impact += 5
    }

    // Wind impact
    if (weather.windSpeed > 30) {
      impact -= 5
      // Forwards most affected by wind
      if (player.position === 'FWD') impact -= 5
    }

    return impact
  }

  private async analyzeRoleSecurity(player: PlayerStats): number {
    const news = await masterData.getLatestNews(player.id)
    let adjustment = 0

    // Check recent news for role concerns
    const roleNews = news.filter(n => n.type === 'ROLE_CHANGE')
    if (roleNews.length > 0) {
      adjustment -= 20
    }

    // High ownership suggests more role security
    if (player.ownership && player.ownership > 30) {
      adjustment += 10
    }

    return adjustment
  }

  private async projectPrices(
    player: PlayerStats,
    weeks: number
  ): Promise<{ price: number; confidence: number }[]> {
    const projections = await masterData.getPriceProjections([player.id], weeks)
    return projections[player.id] || []
  }

  private findOptimalSellWeek(
    projections: { price: number; confidence: number }[]
  ): number {
    let maxPrice = 0
    let bestWeek = 1

    projections.forEach((proj, week) => {
      if (proj.price > maxPrice) {
        maxPrice = proj.price
        bestWeek = week + 1
      }
    })

    return bestWeek
  }

  private identifyWeaknesses(structure: TeamStructure): TeamWeakness[] {
    const weaknesses: TeamWeakness[] = []

    // Check position balance
    Object.entries(structure.positionBalance).forEach(([pos, count]) => {
      const ideal = 7.5 // 30 players / 4 positions
      if (Math.abs(count - ideal) > 2) {
        weaknesses.push({
          type: 'POSITION_IMBALANCE',
          severity: Math.abs(count - ideal) * 10,
          recommendation: count > ideal ?
            `Too many ${pos} players` :
            `Need more ${pos} players`
        })
      }
    })

    // Check premium count
    if (structure.premiumCount < 4) {
      weaknesses.push({
        type: 'PREMIUM_LIGHT',
        severity: (4 - structure.premiumCount) * 25,
        recommendation: 'Need more premium players'
      })
    }

    // Check rookie count
    if (structure.rookieCount > 10) {
      weaknesses.push({
        type: 'ROOKIE_HEAVY',
        severity: (structure.rookieCount - 10) * 10,
        recommendation: 'Too many rookies, need to upgrade some'
      })
    }

    return weaknesses
  }

  private async findUpgradePathways(
    playerIds: string[],
    structure: TeamStructure,
    weaknesses: TeamWeakness[]
  ): Promise<UpgradePathway[]> {
    const pathways: UpgradePathway[] = []
    const players = await Promise.all(
      playerIds.map(id => masterData.getPlayerStats(id))
    )
    const validPlayers = players.filter((p): p is PlayerStats => p !== null)

    // Focus on addressing weaknesses
    for (const weakness of weaknesses) {
      switch (weakness.type) {
        case 'PREMIUM_LIGHT':
          // Find rookie to premium upgrades
          const rookies = validPlayers.filter(p => p.price < 300000)
          for (const rookie of rookies) {
            const upgrade = await this.findBestPremiumUpgrade(rookie)
            if (upgrade) pathways.push(upgrade)
          }
          break

        case 'POSITION_IMBALANCE':
          // Find position-specific upgrades
          const weakPosition = this.findWeakPosition(structure)
          if (weakPosition) {
            const positionUpgrades = await this.findPositionUpgrades(
              validPlayers,
              weakPosition
            )
            pathways.push(...positionUpgrades)
          }
          break
      }
    }

    // Sort by confidence and return top 5
    return pathways
      .sort((a, b) => b.confidence - a.confidence)
      .slice(0, 5)
  }

  private async findBestPremiumUpgrade(
    player: PlayerStats
  ): Promise<UpgradePathway | null> {
    try {
      // Search for premiums in same position
      const position = player.position
      const searchResult = await masterData.searchPlayers({
        positions: [position],
        priceRange: { min: 600000, max: 1000000 }
      })

      if (searchResult.players.length === 0) return null

      // Find best value premium
      const bestPremium = searchResult.players.reduce((best, current) => {
        const currentValue = current.projected / current.price
        const bestValue = best.projected / best.price
        return currentValue > bestValue ? current : best
      })

      const cost = bestPremium.price - player.price
      const pointsImprovement = bestPremium.projected - player.projected

      return {
        from: player,
        to: bestPremium,
        cost,
        pointsImprovement,
        confidence: this.calculateUpgradeConfidence(
          player,
          bestPremium,
          cost,
          pointsImprovement
        )
      }
    } catch (error) {
      logger.error('Error finding premium upgrade', error)
      return null
    }
  }

  private findWeakPosition(structure: TeamStructure): string | null {
    const positions = Object.entries(structure.positionBalance)
    const minPosition = positions.reduce((min, current) => {
      return current[1] < min[1] ? current : min
    })
    return minPosition[1] < 7 ? minPosition[0] : null
  }

  private async findPositionUpgrades(
    currentPlayers: PlayerStats[],
    targetPosition: string
  ): Promise<UpgradePathway[]> {
    const upgrades: UpgradePathway[] = []

    // Find cheapest players in weak position
    const positionPlayers = currentPlayers.filter(
      p => p.position === targetPosition
    )
    const cheapest = positionPlayers.sort((a, b) => a.price - b.price)[0]

    if (!cheapest) return []

    // Look for mid-price upgrades
    const searchResult = await masterData.searchPlayers({
      positions: [targetPosition],
      priceRange: {
        min: cheapest.price + 100000,
        max: cheapest.price + 300000
      }
    })

    for (const target of searchResult.players) {
      const cost = target.price - cheapest.price
      const pointsImprovement = target.projected - cheapest.projected
      
      if (pointsImprovement > 15) { // Only suggest significant upgrades
        upgrades.push({
          from: cheapest,
          to: target,
          cost,
          pointsImprovement,
          confidence: this.calculateUpgradeConfidence(
            cheapest,
            target,
            cost,
            pointsImprovement
          )
        })
      }
    }

    return upgrades
  }

  private calculateUpgradeConfidence(
    from: PlayerStats,
    to: PlayerStats,
    cost: number,
    pointsImprovement: number
  ): number {
    let confidence = 70 // Base confidence

    // Value for money
    const valueRatio = (pointsImprovement / cost) * 500000
    if (valueRatio > 1.2) confidence += 10
    if (valueRatio < 0.8) confidence -= 10

    // Consistency upgrade
    const consistencyValue = {
      'A': 4, 'B': 3, 'C': 2, 'D': 1
    }
    if (consistencyValue[to.consistency] > consistencyValue[from.consistency]) {
      confidence += 10
    }

    // Form consideration
    if (to.formFactor && from.formFactor) {
      if (to.formFactor > from.formFactor) confidence += 5
    }

    return Math.max(0, Math.min(100, confidence))
  }

  private async calculateInjuryRisk(player: PlayerStats): Promise<number> {
    let risk = 0

    // Current injury status
    if (player.injuryStatus === 'QUESTIONABLE') risk += 40
    
    // Recent injury history
    const injuryReport = await masterData.getInjuryReport(player.id)
    if (injuryReport) {
      const daysSinceInjury = this.daysBetween(
        new Date(injuryReport.timestamp),
        new Date()
      )
      if (daysSinceInjury < 30) risk += 20
    }

    // High game time correlation
    if (player.average > 100) risk += 10

    return Math.min(100, risk)
  }

  private async calculateRoleRisk(player: PlayerStats): Promise<number> {
    let risk = 0

    // Check recent news for role-related items
    const news = await masterData.getLatestNews(player.id)
    const roleNews = news.filter(n => 
      n.type === 'ROLE_CHANGE' && 
      this.daysBetween(new Date(n.timestamp), new Date()) < 14
    )

    if (roleNews.length > 0) risk += 30

    // Low ownership suggests less role security
    if (player.ownership && player.ownership < 10) risk += 20

    // Inconsistent scoring suggests variable role
    if (player.consistency === 'C') risk += 20
    if (player.consistency === 'D') risk += 40

    return Math.min(100, risk)
  }

  private calculateFormRisk(player: PlayerStats): number {
    let risk = 0

    // Below average projection
    if (player.projected < player.average) {
      risk += ((player.average - player.projected) / player.average) * 100
    }

    // Poor consistency
    if (player.consistency === 'C') risk += 20
    if (player.consistency === 'D') risk += 40

    // Negative price trend
    if (player.priceChange < 0) {
      risk += Math.min(40, Math.abs(player.priceChange / 10000))
    }

    return Math.min(100, risk)
  }

  private calculatePriceRisk(player: PlayerStats): number {
    let risk = 0

    // High breakeven relative to average
    if (player.breakeven > player.average) {
      risk += ((player.breakeven - player.average) / player.average) * 100
    }

    // Recent price drops
    if (player.priceChange < 0) {
      risk += Math.min(50, Math.abs(player.priceChange / 5000))
    }

    // Premium players have lower price risk
    if (player.price > 600000) risk *= 0.7

    return Math.min(100, risk)
  }

  private daysBetween(date1: Date, date2: Date): number {
    const diffTime = Math.abs(date2.getTime() - date1.getTime())
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  }
}

export const aiEngine = AIAnalysisEngine.getInstance()
