/**
 * AFL Fantasy Trade Tools
 */
import { 
  calculatePriceChange, 
  calculateValueScore, 
  calculateConsistencyScore,
  DEFAULT_MAGIC_NUMBER
} from './utils';

// Player interface for fantasy calculations
export interface FantasyPlayer {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  breakeven: number;
  average: number;
  projectedScore: number;
  lastScore?: number;
  l3Average?: number;
  l5Average?: number;
  selectedBy?: number;
  ceiling?: number;
  floor?: number;
  isInjured?: boolean;
  isSuspended?: boolean;
  consistency?: number;
  scores?: number[];
  bye?: number;
  nextFixtures?: string[];
  nextFixtureDifficulty?: number[];
  redDotFlag?: boolean;
}

/**
 * Calculate trade score based on various factors
 * 
 * @param playerIn Player coming in
 * @param playerOut Player going out
 * @param roundNumber Current round number (for context)
 * @param teamValue Team's total value
 * @param leagueAvgValue League average team value
 * @returns Trade score and analysis
 */
export function calculateTradeScore(
  playerIn: {
    price: number;
    breakeven: number; 
    proj_scores: number[];
    is_red_dot: boolean;
  }, 
  playerOut: {
    price: number;
    breakeven: number;
    proj_scores: number[];
    is_red_dot: boolean;
  },
  roundNumber: number,
  teamValue: number,
  leagueAvgValue: number
) {
  // 1. Calculate scoring score - total projected score difference
  const totalProjIn = playerIn.proj_scores.reduce((a: number, b: number) => a + b, 0);
  const totalProjOut = playerOut.proj_scores.reduce((a: number, b: number) => a + b, 0);
  const scoringScore = totalProjIn - totalProjOut;
  
  // Calculate average projected scores for display
  const avgProjIn = totalProjIn / playerIn.proj_scores.length;
  const avgProjOut = totalProjOut / playerOut.proj_scores.length;
  const scoreDiff = avgProjIn - avgProjOut;

  // 2. Calculate price trends for both players
  // Magic number for price changes
  const magicNumber = DEFAULT_MAGIC_NUMBER;
  
  // Simulate 5-round price trends
  const priceChangesIn: number[] = [];
  const priceChangesOut: number[] = [];
  const projectedPricesIn: number[] = [];
  const projectedPricesOut: number[] = [];
  
  let currentBeIn = playerIn.breakeven;
  let currentBeOut = playerOut.breakeven;
  let currentPriceIn = playerIn.price;
  let currentPriceOut = playerOut.price;
  
  projectedPricesIn.push(currentPriceIn);
  projectedPricesOut.push(currentPriceOut);
  
  for (let i = 0; i < 5; i++) {
    // For player_in: (score - breakeven) * (magic_number / 100)
    // Use projected score for the round or the average if index out of range
    const projScoreIn = i < playerIn.proj_scores.length ? playerIn.proj_scores[i] : avgProjIn;
    const priceChangeIn = calculatePriceChange(projScoreIn, currentBeIn, magicNumber);
    priceChangesIn.push(priceChangeIn);
    
    // Update projected price and breakeven for next round
    currentPriceIn += priceChangeIn;
    projectedPricesIn.push(currentPriceIn);
    
    // Update breakeven - typically 3-round rolling average * 0.85
    // This is a simplified approximation
    currentBeIn = Math.round(projScoreIn * 0.9);
    
    // Same for player_out
    const projScoreOut = i < playerOut.proj_scores.length ? playerOut.proj_scores[i] : avgProjOut;
    const priceChangeOut = calculatePriceChange(projScoreOut, currentBeOut, magicNumber);
    priceChangesOut.push(priceChangeOut);
    
    // Update projected price and breakeven for next round
    currentPriceOut += priceChangeOut;
    projectedPricesOut.push(currentPriceOut);
    
    // Update breakeven
    currentBeOut = Math.round(projScoreOut * 0.9);
  }
  
  // 3. Calculate cash score
  // Initial cash impact
  const initialCashChange = playerOut.price - playerIn.price;
  
  // Projected value change over 5 rounds
  const finalPriceIn = projectedPricesIn[projectedPricesIn.length - 1];
  const finalPriceOut = projectedPricesOut[projectedPricesOut.length - 1];
  const finalCashChange = (finalPriceIn - playerIn.price) - (finalPriceOut - playerOut.price);
  
  // Overall cash score combines immediate and projected impacts
  // Weight more heavily to the immediate cash change
  const cashScore = initialCashChange + (finalCashChange * 0.5);
  
  // 4. Adjust for round context
  // Early in season (rounds 1-7): cash generation more important
  // Late in season (rounds 18+): scoring more important
  // Mid season (rounds 8-17): balanced approach
  let scoringWeight = 0.5;  // Default
  let cashWeight = 0.5;     // Default
  
  if (roundNumber <= 7) {
    // Early season: cash is more important
    scoringWeight = 0.3;
    cashWeight = 0.7;
  } else if (roundNumber >= 18) {
    // Late season: scoring is more important
    scoringWeight = 0.8;
    cashWeight = 0.2;
  } else {
    // Mid season: more balanced but scoring increasing in importance
    const midSeasonProgress = (roundNumber - 8) / 9;  // 0 to 1 scale for mid-season
    scoringWeight = 0.4 + (midSeasonProgress * 0.3);
    cashWeight = 1.0 - scoringWeight;
  }
  
  // Adjust weights based on team value vs. league average
  // If team is below league average, focus more on cash generation
  const valueRatio = leagueAvgValue > 0 ? teamValue / leagueAvgValue : 1;
  
  // If team_value < league_avg_value, reduce scoring weight (focus more on cash)
  // If team_value > league_avg_value, increase scoring weight (focus more on points)
  if (valueRatio < 0.95) {  // Below average team value
    // Reduce scoring weight by up to 0.2, but not below 0.1
    const adjustment = Math.min(0.2, scoringWeight * 0.3);
    scoringWeight = Math.max(0.1, scoringWeight - adjustment);
    cashWeight = 1.0 - scoringWeight;
  } else if (valueRatio > 1.05) {  // Above average team value
    // Increase scoring weight by up to 0.2, but not above 0.9 (unless already 1.0)
    if (scoringWeight < 1.0) {
      const adjustment = Math.min(0.2, cashWeight * 0.3);
      scoringWeight = Math.min(0.9, scoringWeight + adjustment);
      cashWeight = 1.0 - scoringWeight;
    }
  }
  
  // 5. Calculate overall score
  // Normalize cash_score by dividing by 10000 for comparison with points
  const cashScoreNormalized = cashScore / 10000;
  const overallScore = (scoringScore * scoringWeight) + (cashScoreNormalized * cashWeight);
  
  // Scale overall_score to 0-100 range
  const scalingFactor = 5.0;  // Assuming most overall_scores are in range -10 to +10
  const normalizedScore = 50 + (overallScore * scalingFactor);
  const tradeScore = Math.max(0, Math.min(100, normalizedScore));
  
  // Generate explanations
  const explanations = [
    `Player coming in projected to score ${scoreDiff > 0 ? scoreDiff.toFixed(1) + ' points more' : (-scoreDiff).toFixed(1) + ' points less'} per game`,
  ];
  
  const totalCashImpact = priceChangesIn.reduce((a, b) => a + b, 0) - priceChangesOut.reduce((a, b) => a + b, 0);
  if (totalCashImpact > 0) {
    explanations.push(`Projected to gain $${(totalCashImpact/1000).toFixed(1)}k in value over 5 rounds`);
  } else {
    explanations.push(`Projected to lose $${(-totalCashImpact/1000).toFixed(1)}k in value over 5 rounds`);
  }
  
  const priceDiff = playerIn.price - playerOut.price;
  if (priceDiff > 0) {
    explanations.push(`This trade costs $${(priceDiff/1000).toFixed(1)}k immediately`);
  } else {
    explanations.push(`This trade frees up $${(-priceDiff/1000).toFixed(1)}k immediately`);
  }
  
  // Round-specific context
  if (roundNumber <= 7) {
    explanations.push(`Round ${roundNumber}: Cash gain is weighted more heavily than scoring`);
  } else if (roundNumber >= 18) {
    explanations.push(`Round ${roundNumber}: Scoring impact is weighted more heavily than cash`);
  } else {
    explanations.push(`Round ${roundNumber}: Balanced approach to scoring and cash impact`);
  }
  
  // Team value context
  if (valueRatio < 0.95) {
    explanations.push(`Your team value is below league average: Cash generation is prioritized`);
  } else if (valueRatio > 1.05) {
    explanations.push(`Your team value is above league average: Scoring impact is prioritized`);
  }
  
  // Red dot impact
  if (playerOut.is_red_dot && !playerIn.is_red_dot) {
    explanations.push(`Trading out a red-dot player for a healthy player: +5 to score`);
  } else if (playerIn.is_red_dot && !playerOut.is_red_dot) {
    explanations.push(`Trading in a red-dot player: -10 to score due to injury/suspension risk`);
  }
  
  // Generate recommendation
  let recommendation = "";
  let upgradePath = "";
  let seasonMatch = "";
  let verdict = "";
  
  // Upgrade path
  if (playerIn.price > playerOut.price) {
    // Upgrading to higher priced player
    upgradePath = "upgrade";
    if (scoreDiff > 0) {
      recommendation = "Standard upgrade - higher priced player with better scoring";
    } else {
      recommendation = "Risky upgrade - higher priced player with lower projected scoring";
    }
  } else {
    // Downgrading to lower priced player
    upgradePath = "downgrade";
    if (scoreDiff >= 0) {
      recommendation = "Value downgrade - lower priced player with same/better scoring";
    } else if (scoreDiff > -10) {
      recommendation = "Balanced downgrade - minor scoring loss for significant cash generation";
    } else {
      recommendation = "Cash downgrade - significant scoring loss for maximum cash generation";
    }
  }
  
  // Season context
  if (roundNumber <= 7) {
    seasonMatch = initialCashChange < 0 ? "low" : "high";
    if (initialCashChange > 0 && cashScore > 0) {
      verdict = "Perfect Timing";
    } else if (initialCashChange > 0 || cashScore > 0) {
      verdict = "Solid Structure Trade";
    } else {
      verdict = "Early Season Cash Risk";
    }
  } else if (roundNumber >= 18) {
    seasonMatch = scoringScore > 0 ? "high" : "low";
    if (scoringScore > 0) {
      verdict = "Strong Finals Move";
    } else {
      verdict = "Poor Choice";
    }
  } else {
    seasonMatch = (scoringScore > 0 && cashScore >= 0) || (scoringScore >= 0 && cashScore > 0) ? "high" : "medium";
    if (scoringScore > 0 && cashScore > 0) {
      verdict = "Perfect Timing";
    } else if (scoringScore > 0 || cashScore > 0) {
      verdict = "Solid Structure Trade";
    } else {
      verdict = "Risky Move";
    }
  }
  
  // Other flags
  const flags = {
    injury_risk: playerIn.is_red_dot,
    immediate_cash: initialCashChange,
    scoring_impact: scoreDiff > 0 ? "positive" : scoreDiff < 0 ? "negative" : "neutral",
    red_dot_factor: playerOut.is_red_dot && !playerIn.is_red_dot ? 5.0 : 
                     playerIn.is_red_dot && !playerOut.is_red_dot ? 0.0 : 5.0,
    scoring_weight: parseFloat((scoringWeight * 100).toFixed(1)),
    cash_weight: parseFloat((cashWeight * 100).toFixed(1))
  };
  
  return {
    status: "ok",
    trade_score: Math.round(tradeScore),
    scoring_score: parseFloat(scoringScore.toFixed(1)),
    cash_score: Math.round(cashScore),
    score_breakdown: {
      points_diff: parseFloat(scoreDiff.toFixed(1)),
      initial_cash_diff: initialCashChange,
      projected_value_diff: Math.round(finalCashChange),
      scoring_weight: parseFloat((scoringWeight * 100).toFixed(0)),
      cash_weight: parseFloat((cashWeight * 100).toFixed(0))
    },
    price_projections: {
      player_in: priceChangesIn.map(change => Math.round(change)),
      player_out: priceChangesOut.map(change => Math.round(change)),
      net_gain: Math.round(cashScore)
    },
    projected_prices: {
      player_in: projectedPricesIn,
      player_out: projectedPricesOut
    },
    projected_scores: {
      player_in: playerIn.proj_scores,
      player_out: playerOut.proj_scores
    },
    flags: {
      ...flags,
      upgrade_path: upgradePath,
      season_match: seasonMatch
    },
    verdict,
    explanations,
    recommendation
  };
}

