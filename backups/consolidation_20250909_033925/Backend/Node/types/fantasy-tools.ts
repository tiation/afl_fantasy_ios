/**
 * AFL Fantasy Tools Types
 * 
 * Type definitions for the fantasy tools service.
 */

export namespace fantasyTools {
  
  // Base Player Type
  export type FantasyPlayer = {
    id: number;
    name: string;
    position: string;
    team: string;
    price: number;
    breakeven: number;
    average: number;
    projectedScore: number;
    lastScore: number;
    l3Average: number | null;
    l5Average: number | null;
    selectedBy: number;
    ceiling: number | null;
    floor: number | null;
    isInjured: boolean;
    isSuspended: boolean;
    consistency: number | null;
    scores: number[];
    bye: number;
    nextFixtures: string[];
    nextFixtureDifficulty: number[];
    redDotFlag: boolean;
  };
  
  // Trade Score Calculator Types
  export type TradeScorePlayerInfo = {
    price: number;
    breakeven: number;
    proj_scores: number[];
    is_red_dot: boolean;
  };
  
  export type TradeScoreParams = {
    player_in: TradeScorePlayerInfo;
    player_out: TradeScorePlayerInfo;
    round_number: number;
    team_value: number;
    league_avg_value: number;
  };
  
  // One Up One Down Suggester Types
  export type OneUpOneDownParams = {
    currentTeam: FantasyPlayer[];
    maxRookiePrice: number;
  };
  
  // Price Difference Delta Types
  export type PriceDeltaParams = {
    players: FantasyPlayer[];
  };
  
  // Generic Callback Type
  export type ApiCallback = (error: Error | null, data?: any) => void;
  
  // Utility function for finding trade options
  export function findTradeOptions(
    position: string,
    availableCash: number,
    allPlayers: any[],
    currentTeam: FantasyPlayer[],
    minScore: number
  ): any[] {
    // Filter available players by position and minimum score
    const availablePlayers = allPlayers.filter(player => {
      // Match position (or multiple positions)
      const positionMatch = position === 'ALL' || 
                           player.position === position || 
                           (player.secondaryPositions && player.secondaryPositions.includes(position));
      
      // Ensure minimum score
      const scoreValid = player.average >= minScore;
      
      // Filter out players already in team
      const notInTeam = !currentTeam.some(teamPlayer => 
        teamPlayer.id === player.id || teamPlayer.name === player.name
      );
      
      return positionMatch && scoreValid && notInTeam;
    });
    
    // Get current team players of the specified position for potential downgrades
    const teamPlayersByPosition = currentTeam.filter(player => {
      return position === 'ALL' || 
             player.position === position || 
             (player.secondaryPositions && player.secondaryPositions.includes(position));
    });
    
    const tradeOptions: any[] = [];
    
    // Generate trade options
    for (const playerOut of teamPlayersByPosition) {
      for (const playerIn of availablePlayers) {
        // Calculate cash difference
        const priceDiff = playerIn.price - playerOut.price;
        
        // Skip trades that cost more than available cash
        if (priceDiff > availableCash) continue;
        
        // Calculate metrics for trade evaluation
        const scoreDiff = playerIn.average - playerOut.average;
        const beValue = playerIn.breakeven - playerOut.breakeven;
        const valuePerPoint = playerIn.price / playerIn.average - playerOut.price / playerOut.average;
        
        // Only consider trades that improve average score
        if (scoreDiff <= 0) continue;
        
        // Generate option with evaluation metrics
        tradeOptions.push({
          playerOut: {
            id: playerOut.id,
            name: playerOut.name,
            position: playerOut.position,
            team: playerOut.team,
            price: playerOut.price,
            average: playerOut.average,
            breakeven: playerOut.breakeven
          },
          playerIn: {
            id: playerIn.id,
            name: playerIn.name,
            position: playerIn.position,
            team: playerIn.team,
            price: playerIn.price,
            average: playerIn.average,
            breakeven: playerIn.breakeven
          },
          metrics: {
            priceDiff,
            scoreDiff,
            beValue,
            valuePerPoint,
            valueScore: scoreDiff / (priceDiff / 10000) // Points gained per $10k spent
          }
        });
      }
    }
    
    // Sort by value score (descending)
    return tradeOptions.sort((a, b) => b.metrics.valueScore - a.metrics.valueScore);
  }
  
  // Utility function for tracking value gain
  export function trackValueGain(
    initialTeam: FantasyPlayer[],
    currentTeam: FantasyPlayer[]
  ): any {
    // Calculate total team values
    const initialValue = initialTeam.reduce((sum, player) => sum + player.price, 0);
    const currentValue = currentTeam.reduce((sum, player) => sum + player.price, 0);
    
    // Overall value change
    const totalValueChange = currentValue - initialValue;
    const percentageChange = (totalValueChange / initialValue) * 100;
    
    // Track individual player changes
    const playerChanges = currentTeam.map(currentPlayer => {
      // Find matching player in initial team
      const initialPlayer = initialTeam.find(p => 
        p.id === currentPlayer.id || p.name === currentPlayer.name
      );
      
      if (initialPlayer) {
        // Calculate player-specific changes
        const priceChange = currentPlayer.price - initialPlayer.price;
        const percentChange = (priceChange / initialPlayer.price) * 100;
        
        return {
          player: {
            id: currentPlayer.id,
            name: currentPlayer.name,
            position: currentPlayer.position,
            team: currentPlayer.team
          },
          initialPrice: initialPlayer.price,
          currentPrice: currentPlayer.price,
          priceChange,
          percentChange
        };
      }
      
      // If player is new, just return current info
      return {
        player: {
          id: currentPlayer.id,
          name: currentPlayer.name,
          position: currentPlayer.position,
          team: currentPlayer.team
        },
        initialPrice: 0, // New player to the team
        currentPrice: currentPlayer.price,
        priceChange: currentPlayer.price,
        percentChange: 100 // 100% increase from zero
      };
    });
    
    // Sort by absolute price change (descending)
    const sortedChanges = playerChanges.sort(
      (a, b) => Math.abs(b.priceChange) - Math.abs(a.priceChange)
    );
    
    return {
      summary: {
        initialValue,
        currentValue,
        totalValueChange,
        percentageChange
      },
      playerChanges: sortedChanges
    };
  }
  
