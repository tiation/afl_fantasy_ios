/**
 * AFL Fantasy Cash Generation Tools
 */
import { DEFAULT_MAGIC_NUMBER, calculatePriceChange } from './utils';
import { FantasyPlayer } from './trade-tools';

/**
 * Track projected cash generation for a player
 * 
 * @param player Player to analyze
 * @param projectedScores Array of projected scores
 * @param magicNumber Magic number for price calculations
 * @returns Analysis of projected cash generation
 */
export function trackCashGeneration(
  player: FantasyPlayer,
  projectedScores?: number[],
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): {
  player: FantasyPlayer,
  currentPrice: number,
  projectedPrices: number[],
  totalCashGenerated: number,
  averageChange: number,
  cashGenerationRate: string,
  recommendation: string
} {
  // If no projected scores provided, use the player's projected score
  const scores = projectedScores || Array(5).fill(player.projectedScore);
  
  // Simulate price changes over the next few rounds
  let currentPrice = player.price;
  let currentBreakEven = player.breakeven;
  const projectedPrices = [currentPrice];
  
  // For each projected score, calculate price change
  for (let i = 0; i < scores.length; i++) {
    const score = scores[i];
    const priceChange = calculatePriceChange(score, currentBreakEven, magicNumber);
    currentPrice += priceChange;
    projectedPrices.push(currentPrice);
    
    // Update breakeven for next round (simplified approximation)
    currentBreakEven = Math.round((currentPrice / magicNumber) * 0.9);
  }
  
  // Calculate total cash generated
  const totalCashGenerated = projectedPrices[projectedPrices.length - 1] - player.price;
  
  // Calculate average weekly change
  const averageChange = totalCashGenerated / scores.length;
  
  // Determine cash generation rate
  let cashGenerationRate = "neutral";
  if (averageChange > 10000) cashGenerationRate = "high";
  else if (averageChange > 5000) cashGenerationRate = "medium";
  else if (averageChange > 0) cashGenerationRate = "low";
  else cashGenerationRate = "negative";
  
  // Generate recommendation
  let recommendation = "";
  if (cashGenerationRate === "high") {
    recommendation = "Strong cash cow, hold until price peaks";
  } else if (cashGenerationRate === "medium") {
    recommendation = "Moderate cash generation, consider holding for 2-3 more rounds";
  } else if (cashGenerationRate === "low") {
    recommendation = "Limited upside, trade when a better option is available";
  } else {
    recommendation = "Negative cash generation, trade out soon";
  }
  
  return {
    player,
    currentPrice: player.price,
    projectedPrices,
    totalCashGenerated,
    averageChange,
    cashGenerationRate,
    recommendation
  };
}

/**
 * Model a rookie's price growth based on scoring progression
 * 
 * @param player Rookie player to model
 * @param scores Historical scores
 * @param projectedScores Projected future scores
 * @param initialPrice Initial price (defaults to current price if not provided)
 * @param magicNumber Magic number for price calculations
 * @returns Analysis of rookie price curve
 */