/**
 * Find optimal player to trade to based on target position and available cash
 * 
 * @param position Target position to upgrade/downgrade
 * @param availableCash Cash available for the trade
 * @param players All available players
 * @param currentTeam Current team players
 * @param minScore Minimum projected score to consider
 * @returns Array of best trade options
 */
export function findTradeOptions(
  position: string,
  availableCash: number,
  players: FantasyPlayer[],
  currentTeam: FantasyPlayer[],
  minScore: number = 60
): { 
  tradeOut: FantasyPlayer, 
  tradeIn: FantasyPlayer, 
  score: number,
  scoreChange: number,
  cashChange: number,
  cashGenerated: number
}[] {
  // Filter players who aren't in the current team by position
  const availablePlayers = players.filter(
    p => !currentTeam.some(tp => tp.id === p.id) &&
         p.position === position &&
         p.projectedScore >= minScore
  );
  
  // Get current team players in the target position
  const currentPositionPlayers = currentTeam.filter(p => p.position === position);
  
  const tradeOptions = [];
  
  // For each player in the current team at the target position
  for (const outPlayer of currentPositionPlayers) {
    // For each available player at the target position
    for (const inPlayer of availablePlayers) {
      const priceDiff = inPlayer.price - outPlayer.price;
      
      // Skip if not enough cash
      if (priceDiff > availableCash) continue;
      
      // Skip if no significant difference
      if (Math.abs(inPlayer.projectedScore - outPlayer.projectedScore) < 5 &&
          Math.abs(priceDiff) < 50000) continue;
      
      // Calculate price trends for 3 rounds
      let cashGenerated = 0;
      if (inPlayer.scores && outPlayer.scores) {
        // Use historical scores to project change
        const inPriceChange = calculatePriceChange(
          inPlayer.scores.slice(-3).reduce((a, b) => a + b, 0) / 3, 
          inPlayer.breakeven
        );
        const outPriceChange = calculatePriceChange(
          outPlayer.scores.slice(-3).reduce((a, b) => a + b, 0) / 3, 
          outPlayer.breakeven
        );
        cashGenerated = inPriceChange - outPriceChange;
      } else {
        // Use projected scores
        cashGenerated = calculatePriceChange(inPlayer.projectedScore, inPlayer.breakeven) -
                       calculatePriceChange(outPlayer.projectedScore, outPlayer.breakeven);
      }
      
      // Calculate trade score
      const scoreChange = inPlayer.projectedScore - outPlayer.projectedScore;
      
      // Calculate normalized trade score
      // Points gain weighted at 1 point = $8,000
      const normalizedScore = scoreChange + ((-priceDiff + cashGenerated) / 8000);
      
      tradeOptions.push({
        tradeOut: outPlayer,
        tradeIn: inPlayer,
        score: normalizedScore,
        scoreChange,
        cashChange: -priceDiff,
        cashGenerated
      });
    }
  }
  
  // Sort by trade score (descending)
  return tradeOptions.sort((a, b) => b.score - a.score);
}

