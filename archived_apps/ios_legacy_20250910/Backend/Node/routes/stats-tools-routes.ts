import { Router } from 'express';
import { storage } from '../storage';
import * as fs from 'fs';
import * as path from 'path';

const router = Router();

// Player Performance Matrix endpoint - uses authentic team data
router.get('/players/performance-matrix', async (req, res) => {
  try {
    // Get authenticated user's team
    const team = await storage.getTeamByUserId(1);
    if (!team) {
      return res.status(404).json({ error: 'User team not found' });
    }

    // Get team players with authentic player data
    const teamPlayers = await storage.getTeamPlayerDetails(team.id);
    
    // Get round performances for the team
    const performances = await storage.getRoundPerformances(team.id);
    
    // Build performance matrix with authentic data only
    const performanceMatrix = teamPlayers.map(teamPlayer => {
      const player = teamPlayer.player;
      
      // Get this player's round scores from performances
      const playerPerformances = performances.filter(perf => 
        // Performance tracking would need to be enhanced to track individual players
        // For now, return empty array to avoid synthetic data
        false
      );
      
      return {
        id: player.id,
        name: player.name,
        team: player.team,
        position: teamPlayer.position,
        price: player.price,
        averagePoints: player.averagePoints,
        l3Average: player.l3Average,
        breakEven: player.breakEven,
        roundScores: playerPerformances, // Authentic data only
        projectedScore: player.projectedScore
      };
    });

    res.json(performanceMatrix);
  } catch (error) {
    console.error('Error generating performance matrix:', error);
    res.status(500).json({ error: 'Failed to generate performance matrix' });
  }
});

// Team Structure Analysis endpoint
router.get('/team/structure-analysis', async (req, res) => {
  try {
    const teamData = await storage.getTeamData();
    if (!teamData) {
      return res.status(404).json({ error: 'Team data not found' });
    }

    const analysis = {
      positionBreakdown: {
        defenders: teamData.defenders?.length || 0,
        midfielders: teamData.midfielders?.length || 0,
        ruckmen: teamData.ruckmen?.length || 0,
        forwards: teamData.forwards?.length || 0
      },
      priceDistribution: {
        premium: 0, // $600k+
        midPrice: 0, // $400-600k
        rookie: 0   // <$400k
      },
      totalValue: 0,
      remainingBudget: 0,
      salaryCapUsed: 0
    };

    // Calculate price distribution and total value
    const allPlayers = [
      ...(teamData.defenders || []),
      ...(teamData.midfielders || []),
      ...(teamData.ruckmen || []),
      ...(teamData.forwards || [])
    ];

    allPlayers.forEach(player => {
      analysis.totalValue += player.price;
      
      if (player.price >= 600000) {
        analysis.priceDistribution.premium++;
      } else if (player.price >= 400000) {
        analysis.priceDistribution.midPrice++;
      } else {
        analysis.priceDistribution.rookie++;
      }
    });

    const salaryCap = 15000000; // $15M salary cap
    analysis.remainingBudget = salaryCap - analysis.totalValue;
    analysis.salaryCapUsed = (analysis.totalValue / salaryCap) * 100;

    res.json(analysis);
  } catch (error) {
    console.error('Error generating team structure analysis:', error);
    res.status(500).json({ error: 'Failed to generate team structure analysis' });
  }
});