export function modelRookiePriceCurve(
  player: FantasyPlayer,
  scores: number[],
  projectedScores: number[],
  initialPrice?: number,
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): {
  player: FantasyPlayer,
  initialPrice: number,
  currentPrice: number,
  projectedPeakPrice: number,
  projectedPeakRound: number,
  priceTrajectory: number[],
  totalGrowth: number,
  growthPercentage: number,
  recommendation: string
} {
  // Use provided initial price or default to current price
  const startPrice = initialPrice || player.price;
  
  // Combine historical and projected scores
  const allScores = [...scores, ...projectedScores];
  
  // Initialize price trajectory with initial price
  const priceTrajectory = [startPrice];
  let currentPrice = startPrice;
  let currentBE = player.breakeven;
  let peakPrice = startPrice;
  let peakRound = 0;
  
  // Simulate price changes based on AFL Fantasy algorithm
  // For rookies, prices change after 3 games based on average
  if (scores.length < 3) {
    // Rookie hasn't played 3 games yet
    // AFL Fantasy doesn't change prices until 3 games are played
    for (let i = scores.length; i < 3 && i < allScores.length; i++) {
      priceTrajectory.push(currentPrice); // No change yet
    }
    
    // After 3 games, price is based on 3-game average
    if (allScores.length >= 3) {
      const first3Avg = (allScores[0] + allScores[1] + allScores[2]) / 3;
      currentPrice = Math.round(first3Avg * magicNumber);
      priceTrajectory.push(currentPrice);
      
      if (currentPrice > peakPrice) {
        peakPrice = currentPrice;
        peakRound = 3;
      }
      
      // Calculate new breakeven
      currentBE = Math.round((currentPrice / magicNumber) * 0.9);
      
      // Process remaining scores
      for (let i = 3; i < allScores.length; i++) {
        const score = allScores[i];
        const priceChange = calculatePriceChange(score, currentBE, magicNumber);
        currentPrice += priceChange;
        priceTrajectory.push(currentPrice);
        
        // Update peak price
        if (currentPrice > peakPrice) {
          peakPrice = currentPrice;
          peakRound = i;
        }
        
        // Update breakeven for next round
        currentBE = Math.round((currentPrice / magicNumber) * 0.9);
      }
    }
  } else {
    // Rookie has already played 3+ games
    // Process all projected scores
    for (let i = 0; i < projectedScores.length; i++) {
      const score = projectedScores[i];
      const priceChange = calculatePriceChange(score, currentBE, magicNumber);
      currentPrice += priceChange;
      priceTrajectory.push(currentPrice);
      
      // Update peak price
      if (currentPrice > peakPrice) {
        peakPrice = currentPrice;
        peakRound = scores.length + i;
      }
      
      // Update breakeven for next round
      currentBE = Math.round((currentPrice / magicNumber) * 0.9);
    }
  }
  
  // Calculate total growth and percentage
  const totalGrowth = peakPrice - startPrice;
  const growthPercentage = (totalGrowth / startPrice) * 100;
  
  // Generate recommendation
  let recommendation = "";
  if (player.price >= peakPrice) {
    recommendation = "Rookie has likely peaked, consider trading out now";
  } else if (peakRound - scores.length <= 1) {
    recommendation = "Rookie will peak very soon, prepare trade plans";
  } else if (peakRound - scores.length <= 3) {
    recommendation = "Rookie will peak in next 2-3 rounds, hold for now";
  } else {
    recommendation = "Rookie has significant growth potential, strong hold";
  }
  
  return {
    player,
    initialPrice: startPrice,
    currentPrice: player.price,
    projectedPeakPrice: peakPrice,
    projectedPeakRound: peakRound,
    priceTrajectory,
    totalGrowth,
    growthPercentage,
    recommendation
  };
}

/**
 * Find optimal downgrade targets with good value
 * 
 * @param allPlayers All available players
 * @param currentTeam Current team players
 * @param maxPrice Maximum price for downgrade targets
 * @param minProjectedScore Minimum projected score to consider
 * @returns List of downgrade targets ranked by value
 */
export function findDowngradeTargets(
  allPlayers: FantasyPlayer[],
  currentTeam: FantasyPlayer[],
  maxPrice: number = 300000,
  minProjectedScore: number = 65
): {
  player: FantasyPlayer,
  valueIndex: number,
  projectedScoreLoss: number,
  cashSaved: number,
  namedStatus: string
}[] {
  // Filter to players not in current team, below max price, with adequate projected scoring
  const downgradeTargets = allPlayers.filter(
    p => !currentTeam.some(tp => tp.id === p.id) &&
         p.price <= maxPrice &&
         p.projectedScore >= minProjectedScore
  );
  
  // Calculate value index for each target
  const targets = downgradeTargets.map(player => {
    // Calculate points per $1000
    const valueIndex = (player.projectedScore * 1000) / player.price;
    
    // Find comparable player in same position on current team
    const teamPlayerSamePos = currentTeam
      .filter(p => p.position === player.position)
      .sort((a, b) => a.price - b.price)[0]; // Get cheapest as comparison
    
    // Calculate projected score loss vs cheapest player in same position
    const projectedScoreLoss = teamPlayerSamePos ? 
                               teamPlayerSamePos.projectedScore - player.projectedScore :
                               0;
    
    // Calculate cash saved vs player being replaced
    const cashSaved = teamPlayerSamePos ? 
                      teamPlayerSamePos.price - player.price :
                      0;
    
    // Determine if player is named in their team (simplified approximation)
    // In a real implementation, this would check actual team selection data
    const namedStatus = player.redDotFlag ? "Injured/Suspended" : "Named";
    
    return {
      player,
      valueIndex,
      projectedScoreLoss,
      cashSaved,
      namedStatus
    };
  });
  
  // Sort by value index (descending)
  return targets.sort((a, b) => b.valueIndex - a.valueIndex);
}

/**
 * Estimate the floor and ceiling of a player's price
 * 
 * @param player Player to analyze
 * @param floorScore Estimated floor score
 * @param ceilingScore Estimated ceiling score
 * @param magicNumber Magic number for price calculations
 * @returns Analysis of player's price range
 */