/**
 * Find optimal one-up, one-down combinations
 * (downgrade one player to a rookie and use the cash to upgrade another)
 * 
 * @param players All available players
 * @param currentTeam Current team players
 * @param maxRookiePrice Maximum price for a rookie
 * @returns Best one-up, one-down combinations
 */
export function findOneUpOneDown(
  players: FantasyPlayer[],
  currentTeam: FantasyPlayer[],
  maxRookiePrice: number = 300000
): {
  downgrade: { from: FantasyPlayer, to: FantasyPlayer },
  upgrade: { from: FantasyPlayer, to: FantasyPlayer },
  netScore: number,
  netCash: number,
  overallScore: number
}[] {
  // Filter rookies (players not in team below rookie price)
  const rookies = players.filter(
    p => !currentTeam.some(tp => tp.id === p.id) &&
         p.price <= maxRookiePrice &&
         p.projectedScore > 45
  );
  
  // Filter premium options (players not in team with good scoring)
  const premiums = players.filter(
    p => !currentTeam.some(tp => tp.id === p.id) &&
         p.projectedScore >= 85
  );
  
  const combinations = [];
  
  // For each potential downgrade target in the current team 
  // (mid-priced players with moderate scores)
  const downgradeTargets = currentTeam.filter(
    p => p.price > maxRookiePrice &&
         p.price < 800000 &&
         p.projectedScore < 95
  );
  
  for (const downgradeFrom of downgradeTargets) {
    // Find valid rookies for this position
    const positionRookies = rookies.filter(
      r => r.position === downgradeFrom.position || 
           r.position.split(',').includes(downgradeFrom.position)
    );
    
    if (positionRookies.length === 0) continue;
    
    // Find upgrade targets in current team
    const upgradeTargets = currentTeam.filter(
      p => p.price < 900000 &&
           (p.position !== downgradeFrom.position || p.id !== downgradeFrom.id)
    );
    
    for (const upgradeFrom of upgradeTargets) {
      // Find valid premium upgrades for this position
      const positionPremiums = premiums.filter(
        p => p.position === upgradeFrom.position || 
             p.position.split(',').includes(upgradeFrom.position)
      );
      
      if (positionPremiums.length === 0) continue;
      
      // For each rookie and premium combination
      for (const rookie of positionRookies) {
        // Cash generated from downgrade
        const downgradeValue = downgradeFrom.price - rookie.price;
        
        // Skip if downgrade doesn't generate enough cash
        if (downgradeValue < 100000) continue;
        
        // Score lost from downgrade
        const downgradeLoss = downgradeFrom.projectedScore - rookie.projectedScore;
        
        for (const premium of positionPremiums) {
          // Cost of upgrade
          const upgradeCost = premium.price - upgradeFrom.price;
          
          // Skip if can't afford the upgrade
          if (upgradeCost > downgradeValue) continue;
          
          // Score gained from upgrade
          const upgradeGain = premium.projectedScore - upgradeFrom.projectedScore;
          
          // Skip if not a net score gain
          if (upgradeGain <= downgradeLoss) continue;
          
          // Calculate net score and cash
          const netScore = upgradeGain - downgradeLoss;
          const netCash = downgradeValue - upgradeCost;
          
          // Calculate overall score (points and cash)
          const overallScore = netScore + (netCash / 10000);
          
          combinations.push({
            downgrade: {
              from: downgradeFrom,
              to: rookie
            },
            upgrade: {
              from: upgradeFrom,
              to: premium
            },
            netScore,
            netCash,
            overallScore
          });
        }
      }
    }
  }
  
  // Sort by overall score (descending)
  return combinations.sort((a, b) => b.overallScore - a.overallScore);
}

