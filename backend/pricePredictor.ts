import { eq, desc, and } from "drizzle-orm";
import { db } from "../db";
import { players, playerRoundScores, priceHistory, systemParameters } from "../../shared/schema";

export interface PricePredictorInput {
  playerId: number;
  projectedScores: number[]; // Array of projected scores for next 3-5 rounds
}

export interface PricePredictionResult {
  playerId: number;
  playerName: string;
  currentPrice: number;
  currentBreakEven: number;
  predictions: {
    round: number;
    projectedScore: number;
    priceChange: number;
    newPrice: number;
    newBreakEven: number;
  }[];
  totalPriceChange: number;
  finalPrice: number;
}

export class PricePredictorService {
  
  /**
   * Calculate price predictions based on projected scores
   */
  async calculatePricePrediction(input: PricePredictorInput): Promise<PricePredictionResult> {
    // Get player data
    const player = await db.select()
      .from(players)
      .where(eq(players.id, input.playerId))
      .limit(1);
    
    if (!player.length) {
      throw new Error('Player not found');
    }

    const playerData = player[0];

    // Get recent round scores (last 5 games)
    const recentScores = await db.select()
      .from(playerRoundScores)
      .where(eq(playerRoundScores.playerId, input.playerId))
      .orderBy(desc(playerRoundScores.round))
      .limit(5);

    // Get current system parameters (magic number, etc.)
    const systemParams = await db.select()
      .from(systemParameters)
      .orderBy(desc(systemParameters.round))
      .limit(1);

    const magicNumber = systemParams.length > 0 ? systemParams[0].magicNumber : 3500; // Default magic number
    const betaWeight = systemParams.length > 0 ? systemParams[0].betaWeight : 0.15;
    const priceSensitivityFactor = systemParams.length > 0 ? systemParams[0].priceSensitivityFactor : 150;

    // Calculate predictions for each projected score
    const predictions = [];
    let currentPrice = playerData.price;
    let currentBreakEven = playerData.breakEven;

    for (let i = 0; i < input.projectedScores.length; i++) {
      const projectedScore = input.projectedScores[i];
      
      // Apply the AFL Fantasy price formula
      const prediction = this.calculateSinglePricePrediction(
        currentPrice,
        projectedScore,
        recentScores.map(s => s.score),
        magicNumber,
        betaWeight,
        priceSensitivityFactor
      );

      predictions.push({
        round: i + 1,
        projectedScore,
        priceChange: prediction.priceChange,
        newPrice: prediction.newPrice,
        newBreakEven: prediction.newBreakEven
      });

      // Update for next iteration
      currentPrice = prediction.newPrice;
      currentBreakEven = prediction.newBreakEven;
    }

    const totalPriceChange = predictions.reduce((sum, p) => sum + p.priceChange, 0);

    return {
      playerId: input.playerId,
      playerName: playerData.name,
      currentPrice: playerData.price,
      currentBreakEven: playerData.breakEven,
      predictions,
      totalPriceChange,
      finalPrice: currentPrice
    };
  }

  /**
   * Apply the AFL Fantasy price formula for a single round
   * Formula: P_n = (1 - β) * P_{n-1} + M_n - Σ(α_k * S_k)
   */
  private calculateSinglePricePrediction(
    currentPrice: number,
    projectedScore: number,
    recentScores: number[],
    magicNumber: number,
    betaWeight: number,
    priceSensitivityFactor: number
  ) {
    // Score weights (most recent game has highest weight)
    const scoreWeights = [5, 4, 3, 2, 1];
    
    // Add projected score as the most recent
    const allScores = [projectedScore, ...recentScores].slice(0, 5);
    
    // Calculate weighted score sum
    let weightedSum = 0;
    for (let i = 0; i < allScores.length; i++) {
      weightedSum += scoreWeights[i] * allScores[i];
    }

    // Apply price formula
    const newPrice = Math.round(
      (1 - betaWeight) * currentPrice + magicNumber - weightedSum
    );

    const priceChange = newPrice - currentPrice;
    
    // Calculate new breakeven
    // Breakeven = current weighted average + (price change / sensitivity factor)
    const currentWeightedAvg = weightedSum / scoreWeights.slice(0, allScores.length).reduce((a, b) => a + b, 0);
    const newBreakEven = Math.round(currentWeightedAvg + (priceChange / priceSensitivityFactor));

    return {
      newPrice: Math.max(newPrice, 100000), // Minimum price floor
      priceChange,
      newBreakEven: Math.max(newBreakEven, 0) // Minimum breakeven floor
    };
  }

  /**
   * Calculate magic number based on aggregate player data
   * This is a simplified calculation - in reality, AFL Fantasy calculates this internally
   */
  async calculateMagicNumber(round: number): Promise<number> {
    // Get all player scores for the round
    const roundScores = await db.select()
      .from(playerRoundScores)
      .where(eq(playerRoundScores.round, round));

    if (roundScores.length === 0) {
      return 3500; // Default magic number
    }

    // Calculate average score
    const totalScore = roundScores.reduce((sum, score) => sum + score.score, 0);
    const averageScore = totalScore / roundScores.length;

    // Magic number typically adjusts to maintain price balance
    // Higher average scores = higher magic number to prevent runaway inflation
    const baseMagicNumber = 3500;
    const adjustment = (averageScore - 100) * 10; // Adjust based on how far from 100 the average is
    
    return Math.round(baseMagicNumber + adjustment);
  }

  /**
   * Get player's recent scoring form for context
   */
  async getPlayerScoringForm(playerId: number): Promise<{
    last5Scores: number[];
    last3Average: number;
    last5Average: number;
    seasonAverage: number;
  }> {
    const recentScores = await db.select()
      .from(playerRoundScores)
      .where(eq(playerRoundScores.playerId, playerId))
      .orderBy(desc(playerRoundScores.round))
      .limit(5);

    const player = await db.select()
      .from(players)
      .where(eq(players.id, playerId))
      .limit(1);

    const scores = recentScores.map(s => s.score);
    const last3Average = scores.slice(0, 3).reduce((a, b) => a + b, 0) / Math.min(3, scores.length);
    const last5Average = scores.reduce((a, b) => a + b, 0) / scores.length;
    const seasonAverage = player.length > 0 ? player[0].averagePoints : 0;

    return {
      last5Scores: scores,
      last3Average: Math.round(last3Average * 10) / 10,
      last5Average: Math.round(last5Average * 10) / 10,
      seasonAverage
    };
  }
}