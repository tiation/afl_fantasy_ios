/**
 * AFL Fantasy Tools Service
 * 
 * This service interfaces with the Python backend tools and provides
 * structured tool data for the frontend.
 */

import { exec } from 'child_process';
import { fantasyTools } from './types/fantasy-tools';
import util from 'util';

// Convert exec to use promises
const execPromise = util.promisify(exec);

/**
 * Run a Python tool and return the result as JSON
 * 
 * @param module Python module name
 * @param function_name Function to call within the module
 * @param params Optional parameters to pass to the function
 * @returns JSON result from the Python function
 */
async function runPythonTool(module: string, function_name: string, params?: any): Promise<any> {
  let paramString = '';
  
  if (params) {
    paramString = `, ${JSON.stringify(params)}`;
  }
  
  const cmd = `python3 -c "import sys; sys.path.append('backend/python/tools'); import ${module}; import json; print(json.dumps(${module}.${function_name}()${paramString}))"`;
  
  try {
    console.log(`Executing Python command: ${cmd}`);
    const { stdout } = await execPromise(cmd);
    return JSON.parse(stdout);
  } catch (error) {
    console.error(`Error running Python tool ${module}.${function_name}:`, error);
    
    // Return a structured error response
    return {
      status: "error",
      message: `Failed to execute ${module}.${function_name}`,
      error: error
    };
  }
}

/**
 * Run a Python API module and return the result as JSON
 * 
 * @param module Python module name in backend/python/api
 * @param function_name Function to call within the module
 * @param params Optional parameters to pass to the function
 * @returns JSON result from the Python function
 */
async function runPythonToolAPI(module: string, function_name: string, params?: any): Promise<any> {
  let paramString = '';
  
  if (params) {
    paramString = `, ${JSON.stringify(params)}`;
  }
  
  const cmd = `python3 -c "import sys; sys.path.append('backend/python/api'); import ${module}; import json; print(json.dumps(${module}.${function_name}()${paramString}))"`;
  
  try {
    console.log(`Executing Python API command: ${cmd}`);
    const { stdout } = await execPromise(cmd);
    return JSON.parse(stdout);
  } catch (error) {
    console.error(`Error running Python API ${module}.${function_name}:`, error);
    
    // Return a structured error response
    return {
      status: "error",
      message: `Failed to execute ${module}.${function_name}`,
      error: error
    };
  }
}

/**
 * AFL Fantasy Tools categories and tools
 */
