import { exec } from 'child_process';
import { promisify } from 'util';

const execPromise = promisify(exec);

/**
 * Execute a Python risk tool function directly using child_process
 * @param tool The risk tool function to execute
 * @returns The JSON result from the Python function
 */
async function executeRiskTool(tool: string): Promise<any> {
  try {
    // Run the Python script with the specified tool
    const command = `python3 -c "import sys; sys.path.append('backend/python/tools'); import risk_tools; import json; result = risk_tools.${tool}(); print(json.dumps(result))"`;
    const { stdout, stderr } = await execPromise(command);
    
    if (stderr) {
      console.error(`Error executing risk tool ${tool}:`, stderr);
      return { status: 'error', message: 'Error executing risk tool' };
    }
    
    // Parse the JSON output
    const result = JSON.parse(stdout.trim());
    return { status: 'ok', ...result };
  } catch (error) {
    console.error(`Exception executing risk tool ${tool}:`, error);
    return { status: 'error', message: 'Failed to execute risk tool', error: String(error) };
  }
}

/**
 * Tag Watch Monitor
 * Monitors players at risk of being tagged by opponents
 */
export async function tag_watch_monitor() {
  return executeRiskTool('tag_watch_monitor');
}

/**
 * Tag History Impact Tracker
 * Tracks the historical impact of tagging on player performance
 */
export async function tag_history_impact_tracker() {
  return executeRiskTool('tag_history_impact_tracker');
}

/**
 * Tag Target Priority Ranker
 * Ranks players based on their likelihood of being targeted for tags
 */
export async function tag_target_priority_ranker() {
  return executeRiskTool('tag_target_priority_ranker');
}

/**
 * Tag Breaker Score Estimator
 * Estimates a player's ability to overcome or break tags
 */
export async function tag_breaker_score_estimator() {
  return executeRiskTool('tag_breaker_score_estimator');
}

/**
 * Injury Risk Model
 * Evaluates the injury risk of players based on history and current status
 */
export async function injury_risk_model() {
  return executeRiskTool('injury_risk_model');
}

/**
 * Volatility Index Calculator
 * Calculates a player's score volatility to identify consistent performers
 */
export async function volatility_index_calculator() {
  return executeRiskTool('volatility_index_calculator');
}

/**
 * Consistency Score Generator
 * Generates consistency scores to identify reliable performers
 */
export async function consistency_score_generator() {
  return executeRiskTool('consistency_score_generator');
}

/**
 * Scoring Range Predictor
 * Predicts the likely scoring range for players in upcoming matches
 */
export async function scoring_range_predictor() {
  return executeRiskTool('scoring_range_predictor');
}

/**
 * Late Out Risk Estimator
 * Estimates the risk of players being late withdrawals
 */
export async function late_out_risk_estimator() {
  return executeRiskTool('late_out_risk_estimator');
}