  // Utility function for trade burn risk calculation
  export function calculateTradeBurnRisk(
    players: FantasyPlayer[],
    tradesLeft: number
  ): any {
    // Define risk levels based on trades left
    let riskProfile = 'low';
    if (tradesLeft <= 4) riskProfile = 'medium';
    if (tradesLeft <= 2) riskProfile = 'high';
    
    // Calculate risk for each player
    const playerRisks = players.map(player => {
      // Factors that affect trade burn risk
      const isRookie = player.price < 300000;
      const isPremium = player.price > 800000;
      const isInconsistent = player.consistency ? player.consistency > 20 : false;
      const hasInjuryHistory = player.isInjured;
      
      // Calculate base risk score (0-100)
      let riskScore = 0;
      
      // Rookies: Higher risk of being replaced or reaching price ceiling
      if (isRookie) riskScore += 30;
      
      // Premiums: Generally lower risk due to consistent scoring
      if (isPremium) riskScore -= 20;
      
      // Inconsistent players: Higher risk due to unpredictable scores
      if (isInconsistent) riskScore += 25;
      
      // Injury history: Higher risk of recurring issues
      if (hasInjuryHistory) riskScore += 20;
      
      // Adjust by trade situation
      if (riskProfile === 'medium') riskScore += 10;
      if (riskProfile === 'high') riskScore += 25;
      
      // Ensure risk is within 0-100 range
      riskScore = Math.min(100, Math.max(0, riskScore));
      
      // Determine risk level
      let riskLevel = 'Low';
      if (riskScore > 33) riskLevel = 'Medium';
      if (riskScore > 66) riskLevel = 'High';
      
      return {
        player: {
          id: player.id,
          name: player.name,
          position: player.position,
          team: player.team,
          price: player.price
        },
        riskScore,
        riskLevel,
        factors: {
          isRookie,
          isPremium,
          isInconsistent,
          hasInjuryHistory
        }
      };
    });
    
    // Sort by risk score (descending)
    const sortedRisks = playerRisks.sort((a, b) => b.riskScore - a.riskScore);
    
    return {
      tradesLeft,
      riskProfile,
      playerRisks: sortedRisks
    };
  }
  
  // Utility function for trade return calculation
  export function calculateTradeReturn(
    playerIn: FantasyPlayer,
    playerOut: FantasyPlayer,
    weeksToEvaluate: number
  ): any {
    // Calculate immediate price difference
    const priceDiff = playerIn.price - playerOut.price;
    
    // Calculate expected score difference per week
    const weeklyScoreDiff = playerIn.average - playerOut.average;
    
    // Project total score difference over evaluation period
    const totalScoreDiff = weeklyScoreDiff * weeksToEvaluate;
    
    // Project price changes over the period
    const playerInProjectedPriceChange = calculateProjectedPriceChange(playerIn, weeksToEvaluate);
    const playerOutProjectedPriceChange = calculateProjectedPriceChange(playerOut, weeksToEvaluate);
    
    // Net projected price difference
    const projectedPriceDiff = playerInProjectedPriceChange - playerOutProjectedPriceChange;
    
    // Calculate ROI (Return on Investment)
    // (Total score difference) / (Price difference in $10k increments)
    const roi = priceDiff !== 0 ? totalScoreDiff / (priceDiff / 10000) : 0;
    
    // Evaluation metrics
    const isPriceUpgrade = priceDiff > 0;
    const isScoreUpgrade = weeklyScoreDiff > 0;
    const isRookieToPremmie = playerOut.price < 300000 && playerIn.price > 800000;
    
    // Breakeven analysis
    const weeksToBreakeven = weeklyScoreDiff > 0 ? Math.ceil(Math.abs(priceDiff) / (weeklyScoreDiff * 10000)) : Infinity;
    
    return {
      playerIn: {
        id: playerIn.id,
        name: playerIn.name,
        position: playerIn.position,
        team: playerIn.team,
        price: playerIn.price,
        average: playerIn.average,
        projectedPriceChange: playerInProjectedPriceChange
      },
      playerOut: {
        id: playerOut.id,
        name: playerOut.name,
        position: playerOut.position,
        team: playerOut.team,
        price: playerOut.price,
        average: playerOut.average,
        projectedPriceChange: playerOutProjectedPriceChange
      },
      analysis: {
        priceDiff,
        weeklyScoreDiff,
        totalScoreDiff,
        projectedPriceDiff,
        roi,
        isPriceUpgrade,
        isScoreUpgrade,
        isRookieToPremmie,
        weeksToBreakeven,
        weeksToEvaluate
      }
    };
  }
  
  // Helper function for calculating projected price changes
  function calculateProjectedPriceChange(player: FantasyPlayer, weeks: number): number {
    // Price change formula: (average - breakeven) * priceFactor
    // where priceFactor is approximately $975 per point above/below breakeven
    const priceFactor = 975;
    
    // Weekly price change
    const weeklyChange = (player.average - player.breakeven) * priceFactor;
    
    // Project total change over weeks
    return weeklyChange * weeks;
  }
}