const toolCategories = [
  {
    id: "trade",
    name: "Trade Analysis",
    description: "Tools for analyzing and optimizing trades",
    tools: [
      {
        id: "trade_score_calculator",
        name: "Trade Score Calculator",
        description: "Calculate a score for a potential trade based on multiple factors"
      },
      {
        id: "trade_optimizer",
        name: "Trade Optimizer",
        description: "Find optimal trade combinations to maximize team value and performance"
      },
      {
        id: "one_up_one_down_suggester",
        name: "One Up One Down Suggester",
        description: "Suggest upgrade/downgrade trade combinations that work within your budget"
      },
      {
        id: "price_difference_delta",
        name: "Price Difference Delta",
        description: "Analyze the price differential between players to find value in trades"
      },
      {
        id: "value_gain_tracker",
        name: "Value Gain Tracker",
        description: "Track the value gained or lost from trades over time"
      },
      {
        id: "trade_burn_risk_analyzer",
        name: "Trade Burn Risk Analyzer",
        description: "Assess the risk of using trades now versus saving them for later in the season"
      },
      {
        id: "trade_return_analyzer",
        name: "Trade Return Analyzer",
        description: "Calculate the potential return on investment for trades"
      }
    ]
  },
  {
    id: "cash",
    name: "Cash Generation",
    description: "Tools for maximizing cash generation and team value",
    tools: [
      {
        id: "cash_generation_tracker",
        name: "Cash Generation Tracker",
        description: "Track cash generation from rookies and value players"
      },
      {
        id: "rookie_price_curve_model",
        name: "Rookie Price Curve Model",
        description: "Model rookie price growth to identify optimal holding periods"
      },
      {
        id: "downgrade_target_finder",
        name: "Downgrade Target Finder",
        description: "Find optimal downgrade targets to generate cash"
      },
      {
        id: "cash_gen_ceiling_floor",
        name: "Cash Gen Ceiling/Floor",
        description: "Calculate best and worst-case price changes for cash cows"
      },
      {
        id: "price_predictor_calculator",
        name: "Price Predictor Calculator",
        description: "Predict future price changes based on projected scores"
      },
      {
        id: "price_ceiling_floor_estimator",
        name: "Price Ceiling/Floor Estimator",
        description: "Estimate ceiling and floor prices for players"
      }
    ]
  },
  {
    id: "captain",
    name: "Captain Tools",
    description: "Tools for captain selection optimization",
    tools: [
      {
        id: "captain_score_predictor",
        name: "Captain Score Predictor",
        description: "Predict captain-worthy performances for the upcoming round"
      },
      {
        id: "vice_captain_optimizer",
        name: "Vice-Captain Optimizer",
        description: "Optimize vice-captain selections for the loophole strategy"
      },
      {
        id: "loophole_detector",
        name: "Loophole Detector",
        description: "Identify vice-captain loophole opportunities based on player schedules"
      },
      {
        id: "form_based_captain_analyzer",
        name: "Form-Based Captain Analyzer",
        description: "Analyze player form over various timeframes to recommend captains"
      },
      {
        id: "matchup_based_captain_advisor",
        name: "Matchup-Based Captain Advisor",
        description: "Recommend captains based on favorable matchups against opponents"
      }
    ]
  },
  {
    id: "risk",
    name: "Risk Analysis",
    description: "Tools for analyzing player and team risks",
    tools: [
      {
        id: "tag_watch_monitor",
        name: "Tag Watch Monitor",
        description: "Monitor players likely to receive tags in upcoming games"
      },
      {
        id: "tag_history_impact_tracker",
        name: "Tag History Impact Tracker",
        description: "Track how tags have historically impacted player scores"
      },
      {
        id: "tag_target_priority_ranker",
        name: "Tag Target Priority Ranker",
        description: "Rank which players are most likely to be targeted with tags"
      },
      {
        id: "tag_breaker_score_estimator",
        name: "Tag Breaker Score Estimator",
        description: "Estimate scores for players who can break through tags"
      },
      {
        id: "injury_risk_model",
        name: "Injury Risk Model",
        description: "Model injury risk for players based on history and workload"
      },
      {
        id: "volatility_index_calculator",
        name: "Volatility Index Calculator",
        description: "Calculate scoring volatility to identify consistent vs. inconsistent players"
      },
      {
        id: "consistency_score_generator",
        name: "Consistency Score Generator",
        description: "Generate consistency scores for all players"
      },
      {
        id: "scoring_range_predictor",
        name: "Scoring Range Predictor",
        description: "Predict scoring ranges for players in upcoming rounds"
      },
      {
        id: "late_out_risk_estimator",
        name: "Late-Out Risk Estimator",
        description: "Estimate the risk of players being late outs"
      }
    ]
  },
  {
    id: "price",
    name: "Price Tools",
    description: "Tools for price analysis and prediction",
    tools: [
      {
        id: "breakeven_calculator",
        name: "Breakeven Calculator",
        description: "Calculate breakeven scores needed for price stability"
      },
      {
        id: "price_change_predictor",
        name: "Price Change Predictor",
        description: "Predict price changes based on projected scores"
      },
      {
        id: "price_peak_detector",
        name: "Price Peak Detector",
        description: "Detect when players are likely to peak in price"
      },
      {
        id: "price_trough_detector",
        name: "Price Trough Detector",
        description: "Detect when players are likely to bottom out in price"
      },
      {
        id: "value_per_point_analyzer",
        name: "Value Per Point Analyzer",
        description: "Analyze value per point to find efficient players"
      }
    ]
  },
  {
    id: "fixture",
    name: "Fixture Analysis",
    description: "Tools for analyzing player schedules and fixtures",
    tools: [
      {
        id: "fixture_difficulty_matrix",
        name: "Fixture Difficulty Matrix",
        description: "View fixture difficulty for all teams and positions"
      },
      {
        id: "run_home_analyzer",
        name: "Run Home Analyzer",
        description: "Analyze the difficulty of remaining fixtures for each team"
      },
      {
        id: "bye_planning_assistant",
        name: "Bye Planning Assistant",
        description: "Plan for bye rounds to minimize impact on your team"
      },
      {
        id: "favorable_fixture_finder",
        name: "Favorable Fixture Finder",
        description: "Find players with favorable upcoming fixtures"
      }
    ]
  },
  {
    id: "context",
    name: "Context Analysis",
    description: "Tools for understanding contextual factors in AFL Fantasy",
    tools: [
      {
        id: "bye_round_optimizer",
        name: "Bye Round Optimizer",
        description: "Optimize your team structure for the bye rounds"
      },
      {
        id: "late_season_taper_flagger",
        name: "Late Season Taper Flagger",
        description: "Identify players who typically taper off late in the season"
      },
      {
        id: "fast_start_profile_scanner",
        name: "Fast Start Profile Scanner",
        description: "Identify players who typically start seasons strongly"
      },
      {
        id: "venue_bias_detector",
        name: "Venue Bias Detector",
        description: "Detect players who perform significantly better or worse at certain venues"
      },
      {
        id: "contract_year_motivation_checker",
        name: "Contract Year Motivation Checker",
        description: "Identify players in contract years who may have extra motivation"
      }
    ]
  },
  {
    id: "ai",
    name: "AI Tools",
    description: "AI-powered tools for fantasy team optimization",
    tools: [
      {
        id: "ai_trade_suggester",
        name: "AI Trade Suggester",
        description: "AI-powered trade suggestions based on your team"
      },
      {
        id: "ai_captain_advisor",
        name: "AI Captain Advisor",
        description: "AI-powered captain recommendations"
      },
      {
        id: "team_structure_analyzer",
        name: "Team Structure Analyzer",
        description: "AI analysis of your team structure with recommendations"
      },
      {
        id: "ownership_risk_monitor",
        name: "Ownership Risk Monitor",
        description: "AI analysis of ownership risks and opportunities"
      },
      {
        id: "form_vs_price_scanner",
        name: "Form vs Price Scanner",
        description: "AI analysis of player form versus price to identify value"
      }
    ]
  }
];