export function calculatePriceRange(
  player: FantasyPlayer,
  floorScore?: number,
  ceilingScore?: number,
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): {
  player: FantasyPlayer,
  currentPrice: number,
  floorScore: number,
  ceilingScore: number,
  floorPrice: number,
  ceilingPrice: number,
  projectedEndPrice: number,
  recommendation: string
} {
  // If floor/ceiling not provided, estimate them
  const floor = floorScore || 
                (player.floor || 
                (player.projectedScore ? Math.max(player.projectedScore - 20, 40) : 40));
  
  const ceiling = ceilingScore || 
                  (player.ceiling || 
                  (player.projectedScore ? player.projectedScore + 20 : 100));
  
  // Calculate price floor - price if player scores at floor for 3 consecutive games
  const floorAvg = floor;
  const floorPrice = Math.round(floorAvg * magicNumber);
  
  // Calculate price ceiling - price if player scores at ceiling for 3 consecutive games
  const ceilingAvg = ceiling;
  const ceilingPrice = Math.round(ceilingAvg * magicNumber);
  
  // Calculate projected end price based on player's projected score
  const projectedAvg = player.projectedScore || player.average || 
                      ((floor + ceiling) / 2);
  const projectedEndPrice = Math.round(projectedAvg * magicNumber);
  
  // Generate recommendation
  let recommendation = "";
  
  // If current price is close to floor
  if (player.price < floorPrice * 1.1) {
    recommendation = "Player priced near floor, good value to trade in";
  } 
  // If current price is close to ceiling
  else if (player.price > ceilingPrice * 0.9) {
    recommendation = "Player priced near ceiling, consider trading out";
  }
  // If projected price is higher than current price
  else if (projectedEndPrice > player.price * 1.1) {
    recommendation = "Player likely to increase in value";
  }
  // If projected price is lower than current price
  else if (projectedEndPrice < player.price * 0.9) {
    recommendation = "Player likely to decrease in value";
  }
  // Otherwise
  else {
    recommendation = "Player fairly priced, trading decision should be based on other factors";
  }
  
  return {
    player,
    currentPrice: player.price,
    floorScore: floor,
    ceilingScore: ceiling,
    floorPrice,
    ceilingPrice,
    projectedEndPrice,
    recommendation
  };
}

/**
 * Calculate cash generation ceiling and floor for a player
 * 
 * @param player Player to analyze
 * @param projectedScores Array of projected scores
 * @param magicNumber Magic number for price calculations
 * @returns Analysis of cash generation ceiling and floor
 */
export function calculateCashGenCeilingFloor(
  player: FantasyPlayer,
  projectedScores?: number[],
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): {
  player: FantasyPlayer,
  currentPrice: number,
  floorPrice: number,
  ceilingPrice: number,
  breakEvenFloor: number,
  breakEvenCeiling: number,
  maxCashGeneration: number,
  minCashGeneration: number,
  recommendation: string
} {
  // Estimate score floor and ceiling if not available
  const floorScore = player.floor || 
                    (player.projectedScore ? player.projectedScore * 0.8 : 
                    (player.average ? player.average * 0.8 : 40));
  
  const ceilingScore = player.ceiling || 
                      (player.projectedScore ? player.projectedScore * 1.2 : 
                      (player.average ? player.average * 1.2 : 100));
  
  // Calculate price ceiling and floor
  const priceFloor = player.price;
  let priceCeiling = player.price;
  let breakEvenFloor = player.breakeven;
  let breakEvenCeiling = player.breakeven;
  
  // Simulate price changes for floor scenario (consistently poor scores)
  for (let i = 0; i < 3; i++) {
    const priceChange = calculatePriceChange(floorScore, breakEvenFloor, magicNumber);
    breakEvenFloor = Math.round((breakEvenFloor + priceChange) * 0.9);
  }
  const floorPrice = Math.max(priceFloor + calculatePriceChange(floorScore, breakEvenFloor, magicNumber), 0);
  
  // Simulate price changes for ceiling scenario (consistently high scores)
  for (let i = 0; i < 3; i++) {
    const priceChange = calculatePriceChange(ceilingScore, breakEvenCeiling, magicNumber);
    priceCeiling += priceChange;
    breakEvenCeiling = Math.round((priceCeiling / magicNumber) * 0.9);
  }
  const ceilingPrice = priceCeiling;
  
  // Calculate maximum and minimum cash generation
  const maxCashGeneration = ceilingPrice - player.price;
  const minCashGeneration = floorPrice - player.price;
  
  // Generate recommendation
  let recommendation = "";
  if (maxCashGeneration > 100000 && minCashGeneration > 0) {
    recommendation = "Strong cash cow, very likely to increase in value";
  } else if (maxCashGeneration > 50000 && minCashGeneration > -20000) {
    recommendation = "Moderate cash generation potential with low risk";
  } else if (maxCashGeneration > 0 && minCashGeneration < 0) {
    recommendation = "Volatile cash generation, monitor closely";
  } else {
    recommendation = "Likely to lose value, trade out soon";
  }
  
  return {
    player,
    currentPrice: player.price,
    floorPrice,
    ceilingPrice,
    breakEvenFloor,
    breakEvenCeiling,
    maxCashGeneration,
    minCashGeneration,
    recommendation
  };
}