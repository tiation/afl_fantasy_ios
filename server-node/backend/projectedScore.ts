import { eq, desc, and } from "drizzle-orm";
import { db } from "../db";
import { players, playerRoundScores, opponentHistory, venueHistory, fixtures, teamDefenseVsPosition } from "../../shared/schema";

export interface ProjectedScoreInput {
  playerId: number;
  round: number;
  opponent?: string;
  venue?: string;
}

export interface ProjectedScoreResult {
  playerId: number;
  playerName: string;
  projectedScore: number;
  confidence: number; // 0-100 confidence level
  breakdown: {
    seasonAverage: number;
    seasonWeight: number;
    last3Average: number;
    last3Weight: number;
    last5Average: number;
    last5Weight: number;
    lastVsOpponent: number;
    lastVsOpponentWeight: number;
    last3VsOpponent: number;
    last3VsOpponentWeight: number;
    lastAtVenue: number;
    lastAtVenueWeight: number;
    last3AtVenue: number;
    last3AtVenueWeight: number;
  };
  factors: {
    opponentDifficulty: number;
    venueAdvantage: number;
    recentForm: string;
    dataCompleteness: number;
  };
}

export class ProjectedScoreService {
  
  /**
   * Calculate projected score using the v3.4.4 algorithm
   * Formula: Proj = round(0.3 * Avg + 0.2 * L3Avg + 0.2 * L5Avg + 0.15 * LvOp + 0.1 * L3vOp + 0.15 * L@Ven + 0.05 * L3@Ven)
   */
  async calculateProjectedScore(input: ProjectedScoreInput): Promise<ProjectedScoreResult> {
    // Get player basic data
    const player = await db.select()
      .from(players)
      .where(eq(players.id, input.playerId))
      .limit(1);
    
    if (!player.length) {
      throw new Error('Player not found');
    }

    const playerData = player[0];

    // Get opponent and venue from fixtures if not provided
    let opponent = input.opponent;
    let venue = input.venue;
    
    if (!opponent || !venue) {
      const fixture = await this.getPlayerFixture(playerData.team, input.round);
      opponent = opponent || fixture?.opponent || '';
      venue = venue || fixture?.venue || '';
    }

    // Get scoring components
    const [recentForm, opponentStats, venueStats] = await Promise.all([
      this.getRecentForm(input.playerId),
      this.getOpponentStats(input.playerId, opponent),
      this.getVenueStats(input.playerId, venue)
    ]);

    // Apply the projection formula
    const breakdown = {
      seasonAverage: playerData.averagePoints,
      seasonWeight: 0.3,
      last3Average: recentForm.last3Average,
      last3Weight: 0.2,
      last5Average: recentForm.last5Average,
      last5Weight: 0.2,
      lastVsOpponent: opponentStats.lastScore || 0,
      lastVsOpponentWeight: 0.15,
      last3VsOpponent: opponentStats.last3Average || 0,
      last3VsOpponentWeight: 0.1,
      lastAtVenue: venueStats.lastScore || 0,
      lastAtVenueWeight: 0.15,
      last3AtVenue: venueStats.last3Average || 0,
      last3AtVenueWeight: 0.05
    };

    const projectedScore = Math.round(
      breakdown.seasonAverage * breakdown.seasonWeight +
      breakdown.last3Average * breakdown.last3Weight +
      breakdown.last5Average * breakdown.last5Weight +
      breakdown.lastVsOpponent * breakdown.lastVsOpponentWeight +
      breakdown.last3VsOpponent * breakdown.last3VsOpponentWeight +
      breakdown.lastAtVenue * breakdown.lastAtVenueWeight +
      breakdown.last3AtVenue * breakdown.last3AtVenueWeight
    );

    // Calculate confidence and factors
    const confidence = this.calculateConfidence(recentForm, opponentStats, venueStats);
    const factors = await this.calculateFactors(playerData, opponent, venue, recentForm);

    return {
      playerId: input.playerId,
      playerName: playerData.name,
      projectedScore,
      confidence,
      breakdown,
      factors
    };
  }