//=================================================
// Trade Analysis Tool Methods
//=================================================

async function calculateTradeScore(params: fantasyTools.TradeScoreParams): Promise<any> {
  try {
    // Call the trade_api module to calculate trade score
    return await runPythonToolAPI('trade_api', 'trade_score_calculator', params);
  } catch (error) {
    console.error('Error calculating trade score:', error);
    return {
      status: "error",
      message: "Failed to calculate trade score",
      error: error
    };
  }
}

async function findOneUpOneDownCombinations(params: fantasyTools.OneUpOneDownParams): Promise<any> {
  try {
    // Call the trade_api module to find one up one down combinations
    return await runPythonToolAPI('trade_api', 'one_up_one_down_suggester', params);
  } catch (error) {
    console.error('Error finding one up one down combinations:', error);
    return {
      status: "error",
      message: "Failed to find one up one down combinations",
      error: error
    };
  }
}

async function calculatePriceDifferenceDelta(params: fantasyTools.PriceDeltaParams): Promise<any> {
  try {
    // Call the trade_api module to calculate price difference delta
    return await runPythonToolAPI('trade_api', 'price_difference_delta', params);
  } catch (error) {
    console.error('Error calculating price difference delta:', error);
    return {
      status: "error",
      message: "Failed to calculate price difference delta",
      error: error
    };
  }
}

//=================================================
// Cash Generation Tool Methods
//=================================================

async function getCashGenerationTrackerData(): Promise<any> {
  try {
    // Call the cash_tools module to get cash generation tracker data
    return await runPythonTool('cash_tools', 'cash_generation_tracker');
  } catch (error) {
    console.error('Error getting cash generation tracker data:', error);
    return {
      status: "error",
      message: "Failed to get cash generation tracker data",
      error: error
    };
  }
}

async function getRookiePriceCurveModel(): Promise<any> {
  try {
    // Call the cash_tools module to get rookie price curve model data
    return await runPythonTool('cash_tools', 'rookie_price_curve_model');
  } catch (error) {
    console.error('Error getting rookie price curve model data:', error);
    return {
      status: "error",
      message: "Failed to get rookie price curve model data",
      error: error
    };
  }
}

