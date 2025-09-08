import type { Express } from "express";
import { createServer, type Server } from "http";
import * as fs from "fs";
import * as path from "path";
import { storage } from "./storage";
import { z } from "zod";
import { aflFantasyAPI } from "./afl-fantasy-api";

// Import fantasy routes
import { registerFantasyRoutes } from "./fantasy-routes";
import roleApi from "./role-api";
import captainApi from "./captain-api";
import priceApi from "./price-api";
import fixtureApi from "./fixture-api";
import contextApi from "./context-api";
import teamApi from "./team-api";
import statsRoutes from "./routes/stats-routes";
import aflDataRoutes from "./routes/afl-data-routes";
import dataIntegrationRoutes from "./routes/data-integration-routes";
import championDataRoutes from "./routes/champion-data-routes";
import statsToolsRoutes from "./routes/stats-tools-routes";
import algorithmRoutes from "./routes/algorithm-routes";
import scoreProjectionRoutes from "./routes/score-projection-routes";

// Trade score API proxy endpoint
import axios from 'axios';

export async function registerRoutes(app: Express): Promise<Server> {
  // Register fantasy tools routes
  registerFantasyRoutes(app);
  
  // Register role analysis API routes
  app.use('/api/role-tools', roleApi);
  console.log("Role analysis tools API registered");
  
  // Register captain selection tools API routes
  app.use('/api/captains', captainApi);
  console.log("Captain selection tools API registered");
  
  // Register price analysis tools API routes
  app.use('/api/price-tools', priceApi);
  console.log("Price analysis tools API registered");
  
  // Register fixture analysis tools API routes
  app.use('/api/fixture', fixtureApi);
  console.log("Fixture analysis tools API registered");
  
  // Register context analysis tools API routes
  app.use('/api/context', contextApi);
  console.log("Context analysis tools API registered");
  
  // Register team upload and management API routes
  app.use('/api/team', teamApi);
  console.log("Team management API registered");
  
  // Register stats API routes for FootyWire and DFS Australia data
  app.use('/api/stats', statsRoutes);
  console.log("Stats data API registered");
  
  // Register AFL Fantasy data routes for real player data
  app.use('/api/afl-data', aflDataRoutes);
  console.log("AFL Fantasy data API registered");
  
  // Register data integration routes for authenticated AFL Fantasy access
  app.use('/api/integration', dataIntegrationRoutes);
  console.log("Data integration API registered");
  
  // Register Champion Data AFL Sports API routes
  app.use('/api/champion-data', championDataRoutes);
  console.log("Champion Data API registered");
  
  // Register Stats and Tools API routes
  app.use('/api/stats-tools', statsToolsRoutes);
  console.log("Stats and Tools API registered");
  
  // Register Algorithm API routes for Price Predictor and Projected Score
  app.use('/api/algorithms', algorithmRoutes);
  console.log("Algorithm API routes registered");
  
  // Register Score Projection API routes (v3.4.4 algorithm with authentic data)
  app.use('/api/score-projection', scoreProjectionRoutes);
  console.log("Score projection API registered");
  
  // AFL Fantasy Dashboard Data Endpoints
  app.get("/api/afl-fantasy/dashboard-data", async (req, res) => {
    try {
      console.log("Fetching AFL Fantasy dashboard data...");
      
      // Import and run the Python scraper
      const { spawn } = await import('child_process');
      
      const pythonProcess = spawn('python3', ['afl_fantasy_authenticated_scraper.py'], {
        cwd: process.cwd(),
        stdio: ['pipe', 'pipe', 'pipe']
      });
      
      let output = '';
      let error = '';
      
      pythonProcess.stdout.on('data', (data) => {
        output += data.toString();
        console.log(`AFL Fantasy scraper: ${data.toString().trim()}`);
      });
      
      pythonProcess.stderr.on('data', (data) => {
        error += data.toString();
        console.error(`AFL Fantasy scraper error: ${data.toString().trim()}`);
      });
      
      pythonProcess.on('close', async (code) => {
        if (code === 0) {
          try {
            // Read the generated data file
            const dataPath = path.join(process.cwd(), 'afl_fantasy_team_data.json');
            
            if (fs.existsSync(dataPath)) {
              const rawData = fs.readFileSync(dataPath, 'utf8');
              const data = JSON.parse(rawData);
              
              // Format for dashboard consumption
              const dashboardData = {
                team_value: {
                  total: data.team_value || 0,
                  player_count: data.player_count || 0,
                  remaining_salary: Math.max(0, 13000000 - (data.team_value || 0)),
                  formatted: `$${((data.team_value || 0) / 1000000).toFixed(1)}M`
                },
                team_score: {
                  total: data.team_score || 0,
                  captain_score: data.captain_score || 0,
                  change_from_last_round: data.score_change || 0
                },
                overall_rank: {
                  current: data.overall_rank || 0,
                  formatted: `${(data.overall_rank || 0).toLocaleString()}`,
                  change_from_last_round: data.rank_change || 0
                },
                captain: {
                  score: data.captain_score || 0,
                  ownership_percentage: data.captain_ownership || 0,
                  player_name: data.captain_name || 'Unknown'
                },
                last_updated: new Date().toISOString()
              };
              
              console.log("Successfully extracted AFL Fantasy data:", dashboardData);
              res.json(dashboardData);
            } else {
              throw new Error('AFL Fantasy data file not found');
            }
          } catch (parseError) {
            console.error('Error parsing AFL Fantasy data:', parseError);
            res.status(500).json({
              error: 'Failed to parse AFL Fantasy data',
              message: parseError.message
            });
          }
        } else {
          console.error(`AFL Fantasy scraper failed with code ${code}`);
          console.error('Error output:', error);
          res.status(500).json({
            error: 'AFL Fantasy scraper failed',
            message: error || 'Unknown error occurred'
          });
        }
      });
      
      // Set timeout for the scraper
      setTimeout(() => {
        pythonProcess.kill();
        res.status(408).json({
          error: 'AFL Fantasy scraper timeout',
          message: 'The scraper took too long to complete'
        });
      }, 60000); // 60 second timeout
      
    } catch (error) {
      console.error('Error in AFL Fantasy dashboard endpoint:', error);
      res.status(500).json({
        error: 'Internal server error',
        message: error.message
      });
    }
  });
  // Add a proxy endpoint for trade score API
  app.post("/api/trade_score", async (req, res) => {
    try {
      const pythonApiUrl = "http://localhost:5001/api/trade_score";
      
      // Log the incoming request
      console.log("[express] Received trade score request:", req.body);
      
      try {
        // Try to proxy to the Python API
        const response = await axios.post(pythonApiUrl, req.body);
        res.status(response.status).json(response.data);
      } catch (proxyError) {
        // If Python API is not available, calculate a simple score
        console.warn("[express] Python API not available, using fallback trade score calculator");
        
        const { player_in, player_out } = req.body;
        
        // 1. Calculate scoring score - total projected score difference
        const totalProjIn = player_in.proj_scores.reduce((a: number, b: number) => a + b, 0);
        const totalProjOut = player_out.proj_scores.reduce((a: number, b: number) => a + b, 0);
        const scoringScore = totalProjIn - totalProjOut;
        
        // Calculate average projected scores for display
        const avgProjIn = totalProjIn / player_in.proj_scores.length;
        const avgProjOut = totalProjOut / player_out.proj_scores.length;
        const scoreDiff = avgProjIn - avgProjOut;

        // 2. Calculate price trends for both players
        // Magic number for price changes
        const magicNumber = 9750;
        
        // Simulate 5-round price trends
        const priceChangesIn: number[] = [];
        const priceChangesOut: number[] = [];
        
        for (let i = 0; i < 5; i++) {
          // For player_in: (score - breakeven) * (magic_number / 100)
          // Use projected score for the round or the average if index out of range
          const roundScoreIn = i < player_in.proj_scores.length 
            ? player_in.proj_scores[i] 
            : player_in.proj_scores.reduce((a, b) => a + b, 0) / player_in.proj_scores.length;
          
          const priceChangeIn = (roundScoreIn - player_in.breakeven) * (magicNumber / 100);
          priceChangesIn.push(priceChangeIn);
          
          // For player_out
          const roundScoreOut = i < player_out.proj_scores.length 
            ? player_out.proj_scores[i] 
            : player_out.proj_scores.reduce((a, b) => a + b, 0) / player_out.proj_scores.length;
            
          const priceChangeOut = (roundScoreOut - player_out.breakeven) * (magicNumber / 100);
          priceChangesOut.push(priceChangeOut);
        }
        
        // Calculate cash_score
        const cashScore = priceChangesIn.reduce((a, b) => a + b, 0) - priceChangesOut.reduce((a, b) => a + b, 0);
        
        // 3. Determine round weighting based on current round
        let scoringWeight = 0.5;
        let cashWeight = 0.5;
        
        const roundNumber = req.body.round_number || 8; // Default to round 8 if not provided
        
        // Set weights based on round number
        if (roundNumber <= 2) {  // Round 1-2
          scoringWeight = 0.5;
          cashWeight = 0.5;
        } else if (roundNumber <= 7) {  // Round 3-7
          scoringWeight = 0.3;
          cashWeight = 0.7;
        } else if (roundNumber <= 11) {  // Round 8-11
          scoringWeight = 0.5;
          cashWeight = 0.5;
        } else if (roundNumber <= 14) {  // Round 12-14
          scoringWeight = 0.7;
          cashWeight = 0.3;
        } else if (roundNumber <= 17) {  // Round 15-17
          scoringWeight = 0.6;
          cashWeight = 0.4;
        } else {  // Round 18+
          scoringWeight = 1.0;
          cashWeight = 0.0;
        }
        
        // 4. Adjust weights based on team value vs league average
        const teamValue = req.body.team_value || 15000000;
        const leagueAvgValue = req.body.league_avg_value || 15000000;
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
        
        const priceDiff = player_in.price - player_out.price;
        if (priceDiff > 0) {
          explanations.push(`This trade costs $${(priceDiff/1000).toFixed(1)}k immediately`);
        } else {
          explanations.push(`This trade frees up $${(-priceDiff/1000).toFixed(1)}k immediately`);
        }
        
        // Round-specific context
        if (roundNumber <= 7) {
          explanations.push(`Round ${roundNumber}: Cash gain is weighted more heavily than scoring`);
        } else if (roundNumber >= 18) {
          explanations.push(`Round ${roundNumber}: Only scoring matters at this stage of the season`);
        }
        
        if (valueRatio < 0.95) {
          explanations.push(`Your team value is below league average: Cash gain is prioritized`);
        } else if (valueRatio > 1.05) {
          explanations.push(`Your team value is above league average: Scoring is prioritized`);
        }
        
        // Recommendation
        let recommendation = "Neutral trade, consider other options";
        if (tradeScore >= 80) recommendation = "Highly recommend this trade";
        else if (tradeScore >= 60) recommendation = "Good trade opportunity";
        else if (tradeScore < 40) recommendation = "Not recommended, look for better trades";
        
        // Classify players by price
        const classifyPlayerByPrice = (price: number): string => {
          if (price < 450000) return "rookie";
          else if (price < 800000) return "midpricer";
          else if (price < 1000000) return "underpriced_premium";
          else return "premium";
        };
        
        // Check if players have peaked
        const isPlayerPeaked = (projScores: number[], breakeven: number): boolean => {
          return (projScores.reduce((a, b) => a + b, 0) / projScores.length) < breakeven;
        };
        
        // Classify both players
        const playerInClass = classifyPlayerByPrice(player_in.price);
        const playerOutClass = classifyPlayerByPrice(player_out.price);
        
        // Check if they've peaked
        const playerInPeaked = isPlayerPeaked(player_in.proj_scores, player_in.breakeven);
        const playerOutPeaked = isPlayerPeaked(player_out.proj_scores, player_out.breakeven);
        
        // Add flags
        const flags = {
          peaked_rookie: (playerInClass === "rookie" && playerInPeaked) || 
                        (playerOutClass === "rookie" && playerOutPeaked),
          trading_peaked_player: playerOutPeaked,
          getting_peaked_player: playerInPeaked,
          player_in_class: playerInClass,
          player_out_class: playerOutClass
        };
        
        // Add additional explanations based on flags
        if (flags.peaked_rookie) {
          if (playerInClass === "rookie" && playerInPeaked) {
            explanations.push("Warning: You are trading for a rookie who may have peaked in value");
          }
          if (playerOutClass === "rookie" && playerOutPeaked) {
            explanations.push("Good: You are trading away a rookie who may have peaked in value");
          }
        }
        
        if (flags.getting_peaked_player) {
          explanations.push(`Warning: ${playerInClass.charAt(0).toUpperCase() + playerInClass.slice(1)} player coming in may have peaked (avg proj < breakeven)`);
        }
        
        if (flags.trading_peaked_player) {
          explanations.push(`Good: ${playerOutClass.charAt(0).toUpperCase() + playerOutClass.slice(1)} player going out may have peaked (avg proj < breakeven)`);
        }
        
        // Determine verdict based on raw overall_score
        let verdict = "Poor Choice";
        if (overallScore > 15) {
          verdict = "Perfect Timing";
        } else if (overallScore > 5) {
          verdict = "Solid Structure Trade";
        } else if (overallScore > 0) {
          verdict = "Risky Move";
        }
        
        // Calculate projected prices for both players
        const projectedPricesIn: number[] = [];
        const projectedPricesOut: number[] = [];
        
        // Start with current prices
        let currentPriceIn = player_in.price;
        let currentPriceOut = player_out.price;
        
        // Calculate projected prices over 5 rounds
        for (let i = 0; i < 5; i++) {
          currentPriceIn += Math.round(priceChangesIn[i]);
          currentPriceOut += Math.round(priceChangesOut[i]);
          projectedPricesIn.push(Math.round(currentPriceIn));
          projectedPricesOut.push(Math.round(currentPriceOut));
        }
        
        // Determine upgrade path flag
        let upgradePath = "neutral";
        if (player_in.price > player_out.price && avgProjIn > avgProjOut) {
          upgradePath = "upgrade";
        } else if (player_in.price < player_out.price && avgProjIn < avgProjOut) {
          upgradePath = "downgrade";
        }
        
        // Determine if this is good timing based on the season
        const seasonMatch = (roundNumber <= 7 && cashScore > 0) || (roundNumber >= 18 && scoringScore > 0);
        
        // Return fallback result with detailed analysis
        res.json({
          status: "ok",
          trade_score: parseFloat(tradeScore.toFixed(1)),
          scoring_score: parseFloat(scoringScore.toFixed(1)),
          cash_score: Math.round(cashScore),
          overall_score: parseFloat(overallScore.toFixed(1)),
          score_breakdown: {
            projected_score: parseFloat((scoreDiff * 7.5).toFixed(1)), // Scale score diff to match Python API
            value: 15.0, // Default value factor
            breakeven: 10.0, // Default breakeven factor
            risk: player_out.is_red_dot && !player_in.is_red_dot ? 10.0 : 
                 player_in.is_red_dot && !player_out.is_red_dot ? 0.0 : 5.0,
            scoring_weight: parseFloat((scoringWeight * 100).toFixed(1)),
            cash_weight: parseFloat((cashWeight * 100).toFixed(1))
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
            player_in: player_in.proj_scores,
            player_out: player_out.proj_scores
          },
          flags: {
            ...flags,
            upgrade_path: upgradePath,
            season_match: seasonMatch
          },
          verdict,
          explanations,
          recommendation,
          _fallback: true
        });
      }
    } catch (error: any) {
      console.error("[express] Trade score API error:", error.message);
      res.status(500).json({ 
        status: "error", 
        message: `Failed to process trade score request: ${error.message}` 
      });
    }
  });
  // API endpoint to serve AFL Fantasy player data from scraped JSON
  app.get("/api/scraped-players", async (req, res) => {
    try {
      // Try to get the most complete player data from backup file first
      const backupPath = path.join(process.cwd(), 'player_data_backup_20250501_201717.json');
      const jsonPath = path.join(process.cwd(), 'player_data.json');
      
      let playerData: string;
      if (fs.existsSync(backupPath)) {
        // Use the backup file with all players
        playerData = fs.readFileSync(backupPath, 'utf8');
      } else if (fs.existsSync(jsonPath)) {
        // Fallback to regular player_data.json
        playerData = fs.readFileSync(jsonPath, 'utf8');
      } else {
        return res.status(404).json({ 
          message: "Player data file not found. Make sure the Python scraper has been run.",
          path: jsonPath
        });
      }
      
      const players = JSON.parse(playerData);
      
      // Apply filters if query parameters are present
      const query = req.query.q as string | undefined;
      const position = req.query.position as string | undefined;
      
      let filteredPlayers = players;
      
      if (query) {
        const queryLower = query.toLowerCase();
        filteredPlayers = players.filter((player: any) => 
          player.name?.toLowerCase().includes(queryLower) || 
          player.team?.toLowerCase().includes(queryLower)
        );
      }
      
      if (position) {
        filteredPlayers = filteredPlayers.filter((player: any) => 
          player.position?.toLowerCase() === position.toLowerCase()
        );
      }
      
      res.json(filteredPlayers);
    } catch (error) {
      console.error("Error reading player data:", error);
      res.status(500).json({ 
        message: "Failed to read player data from file",
        error: (error as Error).message 
      });
    }
  });
  
  // Original players route from database
  app.get("/api/players", async (req, res) => {
    // First try to get data from player_data.json if it exists
    try {
      const jsonPath = path.join(process.cwd(), 'player_data.json');
      
      if (fs.existsSync(jsonPath)) {
        const playerData = fs.readFileSync(jsonPath, 'utf8');
        const players = JSON.parse(playerData);
        
        // Apply filters if query parameters are present
        const query = req.query.q as string | undefined;
        const position = req.query.position as string | undefined;
        
        let filteredPlayers = players;
        
        if (query) {
          const queryLower = query.toLowerCase();
          filteredPlayers = players.filter((player: any) => 
            player.name?.toLowerCase().includes(queryLower) || 
            player.team?.toLowerCase().includes(queryLower)
          );
        }
        
        if (position) {
          filteredPlayers = filteredPlayers.filter((player: any) => 
            player.position?.toLowerCase() === position.toLowerCase()
          );
        }
        
        return res.json(filteredPlayers);
      }
    } catch (error) {
      console.error("Error reading player data from file, falling back to database:", error);
    }
    
    // If file doesn't exist or there's an error, fall back to database
    const query = req.query.q as string | undefined;
    const position = req.query.position as string | undefined;
    
    let players;
    if (query) {
      players = await storage.searchPlayers(query);
    } else if (position) {
      players = await storage.getPlayersByPosition(position);
    } else {
      players = await storage.getAllPlayers();
    }
    
    res.json(players);
  });

  app.get("/api/players/:id", async (req, res) => {
    const id = Number(req.params.id);
    if (isNaN(id)) {
      return res.status(400).json({ message: "Invalid player ID" });
    }
    
    const player = await storage.getPlayer(id);
    if (!player) {
      return res.status(404).json({ message: "Player not found" });
    }
    
    res.json(player);
  });

  // Team routes
  app.get("/api/teams/:id", async (req, res) => {
    const id = Number(req.params.id);
    if (isNaN(id)) {
      return res.status(400).json({ message: "Invalid team ID" });
    }
    
    const team = await storage.getTeam(id);
    if (!team) {
      return res.status(404).json({ message: "Team not found" });
    }
    
    res.json(team);
  });

  app.get("/api/teams/user/:userId", async (req, res) => {
    const userId = Number(req.params.userId);
    if (isNaN(userId)) {
      return res.status(400).json({ message: "Invalid user ID" });
    }
    
    const team = await storage.getTeamByUserId(userId);
    if (!team) {
      return res.status(404).json({ message: "Team not found for this user" });
    }
    
    res.json(team);
  });

  app.put("/api/teams/:id", async (req, res) => {
    const id = Number(req.params.id);
    if (isNaN(id)) {
      return res.status(400).json({ message: "Invalid team ID" });
    }

    const updatedTeam = await storage.updateTeam(id, req.body);
    if (!updatedTeam) {
      return res.status(404).json({ message: "Team not found" });
    }
    
    res.json(updatedTeam);
  });

  // Team Players routes
  app.get("/api/teams/:teamId/players", async (req, res) => {
    const teamId = Number(req.params.teamId);
    if (isNaN(teamId)) {
      return res.status(400).json({ message: "Invalid team ID" });
    }
    
    const players = await storage.getTeamPlayerDetails(teamId);
    res.json(players);
  });

  app.get("/api/teams/:teamId/players/:position", async (req, res) => {
    const teamId = Number(req.params.teamId);
    if (isNaN(teamId)) {
      return res.status(400).json({ message: "Invalid team ID" });
    }
    
    const position = req.params.position;
    if (!["MID", "FWD", "DEF", "RUCK"].includes(position)) {
      return res.status(400).json({ message: "Invalid position" });
    }
    
    const players = await storage.getTeamPlayersByPosition(teamId, position);
    res.json(players);
  });

  app.post("/api/teams/:teamId/players", async (req, res) => {
    const teamId = Number(req.params.teamId);
    if (isNaN(teamId)) {
      return res.status(400).json({ message: "Invalid team ID" });
    }
    
    const schema = z.object({
      playerId: z.number(),
      position: z.string(),
      isOnField: z.boolean().default(false)
    });
    
    const validationResult = schema.safeParse(req.body);
    if (!validationResult.success) {
      return res.status(400).json({ message: "Invalid request data", errors: validationResult.error.errors });
    }
    
    try {
      const teamPlayer = await storage.addPlayerToTeam({
        teamId,
        playerId: validationResult.data.playerId,
        position: validationResult.data.position,
        isOnField: validationResult.data.isOnField
      });
      
      res.status(201).json(teamPlayer);
    } catch (error) {
      res.status(500).json({ message: "Failed to add player to team" });
    }
  });

  app.delete("/api/teams/:teamId/players/:playerId", async (req, res) => {
    const teamId = Number(req.params.teamId);
    const playerId = Number(req.params.playerId);
    
    if (isNaN(teamId) || isNaN(playerId)) {
      return res.status(400).json({ message: "Invalid ID parameters" });
    }
    
    const success = await storage.removePlayerFromTeam(teamId, playerId);
    if (!success) {
      return res.status(404).json({ message: "Player not found in team" });
    }
    
    res.status(204).send();
  });

  // League routes
  app.get("/api/leagues/user/:userId", async (req, res) => {
    const userId = Number(req.params.userId);
    if (isNaN(userId)) {
      return res.status(400).json({ message: "Invalid user ID" });
    }
    
    const leagues = await storage.getLeaguesByUserId(userId);
    res.json(leagues);
  });

  app.get("/api/leagues/:leagueId/teams", async (req, res) => {
    const leagueId = Number(req.params.leagueId);
    if (isNaN(leagueId)) {
      return res.status(400).json({ message: "Invalid league ID" });
    }
    
    const teams = await storage.getLeagueTeamDetails(leagueId);
    res.json(teams);
  });

  app.get("/api/leagues/:leagueId/matchups/:round", async (req, res) => {
    const leagueId = Number(req.params.leagueId);
    const round = Number(req.params.round);
    
    if (isNaN(leagueId) || isNaN(round)) {
      return res.status(400).json({ message: "Invalid parameters" });
    }
    
    const matchups = await storage.getMatchupDetails(leagueId, round);
    res.json(matchups);
  });

  // Round Performance routes
  app.get("/api/teams/:teamId/performances", async (req, res) => {
    const teamId = Number(req.params.teamId);
    if (isNaN(teamId)) {
      return res.status(400).json({ message: "Invalid team ID" });
    }
    
    const performances = await storage.getRoundPerformances(teamId);
    res.json(performances);
  });

  // Get current user (for demo purposes, return user ID 1)
  app.get("/api/me", async (_req, res) => {
    const user = await storage.getUser(1);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Don't return password
    const { password, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  });

  // AFL Fantasy API integration routes
  app.get("/api/afl-fantasy/test", async (req, res) => {
    try {
      const isAuthenticated = await aflFantasyAPI.authenticate();
      if (isAuthenticated) {
        res.json({ 
          status: "success", 
          message: "Successfully connected to AFL Fantasy",
          authenticated: true 
        });
      } else {
        res.status(401).json({ 
          status: "error", 
          message: "Failed to authenticate with AFL Fantasy",
          authenticated: false 
        });
      }
    } catch (error) {
      res.status(500).json({ 
        status: "error", 
        message: "Error connecting to AFL Fantasy",
        authenticated: false 
      });
    }
  });

  app.get("/api/afl-fantasy/team", async (req, res) => {
    try {
      const teamData = await aflFantasyAPI.getTeamData();
      if (teamData) {
        res.json({ status: "success", data: teamData });
      } else {
        res.status(404).json({ status: "error", message: "Could not fetch team data" });
      }
    } catch (error) {
      res.status(500).json({ status: "error", message: "Error fetching team data" });
    }
  });

  app.get("/api/afl-fantasy/ranking", async (req, res) => {
    try {
      const ranking = await aflFantasyAPI.getUserRanking();
      if (ranking) {
        res.json({ status: "success", data: ranking });
      } else {
        res.status(404).json({ status: "error", message: "Could not fetch ranking data" });
      }
    } catch (error) {
      res.status(500).json({ status: "error", message: "Error fetching ranking data" });
    }
  });

  const httpServer = createServer(app);
  return httpServer;
}