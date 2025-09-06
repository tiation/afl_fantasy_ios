import { Router } from "express";
import { z } from "zod";
import ScoreProjector from "../services/scoreProjector";

const router = Router();

// Initialize the score projector
const scoreProjector = new ScoreProjector();

// Validation schemas
const singleProjectionSchema = z.object({
  playerName: z.string().min(1),
  round: z.number().int().min(1).max(24).optional().default(21)
});

const batchProjectionSchema = z.object({
  playerNames: z.array(z.string().min(1)).min(1).max(50),
  round: z.number().int().min(1).max(24).optional().default(21)
});

const topScorersSchema = z.object({
  count: z.number().int().min(1).max(100).optional().default(20),
  round: z.number().int().min(1).max(24).optional().default(20)
});

const allPlayersSchema = z.object({
  round: z.number().int().min(1).max(24).optional().default(20)
});

/**
 * Get projected score for a single player
 * POST /api/score-projection/player
 */
router.post("/player", async (req, res) => {
  try {
    const { playerName, round } = singleProjectionSchema.parse(req.body);
    
    const projection = scoreProjector.calculateProjectedScore(playerName, round);
    
    if (!projection) {
      return res.status(404).json({
        success: false,
        error: `Player '${playerName}' not found`
      });
    }
    
    res.json({
      success: true,
      data: projection
    });
  } catch (error) {
    console.error("Single projection error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Get projected scores for multiple players
 * POST /api/score-projection/batch
 */
router.post("/batch", async (req, res) => {
  try {
    const { playerNames, round } = batchProjectionSchema.parse(req.body);
    
    const projections = scoreProjector.calculateBatchProjections(playerNames, round);
    
    res.json({
      success: true,
      data: projections,
      meta: {
        requested: playerNames.length,
        found: projections.length,
        round
      }
    });
  } catch (error) {
    console.error("Batch projection error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Get projected scores for all players
 * GET /api/score-projection/all-players
 */
router.get("/all-players", async (req, res) => {
  try {
    const round = req.query.round ? parseInt(req.query.round as string) : 20;
    
    if (isNaN(round) || round < 1 || round > 24) {
      return res.status(400).json({
        success: false,
        error: "Invalid round number (1-24)"
      });
    }
    
    const allProjections = scoreProjector.getAllPlayerProjections(round);
    
    res.json({
      success: true,
      data: allProjections,
      meta: {
        count: allProjections.length,
        round: round,
        generatedAt: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error("All players projection error:", error);
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : "Failed to get all player projections"
    });
  }
});

/**
 * Get top projected scorers for a round
 * GET /api/score-projection/top-scorers
 */
router.get("/top-scorers", async (req, res) => {
  try {
    const query = topScorersSchema.parse({
      count: req.query.count ? parseInt(req.query.count as string) : undefined,
      round: req.query.round ? parseInt(req.query.round as string) : undefined
    });
    
    const topScorers = scoreProjector.getTopProjectedScorers(query.count, query.round);
    
    res.json({
      success: true,
      data: topScorers,
      meta: {
        count: topScorers.length,
        round: query.round
      }
    });
  } catch (error) {
    console.error("Top scorers error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Get projected scores for a team
 * GET /api/score-projection/team/:teamCode
 */
router.get("/team/:teamCode", async (req, res) => {
  try {
    const teamCode = req.params.teamCode.toUpperCase();
    const round = req.query.round ? parseInt(req.query.round as string) : 21;
    
    if (isNaN(round) || round < 1 || round > 24) {
      return res.status(400).json({
        success: false,
        error: "Invalid round number (1-24)"
      });
    }
    
    const teamProjections = scoreProjector.getTeamProjections(teamCode, round);
    
    res.json({
      success: true,
      data: teamProjections,
      meta: {
        team: teamCode,
        round,
        playerCount: teamProjections.length
      }
    });
  } catch (error) {
    console.error("Team projections error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

/**
 * Get projected score by player name (GET endpoint for easy access)
 * GET /api/score-projection/player/:playerName
 */
router.get("/player/:playerName", async (req, res) => {
  try {
    const playerName = decodeURIComponent(req.params.playerName);
    const round = req.query.round ? parseInt(req.query.round as string) : 21;
    
    if (isNaN(round) || round < 1 || round > 24) {
      return res.status(400).json({
        success: false,
        error: "Invalid round number (1-24)"
      });
    }
    
    const projection = scoreProjector.calculateProjectedScore(playerName, round);
    
    if (!projection) {
      return res.status(404).json({
        success: false,
        error: `Player '${playerName}' not found`
      });
    }
    
    res.json({
      success: true,
      data: projection
    });
  } catch (error) {
    console.error("Player projection error:", error);
    res.status(400).json({
      success: false,
      error: error instanceof Error ? error.message : "Unknown error occurred"
    });
  }
});

export default router;