  /**
   * Get player's recent form (last 3 and 5 games)
   */
  private async getRecentForm(playerId: number) {
    const recentScores = await db.select()
      .from(playerRoundScores)
      .where(eq(playerRoundScores.playerId, playerId))
      .orderBy(desc(playerRoundScores.round))
      .limit(5);

    const scores = recentScores.map(s => s.score);
    const last3Scores = scores.slice(0, 3);
    const last5Scores = scores;

    return {
      last3Average: last3Scores.length > 0 ? 
        Math.round((last3Scores.reduce((a, b) => a + b, 0) / last3Scores.length) * 10) / 10 : 0,
      last5Average: last5Scores.length > 0 ? 
        Math.round((last5Scores.reduce((a, b) => a + b, 0) / last5Scores.length) * 10) / 10 : 0,
      gamesPlayed: scores.length,
      scores: scores
    };
  }

  /**
   * Get player's performance against specific opponent
   */
  private async getOpponentStats(playerId: number, opponent: string) {
    if (!opponent) {
      return { lastScore: null, last3Average: null, gamesPlayed: 0 };
    }

    const opponentData = await db.select()
      .from(opponentHistory)
      .where(and(
        eq(opponentHistory.playerId, playerId),
        eq(opponentHistory.opponent, opponent)
      ))
      .limit(1);

    if (opponentData.length > 0) {
      return {
        lastScore: opponentData[0].lastScore,
        last3Average: opponentData[0].last3Average,
        gamesPlayed: opponentData[0].gamesPlayed
      };
    }

    // Fallback: get recent scores against this opponent from round scores
    const recentVsOpponent = await db.select()
      .from(playerRoundScores)
      .where(and(
        eq(playerRoundScores.playerId, playerId),
        eq(playerRoundScores.opponent, opponent)
      ))
      .orderBy(desc(playerRoundScores.round))
      .limit(3);

    const scores = recentVsOpponent.map(s => s.score);
    return {
      lastScore: scores.length > 0 ? scores[0] : null,
      last3Average: scores.length > 0 ? 
        Math.round((scores.reduce((a, b) => a + b, 0) / scores.length) * 10) / 10 : null,
      gamesPlayed: scores.length
    };
  }

  /**
   * Get player's performance at specific venue
   */
  private async getVenueStats(playerId: number, venue: string) {
    if (!venue) {
      return { lastScore: null, last3Average: null, gamesPlayed: 0 };
    }

    const venueData = await db.select()
      .from(venueHistory)
      .where(and(
        eq(venueHistory.playerId, playerId),
        eq(venueHistory.venue, venue)
      ))
      .limit(1);

    if (venueData.length > 0) {
      return {
        lastScore: venueData[0].lastScore,
        last3Average: venueData[0].last3Average,
        gamesPlayed: venueData[0].gamesPlayed
      };
    }

    // Fallback: get recent scores at this venue from round scores
    const recentAtVenue = await db.select()
      .from(playerRoundScores)
      .where(and(
        eq(playerRoundScores.playerId, playerId),
        eq(playerRoundScores.venue, venue)
      ))
      .orderBy(desc(playerRoundScores.round))
      .limit(3);

    const scores = recentAtVenue.map(s => s.score);
    return {
      lastScore: scores.length > 0 ? scores[0] : null,
      last3Average: scores.length > 0 ? 
        Math.round((scores.reduce((a, b) => a + b, 0) / scores.length) * 10) / 10 : null,
      gamesPlayed: scores.length
    };
  }