async function getDowngradeTargetFinder(): Promise<any> {
  try {
    // Call the cash_tools module to get downgrade target finder data
    return await runPythonTool('cash_tools', 'downgrade_target_finder');
  } catch (error) {
    console.error('Error getting downgrade target finder data:', error);
    return {
      status: "error",
      message: "Failed to get downgrade target finder data",
      error: error
    };
  }
}

async function getCashGenCeilingFloor(): Promise<any> {
  try {
    // Call the cash_tools module to get cash gen ceiling/floor data
    return await runPythonTool('cash_tools', 'cash_gen_ceiling_floor');
  } catch (error) {
    console.error('Error getting cash gen ceiling/floor data:', error);
    return {
      status: "error",
      message: "Failed to get cash gen ceiling/floor data",
      error: error
    };
  }
}

async function getPricePredictorCalculator(params?: any): Promise<any> {
  try {
    // Call the cash_tools module to get price predictor calculator data
    return await runPythonTool('cash_tools', 'price_predictor_calculator', params);
  } catch (error) {
    console.error('Error getting price predictor calculator data:', error);
    return {
      status: "error",
      message: "Failed to get price predictor calculator data",
      error: error
    };
  }
}

async function getPriceCeilingFloorEstimator(): Promise<any> {
  try {
    // Call the cash_tools module to get price ceiling/floor estimator data
    return await runPythonTool('cash_tools', 'price_ceiling_floor_estimator');
  } catch (error) {
    console.error('Error getting price ceiling/floor estimator data:', error);
    return {
      status: "error",
      message: "Failed to get price ceiling/floor estimator data",
      error: error
    };
  }
}

//=================================================
// Captain Tool Methods
//=================================================

async function getCaptainScorePredictor(): Promise<any> {
  try {
    // Call the captain_tools module to get captain score predictor data
    return await runPythonTool('captain_tools', 'captain_score_predictor');
  } catch (error) {
    console.error('Error getting captain score predictor data:', error);
    return {
      status: "error",
      message: "Failed to get captain score predictor data",
      error: error
    };
  }
}

async function getViceCaptainOptimizer(): Promise<any> {
  try {
    // Call the captain_tools module to get vice-captain optimizer data
    return await runPythonTool('captain_tools', 'vice_captain_optimizer');
  } catch (error) {
    console.error('Error getting vice-captain optimizer data:', error);
    return {
      status: "error",
      message: "Failed to get vice-captain optimizer data",
      error: error
    };
  }
}

async function getLoopholeDetector(): Promise<any> {
  try {
    // Call the captain_tools module to get loophole detector data
    return await runPythonTool('captain_tools', 'loophole_detector');
  } catch (error) {
    console.error('Error getting loophole detector data:', error);
    return {
      status: "error",
      message: "Failed to get loophole detector data",
      error: error
    };
  }
}

async function getFormBasedCaptainAnalyzer(): Promise<any> {
  try {
    // Call the captain_tools module to get form-based captain analyzer data
    return await runPythonTool('captain_tools', 'form_based_captain_analyzer');
  } catch (error) {
    console.error('Error getting form-based captain analyzer data:', error);
    return {
      status: "error",
      message: "Failed to get form-based captain analyzer data",
      error: error
    };
  }
}

async function getMatchupBasedCaptainAdvisor(): Promise<any> {
  try {
    // Call the captain_tools module to get matchup-based captain advisor data
    return await runPythonTool('captain_tools', 'matchup_based_captain_advisor');
  } catch (error) {
    console.error('Error getting matchup-based captain advisor data:', error);
    return {
      status: "error",
      message: "Failed to get matchup-based captain advisor data",
      error: error
    };
  }
}

//=================================================
// Risk Analysis Tool Methods
//=================================================

async function getTagWatchMonitorData(): Promise<any> {
  try {
    // Call the risk_tools module to get tag watch monitor data
    return await runPythonTool('risk_tools', 'tag_watch_monitor');
  } catch (error) {
    console.error('Error getting tag watch monitor data:', error);
    return {
      status: "error",
      message: "Failed to get tag watch monitor data",
      error: error
    };
  }
}