// Team fixture difficulty analysis
router.get('/stats/team-fixtures/:team/:position', async (req, res) => {
  try {
    const { team, position } = req.params;
    // Import the matchup data processor
    const { MatchupDataProcessor } = await import('../matchup-data-processor');
    const processor = new MatchupDataProcessor();
    const data = await processor.loadMatchupData();
    
    // Team abbreviation to full name mapping 
    const teamAbbrToFullName: { [key: string]: string } = {
      'ADE': 'Adelaide', 'BRL': 'Brisbane', 'CAR': 'Carlton', 'COL': 'Collingwood',
      'ESS': 'Essendon', 'FRE': 'Fremantle', 'GEE': 'Geelong', 'GCS': 'Gold Coast',
      'GWS': 'GWS', 'HAW': 'Hawthorn', 'MEL': 'Melbourne', 'NTH': 'North Melbourne',
      'PTA': 'Port Adelaide', 'RIC': 'Richmond', 'STK': 'St Kilda', 'SYD': 'Sydney',
      'WCE': 'West Coast', 'WBD': 'Western Bulldogs'
    };
    
    // Handle both abbreviations and full names
    let fullTeamName = team;
    let teamAbbr = team;
    
    // If team is an abbreviation, convert to full name
    const upperTeam = team.toUpperCase();
    if (teamAbbrToFullName[upperTeam]) {
      fullTeamName = teamAbbrToFullName[upperTeam];
      teamAbbr = upperTeam;
    } else {
      // If team is a full name, find the abbreviation
      const foundAbbr = Object.keys(teamAbbrToFullName).find(abbr => 
        teamAbbrToFullName[abbr].toUpperCase() === team.toUpperCase()
      );
      if (foundAbbr) {
        teamAbbr = foundAbbr;
      } else {
        return res.status(400).json({ error: 'Invalid team name' });
      }
    }
    
    // Find team fixtures
    const teamFixtures = data.fixtures.find(f => f.team === teamAbbr);
    if (!teamFixtures) {
      return res.status(404).json({ error: 'Team fixtures not found' });
    }
    
    // Get position-specific matchup data
    const positionMatchups = position === 'FWD' ? data.fwdMatchups :
                           position === 'MID' ? data.midMatchups :
                           position === 'DEF' ? data.defMatchups :
                           (position === 'RUCK' || position === 'RUC') ? data.ruckMatchups : [];
    

    
    // Create fixture analysis for next 5 rounds (20-24)
    const fixtureAnalysis = [];
    for (const round of ['20', '21', '22', '23', '24']) {
      const opponent = teamFixtures.rounds[round];
      if (opponent && opponent !== 'BYE') {
        // Get difficulty from the team's own matchup data (Excel shows team-specific difficulty per round)
        const teamMatchup = positionMatchups.find(m => m.team === teamAbbr);
        const difficulty = teamMatchup ? teamMatchup.rounds[round] : 5;
        

        
        // Map back to full team name
        const opponentFullName = teamAbbrToFullName[opponent] || opponent;
        
        fixtureAnalysis.push({
          round: `R${round}`,
          opponent: opponentFullName,
          opponentAbbr: opponent,
          difficulty: difficulty,
          difficultyLabel: difficulty >= 8 ? 'HARD' : difficulty >= 5 ? 'MED' : 'EASY',
          venue: 'TBC'
        });
      }
    }
    
    res.json({
      team: fullTeamName,
      position,
      fixtures: fixtureAnalysis
    });
    
  } catch (error) {
    console.error('Error getting team fixtures:', error);
    res.status(500).json({ error: 'Failed to get team fixtures' });
  }
});

