import { fantasyTools } from '../../types/fantasy-tools';
import { 
  DEFAULT_MAGIC_NUMBER, 
  calculatePriceChange, 
  calculatePriceTrajectory,
  calculateValueScore,
  calculateConsistencyScore
} from '../utils';

/**
 * Trade Score Calculator
 * 
 * This tool calculates a comprehensive trade score to evaluate potential trades based on:
 * 1. Scoring improvement
 * 2. Price/Value impact
 * 3. Team structure considerations
 * 4. Timing in the season
 * 
 * The score ranges from 0-100, where:
 * - 90-100: "Perfect Timing" - Excellent trade with multiple benefits
 * - 75-89: "Solid Structure Trade" - Strong trade that helps your team structure
 * - 60-74: "Calculated Risk" - Good trade with some upside and manageable risk
 * - 40-59: "Even Trade" - Neutral trade with balanced pros and cons
 * - 20-39: "Risky Move" - Trade with significant risk that may not pay off
 * - 0-19: "Poor Choice" - Inadvisable trade that will likely hurt your team
 */
export async function calculateTradeScore(
  params: fantasyTools.TradeScoreParams
): Promise<fantasyTools.TradeScoreResponse> {
  try {
    // Extract parameters
    const { 
      player_in, 
      player_out, 
      round_number, 
      team_value, 
      league_avg_value 
    } = params;
    
    // Default values if not provided
    const currentRound = round_number || 8;
    const teamValue = team_value || 15000000;
    const leagueAvgValue = league_avg_value || 14500000;
    
    // Validate required parameters
    if (!player_in || !player_out) {
      return {
        status: "error",
        message: "Missing required fields: player_in and player_out are required"
      };
    }
    
    // Calculate scoring score (0-100)
    // This evaluates the projected scoring impact of the trade
    const avgScoreDiff = calculateAvgScoreDifference(player_in, player_out);
    const scoringScore = calculateScoringScore(avgScoreDiff);
    
    // Calculate cash score (0-100)
    // This evaluates the price/value impact of the trade
    const priceDiff = player_out.price - player_in.price;
    const valueDiff = calculateValueDifference(player_in, player_out);
    const cashScore = calculateCashScore(priceDiff, valueDiff);
    
    // Determine if this is an upgrade or downgrade
    const upgradePath = determineUpgradePath(player_in, player_out);
    
    // Determine the season stage (early, mid, late)
    const seasonMatch = determineSeasonStage(currentRound);
    
    // Adjust weights based on season stage
    const weights = calculateWeights(seasonMatch, teamValue, leagueAvgValue);
    
    // Calculate overall trade score (0-100)
    const overallScore = Math.round(
      (scoringScore * weights.scoring) + 
      (cashScore * weights.cash)
    );
    
    // Generate verdict and recommendation
    const verdict = determineVerdict(overallScore);
    const recommendation = generateRecommendation(
      overallScore, 
      upgradePath, 
      seasonMatch, 
      player_in,
      player_out
    );
    
    // Generate explanations for the score
    const explanations = generateExplanations(
      avgScoreDiff,
      priceDiff,
      valueDiff,
      upgradePath,
      seasonMatch,
      teamValue,
      leagueAvgValue
    );
    
    // Calculate price trajectories for both players
    // Provide 5 weeks of projections
    const forecastWeeks = 5;
    const playerInTrajectory = calculatePriceTrajectory(
      player_in.price,
      player_in.breakeven,
      player_in.proj_scores.slice(0, forecastWeeks)
    );
    
    const playerOutTrajectory = calculatePriceTrajectory(
      player_out.price,
      player_out.breakeven,
      player_out.proj_scores.slice(0, forecastWeeks)
    );
    
    // Return score and details
    return {
      status: "ok",
      trade_score: overallScore,
      score_breakdown: {
        scoring_score: scoringScore,
        cash_score: cashScore,
        overall_score: overallScore
      },
      upgrade_path: upgradePath,
      season_match: seasonMatch,
      verdict,
      recommendation,
      explanations,
      price_trend: {
        player_in: playerInTrajectory,
        player_out: playerOutTrajectory
      }
    };
  } catch (error) {
    console.error("Error in calculateTradeScore:", error);
    return {
      status: "error",
      message: "An error occurred while calculating the trade score"
    };
  }
}

// Helper Functions

/**
 * Calculate the average score difference between player_in and player_out
 */
function calculateAvgScoreDifference(player_in: any, player_out: any): number {
  const inAvg = player_in.proj_scores.reduce((sum: number, score: number) => sum + score, 0) / 
                player_in.proj_scores.length;
                
  const outAvg = player_out.proj_scores.reduce((sum: number, score: number) => sum + score, 0) / 
                 player_out.proj_scores.length;
                 
  return inAvg - outAvg;
}