/**
 * Calculate price difference delta between two players
 * 
 * @param playerA First player
 * @param playerB Second player
 * @returns Analysis of price difference vs score difference
 */
export function calculatePriceDifferenceDelta(
  playerA: FantasyPlayer,
  playerB: FantasyPlayer
): {
  priceDifference: number,
  scoreDifference: number,
  pricePerPoint: number,
  efficiencyRating: number,
  recommendation: string,
  playerAValue: number,
  playerBValue: number
} {
  const priceDifference = playerA.price - playerB.price;
  const scoreDifference = playerA.projectedScore - playerB.projectedScore;
  
  // Calculate price per point difference
  const pricePerPoint = Math.abs(scoreDifference) < 0.1 ? 
                         0 : // Avoid division by zero
                         Math.abs(priceDifference / scoreDifference);
  
  // Calculate value (points per $1000)
  const playerAValue = calculateValueScore(playerA.projectedScore, playerA.price);
  const playerBValue = calculateValueScore(playerB.projectedScore, playerB.price);
  
  // Calculate efficiency rating (1.0 is average, higher is better)
  const efficiencyRating = playerAValue / playerBValue;
  
  // Determine recommendation
  let recommendation = "";
  if (priceDifference > 0 && scoreDifference > 0) {
    // PlayerA is more expensive but scores more
    if (pricePerPoint < 5000) {
      recommendation = `${playerA.name} is excellent value, worth the upgrade`;
    } else if (pricePerPoint < 10000) {
      recommendation = `${playerA.name} is good value for the price difference`;
    } else {
      recommendation = `${playerB.name} is better value despite lower scoring`;
    }
  } else if (priceDifference < 0 && scoreDifference > 0) {
    // PlayerA is cheaper but scores more
    recommendation = `${playerA.name} is clearly better value`;
  } else if (priceDifference > 0 && scoreDifference < 0) {
    // PlayerA is more expensive but scores less
    recommendation = `${playerB.name} is clearly better value`;
  } else {
    // PlayerA is cheaper but scores less
    if (pricePerPoint < 5000) {
      recommendation = `${playerB.name} is worth the extra cost`;
    } else if (pricePerPoint < 10000) {
      recommendation = `${playerB.name} is reasonable value for the extra cost`;
    } else {
      recommendation = `${playerA.name} is better value despite lower scoring`;
    }
  }
  
  return {
    priceDifference,
    scoreDifference,
    pricePerPoint,
    efficiencyRating,
    recommendation,
    playerAValue,
    playerBValue
  };
}

