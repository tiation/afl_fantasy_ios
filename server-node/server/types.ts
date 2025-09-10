// Player Types
export type PlayerPosition = 'DEF' | 'MID' | 'RUC' | 'FWD'
export type ConsistencyGrade = 'A' | 'B' | 'C' | 'D'
export type InjuryStatus = 'HEALTHY' | 'QUESTIONABLE' | 'OUT'

export interface PlayerStats {
  id: string
  name: string
  team: string
  position: PlayerPosition
  price: number
  average: number
  projected: number
  breakeven: number
  consistency: ConsistencyGrade
  priceChange: number
  ownership?: number
  injuryStatus?: InjuryStatus
  venueStats?: VenueStats
  formFactor?: number
  dvpImpact?: number
}

// Venue Types
export interface VenueStats {
  id: string
  name: string
  averageScore: number
  weatherImpact: number
  positionBias: Record<PlayerPosition, number>
  games?: GameStats[]
}

export interface GameStats {
  id: string
  date: string
  homeTeam: string
  awayTeam: string
  playerStats: PlayerGameStats[]
}

export interface PlayerGameStats {
  playerId: string
  position: PlayerPosition
  score: number
}

// Team Types
export interface TeamStructure {
  totalValue: number
  bankBalance: number
  positionBalance: Record<PlayerPosition, number>
  premiumCount: number
  midPriceCount: number
  rookieCount: number
}

// Analysis Types
export interface PriceProjection {
  round: number
  price: number
  confidence: number
}

export interface DVPStats {
  teamId: string
  positions: Record<PlayerPosition, {
    pointsAllowed: number
    rankAgainst: number
    lastFiveGames: number[]
  }>
}

// Weather Types
export interface WeatherForecast {
  temperature: number
  rainProbability: number
  windSpeed: number
  windDirection: string
  conditions: string
}

// Injury Types
export interface InjuryReport {
  playerId: string
  status: InjuryStatus
  details: string
  expectedReturn?: string
  timestamp: string
}

// News Types
export interface NewsItem {
  id: string
  timestamp: string
  title: string
  content: string
  type: 'INJURY' | 'ROLE_CHANGE' | 'LATE_OUT' | 'GENERAL'
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'
  playerId?: string
  teamId?: string
}

// Analysis Time Frames
export type AnalysisTimeframe = 'NOW' | '2_WEEKS' | '4_WEEKS' | 'OPTIMAL'

// Captain Selection Types
export interface CaptainSuggestion {
  player: PlayerStats
  confidence: number
  reasoning: string[]
  projectedPoints: number
  formFactor: number
  venueBias: number
  weatherImpact: number
}

// Cash Cow Analysis Types
export interface CashCowAnalysis {
  player: PlayerStats
  generated: number
  projectedGeneration: number
  sellWeek: number
  confidence: number
  priceTrajectory: PriceProjection[]
}

// Team Analysis Types
export interface TeamWeakness {
  type: 'POSITION_IMBALANCE' | 'PREMIUM_LIGHT' | 'ROOKIE_HEAVY' | 'INJURY_RISK' | 'BYE_ROUND_EXPOSURE'
  severity: number
  recommendation: string
}

export interface UpgradePathway {
  from: PlayerStats
  to: PlayerStats
  cost: number
  pointsImprovement: number
  confidence: number
}

// Settings Types
export interface AISettings {
  aiConfidenceThreshold: number
  analysisFactors: {
    recentForm: boolean
    opponentDVP: boolean
    venueBias: boolean
    weather: boolean
    consistency: boolean
    injuryRisk: boolean
    ownership: boolean
    ceilingFloor: boolean
  }
  notifications: {
    priceAlerts: boolean
    injuryNews: boolean
    tradeDeadlines: boolean
    captainReminders: boolean
  }
}

// Alert Types
export type AlertType = 'PRICE_CHANGE' | 'INJURY_UPDATE' | 'LATE_OUT' | 'ROLE_CHANGE' | 'BREAKING_NEWS'
export type AlertSeverity = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL'

export interface Alert {
  type: AlertType
  severity: AlertSeverity
  message: string
  timestamp: string
  playerId?: string
  teamId?: string
  data?: Record<string, any>
}
