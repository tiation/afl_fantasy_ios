/**
 * AFL Fantasy Price Prediction Tools
 */
import { 
  DEFAULT_MAGIC_NUMBER, 
  calculatePriceChange, 
  calculatePriceWithRollingAverage 
} from './utils';
import { FantasyPlayer } from './trade-tools';

/**
 * Predict player prices based on projected scores
 * 
 * @param player Player to analyze
 * @param projectedScores Projected future scores
 * @param magicNumber Magic number for price calculations
 * @returns Projected price changes
 */
export function predictPlayerPrice(
  player: FantasyPlayer,
  projectedScores: number[],
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): {
  player: FantasyPlayer,
  currentPrice: number,
  projectedPrices: number[],
  priceChanges: number[],
  totalChange: number,
  changePercentage: number,
  recommendation: string
} {
  // Initialize with current price
  let currentPrice = player.price;
  let currentBreakEven = player.breakeven;
  
  const projectedPrices = [currentPrice];
  const priceChanges = [];
  
  // For each projected score
  for (let i = 0; i < projectedScores.length; i++) {
    const score = projectedScores[i];
    const priceChange = calculatePriceChange(score, currentBreakEven, magicNumber);
    
    priceChanges.push(priceChange);
    currentPrice += priceChange;
    projectedPrices.push(currentPrice);
    
    // Update breakeven for next round (simplified approximation)
    currentBreakEven = Math.round((currentPrice / magicNumber) * 0.9);
  }
  
  // Calculate total change and percentage
  const totalChange = projectedPrices[projectedPrices.length - 1] - player.price;
  const changePercentage = (totalChange / player.price) * 100;
  
  // Generate recommendation
  let recommendation = "";
  if (changePercentage > 10) {
    recommendation = "Strong price growth expected, ideal trade-in target";
  } else if (changePercentage > 5) {
    recommendation = "Moderate price growth expected, good trade-in candidate";
  } else if (changePercentage > -5) {
    recommendation = "Price relatively stable, trading decision should be based on other factors";
  } else if (changePercentage > -10) {
    recommendation = "Price decline expected, consider trading out if better options available";
  } else {
    recommendation = "Significant price drop expected, trade out soon";
  }
  
  return {
    player,
    currentPrice: player.price,
    projectedPrices,
    priceChanges,
    totalChange,
    changePercentage,
    recommendation
  };
}

/**
 * Estimate price ceiling and floor for a player
 * 
 * @param player Player to analyze
 * @param magicNumber Magic number for price calculations
 * @returns Estimates of price ceiling and floor
 */
export function estimatePriceCeilingFloor(
  player: FantasyPlayer,
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): {
  player: FantasyPlayer,
  currentPrice: number,
  ceilingPrice: number,
  floorPrice: number,
  potentialGain: number,
  potentialLoss: number,
  recommendation: string
} {
  // Calculate ceiling score - use player's ceiling or estimate it
  const ceilingScore = player.ceiling || 
                      (player.projectedScore ? player.projectedScore * 1.2 : 
                      (player.average ? player.average * 1.2 : 100));
  
  // Calculate floor score - use player's floor or estimate it
  const floorScore = player.floor || 
                    (player.projectedScore ? player.projectedScore * 0.8 : 
                    (player.average ? player.average * 0.8 : 40));
  
  // Calculate ceiling price - if player scores at ceiling for 3 rounds
  const ceilingPrice = Math.round(ceilingScore * magicNumber);
  
  // Calculate floor price - if player scores at floor for 3 rounds
  const floorPrice = Math.round(floorScore * magicNumber);
  
  // Calculate potential gain and loss
  const potentialGain = ceilingPrice - player.price;
  const potentialLoss = player.price - floorPrice;
  
  // Generate recommendation
  let recommendation = "";
  if (potentialGain > potentialLoss * 2) {
    recommendation = "Asymmetric upside: Much more to gain than lose";
  } else if (potentialGain > potentialLoss) {
    recommendation = "Positive skew: More potential upside than downside";
  } else if (potentialLoss > potentialGain * 2) {
    recommendation = "Significant downside risk: Consider trading out";
  } else if (potentialLoss > potentialGain) {
    recommendation = "Negative skew: More potential downside than upside";
  } else {
    recommendation = "Balanced risk profile: Equal upside and downside";
  }
  
  return {
    player,
    currentPrice: player.price,
    ceilingPrice,
    floorPrice,
    potentialGain,
    potentialLoss,
    recommendation
  };
}

/**
 * Analyze price trends for a player
 * 
 * @param player Player to analyze
 * @param priceHistory Array of historical prices
 * @returns Analysis of price trends
 */