/**
 * Track value gained/lost from trades
 * 
 * @param initialTeam Initial team
 * @param currentTeam Current team
 * @returns Analysis of value changes
 */
export function trackValueGain(
  initialTeam: FantasyPlayer[],
  currentTeam: FantasyPlayer[]
): {
  initialValue: number,
  currentValue: number,
  valueGain: number,
  scoreGain: number,
  valueEfficiency: number,
  topGainers: { player: FantasyPlayer, gain: number }[],
  topLosers: { player: FantasyPlayer, loss: number }[]
} {
  // Calculate initial team value
  const initialValue = initialTeam.reduce((sum, player) => sum + player.price, 0);
  
  // Calculate current team value
  const currentValue = currentTeam.reduce((sum, player) => sum + player.price, 0);
  
  // Calculate value gain
  const valueGain = currentValue - initialValue;
  
  // Calculate score difference
  const initialScore = initialTeam.reduce((sum, player) => 
    sum + (player.projectedScore || player.average || 0), 0);
  const currentScore = currentTeam.reduce((sum, player) => 
    sum + (player.projectedScore || player.average || 0), 0);
  const scoreGain = currentScore - initialScore;
  
  // Calculate value efficiency (points gained per $100k)
  const valueEfficiency = valueGain !== 0 ? 
                           (scoreGain / (valueGain / 100000)) : 0;
  
  // Track individual player value changes
  const remainingPlayers = initialTeam.filter(
    ip => currentTeam.some(cp => cp.id === ip.id)
  );
  
  const playerGains = remainingPlayers.map(player => {
    const initialPlayer = initialTeam.find(p => p.id === player.id)!;
    const currentPlayer = currentTeam.find(p => p.id === player.id)!;
    return {
      player: currentPlayer,
      gain: currentPlayer.price - initialPlayer.price
    };
  });
  
  // New players (not in initial team)
  const newPlayers = currentTeam.filter(
    cp => !initialTeam.some(ip => ip.id === cp.id)
  ).map(player => ({
    player,
    gain: player.price - (player.price * 0.9) // Assume 10% gain for new players
  }));
  
  // Combine and sort
  const allGains = [...playerGains, ...newPlayers].sort((a, b) => b.gain - a.gain);
  
  // Get top gainers and losers
  const topGainers = allGains.filter(p => p.gain > 0).slice(0, 5);
  const topLosers = [...allGains]
                     .filter(p => p.gain < 0)
                     .sort((a, b) => a.gain - b.gain)
                     .slice(0, 5)
                     .map(p => ({ player: p.player, loss: Math.abs(p.gain) }));
  
  return {
    initialValue,
    currentValue,
    valueGain,
    scoreGain,
    valueEfficiency,
    topGainers,
    topLosers
  };
}

