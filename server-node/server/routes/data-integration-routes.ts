/**
 * Data Integration Routes
 * 
 * Handles data fetching with priority for authentic AFL Fantasy sources
 * when authentication is available, otherwise uses available scraped data.
 */

import { Router } from 'express';
import { aflFantasyIntegration } from '../afl-fantasy-integration';
import fs from 'fs';
import path from 'path';

const router = Router();

/**
 * Get team data - prioritizes authentic AFL Fantasy data
 */
router.get('/team/integrated', async (req, res) => {
  try {
    // First try to get authentic data from AFL Fantasy
    if (aflFantasyIntegration.isAuthenticated()) {
      const authenteticTeam = await aflFantasyIntegration.fetchUserTeam();
      if (authenteticTeam) {
        return res.json({
          source: 'afl_fantasy_api',
          authenticated: true,
          data: authenteticTeam
        });
      }
    }

    // Fall back to current team data with clear indication
    try {
      const teamData = JSON.parse(fs.readFileSync('./user_team.json', 'utf8'));
      return res.json({
        source: 'local_data',
        authenticated: false,
        data: teamData,
        notice: 'Using local team data. Provide AFL Fantasy authentication for real team composition.'
      });
    } catch (error) {
      return res.status(500).json({
        error: 'No team data available',
        message: 'AFL Fantasy authentication required for team data'
      });
    }

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch team data',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Get player data with current prices
 */
router.get('/players/integrated', async (req, res) => {
  try {
    // Try to get current AFL Fantasy prices
    const aflPlayers = await aflFantasyIntegration.fetchPlayerData();
    
    // Always load our scraped data as baseline
    const localData = JSON.parse(fs.readFileSync('./player_data.json', 'utf8'));
    
    if (aflPlayers && aflPlayers.length > 0) {
      // Merge AFL Fantasy prices with our scraped statistics
      const mergedData = localData.map(localPlayer => {
        const aflPlayer = aflPlayers.find(p => 
          p.name.toLowerCase() === localPlayer.name.toLowerCase()
        );
        
        if (aflPlayer) {
          return {
            ...localPlayer,
            price: aflPlayer.price, // Use official AFL Fantasy price
            averagePoints: aflPlayer.averagePoints,
            lastScore: aflPlayer.lastScore,
            breakeven: aflPlayer.breakeven,
            status: aflPlayer.status
          };
        }
        return localPlayer;
      });
      
      return res.json({
        source: 'merged_data',
        players: mergedData,
        notice: 'Merged AFL Fantasy prices with statistical data'
      });
    }
    
    // Use scraped data only
    return res.json({
      source: 'scraped_data',
      players: localData,
      notice: 'Using scraped player data. AFL Fantasy API access would provide current prices.'
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch player data',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Get user performance data
 */
router.get('/performance/integrated', async (req, res) => {
  try {
    if (aflFantasyIntegration.isAuthenticated()) {
      const performance = await aflFantasyIntegration.fetchUserPerformance();
      if (performance) {
        return res.json({
          source: 'afl_fantasy_api',
          authenticated: true,
          data: performance
        });
      }
    }

    // Return placeholder structure with clear indication
    const mockPerformance = {
      userId: 1,
      currentRank: 0,
      totalScore: 0,
      roundScores: [],
      notice: 'Performance data requires AFL Fantasy authentication'
    };

    return res.json({
      source: 'placeholder',
      authenticated: false,
      data: mockPerformance,
      message: 'Provide AFL Fantasy authentication for real performance data'
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to fetch performance data',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

/**
 * Test authentication status
 */
router.get('/auth/status', (req, res) => {
  const isAuth = aflFantasyIntegration.isAuthenticated();
  
  res.json({
    authenticated: isAuth,
    message: isAuth 
      ? 'AFL Fantasy authentication configured'
      : 'AFL Fantasy authentication required for full functionality',
    availableData: {
      scrapedPlayers: true,
      dvpMatrix: true,
      fixtureData: true,
      userTeam: isAuth,
      liveScores: isAuth,
      currentPrices: isAuth
    }
  });
});

/**
 * Get data integration summary
 */
router.get('/summary', async (req, res) => {
  try {
    const authStatus = aflFantasyIntegration.isAuthenticated();
    
    // Count available data
    let playerCount = 0;
    let teamValue = 0;
    
    try {
      const teamData = JSON.parse(fs.readFileSync('./user_team.json', 'utf8'));
      const positions = ['defenders', 'midfielders', 'rucks', 'forwards'];
      
      positions.forEach(pos => {
        if (teamData[pos]) {
          playerCount += teamData[pos].length;
          teamData[pos].forEach(player => teamValue += player.price || 0);
        }
      });
      
      // Add bench players
      if (teamData.bench) {
        Object.values(teamData.bench).forEach((benchPos: any) => {
          if (Array.isArray(benchPos)) {
            playerCount += benchPos.length;
            benchPos.forEach(player => teamValue += player.price || 0);
          }
        });
      }
    } catch (error) {
      // Team data not available
    }

    res.json({
      authentication: {
        status: authStatus ? 'connected' : 'required',
        message: authStatus 
          ? 'Full AFL Fantasy integration active'
          : 'Authentication needed for complete functionality'
      },
      currentData: {
        teamPlayers: playerCount,
        teamValue: teamValue,
        formattedValue: `$${(teamValue / 1000000).toFixed(1)}M`,
        dataGaps: playerCount < 26 ? `Missing ${26 - playerCount} players` : 'Complete'
      },
      integrationReady: true,
      nextSteps: authStatus ? [] : [
        'Provide AFL Fantasy authentication tokens',
        'Access real team composition and prices',
        'Enable live scoring and ranking data'
      ]
    });

  } catch (error) {
    res.status(500).json({
      error: 'Failed to generate summary',
      details: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

export default router;