export function analyzePriceTrends(
  player: FantasyPlayer,
  priceHistory: number[]
): {
  player: FantasyPlayer,
  currentPrice: number,
  priceTrend: string,
  weeklyChanges: number[],
  averageWeeklyChange: number,
  totalChange: number,
  changePercentage: number,
  recommendation: string
} {
  if (!priceHistory || priceHistory.length < 2) {
    return {
      player,
      currentPrice: player.price,
      priceTrend: "insufficient data",
      weeklyChanges: [],
      averageWeeklyChange: 0,
      totalChange: 0,
      changePercentage: 0,
      recommendation: "Insufficient price history data"
    };
  }
  
  // Calculate weekly changes
  const weeklyChanges = [];
  for (let i = 1; i < priceHistory.length; i++) {
    weeklyChanges.push(priceHistory[i] - priceHistory[i-1]);
  }
  
  // Calculate average weekly change
  const averageWeeklyChange = weeklyChanges.reduce((sum, change) => sum + change, 0) / weeklyChanges.length;
  
  // Calculate total change and percentage
  const totalChange = priceHistory[priceHistory.length - 1] - priceHistory[0];
  const changePercentage = (totalChange / priceHistory[0]) * 100;
  
  // Determine price trend
  let priceTrend = "stable";
  if (averageWeeklyChange > 10000) priceTrend = "strong growth";
  else if (averageWeeklyChange > 5000) priceTrend = "moderate growth";
  else if (averageWeeklyChange > 0) priceTrend = "slight growth";
  else if (averageWeeklyChange > -5000) priceTrend = "slight decline";
  else if (averageWeeklyChange > -10000) priceTrend = "moderate decline";
  else priceTrend = "strong decline";
  
  // Generate recommendation
  let recommendation = "";
  if (priceTrend === "strong growth") {
    const recentChanges = weeklyChanges.slice(-3);
    const isAccelerating = recentChanges[recentChanges.length - 1] > recentChanges[0];
    
    recommendation = isAccelerating ? 
                     "Strong and accelerating growth, hold for continued increase" :
                     "Strong but decelerating growth, may be approaching peak";
  } else if (priceTrend === "moderate growth") {
    recommendation = "Steady price increase, good hold or trade-in target";
  } else if (priceTrend === "slight growth") {
    recommendation = "Mild price growth, monitor for acceleration or stagnation";
  } else if (priceTrend === "stable") {
    recommendation = "Price stability, trading decisions should be based on other factors";
  } else if (priceTrend === "slight decline") {
    recommendation = "Mild price depreciation, monitor closely for further drops";
  } else if (priceTrend === "moderate decline") {
    recommendation = "Significant depreciation, consider trading out";
  } else {
    recommendation = "Sharp price drop, trade out as soon as possible";
  }
  
  return {
    player,
    currentPrice: player.price,
    priceTrend,
    weeklyChanges,
    averageWeeklyChange,
    totalChange,
    changePercentage,
    recommendation
  };
}

/**
 * Predict price changes based on breakeven and projected score
 * 
 * @param player Player to analyze
 * @param projectedScore Projected score for next round
 * @param magicNumber Magic number for price calculations
 * @returns Projected price change analysis
 */
export function predictNextPriceChange(
  player: FantasyPlayer,
  projectedScore?: number,
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): {
  player: FantasyPlayer,
  currentPrice: number,
  breakEven: number,
  projectedScore: number,
  projectedChange: number,
  changePercentage: number,
  recommendation: string
} {
  // Use provided projected score or default to player's projected score
  const score = projectedScore || player.projectedScore || player.average || 0;
  
  // Calculate projected price change
  const projectedChange = calculatePriceChange(score, player.breakeven, magicNumber);
  
  // Calculate percentage change
  const changePercentage = (projectedChange / player.price) * 100;
  
  // Determine if player will hit breakeven
  const hitsBreakEven = score >= player.breakeven;
  
  // Generate recommendation
  let recommendation = "";
  if (projectedChange > 20000) {
    recommendation = "Substantial price rise expected, ideal trade-in or hold";
  } else if (projectedChange > 10000) {
    recommendation = "Significant price increase expected, good trade-in or hold";
  } else if (projectedChange > 0) {
    recommendation = "Modest price increase expected";
  } else if (projectedChange > -10000) {
    recommendation = "Small price drop expected, monitor situation";
  } else if (projectedChange > -20000) {
    recommendation = "Significant price drop expected, consider trading out";
  } else {
    recommendation = "Major price drop expected, trade out soon";
  }
  
  return {
    player,
    currentPrice: player.price,
    breakEven: player.breakeven,
    projectedScore: score,
    projectedChange,
    changePercentage,
    recommendation
  };
}