/**
 * Calculate risk score for using multiple trades
 * 
 * @param players Players involved in potential trades
 * @param tradesLeft Number of trades left
 * @returns Risk assessment of using multiple trades
 */
export function calculateTradeBurnRisk(
  players: FantasyPlayer[],
  tradesLeft: number
): {
  riskScore: number,
  recommendation: string,
  factors: { factor: string, impact: number }[]
} {
  if (tradesLeft <= 1) {
    return {
      riskScore: 90,
      recommendation: "Critical trade shortage: Only use for emergencies",
      factors: [
        { factor: "Nearly out of trades", impact: 90 }
      ]
    };
  }
  
  // Calculate base risk (inversely proportional to trades left)
  const baseRisk = Math.max(0, Math.min(50, 60 - (tradesLeft * 5)));
  
  const factors = [
    { factor: `${tradesLeft} trades remaining`, impact: baseRisk }
  ];
  
  // Check for injuries/suspensions in proposed trade targets
  const injuryRisk = players.filter(p => p.isInjured || p.isSuspended).length * 15;
  if (injuryRisk > 0) {
    factors.push({ 
      factor: "Injury/suspension risk in trade targets", 
      impact: injuryRisk 
    });
  }
  
  // Check for volatile players (low consistency scores)
  const volatilePlayerCount = players.filter(p => 
    p.consistency !== undefined && p.consistency < 50
  ).length;
  const volatilityRisk = volatilePlayerCount * 10;
  
  if (volatilityRisk > 0) {
    factors.push({ 
      factor: "Volatile scoring patterns in trade targets", 
      impact: volatilityRisk 
    });
  }
  
  // Calculate price volatility risk
  const priceVolatilityRisk = players.filter(p =>
    Math.abs(p.breakeven - p.projectedScore) > 30
  ).length * 5;
  
  if (priceVolatilityRisk > 0) {
    factors.push({ 
      factor: "Price volatility in trade targets", 
      impact: priceVolatilityRisk 
    });
  }
  
  // Add up all risk factors
  const totalRisk = Math.min(100, factors.reduce((sum, f) => sum + f.impact, 0));
  
  // Generate recommendation
  let recommendation = "";
  if (totalRisk < 30) {
    recommendation = "Low risk: Proceed with trades as planned";
  } else if (totalRisk < 60) {
    recommendation = "Moderate risk: Consider prioritizing the most important trades";
  } else if (totalRisk < 80) {
    recommendation = "High risk: Only make essential trades";
  } else {
    recommendation = "Critical risk: Save trades for emergencies only";
  }
  
  return {
    riskScore: totalRisk,
    recommendation,
    factors
  };
}