/**
 * Calculate scoring score based on projected score difference
 */
function calculateScoringScore(avgScoreDiff: number): number {
  // Scale:
  // +20 or more: 100
  // +15: 90
  // +10: 80
  // +5: 70
  // 0: 50
  // -5: 30
  // -10: 20
  // -15: 10
  // -20 or worse: 0
  
  if (avgScoreDiff >= 20) return 100;
  if (avgScoreDiff <= -20) return 0;
  
  // Linear interpolation between the defined points
  if (avgScoreDiff > 0) {
    return 50 + (avgScoreDiff / 20) * 50;
  } else {
    return 50 + (avgScoreDiff / 20) * 50;
  }
}

/**
 * Calculate value difference between player_in and player_out
 */
function calculateValueDifference(player_in: any, player_out: any): number {
  const inAvg = player_in.proj_scores.reduce((sum: number, score: number) => sum + score, 0) / 
                player_in.proj_scores.length;
                
  const outAvg = player_out.proj_scores.reduce((sum: number, score: number) => sum + score, 0) / 
                 player_out.proj_scores.length;
                 
  const inValue = inAvg / (player_in.price / 100000);
  const outValue = outAvg / (player_out.price / 100000);
  
  return inValue - outValue;
}

/**
 * Calculate cash score based on price and value differences
 */
function calculateCashScore(priceDiff: number, valueDiff: number): number {
  // Start with a base score of 50
  let cashScore = 50;
  
  // Adjust for price difference (getting money back is good)
  if (priceDiff > 0) {
    // Getting cash back
    const cashFactor = Math.min(1, priceDiff / 300000); // Cap at 300k
    cashScore += cashFactor * 25; // Up to +25 points
  } else {
    // Spending cash
    const cashFactor = Math.min(1, Math.abs(priceDiff) / 300000); // Cap at 300k
    cashScore -= cashFactor * 15; // Up to -15 points
  }
  
  // Adjust for value difference (better value is good)
  if (valueDiff > 0) {
    // Getting better value
    const valueFactor = Math.min(1, valueDiff / 2); // Cap at 2 pts/100k
    cashScore += valueFactor * 25; // Up to +25 points
  } else {
    // Getting worse value
    const valueFactor = Math.min(1, Math.abs(valueDiff) / 2); // Cap at 2 pts/100k
    cashScore -= valueFactor * 35; // Up to -35 points
  }
  
  // Ensure score is within 0-100 range
  return Math.max(0, Math.min(100, cashScore));
}

/**
 * Determine if this is an upgrade, downgrade, or sideways trade
 */
function determineUpgradePath(player_in: any, player_out: any): fantasyTools.TradeScoreResponse['upgrade_path'] {
  const priceDiff = player_in.price - player_out.price;
  
  if (priceDiff >= 100000) {
    return "upgrade";
  } else if (priceDiff <= -100000) {
    return "downgrade";
  } else {
    return "sideways";
  }
}

/**
 * Determine the stage of the season based on round number
 */
function determineSeasonStage(round: number): fantasyTools.TradeScoreResponse['season_match'] {
  if (round <= 7) {
    return "early";
  } else if (round <= 15) {
    return "mid";
  } else {
    return "late";
  }
}

/**
 * Calculate scoring vs cash weights based on stage of season and team value
 */
function calculateWeights(
  seasonStage: fantasyTools.TradeScoreResponse['season_match'],
  teamValue: number,
  leagueAvgValue: number
): { scoring: number, cash: number } {
  // Base weights
  let scoringWeight = 0.6;
  let cashWeight = 0.4;
  
  // Adjust for season stage
  if (seasonStage === "early") {
    // Early season: Focus more on cash generation
    scoringWeight = 0.5;
    cashWeight = 0.5;
  } else if (seasonStage === "late") {
    // Late season: Focus heavily on scoring
    scoringWeight = 0.8;
    cashWeight = 0.2;
  }
  
  // Adjust for team value vs league average
  const valueDiff = teamValue - leagueAvgValue;
  if (valueDiff < -500000) {
    // Team is significantly behind in value: Focus more on cash
    scoringWeight -= 0.1;
    cashWeight += 0.1;
  } else if (valueDiff > 500000) {
    // Team is significantly ahead in value: Focus more on scoring
    scoringWeight += 0.1;
    cashWeight -= 0.1;
  }
  
  // Ensure weights sum to 1
  return {
    scoring: scoringWeight,
    cash: cashWeight
  };
}

/**
 * Determine verdict based on overall score
 */
function determineVerdict(score: number): string {
  if (score >= 90) return "Perfect Timing";
  if (score >= 75) return "Solid Structure Trade";
  if (score >= 60) return "Calculated Risk";
  if (score >= 40) return "Even Trade";
  if (score >= 20) return "Risky Move";
  return "Poor Choice";
}

