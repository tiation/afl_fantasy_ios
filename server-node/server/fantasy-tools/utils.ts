/**
 * Fantasy Tools Utility Functions
 */

// Common calculation constants
export const DEFAULT_MAGIC_NUMBER = 1.25; // Default value used for price change calculations

/**
 * Calculate a player's price change based on their breakeven and score
 * 
 * @param price Current player price
 * @param breakeven Breakeven score
 * @param projectedScore Projected score
 * @param magicNumber Magic number multiplier (default: 1.25)
 * @returns Price change amount (can be negative)
 */
export function calculatePriceChange(
  price: number,
  breakeven: number,
  projectedScore: number,
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): number {
  // Price change formula:
  // If score > breakeven: (score - breakeven) * magicNumber * price / 100
  // If score < breakeven: (score - breakeven) * magicNumber * price / 100
  
  const scoreDifference = projectedScore - breakeven;
  const changeFactor = scoreDifference * magicNumber * price / 10000;
  
  // Round to nearest $100
  return Math.round(changeFactor / 100) * 100;
}

/**
 * Calculate a player's value score based on their price and projected score
 * 
 * @param price Player price
 * @param projectedScore Projected score or average
 * @returns Value score (points per $100k)
 */
export function calculateValueScore(
  price: number,
  projectedScore: number
): number {
  if (price <= 0) return 0;
  return (projectedScore / (price / 100000));
}

/**
 * Calculate a player's consistency score based on their projected scores
 * 
 * @param projectedScores Array of projected scores
 * @returns Consistency score (0-100)
 */
export function calculateConsistencyScore(projectedScores: number[]): number {
  if (!projectedScores || projectedScores.length <= 1) return 50; // Default score
  
  // Calculate standard deviation
  const average = projectedScores.reduce((sum, score) => sum + score, 0) / projectedScores.length;
  const squareDiffs = projectedScores.map(score => Math.pow(score - average, 2));
  const avgSquareDiff = squareDiffs.reduce((sum, diff) => sum + diff, 0) / squareDiffs.length;
  const stdDev = Math.sqrt(avgSquareDiff);
  
  // Calculate coefficient of variation (CV) = stdDev / average
  const cv = stdDev / average;
  
  // Convert CV to a 0-100 scale (inverted, as lower CV means higher consistency)
  // Typical CV values for AFL players range from 0.1 (very consistent) to 0.5 (highly inconsistent)
  const consistencyScore = Math.max(0, Math.min(100, 100 - (cv * 200)));
  
  return Math.round(consistencyScore);
}

/**
 * Calculate a player's price trajectory over multiple rounds
 * 
 * @param price Starting price
 * @param breakeven Starting breakeven
 * @param projectedScores Array of projected scores for future rounds
 * @param magicNumber Magic number multiplier (default: 1.25)
 * @returns Array of price projections, with week numbers and change amounts
 */
export function calculatePriceTrajectory(
  price: number,
  breakeven: number,
  projectedScores: number[],
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): { price: number, change: number, week: number }[] {
  const trajectory: { price: number, change: number, week: number }[] = [];
  let currentPrice = price;
  let currentBreakeven = breakeven;
  
  // Add current price as starting point
  trajectory.push({
    price: currentPrice,
    change: 0,
    week: 0
  });
  
  // Calculate price changes for each projected score
  projectedScores.forEach((score, index) => {
    const week = index + 1;
    const priceChange = calculatePriceChange(currentPrice, currentBreakeven, score, magicNumber);
    
    // Update price
    currentPrice += priceChange;
    
    // Update breakeven based on the new price and score
    // Breakeven typically adjusts by about 10% of the difference between score and old breakeven
    currentBreakeven = Math.round(
      currentBreakeven + (score - currentBreakeven) * 0.1
    );
    
    // Add to trajectory
    trajectory.push({
      price: currentPrice,
      change: priceChange,
      week
    });
  });
  
  return trajectory;
}

/**
 * Calculate a player's rolling average score
 * 
 * @param historicalScores Array of historical scores
 * @param windowSize Window size for rolling average (default: 3)
 * @returns Rolling average score
 */
export function calculateRollingAverage(
  historicalScores: number[],
  windowSize: number = 3
): number {
  if (!historicalScores || historicalScores.length === 0) return 0;
  
  // If we have fewer scores than the window size, use all scores
  const effectiveWindowSize = Math.min(windowSize, historicalScores.length);
  const recentScores = historicalScores.slice(-effectiveWindowSize);
  
  // Calculate average
  return recentScores.reduce((sum, score) => sum + score, 0) / effectiveWindowSize;
}

/**
 * Calculate price projections based on a rolling average of scores
 * 
 * @param price Starting price
 * @param breakeven Starting breakeven
 * @param historicalScores Array of historical scores
 * @param projectedScores Array of projected future scores
 * @param windowSize Window size for rolling average (default: 3)
 * @param magicNumber Magic number multiplier (default: 1.25)
 * @returns Price projection
 */
export function calculatePriceWithRollingAverage(
  price: number,
  breakeven: number,
  historicalScores: number[],
  projectedScores: number[],
  windowSize: number = 3,
  magicNumber: number = DEFAULT_MAGIC_NUMBER
): number {
  if (!projectedScores || projectedScores.length === 0) return price;
  
  // Start with all historical scores
  const allScores = [...historicalScores];
  let currentPrice = price;
  let currentBreakeven = breakeven;
  
  // Process each projected score
  for (const projectedScore of projectedScores) {
    // Add the projected score to our score history
    allScores.push(projectedScore);
    
    // Calculate rolling average based on recent scores
    const rollingAvg = calculateRollingAverage(allScores, windowSize);
    
    // Calculate price change based on rolling average vs breakeven
    const priceChange = calculatePriceChange(currentPrice, currentBreakeven, rollingAvg, magicNumber);
    
    // Update price
    currentPrice += priceChange;
    
    // Update breakeven
    currentBreakeven = Math.round(
      currentBreakeven + (rollingAvg - currentBreakeven) * 0.1
    );
  }
  
  return currentPrice;
}