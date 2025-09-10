import { fantasyTools } from '../../types/fantasy-tools';

/**
 * One Up One Down Suggester
 * 
 * This tool suggests optimal "one up, one down" trade combinations by:
 * 1. Downgrading a player to a rookie to free up cash
 * 2. Using that cash to upgrade another player in your team
 * 
 * The combinations are scored based on:
 * - Net score impact (projected score gain minus loss)
 * - Net cash impact (cash generated minus cash used)
 * - Value for money (score gain per dollar spent)
 */
export async function findOneUpOneDownCombinations(
  params: fantasyTools.OneUpOneDownParams
): Promise<fantasyTools.OneUpOneDownResponse> {
  // Extract parameters
  const { currentTeam, maxRookiePrice } = params;
  
  try {
    // Use current team as the basis for analysis
    // In a real implementation, we would fetch the complete player data
    // But for now, we'll simulate with just the players in the current team
    if (!currentTeam || currentTeam.length === 0) {
      return {
        status: "error",
        message: "No players in current team"
      };
    }
    
    // In a real implementation, this would be all available players
    // For now, we'll use the current team as a stand-in for demo purposes
    const allPlayers = [...currentTeam];
    
    // Identify potential rookies (downgrade targets) based on maxRookiePrice
    const rookies = allPlayers.filter(player => 
      player.price <= maxRookiePrice && 
      player.price > 150000 && // Exclude bench fodder
      player.projectedScore >= 60 // Playable rookies only
    );
    
    // Identify premium players (upgrade targets)
    const premiumPlayers = allPlayers.filter(player => 
      player.price >= 800000 && // Only consider premium options
      player.average >= 90 // Must be a good scorer
    );
    
    // No rookies available? Return error
    if (rookies.length === 0) {
      return {
        status: "error",
        message: "No viable rookie options found with the given price limit"
      };
    }
    
    // No premiums available? Return error
    if (premiumPlayers.length === 0) {
      return {
        status: "error",
        message: "No viable premium options found"
      };
    }
    
    // Identify downgrade candidates from current team
    // These are mid-priced players that can be downgraded
    const downgradeFromCandidates = currentTeam.filter(player => 
      player.price >= 500000 && 
      player.price <= 900000 && 
      player.position !== "RUCK" // Avoid downgrading rucks as they're harder to replace
    );
    
    // Identify upgrade candidates from current team
    // These are players that can be upgraded to premium options
    const upgradeFromCandidates = currentTeam.filter(player => 
      player.price >= 400000 && 
      player.price <= 800000 &&
      player.average <= 95 // Only upgrade players who aren't already scoring well
    );
    
    // Generate all possible downgrade combinations
    const downgradeCombinations = [];
    
    for (const downgradeFrom of downgradeFromCandidates) {
      // Only consider rookies in the same position
      const positionRookies = rookies.filter(rookie => 
        rookie.position === downgradeFrom.position
      );
      
      for (const downgradeTo of positionRookies) {
        // Calculate cash freed up by the downgrade
        const cashFreed = downgradeFrom.price - downgradeTo.price;
        
        // Calculate score impact of the downgrade
        const scoreImpact = downgradeTo.projectedScore - downgradeFrom.projectedScore;
        
        // Only include substantial cash generation
        if (cashFreed >= 150000) {
          downgradeCombinations.push({
            from: downgradeFrom,
            to: downgradeTo,
            cashFreed,
            scoreImpact
          });
        }
      }
    }
    
    // Generate all possible upgrade combinations
    const upgradeCombinations = [];
    
    for (const upgradeFrom of upgradeFromCandidates) {
      // Only consider premiums in the same position
      const positionPremiums = premiumPlayers.filter(premium => 
        premium.position === upgradeFrom.position
      );
      
      for (const upgradeTo of positionPremiums) {
        // Calculate cash needed for the upgrade
        const cashNeeded = upgradeTo.price - upgradeFrom.price;
        
        // Calculate score impact of the upgrade
        const scoreImpact = upgradeTo.projectedScore - upgradeFrom.projectedScore;
        
        // Only include meaningful upgrades
        if (scoreImpact >= 5) {
          upgradeCombinations.push({
            from: upgradeFrom,
            to: upgradeTo,
            cashNeeded,
            scoreImpact
          });
        }
      }
    }
    
    // Find valid one-up-one-down combinations
    const validCombinations = [];
    
    for (const downgrade of downgradeCombinations) {
      for (const upgrade of upgradeCombinations) {
        // Skip if trying to involve the same player
        if (
          downgrade.from.id === upgrade.from.id ||
          downgrade.from.id === upgrade.to.id ||
          downgrade.to.id === upgrade.from.id ||
          downgrade.to.id === upgrade.to.id
        ) {
          continue;
        }
        
        // Calculate net cash after both trades
        const netCash = downgrade.cashFreed - upgrade.cashNeeded;
        
        // Calculate net score impact
        const netScore = downgrade.scoreImpact + upgrade.scoreImpact;
        
        // Calculate overall value score (0-10)
        // This weights score impact and cash management
        let overallScore = 0;
        
        // Score impact weight (0-6)
        if (netScore >= 20) overallScore += 6;
        else if (netScore >= 15) overallScore += 5;
        else if (netScore >= 10) overallScore += 4;
        else if (netScore >= 5) overallScore += 3;
        else if (netScore >= 0) overallScore += 2;
        else if (netScore >= -5) overallScore += 1;
        
        // Cash management weight (0-4)
        if (netCash >= 200000) overallScore += 4;
        else if (netCash >= 100000) overallScore += 3;
        else if (netCash >= 50000) overallScore += 2;
        else if (netCash >= 0) overallScore += 1;
        
        // Only include affordable combinations with reasonable impact
        if (netCash >= -50000) {
          validCombinations.push({
            downgrade: {
              from: downgrade.from,
              to: downgrade.to
            },
            upgrade: {
              from: upgrade.from,
              to: upgrade.to
            },
            netScore,
            netCash,
            overallScore: overallScore / 10 // Normalize to 0-1
          });
        }
      }
    }
    
    // Sort by overall score (descending)
    validCombinations.sort((a, b) => b.overallScore - a.overallScore);
    
    // Limit to top 10 combinations
    const topCombinations = validCombinations.slice(0, 10);
    
    return {
      status: "ok",
      combinations: topCombinations
    };
  } catch (error) {
    console.error("Error in findOneUpOneDownCombinations:", error);
    return {
      status: "error",
      message: "An error occurred while processing your request"
    };
  }
}