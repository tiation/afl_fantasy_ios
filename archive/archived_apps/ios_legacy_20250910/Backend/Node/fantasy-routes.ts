/**
 * AFL Fantasy Tools API Routes
 */

import { Express, Request, Response } from "express";
import { fantasyToolsService } from './fantasy-tools';
import path from 'path';
import fs from 'fs';

// Import type for FantasyPlayer - fixed import to use non-type import for runtime use
import { fantasyTools } from './types/fantasy-tools';

// Helper function to read player data from JSON file
function getPlayerData() {
  try {
    const jsonPath = path.join(process.cwd(), 'player_data.json');
    
    if (fs.existsSync(jsonPath)) {
      const playerData = fs.readFileSync(jsonPath, 'utf8');
      return JSON.parse(playerData);
    }
    
    return [];
  } catch (error) {
    console.error("Error reading player data:", error);
    return [];
  }
}

// Helper to validate scores array
function validateScores(scores: any): number[] {
  if (!scores) return [];
  
  if (Array.isArray(scores)) {
    return scores.map(score => typeof score === 'number' ? score : parseFloat(score) || 0);
  }
  
  return [];
}

// Helper to validate team data
function validateTeamPlayers(players: any[]): fantasyTools.FantasyPlayer[] {
  if (!players || !Array.isArray(players)) return [];
  
  return players.map(player => ({
    id: player.id || 0,
    name: player.name || 'Unknown',
    position: player.position || 'NA',
    team: player.team || 'NA',
    price: player.price || 0,
    breakeven: player.breakeven || player.breakEven || 0,
    average: player.average || player.averagePoints || 0,
    projectedScore: player.projectedScore || player.projected_score || player.average || 0,
    lastScore: player.lastScore || player.last1 || 0,
    l3Average: player.l3Average || null,
    l5Average: player.l5Average || null,
    selectedBy: player.selectionPercentage || player.selectedBy || 0,
    ceiling: player.ceiling || null,
    floor: player.floor || null,
    isInjured: player.isInjured || false,
    isSuspended: player.isSuspended || false,
    consistency: player.consistency || null,
    scores: validateScores(player.scores),
    bye: player.bye || 0,
    nextFixtures: player.nextFixtures || [],
    nextFixtureDifficulty: player.nextFixtureDifficulty || [],
    redDotFlag: player.redDotFlag || player.isInjured || player.isSuspended || false
  }));
}