async function getTagHistoryImpactTrackerData(): Promise<any> {
  try {
    // Call the risk_tools module to get tag history impact tracker data
    return await runPythonTool('risk_tools', 'tag_history_impact_tracker');
  } catch (error) {
    console.error('Error getting tag history impact tracker data:', error);
    return {
      status: "error",
      message: "Failed to get tag history impact tracker data",
      error: error
    };
  }
}

async function getTagTargetPriorityRankerData(): Promise<any> {
  try {
    // Call the risk_tools module to get tag target priority ranker data
    return await runPythonTool('risk_tools', 'tag_target_priority_ranker');
  } catch (error) {
    console.error('Error getting tag target priority ranker data:', error);
    return {
      status: "error",
      message: "Failed to get tag target priority ranker data",
      error: error
    };
  }
}

async function getTagBreakerScoreEstimatorData(): Promise<any> {
  try {
    // Call the risk_tools module to get tag breaker score estimator data
    return await runPythonTool('risk_tools', 'tag_breaker_score_estimator');
  } catch (error) {
    console.error('Error getting tag breaker score estimator data:', error);
    return {
      status: "error",
      message: "Failed to get tag breaker score estimator data",
      error: error
    };
  }
}

async function getInjuryRiskModelData(): Promise<any> {
  try {
    // Call the risk_tools module to get injury risk model data
    return await runPythonTool('risk_tools', 'injury_risk_model');
  } catch (error) {
    console.error('Error getting injury risk model data:', error);
    return {
      status: "error",
      message: "Failed to get injury risk model data",
      error: error
    };
  }
}

async function getVolatilityIndexCalculatorData(): Promise<any> {
  try {
    // Call the risk_tools module to get volatility index calculator data
    return await runPythonTool('risk_tools', 'volatility_index_calculator');
  } catch (error) {
    console.error('Error getting volatility index calculator data:', error);
    return {
      status: "error",
      message: "Failed to get volatility index calculator data",
      error: error
    };
  }
}

async function getConsistencyScoreGeneratorData(): Promise<any> {
  try {
    // Call the risk_tools module to get consistency score generator data
    return await runPythonTool('risk_tools', 'consistency_score_generator');
  } catch (error) {
    console.error('Error getting consistency score generator data:', error);
    return {
      status: "error",
      message: "Failed to get consistency score generator data",
      error: error
    };
  }
}

async function getScoringRangePredictorData(): Promise<any> {
  try {
    // Call the risk_tools module to get scoring range predictor data
    return await runPythonTool('risk_tools', 'scoring_range_predictor');
  } catch (error) {
    console.error('Error getting scoring range predictor data:', error);
    return {
      status: "error",
      message: "Failed to get scoring range predictor data",
      error: error
    };
  }
}

async function getLateOutRiskEstimatorData(): Promise<any> {
  try {
    // Call the risk_tools module to get late-out risk estimator data
    return await runPythonTool('risk_tools', 'late_out_risk_estimator');
  } catch (error) {
    console.error('Error getting late-out risk estimator data:', error);
    return {
      status: "error",
      message: "Failed to get late-out risk estimator data",
      error: error
    };
  }
}

//=================================================
// Price Analysis Tool Methods
//=================================================

async function getBreakevenCalculator(params?: any): Promise<any> {
  try {
    // Call the price_tools module to get breakeven calculator data
    return await runPythonTool('price_tools', 'breakeven_calculator', params);
  } catch (error) {
    console.error('Error getting breakeven calculator data:', error);
    return {
      status: "error",
      message: "Failed to get breakeven calculator data",
      error: error
    };
  }
}

async function getPriceChangePredictor(params?: any): Promise<any> {
  try {
    // Call the price_tools module to get price change predictor data
    return await runPythonTool('price_tools', 'price_change_predictor', params);
  } catch (error) {
    console.error('Error getting price change predictor data:', error);
    return {
      status: "error",
      message: "Failed to get price change predictor data",
      error: error
    };
  }
}

async function getPricePeakDetector(): Promise<any> {
  try {
    // Call the price_tools module to get price peak detector data
    return await runPythonTool('price_tools', 'price_peak_detector');
  } catch (error) {
    console.error('Error getting price peak detector data:', error);
    return {
      status: "error",
      message: "Failed to get price peak detector data",
      error: error
    };
  }
}

