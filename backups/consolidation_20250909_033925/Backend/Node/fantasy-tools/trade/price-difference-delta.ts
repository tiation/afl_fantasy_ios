import { fantasyTools } from '../../types/fantasy-tools';
import { calculatePriceChange, calculatePriceTrajectory } from '../utils';

/**
 * Price Difference Delta
 * 
 * This tool calculates the projected price deltas between two players
 * to help determine which player will increase in value more over time.
 * 
 * It takes into account:
 * - Current price
 * - Breakeven
 * - Projected scores
 * - Historical performance trends
 */
export async function calculatePriceDifferenceDelta(
  params: fantasyTools.PriceDeltaParams
): Promise<fantasyTools.PriceDeltaResponse> {
  try {
    // Extract parameters
    const { players } = params;
    
    if (!players || players.length === 0) {
      return {
        status: "error",
        message: "No players provided for price delta calculation"
      };
    }
    
    // Calculate price deltas for each player
    const deltas = players.map(player => {
      // Get projected score (or use average if not provided)
      const projectedScore = player.projectedScore || player.average || 0;
      
      // Calculate immediate price change based on projected score vs breakeven
      const immediateChange = calculatePriceChange(
        player.price,
        player.breakeven,
        projectedScore
      );
      
      // Calculate projected price after one round
      const projectedPrice = player.price + immediateChange;
      
      // Calculate percentage change
      const percentage = (immediateChange / player.price) * 100;
      
      return {
        name: player.name,
        currentPrice: player.price,
        projectedPrice,
        delta: immediateChange,
        percentage: parseFloat(percentage.toFixed(2))
      };
    });
    
    // Sort by percentage change (descending)
    deltas.sort((a, b) => b.percentage - a.percentage);
    
    return {
      status: "ok",
      deltas
    };
  } catch (error) {
    console.error("Error in calculatePriceDifferenceDelta:", error);
    return {
      status: "error",
      message: "An error occurred while calculating price difference deltas"
    };
  }
}