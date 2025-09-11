// API Schema for AFL Fantasy iOS App

import { z } from 'zod'
import type { PlayerPosition, AnalysisTimeframe } from '../types'

// Base Types
export const PlayerStatsSchema = z.object({
  id: z.string(),
  name: z.string(),
  team: z.string(),
  position: z.enum(['DEF', 'MID', 'RUC', 'FWD']),
  price: z.number(),
  average: z.number(),
  projected: z.number(),
  breakeven: z.number(),
  consistency: z.enum(['A', 'B', 'C', 'D']),
  priceChange: z.number(),
  ownership: z.number().optional(),
  injuryStatus: z.enum(['HEALTHY', 'QUESTIONABLE', 'OUT']).optional(),
})

export const VenueStatsSchema = z.object({
  id: z.string(),
  name: z.string(),
  averageScore: z.number(),
  weatherImpact: z.number(),
  positionBias: z.record(z.enum(['DEF', 'MID', 'RUC', 'FWD']), z.number()),
})

export const TeamStructureSchema = z.object({
  totalValue: z.number(),
  bankBalance: z.number(),
  positionBalance: z.record(z.enum(['DEF', 'MID', 'RUC', 'FWD']), z.number()),
  premiumCount: z.number(),
  midPriceCount: z.number(),
  rookieCount: z.number(),
})

// API Endpoints Schemas

// 1. Team Management
export const TeamManagementAPI = {
  getCurrentTeam: {
    response: z.object({
      players: z.array(PlayerStatsSchema),
      structure: TeamStructureSchema,
      trades: z.object({
        remaining: z.number(),
        used: z.number(),
      }),
    }),
  },
  
  makeTradeRequest: {
    request: z.object({
      playersIn: z.array(z.string()),
      playersOut: z.array(z.string()),
    }),
    response: z.object({
      success: z.boolean(),
      newBalance: z.number(),
      structureImpact: TeamStructureSchema,
      projectedPointsChange: z.number(),
    }),
  },
}

// 2. Captain Selection
export const CaptainAPI = {
  getCaptainSuggestions: {
    request: z.object({
      venue: z.string(),
      opponent: z.string(),
      considerationFactors: z.array(z.enum([
        'RECENT_FORM',
        'VENUE_BIAS',
        'OPPONENT_DVP',
        'WEATHER',
      ])),
    }),
    response: z.object({
      suggestions: z.array(z.object({
        player: PlayerStatsSchema,
        confidence: z.number(),
        reasoning: z.array(z.string()),
        projectedPoints: z.number(),
        formFactor: z.number(),
        venueBias: z.number(),
        weatherImpact: z.number(),
      })),
    }),
  },
}

// 3. Cash Generation Analytics
export const CashAnalyticsAPI = {
  getCashCows: {
    request: z.object({
      timeframe: z.enum(['NOW', '2_WEEKS', '4_WEEKS', 'OPTIMAL']),
      minConfidence: z.number(),
    }),
    response: z.object({
      cashCows: z.array(z.object({
        player: PlayerStatsSchema,
        generated: z.number(),
        projectedGeneration: z.number(),
        sellWeek: z.number(),
        confidence: z.number(),
        priceTrajectory: z.array(z.object({
          round: z.number(),
          price: z.number(),
        })),
      })),
      totalProjectedCash: z.number(),
      activeCashCowCount: z.number(),
    }),
  },
}

// 4. Price Analytics
export const PriceAnalyticsAPI = {
  getPriceProjections: {
    request: z.object({
      playerIds: z.array(z.string()),
      timeframe: z.number(), // number of weeks
    }),
    response: z.object({
      projections: z.array(z.object({
        player: PlayerStatsSchema,
        weeklyProjections: z.array(z.object({
          round: z.number(),
          price: z.number(),
          confidence: z.number(),
        })),
      })),
    }),
  },
}

// 5. Team Analysis
export const TeamAnalysisAPI = {
  getTeamAnalysis: {
    response: z.object({
      structure: TeamStructureSchema,
      weaknesses: z.array(z.object({
        type: z.enum([
          'POSITION_IMBALANCE',
          'PREMIUM_LIGHT',
          'ROOKIE_HEAVY',
          'INJURY_RISK',
          'BYE_ROUND_EXPOSURE',
        ]),
        severity: z.number(),
        recommendation: z.string(),
      })),
      upgradePathways: z.array(z.object({
        from: PlayerStatsSchema,
        to: PlayerStatsSchema,
        cost: z.number(),
        pointsImprovement: z.number(),
        confidence: z.number(),
      })),
    }),
  },
}

// 6. Player Search & Filters
export const PlayerSearchAPI = {
  searchPlayers: {
    request: z.object({
      query: z.string().optional(),
      positions: z.array(z.enum(['DEF', 'MID', 'RUC', 'FWD'])).optional(),
      priceRange: z.object({
        min: z.number(),
        max: z.number(),
      }).optional(),
      avgRange: z.object({
        min: z.number(),
        max: z.number(),
      }).optional(),
      sortBy: z.enum([
        'PRICE_ASC',
        'PRICE_DESC',
        'AVG_ASC',
        'AVG_DESC',
        'PROJ_ASC',
        'PROJ_DESC',
      ]).optional(),
    }),
    response: z.object({
      players: z.array(PlayerStatsSchema),
      totalCount: z.number(),
    }),
  },
}

// 7. Real-time Updates
export const LiveUpdatesAPI = {
  connect: {
    // WebSocket connection
    message: z.object({
      type: z.enum([
        'PRICE_CHANGE',
        'INJURY_UPDATE',
        'LATE_OUT',
        'ROLE_CHANGE',
        'BREAKING_NEWS',
      ]),
      data: z.object({
        playerId: z.string(),
        timestamp: z.string(),
        message: z.string(),
        severity: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']),
      }),
    }),
  },
}

// 8. Settings & Preferences
export const SettingsAPI = {
  getSettings: {
    response: z.object({
      aiConfidenceThreshold: z.number(),
      analysisFactors: z.object({
        recentForm: z.boolean(),
        opponentDVP: z.boolean(),
        venueBias: z.boolean(),
        weather: z.boolean(),
        consistency: z.boolean(),
        injuryRisk: z.boolean(),
        ownership: z.boolean(),
        ceilingFloor: z.boolean(),
      }),
      notifications: z.object({
        priceAlerts: z.boolean(),
        injuryNews: z.boolean(),
        tradeDeadlines: z.boolean(),
        captainReminders: z.boolean(),
      }),
    }),
  },
  
  updateSettings: {
    request: z.object({
      aiConfidenceThreshold: z.number().optional(),
      analysisFactors: z.object({
        recentForm: z.boolean(),
        opponentDVP: z.boolean(),
        venueBias: z.boolean(),
        weather: z.boolean(),
        consistency: z.boolean(),
        injuryRisk: z.boolean(),
        ownership: z.boolean(),
        ceilingFloor: z.boolean(),
      }).optional(),
      notifications: z.object({
        priceAlerts: z.boolean(),
        injuryNews: z.boolean(),
        tradeDeadlines: z.boolean(),
        captainReminders: z.boolean(),
      }).optional(),
    }),
    response: z.object({
      success: z.boolean(),
      updatedSettings: z.any(),
    }),
  },
}