async function getPriceTroughDetector(): Promise<any> {
  try {
    // Call the price_tools module to get price trough detector data
    return await runPythonTool('price_tools', 'price_trough_detector');
  } catch (error) {
    console.error('Error getting price trough detector data:', error);
    return {
      status: "error",
      message: "Failed to get price trough detector data",
      error: error
    };
  }
}

async function getValuePerPointAnalyzer(): Promise<any> {
  try {
    // Call the price_tools module to get value per point analyzer data
    return await runPythonTool('price_tools', 'value_per_point_analyzer');
  } catch (error) {
    console.error('Error getting value per point analyzer data:', error);
    return {
      status: "error",
      message: "Failed to get value per point analyzer data",
      error: error
    };
  }
}

//=================================================
// Fixture Analysis Tool Methods
//=================================================

async function getFixtureDifficultyMatrix(): Promise<any> {
  try {
    // Call the fixture_tools module to get fixture difficulty matrix data
    return await runPythonTool('fixture_tools', 'fixture_difficulty_matrix');
  } catch (error) {
    console.error('Error getting fixture difficulty matrix data:', error);
    return {
      status: "error",
      message: "Failed to get fixture difficulty matrix data",
      error: error
    };
  }
}

async function getRunHomeAnalyzer(): Promise<any> {
  try {
    // Call the fixture_tools module to get run home analyzer data
    return await runPythonTool('fixture_tools', 'run_home_analyzer');
  } catch (error) {
    console.error('Error getting run home analyzer data:', error);
    return {
      status: "error",
      message: "Failed to get run home analyzer data",
      error: error
    };
  }
}

async function getByePlanningAssistant(): Promise<any> {
  try {
    // Call the fixture_tools module to get bye planning assistant data
    return await runPythonTool('fixture_tools', 'bye_planning_assistant');
  } catch (error) {
    console.error('Error getting bye planning assistant data:', error);
    return {
      status: "error",
      message: "Failed to get bye planning assistant data",
      error: error
    };
  }
}

async function getFavorableFixtureFinder(): Promise<any> {
  try {
    // Call the fixture_tools module to get favorable fixture finder data
    return await runPythonTool('fixture_tools', 'favorable_fixture_finder');
  } catch (error) {
    console.error('Error getting favorable fixture finder data:', error);
    return {
      status: "error",
      message: "Failed to get favorable fixture finder data",
      error: error
    };
  }
}

//=================================================
// Context Analysis Tool Methods
//=================================================

async function getByeRoundOptimizer(): Promise<any> {
  try {
    // Call the context_tools module to get bye round optimizer data
    return await runPythonTool('context_tools', 'bye_round_optimizer');
  } catch (error) {
    console.error('Error getting bye round optimizer data:', error);
    return {
      status: "error",
      message: "Failed to get bye round optimizer data",
      error: error
    };
  }
}

async function getLateSeasonTaperFlagger(): Promise<any> {
  try {
    // Call the context_tools module to get late season taper flagger data
    return await runPythonTool('context_tools', 'late_season_taper_flagger');
  } catch (error) {
    console.error('Error getting late season taper flagger data:', error);
    return {
      status: "error",
      message: "Failed to get late season taper flagger data",
      error: error
    };
  }
}

async function getFastStartProfileScanner(): Promise<any> {
  try {
    // Call the context_tools module to get fast start profile scanner data
    return await runPythonTool('context_tools', 'fast_start_profile_scanner');
  } catch (error) {
    console.error('Error getting fast start profile scanner data:', error);
    return {
      status: "error",
      message: "Failed to get fast start profile scanner data",
      error: error
    };
  }
}

async function getVenueBiasDetector(): Promise<any> {
  try {
    // Call the context_tools module to get venue bias detector data
    return await runPythonTool('context_tools', 'venue_bias_detector');
  } catch (error) {
    console.error('Error getting venue bias detector data:', error);
    return {
      status: "error",
      message: "Failed to get venue bias detector data",
      error: error
    };
  }
}