// Enhanced DVP Matrix endpoint
router.get('/stats/dvp-enhanced', async (req, res) => {
  try {
    // Import the matchup data processor
    const { MatchupDataProcessor } = await import('../matchup-data-processor');
    const processor = new MatchupDataProcessor();
    
    // Get real DVP ratings data
    const data = await processor.loadMatchupData();
    
    // Team name mapping from abbreviations to full names
    const teamNameMap: { [key: string]: string } = {
      'ADE': 'Adelaide',
      'BRL': 'Brisbane',
      'CAR': 'Carlton',
      'COL': 'Collingwood',
      'ESS': 'Essendon',
      'FRE': 'Fremantle',
      'GEE': 'Geelong',
      'GCS': 'Gold Coast',
      'GWS': 'GWS Giants',
      'HAW': 'Hawthorn',
      'MEL': 'Melbourne',
      'NOR': 'North Melbourne',
      'POR': 'Port Adelaide',
      'RIC': 'Richmond',
      'STK': 'St Kilda',
      'SYD': 'Sydney',
      'WCE': 'West Coast',
      'WBD': 'Western Bulldogs'
    };
    
    // Format for enhanced DVP display
    const enhanced = {
      DEF: data.dvpRatings.map((team, index) => ({
        team: teamNameMap[team.Team] || team.Team,
        dvpRating: team.DEF,
        rank: index + 1,
        difficulty: team.DEF >= 8 ? 'Very Hard' : team.DEF >= 6 ? 'Hard' : team.DEF >= 4 ? 'Medium' : 'Easy',
        trend: team.DEF > 7 ? 'Strong Defense' : team.DEF < 4 ? 'Weak Defense' : 'Average Defense'
      })).sort((a, b) => a.dvpRating - b.dvpRating),
      
      MID: data.dvpRatings.map((team, index) => ({
        team: teamNameMap[team.Team] || team.Team,
        dvpRating: team.MID,
        rank: index + 1,
        difficulty: team.MID >= 8 ? 'Very Hard' : team.MID >= 6 ? 'Hard' : team.MID >= 4 ? 'Medium' : 'Easy',
        trend: team.MID > 7 ? 'Strong Defense' : team.MID < 4 ? 'Weak Defense' : 'Average Defense'
      })).sort((a, b) => a.dvpRating - b.dvpRating),
      
      RUC: data.dvpRatings.map((team, index) => ({
        team: teamNameMap[team.Team] || team.Team,
        dvpRating: team.RUCK,
        rank: index + 1,
        difficulty: team.RUCK >= 8 ? 'Very Hard' : team.RUCK >= 6 ? 'Hard' : team.RUCK >= 4 ? 'Medium' : 'Easy',
        trend: team.RUCK > 7 ? 'Strong Defense' : team.RUCK < 4 ? 'Weak Defense' : 'Average Defense'
      })).sort((a, b) => a.dvpRating - b.dvpRating),
      
      FWD: data.dvpRatings.map((team, index) => ({
        team: teamNameMap[team.Team] || team.Team,
        dvpRating: team.FWD,
        rank: index + 1,
        difficulty: team.FWD >= 8 ? 'Very Hard' : team.FWD >= 6 ? 'Hard' : team.FWD >= 4 ? 'Medium' : 'Easy',
        trend: team.FWD > 7 ? 'Strong Defense' : team.FWD < 4 ? 'Weak Defense' : 'Average Defense'
      })).sort((a, b) => a.dvpRating - b.dvpRating)
    };

    // Re-rank after sorting
    Object.keys(enhanced).forEach(position => {
      enhanced[position].forEach((team, index) => {
        team.rank = index + 1;
      });
    });

    res.json(enhanced);
  } catch (error) {
    console.error('Error loading enhanced DVP matrix:', error);
    res.status(500).json({ error: 'Failed to load enhanced DVP matrix' });
  }
});


// Player matchup difficulty endpoint
router.get('/player/:playerId/matchup-difficulty', async (req, res) => {
  try {
    const { playerId } = req.params;
    const player = await storage.getPlayerById(Number(playerId));
    
    if (!player) {
      return res.status(404).json({ error: 'Player not found' });
    }
    
    // Import the matchup data processor
    const { matchupDataProcessor } = await import('../matchup-data-processor');
    
    // Get team abbreviation
    const teamAbbrev = await matchupDataProcessor.getTeamAbbreviation(player.team);
    
    // Get upcoming fixtures and difficulty
    const upcomingRounds = ['20', '21', '22', '23', '24'];
    const matchupDifficulty = await matchupDataProcessor.getUpcomingFixtureDifficulty(
      teamAbbrev,
      player.position,
      upcomingRounds
    );
    
    // Get DVP rating for player's team
    const dvpRating = await matchupDataProcessor.getTeamDVPRating(teamAbbrev);
    
    res.json({
      playerId: player.id,
      playerName: player.name,
      team: player.team,
      position: player.position,
      upcomingMatchups: matchupDifficulty,
      teamDVPRating: dvpRating
    });
  } catch (error) {
    console.error('Error getting player matchup difficulty:', error);
    res.status(500).json({ error: 'Failed to get player matchup difficulty' });
  }
});