  /**
   * Get player's upcoming fixture information
   */
  private async getPlayerFixture(team: string, round: number) {
    const fixture = await db.select()
      .from(fixtures)
      .where(and(
        eq(fixtures.round, round),
        eq(fixtures.homeTeam, team)
      ))
      .limit(1);

    if (fixture.length > 0) {
      return {
        opponent: fixture[0].awayTeam,
        venue: fixture[0].venue,
        isHome: true
      };
    }

    const awayFixture = await db.select()
      .from(fixtures)
      .where(and(
        eq(fixtures.round, round),
        eq(fixtures.awayTeam, team)
      ))
      .limit(1);

    if (awayFixture.length > 0) {
      return {
        opponent: awayFixture[0].homeTeam,
        venue: awayFixture[0].venue,
        isHome: false
      };
    }

    return null;
  }

  /**
   * Calculate confidence level based on data completeness and consistency
   */
  private calculateConfidence(recentForm: any, opponentStats: any, venueStats: any): number {
    let confidence = 100;

    // Reduce confidence based on missing data
    if (recentForm.gamesPlayed < 3) confidence -= 20;
    if (recentForm.gamesPlayed < 5) confidence -= 10;
    if (!opponentStats.lastScore) confidence -= 15;
    if (!opponentStats.last3Average) confidence -= 10;
    if (!venueStats.lastScore) confidence -= 15;
    if (!venueStats.last3Average) confidence -= 10;

    // Reduce confidence based on scoring volatility
    if (recentForm.scores.length >= 3) {
      const scores = recentForm.scores.slice(0, 3);
      const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
      const variance = scores.reduce((sum, score) => sum + Math.pow(score - avg, 2), 0) / scores.length;
      const stdDev = Math.sqrt(variance);
      
      if (stdDev > 30) confidence -= 15; // High volatility
      else if (stdDev > 20) confidence -= 10;
    }

    return Math.max(confidence, 30); // Minimum 30% confidence
  }

  /**
   * Calculate additional factors affecting the projection
   */
  private async calculateFactors(player: any, opponent: string, venue: string, recentForm: any) {
    // Get opponent difficulty
    let opponentDifficulty = 50; // Neutral default
    if (opponent) {
      const defenseData = await db.select()
        .from(teamDefenseVsPosition)
        .where(and(
          eq(teamDefenseVsPosition.team, opponent),
          eq(teamDefenseVsPosition.position, player.position)
        ))
        .limit(1);

      if (defenseData.length > 0) {
        // Convert rank to difficulty (1 = easiest = 100, 18 = hardest = 0)
        opponentDifficulty = Math.max(0, 100 - ((defenseData[0].rank - 1) * 5.56));
      }
    }

    // Calculate venue advantage (simplified)
    const venueAdvantage = venue ? 50 : 50; // Would need home/away venue mapping

    // Recent form assessment
    let recentFormStr = 'Average';
    if (recentForm.last3Average > player.averagePoints + 10) recentFormStr = 'Excellent';
    else if (recentForm.last3Average > player.averagePoints + 5) recentFormStr = 'Good';
    else if (recentForm.last3Average < player.averagePoints - 10) recentFormStr = 'Poor';
    else if (recentForm.last3Average < player.averagePoints - 5) recentFormStr = 'Below Average';

    // Data completeness
    let dataCompleteness = 100;
    if (!opponent) dataCompleteness -= 25;
    if (!venue) dataCompleteness -= 25;
    if (recentForm.gamesPlayed < 5) dataCompleteness -= 20;
    if (recentForm.gamesPlayed < 3) dataCompleteness -= 30;

    return {
      opponentDifficulty: Math.round(opponentDifficulty),
      venueAdvantage: Math.round(venueAdvantage),
      recentForm: recentFormStr,
      dataCompleteness: Math.max(dataCompleteness, 0)
    };
  }

  /**
   * Batch calculate projected scores for multiple players
   */
  async calculateBatchProjections(inputs: ProjectedScoreInput[]): Promise<ProjectedScoreResult[]> {
    const results = await Promise.all(
      inputs.map(input => this.calculateProjectedScore(input))
    );
    return results;
  }
}