async function getContractYearMotivationChecker(): Promise<any> {
  try {
    // Call the context_tools module to get contract year motivation checker data
    return await runPythonTool('context_tools', 'contract_year_motivation_checker');
  } catch (error) {
    console.error('Error getting contract year motivation checker data:', error);
    return {
      status: "error",
      message: "Failed to get contract year motivation checker data",
      error: error
    };
  }
}

//=================================================
// AI Tools Methods
//=================================================

async function getAiTradeSuggester(params?: any): Promise<any> {
  try {
    // Call the ai_tools module to get AI trade suggester data
    return await runPythonTool('ai_tools', 'ai_trade_suggester', params);
  } catch (error) {
    console.error('Error getting AI trade suggester data:', error);
    return {
      status: "error",
      message: "Failed to get AI trade suggester data",
      error: error
    };
  }
}

async function getAiCaptainAdvisor(params?: any): Promise<any> {
  try {
    // Call the ai_tools module to get AI captain advisor data
    return await runPythonTool('ai_tools', 'ai_captain_advisor', params);
  } catch (error) {
    console.error('Error getting AI captain advisor data:', error);
    return {
      status: "error",
      message: "Failed to get AI captain advisor data",
      error: error
    };
  }
}

async function getTeamStructureAnalyzer(params?: any): Promise<any> {
  try {
    // Call the ai_tools module to get team structure analyzer data
    return await runPythonTool('ai_tools', 'team_structure_analyzer', params);
  } catch (error) {
    console.error('Error getting team structure analyzer data:', error);
    return {
      status: "error",
      message: "Failed to get team structure analyzer data",
      error: error
    };
  }
}

async function getOwnershipRiskMonitor(): Promise<any> {
  try {
    // Call the ai_tools module to get ownership risk monitor data
    return await runPythonTool('ai_tools', 'ownership_risk_monitor');
  } catch (error) {
    console.error('Error getting ownership risk monitor data:', error);
    return {
      status: "error",
      message: "Failed to get ownership risk monitor data",
      error: error
    };
  }
}

async function getFormVsPriceScanner(): Promise<any> {
  try {
    // Call the ai_tools module to get form vs price scanner data
    return await runPythonTool('ai_tools', 'form_vs_price_scanner');
  } catch (error) {
    console.error('Error getting form vs price scanner data:', error);
    return {
      status: "error",
      message: "Failed to get form vs price scanner data",
      error: error
    };
  }
}

// Export the fantasy tools service
export const fantasyToolsService = {
  toolCategories,
  
  // Trade Analysis Tools
  calculateTradeScore,
  findOneUpOneDownCombinations,
  calculatePriceDifferenceDelta,
  
  // Cash Generation Tools
  getCashGenerationTrackerData,
  getRookiePriceCurveModel,
  getDowngradeTargetFinder,
  getCashGenCeilingFloor,
  getPricePredictorCalculator,
  getPriceCeilingFloorEstimator,
  
  // Captain Tools
  getCaptainScorePredictor,
  getViceCaptainOptimizer,
  getLoopholeDetector,
  getFormBasedCaptainAnalyzer,
  getMatchupBasedCaptainAdvisor,
  
  // Risk Analysis Tools
  getTagWatchMonitorData,
  getTagHistoryImpactTrackerData,
  getTagTargetPriorityRankerData,
  getTagBreakerScoreEstimatorData,
  getInjuryRiskModelData,
  getVolatilityIndexCalculatorData,
  getConsistencyScoreGeneratorData,
  getScoringRangePredictorData,
  getLateOutRiskEstimatorData,
  
  // Price Analysis Tools
  getBreakevenCalculator,
  getPriceChangePredictor,
  getPricePeakDetector,
  getPriceTroughDetector,
  getValuePerPointAnalyzer,
  
  // Fixture Analysis Tools
  getFixtureDifficultyMatrix,
  getRunHomeAnalyzer,
  getByePlanningAssistant,
  getFavorableFixtureFinder,
  
  // Context Analysis Tools
  getByeRoundOptimizer,
  getLateSeasonTaperFlagger,
  getFastStartProfileScanner,
  getVenueBiasDetector,
  getContractYearMotivationChecker,
  
  // AI Tools
  getAiTradeSuggester,
  getAiCaptainAdvisor,
  getTeamStructureAnalyzer,
  getOwnershipRiskMonitor,
  getFormVsPriceScanner
};