// Register all fantasy tool routes
export function registerFantasyRoutes(app: Express): void {
  
  // Get player data for use in frontend
  app.get("/api/fantasy/player_data", (req: Request, res: Response) => {
    try {
      const players = getPlayerData();
      res.json({ players });
    } catch (error) {
      console.error("Error fetching player data:", error);
      res.status(500).json({ error: "Failed to fetch player data" });
    }
  });
  
  // Get all tool categories and descriptions
  app.get("/api/fantasy/tools", (req: Request, res: Response) => {
    res.json(fantasyToolsService.toolCategories);
  });
  
  // Get tools for a specific category
  app.get("/api/fantasy/tools/:category", (req: Request, res: Response) => {
    const category = req.params.category;
    const categoryInfo = fantasyToolsService.toolCategories.find((c: any) => c.id === category);
    
    if (!categoryInfo) {
      return res.status(404).json({ error: "Category not found" });
    }
    
    res.json(categoryInfo);
  });
  
  //=================================================
  // Trade Tools API Endpoints
  //=================================================
  
  // Trade Calculator
  // Replaces/extends the existing trade_score endpoint
  app.post("/api/fantasy/tools/trade_score_calculator", async (req: Request, res: Response) => {
    try {
      const { player_in, player_out, round_number, team_value, league_avg_value } = req.body;
      
      if (!player_in || !player_out) {
        return res.status(400).json({ 
          error: "Missing required fields: player_in and player_out are required" 
        });
      }
      
      // Format parameters for our API
      const params: fantasyTools.TradeScoreParams = {
        player_in: {
          price: player_in.price,
          breakeven: player_in.breakeven || player_in.breakEven || 0,
          proj_scores: Array.isArray(player_in.projectedScores) 
            ? player_in.projectedScores 
            : [player_in.projectedScore || player_in.average || 0],
          is_red_dot: player_in.isInjured || player_in.isSuspended || false
        },
        player_out: {
          price: player_out.price,
          breakeven: player_out.breakeven || player_out.breakEven || 0,
          proj_scores: Array.isArray(player_out.projectedScores) 
            ? player_out.projectedScores 
            : [player_out.projectedScore || player_out.average || 0],
          is_red_dot: player_out.isInjured || player_out.isSuspended || false
        },
        round_number: round_number || 8,
        team_value: team_value || 15000000,
        league_avg_value: league_avg_value || 14500000
      };
      
      const tradeScore = await fantasyToolsService.calculateTradeScore(params);
      
      res.json(tradeScore);
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error calculating trade score",
        message: error.message 
      });
    }
  });
  
  // Trade Optimizer
  app.post("/api/fantasy/tools/trade_optimizer", async (req: Request, res: Response) => {
    try {
      const { position, availableCash, currentTeam, minScore } = req.body;
      
      if (!position || availableCash === undefined || !currentTeam) {
        return res.status(400).json({ 
          error: "Missing required fields: position, availableCash, and currentTeam are required" 
        });
      }
      
      // Get all player data
      const allPlayers = getPlayerData();
      
      // Validate and format team players
      const formattedTeam = validateTeamPlayers(currentTeam);
      
      // Find trade options
      const tradeOptions = fantasyTools.findTradeOptions(
        position,
        availableCash,
        allPlayers,
        formattedTeam,
        minScore || 60
      );
      
      res.json({
        status: "ok",
        position,
        availableCash,
        tradeOptions: tradeOptions.slice(0, 10) // Return top 10 options
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error finding trade options",
        message: error.message 
      });
    }
  });
  
  // One Up One Down Suggester
  app.post("/api/fantasy/tools/one_up_one_down_suggester", async (req: Request, res: Response) => {
    try {
      const { currentTeam, maxRookiePrice } = req.body;
      
      if (!currentTeam) {
        return res.status(400).json({ 
          error: "Missing required field: currentTeam is required" 
        });
      }
      
      // Validate and format team players
      const formattedTeam = validateTeamPlayers(currentTeam);
      
      // Format params for our API
      const params: fantasyTools.OneUpOneDownParams = {
        currentTeam: formattedTeam,
        maxRookiePrice: maxRookiePrice || 300000
      };
      
      // Find one up one down combinations
      const response = await fantasyToolsService.findOneUpOneDownCombinations(params);
      
      res.json(response);
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error finding one up one down combinations",
        message: error.message 
      });
    }
  });
  
  // Price Difference Delta
  app.post("/api/fantasy/tools/price_difference_delta", async (req: Request, res: Response) => {
    try {
      const { players } = req.body;
      
      if (!players || !Array.isArray(players) || players.length === 0) {
        return res.status(400).json({ 
          error: "Missing required field: players array is required" 
        });
      }
      
      // Format parameters for our API
      const params: fantasyTools.PriceDeltaParams = {
        players: validateTeamPlayers(players)
      };
      
      // Calculate price difference delta
      const response = await fantasyToolsService.calculatePriceDifferenceDelta(params);
      
      res.json(response);
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error calculating price difference delta",
        message: error.message 
      });
    }
  });
  
  // Value Gain Tracker
  app.post("/api/fantasy/tools/value_gain_tracker", async (req: Request, res: Response) => {
    try {
      const { initialTeam, currentTeam } = req.body;
      
      if (!initialTeam || !currentTeam) {
        return res.status(400).json({ 
          error: "Missing required fields: initialTeam and currentTeam are required" 
        });
      }
      
      // Validate and format team players
      const formattedInitialTeam = validateTeamPlayers(initialTeam);
      const formattedCurrentTeam = validateTeamPlayers(currentTeam);
      
      // Track value gain
      const valueGain = fantasyTools.trackValueGain(
        formattedInitialTeam,
        formattedCurrentTeam
      );
      
      res.json({
        status: "ok",
        ...valueGain
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error tracking value gain",
        message: error.message 
      });
    }
  });
  
  // Trade Burn Risk Analyzer
  app.post("/api/fantasy/tools/trade_burn_risk_analyzer", async (req: Request, res: Response) => {
    try {
      const { players, tradesLeft } = req.body;
      
      if (!players || tradesLeft === undefined) {
        return res.status(400).json({ 
          error: "Missing required fields: players and tradesLeft are required" 
        });
      }
      
      // Validate and format players
      const formattedPlayers = validateTeamPlayers(players);
      
      // Calculate trade burn risk
      const riskAnalysis = fantasyTools.calculateTradeBurnRisk(
        formattedPlayers,
        tradesLeft
      );
      
      res.json({
        status: "ok",
        ...riskAnalysis
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error calculating trade burn risk",
        message: error.message 
      });
    }
  });
  
  // Trade Return Analyzer
  app.post("/api/fantasy/tools/trade_return_analyzer", async (req: Request, res: Response) => {
    try {
      const { player_in, player_out, weeks_to_evaluate } = req.body;
      
      if (!player_in || !player_out) {
        return res.status(400).json({ 
          error: "Missing required fields: player_in and player_out are required" 
        });
      }
      
      // Validate and format players
      const playerIn = validateTeamPlayers([player_in])[0];
      const playerOut = validateTeamPlayers([player_out])[0];
      
      // Calculate trade return
      const tradeReturn = fantasyTools.calculateTradeReturn(
        playerIn,
        playerOut,
        weeks_to_evaluate || 5
      );
      
      res.json({
        status: "ok",
        ...tradeReturn
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error calculating trade return",
        message: error.message 
      });
    }
  });
  
  //=================================================
  // Risk Analysis Tools API Endpoints
  //=================================================

  // Risk Tool Group route
  app.get("/api/fantasy/tools/risk/:tool", async (req: Request, res: Response) => {
    try {
      const toolId = req.params.tool;
      
      switch (toolId) {
        case "tag_watch_monitor":
          const tagWatchData = await fantasyToolsService.getTagWatchMonitorData();
          res.json({
            status: "ok",
            players: tagWatchData.data
          });
          break;
          
        case "tag_history_impact_tracker":
          const tagHistoryData = await fantasyToolsService.getTagHistoryImpactTrackerData();
          res.json({
            status: "ok",
            players: tagHistoryData.data
          });
          break;
          
        case "tag_target_priority_ranker":
          const tagTargetData = await fantasyToolsService.getTagTargetPriorityRankerData();
          res.json({
            status: "ok",
            players: tagTargetData.data
          });
          break;
          
        case "tag_breaker_score_estimator":
          const tagBreakerData = await fantasyToolsService.getTagBreakerScoreEstimatorData();
          res.json({
            status: "ok",
            players: tagBreakerData.data
          });
          break;
          
        case "injury_risk_model":
          const injuryRiskData = await fantasyToolsService.getInjuryRiskModelData();
          res.json({
            status: "ok",
            players: injuryRiskData.data
          });
          break;
          
        case "volatility_index_calculator":
          const volatilityData = await fantasyToolsService.getVolatilityIndexCalculatorData();
          res.json({
            status: "ok",
            players: volatilityData.data
          });
          break;
          
        case "consistency_score_generator":
          const consistencyData = await fantasyToolsService.getConsistencyScoreGeneratorData();
          res.json({
            status: "ok",
            players: consistencyData.data
          });
          break;
          
        case "scoring_range_predictor":
          const scoringRangeData = await fantasyToolsService.getScoringRangePredictorData();
          res.json({
            status: "ok",
            players: scoringRangeData.data
          });
          break;
          
        case "late_out_risk_estimator":
          const lateOutRiskData = await fantasyToolsService.getLateOutRiskEstimatorData();
          res.json({
            status: "ok",
            players: lateOutRiskData.data
          });
          break;
          
        default:
          res.status(404).json({ error: "Tool not found" });
      }
    } catch (error: any) {
      res.status(500).json({ 
        error: `Error executing risk tool: ${req.params.tool}`,
        message: error.message 
      });
    }
  });

  // Individual Risk Tools endpoints
  
  // Tag Watch Monitor
  app.get("/api/fantasy/tools/tag_watch_monitor", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getTagWatchMonitorData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching tag watch monitor data",
        message: error.message 
      });
    }
  });
  
  // Tag History Impact Tracker
  app.get("/api/fantasy/tools/tag_history_impact_tracker", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getTagHistoryImpactTrackerData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching tag history impact data",
        message: error.message 
      });
    }
  });
  
  // Tag Target Priority Ranker
  app.get("/api/fantasy/tools/tag_target_priority_ranker", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getTagTargetPriorityRankerData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching tag target priority data",
        message: error.message 
      });
    }
  });
  
  // Tag Breaker Score Estimator
  app.get("/api/fantasy/tools/tag_breaker_score_estimator", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getTagBreakerScoreEstimatorData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching tag breaker score data",
        message: error.message 
      });
    }
  });
  
  // Injury Risk Model
  app.get("/api/fantasy/tools/injury_risk_model", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getInjuryRiskModelData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching injury risk model data",
        message: error.message 
      });
    }
  });
  
  // Volatility Index Calculator
  app.get("/api/fantasy/tools/volatility_index_calculator", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getVolatilityIndexCalculatorData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching volatility index data",
        message: error.message 
      });
    }
  });
  
  // Consistency Score Generator
  app.get("/api/fantasy/tools/consistency_score_generator", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getConsistencyScoreGeneratorData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching consistency score data",
        message: error.message 
      });
    }
  });
  
  // Scoring Range Predictor
  app.get("/api/fantasy/tools/scoring_range_predictor", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getScoringRangePredictorData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching scoring range predictor data",
        message: error.message 
      });
    }
  });
  
  // Late Out Risk Estimator
  app.get("/api/fantasy/tools/late_out_risk_estimator", async (req: Request, res: Response) => {
    try {
      const data = await fantasyToolsService.getLateOutRiskEstimatorData();
      res.json({
        status: "ok",
        players: data.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error fetching late out risk data",
        message: error.message 
      });
    }
  });
  
  //=================================================
  // AI Tools API Endpoints
  //=================================================
  
  // AI Tool Group route
  app.get("/api/fantasy/tools/ai/:tool", async (req: Request, res: Response) => {
    try {
      const toolId = req.params.tool;
      
      switch (toolId) {
        case "ai_trade_suggester":
          const tradeSuggesterData = await fantasyToolsService.getAITradeSuggesterData();
          res.json({
            status: "ok",
            ...tradeSuggesterData.data
          });
          break;
          
        case "ai_captain_advisor":
          const captainAdvisorData = await fantasyToolsService.getAICaptainAdvisorData();
          res.json({
            status: "ok",
            players: captainAdvisorData.data
          });
          break;
          
        case "team_structure_analyzer":
          const teamStructureData = await fantasyToolsService.getTeamStructureAnalyzerData();
          res.json({
            status: "ok",
            tiers: teamStructureData.data
          });
          break;
          
        case "ownership_risk_monitor":
          const ownershipRiskData = await fantasyToolsService.getOwnershipRiskMonitorData();
          res.json({
            status: "ok",
            players: ownershipRiskData.data
          });
          break;
          
        case "form_vs_price_scanner":
          const formVsPriceData = await fantasyToolsService.getFormVsPriceScannerData();
          res.json({
            status: "ok",
            players: formVsPriceData.data
          });
          break;
          
        default:
          res.status(404).json({ error: "AI Tool not found" });
      }
    } catch (error: any) {
      res.status(500).json({ 
        error: `Error executing AI tool: ${req.params.tool}`,
        message: error.message 
      });
    }
  });
  
  // Note: Individual AI Tool endpoints have been removed.
  // All AI tools are now served through the group route above at:
  // app.get("/api/fantasy/tools/ai/:tool", ...)
  
  //=================================================
  // Cash Generation Tools API Endpoints
  //=================================================
  
  // Cash Tool Group route
  app.get("/api/fantasy/tools/cash/:tool", async (req: Request, res: Response) => {
    try {
      const toolId = req.params.tool;
      
      switch (toolId) {
        case "cash_generation_tracker":
          // Use our Python API implementation
          const cashGenerationData = await fantasyToolsService.getCashGenerationTrackerData();
          
          // Return the results
          res.json({
            status: "ok",
            players: cashGenerationData.data
          });
          break;
          
        case "rookie_price_curve_model":
          // Use our Python API implementation
          const rookiePriceCurveData = await fantasyToolsService.getRookiePriceCurveData();
          
          // Return the results
          res.json({
            status: "ok",
            rookies: rookiePriceCurveData.data
          });
          break;
          
        case "downgrade_target_finder":
          // Use our Python API implementation
          const downgradeTargetsData = await fantasyToolsService.getDowngradeTargets();
          
          // Return the results
          res.json({
            status: "ok",
            targets: downgradeTargetsData.data
          });
          break;
          
        case "cash_gen_ceiling_floor":
          // Use our Python API implementation
          const ceilingFloorData = await fantasyToolsService.getCashGenCeilingFloor();
          
          // Return the results
          res.json({
            status: "ok",
            players: ceilingFloorData.data
          });
          break;
          
        default:
          res.status(404).json({ error: "Tool not found" });
      }
    } catch (error: any) {
      res.status(500).json({ 
        error: `Error executing cash tool: ${req.params.tool}`,
        message: error.message 
      });
    }
  });
  
  // Individual Cash Tools
  
  // Cash Generation Tracker
  app.get("/api/fantasy/tools/cash_generation_tracker", async (req: Request, res: Response) => {
    try {
      // Use our Python API implementation
      const cashGenerationData = await fantasyToolsService.getCashGenerationTrackerData();
      
      // Return the results
      res.json({
        status: "ok",
        players: cashGenerationData.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error tracking cash generation",
        message: error.message 
      });
    }
  });
  
  // Rookie Price Curve Model
  app.get("/api/fantasy/tools/rookie_price_curve_model", async (req: Request, res: Response) => {
    try {
      // Use our Python API implementation
      const rookiePriceCurveData = await fantasyToolsService.getRookiePriceCurveData();
      
      // Return the results
      res.json({
        status: "ok",
        rookies: rookiePriceCurveData.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error modeling rookie price curve",
        message: error.message 
      });
    }
  });
  
  // Downgrade Target Finder
  app.get("/api/fantasy/tools/downgrade_target_finder", async (req: Request, res: Response) => {
    try {
      // Use our Python API implementation
      const downgradeTargetsData = await fantasyToolsService.getDowngradeTargets();
      
      // Return the results
      res.json({
        status: "ok",
        targets: downgradeTargetsData.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error finding downgrade targets",
        message: error.message 
      });
    }
  });
  
  // Cash Gen Ceiling/Floor
  app.get("/api/fantasy/tools/cash_gen_ceiling_floor", async (req: Request, res: Response) => {
    try {
      // Use our Python API implementation
      const cashGenCeilingFloorData = await fantasyToolsService.getCashGenCeilingFloor();
      
      // Return the results
      res.json({
        status: "ok",
        players: cashGenCeilingFloorData.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error calculating cash gen ceiling/floor",
        message: error.message 
      });
    }
  });
  
  //=================================================
  // Price Predictor Tools API Endpoints
  //=================================================
  
  // Price Predictor Calculator
  app.post("/api/fantasy/tools/price_predictor_calculator", async (req: Request, res: Response) => {
    try {
      const { player_name, scores } = req.body;
      
      if (!player_name || !scores) {
        return res.status(400).json({ 
          error: "Missing required fields: player_name and scores are required" 
        });
      }
      
      // Use our Python API implementation
      const pricePredictorData = await fantasyToolsService.calculatePricePredictions(
        player_name,
        scores
      );
      
      // Return the results
      res.json({
        status: "ok",
        data: pricePredictorData.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error predicting player price",
        message: error.message 
      });
    }
  });
  
  // Price Ceiling/Floor Estimator
  app.get("/api/fantasy/tools/price_ceiling_floor_estimator", async (req: Request, res: Response) => {
    try {
      // Use our Python API implementation
      const priceCeilingFloorData = await fantasyToolsService.getPriceCeilingFloor();
      
      // Return the results
      res.json({
        status: "ok",
        players: priceCeilingFloorData.data
      });
    } catch (error: any) {
      res.status(500).json({ 
        error: "Error estimating price ceiling/floor",
        message: error.message 
      });
    }
  });
  
  // For any other tool categories, placeholder responses for now
  app.post("/api/fantasy/tools/:tool_id", async (req: Request, res: Response) => {
    const toolId = req.params.tool_id;
    // Find the tool in categories
    let toolFound = false;
    let toolCategory = "";
    
    for (const category of fantasyTools.toolCategories) {
      const tool = category.tools.find(t => t.id === toolId);
      if (tool) {
        toolFound = true;
        toolCategory = category.id;
        break;
      }
    }
    
    if (!toolFound) {
      return res.status(404).json({ error: "Tool not found" });
    }
    
    // Return a placeholder response for unimplemented tools
    res.json({
      status: "ok",
      tool_id: toolId,
      category: toolCategory,
      message: "This tool is not fully implemented yet. Please check back later.",
      example_data: {
        player: req.body.player,
        calculation: "Sample calculation",
        recommendation: "Sample recommendation"
      }
    });
  });
}