/**
 * Evaluate long-term return on a trade
 * 
 * @param playerIn Player being traded in
 * @param playerOut Player being traded out
 * @param weeksToEvaluate Number of weeks to project
 * @returns Analysis of long-term trade return
 */
export function calculateTradeReturn(
  playerIn: FantasyPlayer,
  playerOut: FantasyPlayer,
  weeksToEvaluate: number = 5
): {
  cumulativeScoreDiff: number,
  breakevenWeek: number | null,
  roiPercentage: number,
  netReturn: number,
  recommendation: string,
  weeklyProjections: { week: number, scoreDiff: number, cumulativeDiff: number }[]
} {
  // Calculate weekly projected scores
  // For simplicity, we'll use the single projected score for all weeks
  // In a real implementation, you'd have week-by-week projections
  const weeklyScoreDiff = playerIn.projectedScore - playerOut.projectedScore;
  
  // Initialize projections
  const weeklyProjections = [];
  let cumulativeScoreDiff = 0;
  let breakevenWeek = null;
  
  // For each week
  for (let week = 1; week <= weeksToEvaluate; week++) {
    // Adjust for random variation (±10%)
    const weekVariation = 1 + ((Math.random() * 0.2) - 0.1);
    const adjustedScoreDiff = weeklyScoreDiff * weekVariation;
    
    // Update cumulative difference
    cumulativeScoreDiff += adjustedScoreDiff;
    
    // Check for breakeven week
    if (breakevenWeek === null && cumulativeScoreDiff >= 0 && weeklyScoreDiff > 0) {
      breakevenWeek = week;
    }
    
    // Add to projections
    weeklyProjections.push({
      week,
      scoreDiff: adjustedScoreDiff,
      cumulativeDiff: cumulativeScoreDiff
    });
  }
  
  // Calculate ROI
  // ROI = (Score Gain) / (Price Difference)
  const priceDiff = playerIn.price - playerOut.price;
  const roiPercentage = priceDiff !== 0 ? 
                        (cumulativeScoreDiff / Math.abs(priceDiff)) * 100000 : 0;
  
  // Calculate net return (normalized score - e.g., 1 point = $5k-$10k in value)
  const valuePerPoint = 8000; // $8k per point
  const netReturn = cumulativeScoreDiff * valuePerPoint - priceDiff;
  
  // Generate recommendation
  let recommendation = "";
  if (cumulativeScoreDiff > 0 && priceDiff <= 0) {
    recommendation = "Excellent trade: Gains points and saves/generates cash";
  } else if (cumulativeScoreDiff > 0) {
    if (breakevenWeek !== null && breakevenWeek <= 2) {
      recommendation = "Strong trade: Quick return on investment";
    } else if (breakevenWeek !== null && breakevenWeek <= 4) {
      recommendation = "Good trade: Reasonable timeframe for return";
    } else {
      recommendation = "Long-term trade: Will take 5+ weeks to see full return";
    }
  } else if (priceDiff < 0) {
    recommendation = "Cash generation trade: Losing points but significant cash benefit";
  } else {
    recommendation = "Poor trade: Loses points and costs cash";
  }
  
  return {
    cumulativeScoreDiff,
    breakevenWeek,
    roiPercentage,
    netReturn,
    recommendation,
    weeklyProjections
  };
}