/**
 * Generate recommendation based on score and context
 */
function generateRecommendation(
  score: number,
  upgradePath: fantasyTools.TradeScoreResponse['upgrade_path'],
  seasonStage: fantasyTools.TradeScoreResponse['season_match'],
  player_in: any,
  player_out: any
): string {
  if (score >= 80) {
    return `Strongly recommend this trade. ${upgradePath === "upgrade" ? 
      `Upgrading to ${player_in.price > 900000 ? "premium" : "solid"} player provides significant scoring boost.` : 
      upgradePath === "downgrade" ? 
      `Downgrading to generate cash is a smart move at this ${seasonStage} stage of the season.` : 
      `Lateral move to a player with better scoring potential.`}`;
  } else if (score >= 60) {
    return `This trade looks promising but consider the timing. ${seasonStage === "early" ? 
      "Early season trades should focus on team value growth." : 
      seasonStage === "mid" ? 
      "Mid-season trades should balance scoring and value." : 
      "Late season trades should prioritize pure scoring."}`;
  } else if (score >= 40) {
    return `This trade is roughly even in value. Consider if it fits your team strategy or if there are better alternatives.`;
  } else {
    return `This trade is not recommended. ${player_in.is_red_dot ? 
      "The player you're trading in has injury/suspension concerns." : 
      player_out.proj_scores[0] > player_in.proj_scores[0] ? 
      "You're losing significant scoring potential." : 
      "The value proposition doesn't make sense at this stage of the season."}`;
  }
}

/**
 * Generate explanations for the trade score
 */
function generateExplanations(
  avgScoreDiff: number,
  priceDiff: number,
  valueDiff: number,
  upgradePath: fantasyTools.TradeScoreResponse['upgrade_path'],
  seasonStage: fantasyTools.TradeScoreResponse['season_match'],
  teamValue: number,
  leagueAvgValue: number
): string[] {
  const explanations = [];
  
  // Scoring explanation
  if (avgScoreDiff >= 10) {
    explanations.push(`+${Math.round(avgScoreDiff)} avg points: Significant scoring upgrade.`);
  } else if (avgScoreDiff >= 5) {
    explanations.push(`+${Math.round(avgScoreDiff)} avg points: Moderate scoring improvement.`);
  } else if (avgScoreDiff >= 0) {
    explanations.push(`+${Math.round(avgScoreDiff)} avg points: Slight scoring increase.`);
  } else if (avgScoreDiff >= -5) {
    explanations.push(`${Math.round(avgScoreDiff)} avg points: Minor scoring downgrade.`);
  } else if (avgScoreDiff >= -10) {
    explanations.push(`${Math.round(avgScoreDiff)} avg points: Significant scoring loss.`);
  } else {
    explanations.push(`${Math.round(avgScoreDiff)} avg points: Major scoring downgrade.`);
  }
  
  // Price explanation
  if (priceDiff > 0) {
    explanations.push(`+$${Math.round(priceDiff / 1000)}k cash: Trade generates money for future moves.`);
  } else if (priceDiff < 0) {
    explanations.push(`-$${Math.round(Math.abs(priceDiff) / 1000)}k cash: Trade requires additional investment.`);
  } else {
    explanations.push(`$0 cash: Trade is even in terms of player prices.`);
  }
  
  // Value explanation
  if (valueDiff > 0.5) {
    explanations.push(`+${valueDiff.toFixed(1)} pts/$100k: Excellent value improvement.`);
  } else if (valueDiff > 0) {
    explanations.push(`+${valueDiff.toFixed(1)} pts/$100k: Better value efficiency.`);
  } else if (valueDiff > -0.5) {
    explanations.push(`${valueDiff.toFixed(1)} pts/$100k: Slightly less value efficiency.`);
  } else {
    explanations.push(`${valueDiff.toFixed(1)} pts/$100k: Significantly worse value proposition.`);
  }
  
  // Season context
  if (seasonStage === "early") {
    explanations.push(`Round timing: Early season trades should focus on building team value.`);
  } else if (seasonStage === "mid") {
    explanations.push(`Round timing: Mid-season trades should balance scoring and value.`);
  } else {
    explanations.push(`Round timing: Late season trades should prioritize pure scoring.`);
  }
  
  // Team value context
  if (teamValue < leagueAvgValue - 500000) {
    explanations.push(`Team value: Your team is below league average, prioritize value growth.`);
  } else if (teamValue > leagueAvgValue + 500000) {
    explanations.push(`Team value: Your team is above league average, can focus more on scoring.`);
  } else {
    explanations.push(`Team value: Your team is near league average, maintain balanced approach.`);
  }
  
  return explanations;
}