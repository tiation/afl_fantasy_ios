// Base Player interface
export interface BasePlayer {
  id: number;
  name: string;
  position: string;
  price: number;
  breakEven: number;
  category: string;
  team: string;
  averagePoints: number;
  lastScore: number | null;
  projectedScore: number | null;
  
  // Fantasy stats
  roundsPlayed?: number;
  l3Average?: number | null;
  l5Average?: number | null;
  priceChange?: number;
  pricePerPoint?: number | null;
  totalPoints?: number;
  selectionPercentage?: number | null;
  
  // Basic stats
  kicks?: number | null;
  handballs?: number | null;
  disposals?: number | null;
  marks?: number | null;
  tackles?: number | null;
  freeKicksFor?: number | null;
  freeKicksAgainst?: number | null;
  clearances?: number | null;
  hitouts?: number | null;
  cba?: number | null;
  kickIns?: number | null;
  uncontestedMarks?: number | null;
  contestedMarks?: number | null;
  uncontestedDisposals?: number | null;
  contestedDisposals?: number | null;
  
  // VS stats
  averageVsOpp?: number | null;
  averageAtVenue?: number | null;
  averageVs3RoundOpp?: number | null;
  averageAt3RoundVenue?: number | null;
  opponentDifficulty?: number | null;
  opponent3RoundDifficulty?: number | null;
  
  // Extended stats
  standardDeviation?: number | null;
  highScore?: number | null;
  lowScore?: number | null;
  belowAveragePercentage?: number | null;
  nextOpponent?: string | null;
  scoreImpact?: number | null;
  projectedAverage?: number | null;
  nextVenue?: string | null;
  venueScoreVariance?: number | null;
  projectedPriceChange?: number | null;
  breakEvenPercentage?: number | null;
  projectedOwnershipChange?: number | null;
  
  // Status
  isSelected?: boolean;
  isInjured?: boolean;
  isSuspended?: boolean;
  isFavorite?: boolean;
}

// Extended Player interface with UI-specific properties
export interface Player extends BasePlayer {
  isFavorite?: boolean;
  
  // Recent game scores (for player detail modal)
  last1?: number | null;
  last2?: number | null;
  last3?: number | null;
  last4?: number | null;
  last5?: number | null;
}

// Available stats categories
export type StatsCategory = 'basic' | 'fantasy' | 'value' | 'consistency' | 'opposition' | 'venue';

// Player status filters
export type StatusFilter = 'all' | 'selected' | 'not-selected' | 'injured' | 'suspended' | 'favorites';

// Sort fields for each category
export type BasicSortField = 'name' | 'team' | 'kicks' | 'handballs' | 'disposals' | 'marks' | 'tackles' | 'clearances' | 'freeKicksFor' | 'freeKicksAgainst' | 'hitouts' | 'cba' | 'kickIns' | 'contestedMarks' | null;

export type FantasySortField = 'name' | 'team' | 'price' | 'lastScore' | 'totalPoints' | 'averagePoints' | 'l3Average' | 'l5Average' | 'breakEven' | 'pricePerPoint' | 'selectionPercentage' | 'roundsPlayed' | 'priceChange' | null;

export type ValueSortField = 'name' | 'team' | 'price' | 'breakEven' | 'projectedScore' | 'projectedPriceChange' | 'breakEvenPercentage' | 'projectedOwnershipChange' | null;

export type ConsistencySortField = 'name' | 'team' | 'roundsPlayed' | 'averagePoints' | 'standardDeviation' | 'highScore' | 'lowScore' | 'belowAveragePercentage' | null;

export type OppositionSortField = 'name' | 'team' | 'nextOpponent' | 'averageVsOpp' | 'opponent3RoundDifficulty' | 'scoreImpact' | 'projectedAverage' | null;

export type VenueSortField = 'name' | 'team' | 'nextVenue' | 'averageAtVenue' | 'averageAt3RoundVenue' | 'opponent3RoundDifficulty' | 'venueScoreVariance' | null;

export type SortDirection = 'asc' | 'desc' | null;