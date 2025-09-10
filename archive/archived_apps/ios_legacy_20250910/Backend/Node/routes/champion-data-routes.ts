/**
 * Champion Data API Routes
 * 
 * Routes for accessing official AFL statistics from Champion Data
 */

import { Router } from 'express';
import { championDataAPI } from '../champion-data-api';

const router = Router();

/**
 * Test Champion Data API connection
 */
router.get('/test', async (req, res) => {
  try {
    if (!championDataAPI.isConfigured()) {
      return res.status(400).json({
        error: 'Champion Data API not configured',
        message: 'API credentials required'
      });
    }

    const result = await championDataAPI.testConnection();
    res.json(result);
  } catch (error) {
    res.status(500).json({
      error: 'Failed to test Champion Data API',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Get available leagues
 */
router.get('/leagues', async (req, res) => {
  try {
    const leagues = await championDataAPI.getLeagues();
    if (leagues) {
      res.json({ success: true, data: leagues });
    } else {
      res.status(404).json({ error: 'No leagues data available' });
    }
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch leagues',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Get AFL levels
 */
router.get('/afl-levels', async (req, res) => {
  try {
    const levels = await championDataAPI.getAFLLevels();
    if (levels) {
      res.json({ success: true, data: levels });
    } else {
      res.status(404).json({ error: 'No AFL levels data available' });
    }
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch AFL levels',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Get player statistics for a match
 */
router.get('/match/:matchId/players', async (req, res) => {
  try {
    const matchId = parseInt(req.params.matchId);
    if (isNaN(matchId)) {
      return res.status(400).json({ error: 'Invalid match ID' });
    }

    const playerStats = await championDataAPI.getMatchPlayerStats(matchId);
    if (playerStats) {
      res.json({ success: true, data: playerStats });
    } else {
      res.status(404).json({ error: 'No player statistics available for this match' });
    }
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch player statistics',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Get match information
 */
router.get('/match/:matchId', async (req, res) => {
  try {
    const matchId = parseInt(req.params.matchId);
    if (isNaN(matchId)) {
      return res.status(400).json({ error: 'Invalid match ID' });
    }

    const matchInfo = await championDataAPI.getMatchInfo(matchId);
    if (matchInfo) {
      res.json({ success: true, data: matchInfo });
    } else {
      res.status(404).json({ error: 'No match information available' });
    }
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch match information',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Get available metrics for a match
 */
router.get('/match/:matchId/metrics', async (req, res) => {
  try {
    const matchId = parseInt(req.params.matchId);
    if (isNaN(matchId)) {
      return res.status(400).json({ error: 'Invalid match ID' });
    }

    const metrics = await championDataAPI.getMatchMetrics(matchId);
    if (metrics) {
      res.json({ success: true, data: metrics });
    } else {
      res.status(404).json({ error: 'No metrics available for this match' });
    }
  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch match metrics',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;