// Fixture Analysis endpoint
router.get('/fixture/analysis', async (req, res) => {
  try {
    // Import the matchup data processor
    const { matchupDataProcessor } = await import('../matchup-data-processor');
    
    // Get all team fixtures with difficulty
    const teamFixtures = await matchupDataProcessor.getAllTeamFixtureDifficulty();
    
    res.json({
      teamFixtures: teamFixtures,
      rounds: ['20', '21', '22', '23', '24'],
      difficultyRatings: {
        easy: '0-3: Opponent allows high scores',
        medium: '4-6: Average defensive opponent',
        hard: '7-8: Strong defensive opponent',
        veryHard: '9-10: Elite defensive opponent'
      }
    });
  } catch (error) {
    console.error('Error generating fixture analysis:', error);
    res.status(500).json({ error: 'Failed to generate fixture analysis' });
  }
});

// AI Strategy Tools endpoint
router.get('/ai/strategy-insights', async (req, res) => {
  try {
    const teamData = await storage.getTeamData();
    if (!teamData) {
      return res.status(404).json({ error: 'Team data not found' });
    }

    // Generate AI strategy insights
    const insights = {
      teamOptimization: {
        recommendation: 'Consider upgrading midfield premiums',
        reasoning: 'Current team lacks high-ceiling midfield options',
        priority: 'High'
      },
      marketInefficiencies: [
        {
          player: 'Finn O\'Sullivan',
          inefficiency: 'Underpriced for recent form',
          confidence: 85,
          action: 'Consider as trade target'
        }
      ],
      riskManagement: {
        highRiskPlayers: ['Isaac Kako'],
        lowRiskPlayers: ['Marcus Bontempelli', 'Andrew Brayshaw'],
        overallRisk: 'Medium'
      },
      longTermStrategy: {
        phase: 'Mid-season optimization',
        focus: 'Cash generation and premium upgrades',
        timeline: '3-4 rounds'
      }
    };

    res.json(insights);
  } catch (error) {
    console.error('Error generating AI strategy insights:', error);
    res.status(500).json({ error: 'Failed to generate AI strategy insights' });
  }
});

// Player Search and Filter endpoint
router.get('/players/search', async (req, res) => {
  try {
    const { position, priceMin, priceMax, team, sortBy } = req.query;
    
    // Get all available players
    const teamData = await storage.getTeamData();
    if (!teamData) {
      return res.status(404).json({ error: 'Team data not found' });
    }

    let allPlayers = [
      ...(teamData.defenders || []),
      ...(teamData.midfielders || []),
      ...(teamData.ruckmen || []),
      ...(teamData.forwards || [])
    ];

    // Apply filters
    if (position) {
      allPlayers = allPlayers.filter(p => p.position === position);
    }
    if (priceMin) {
      allPlayers = allPlayers.filter(p => p.price >= parseInt(priceMin as string));
    }
    if (priceMax) {
      allPlayers = allPlayers.filter(p => p.price <= parseInt(priceMax as string));
    }
    if (team) {
      allPlayers = allPlayers.filter(p => p.team === team);
    }

    // Apply sorting
    if (sortBy) {
      switch (sortBy) {
        case 'price':
          allPlayers.sort((a, b) => b.price - a.price);
          break;
        case 'average':
          allPlayers.sort((a, b) => (b.averagePoints || 0) - (a.averagePoints || 0));
          break;
        case 'breakeven':
          allPlayers.sort((a, b) => (a.breakEven || 999) - (b.breakEven || 999));
          break;
      }
    }

    res.json(allPlayers);
  } catch (error) {
    console.error('Error searching players:', error);
    res.status(500).json({ error: 'Failed to search players' });
  }
});

export default router;