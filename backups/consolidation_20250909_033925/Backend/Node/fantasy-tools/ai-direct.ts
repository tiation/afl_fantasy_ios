/**
 * AFL Fantasy AI Direct Tools with Gemini Integration
 * 
 * This module provides AI-powered analysis tools for AFL Fantasy with intelligent
 * fallback between Google Gemini and OpenAI/Python implementations.
 * 
 * INTEGRATION FEATURES:
 * - Automatic fallback: Tries Gemini first, falls back to OpenAI if unavailable
 * - Environment-based configuration: Uses GEMINI_API_KEY environment variable
 * - Graceful error handling: Continues to work even if Gemini is not configured
 * - Existing API compatibility: Maintains backward compatibility with existing endpoints
 * 
 * FUNCTIONS WITH GEMINI INTEGRATION:
 * - ai_trade_suggester: Trade analysis with intelligent suggestions
 * - ai_captain_advisor: Captain selection with matchup analysis
 * - team_structure_analyzer: Team balance and optimization advice
 * 
 * NEW GEMINI-ONLY FUNCTIONS:
 * - gemini_breakout_predictions: Advanced breakout player predictions
 * - gemini_injury_analysis: Injury impact assessment
 * - test_gemini_connection: API connectivity testing
 * 
 * FALLBACK BEHAVIOR:
 * 1. Check if GEMINI_API_KEY is configured
 * 2. Check if gemini_tools.py exists
 * 3. Attempt Gemini API call
 * 4. On failure/throttling, fallback to OpenAI/Python implementation
 * 5. Log appropriate messages for debugging
 */

import { exec } from 'child_process';
import { promisify } from 'util';
import * as fs from 'fs';

const execPromise = promisify(exec);

/**
 * Check if Gemini API is available and configured
 * @returns Promise<boolean> True if Gemini API is available
 */
async function isGeminiAvailable(): Promise<boolean> {
  try {
    const geminiApiKey = process.env.GEMINI_API_KEY;
    if (!geminiApiKey) {
      console.log('Gemini API key not configured, falling back to OpenAI');
      return false;
    }
    
    // Check if gemini_tools.py exists
    const geminiToolsPath = 'backend/python/tools/gemini_tools.py';
    if (!fs.existsSync(geminiToolsPath)) {
      console.log('Gemini tools module not found, falling back to OpenAI');
      return false;
    }
    
    return true;
  } catch (error) {
    console.error('Error checking Gemini availability:', error);
    return false;
  }
}

/**
 * Execute a Gemini AI tool function with fallback to OpenAI
 * @param geminiFunction The Gemini function name to execute
 * @param fallbackFunction The fallback OpenAI/Python function name
 * @param params Optional parameters to pass to the functions
 * @returns The JSON result from Gemini or fallback function
 */
async function executeAIToolWithFallback(
  geminiFunction: string, 
  fallbackFunction: string, 
  params?: any
): Promise<any> {
  try {
    // First, try Gemini if available
    if (await isGeminiAvailable()) {
      console.log(`Attempting to use Gemini for ${geminiFunction}`);
      
      // For now, call Gemini functions with default parameters - more complex parameter passing can be added later
      const geminiCommand = `python3 -c "import sys; sys.path.append('backend/python/tools'); import gemini_tools; import json; result = gemini_tools.${geminiFunction}([], []); print(json.dumps(result))"`;
      
      const { stdout, stderr } = await execPromise(geminiCommand);
      
      if (!stderr) {
        const result = JSON.parse(stdout.trim());
        if (result.status === 'success' || result.status === 'ok') {
          console.log(`Successfully used Gemini for ${geminiFunction}`);
          return result;
        }
      }
      
      console.log(`Gemini request failed or throttled for ${geminiFunction}, falling back to OpenAI`);
    }
    
    // Fallback to existing OpenAI/Python implementation
    console.log(`Using fallback method ${fallbackFunction}`);
    return await executeAITool(fallbackFunction);
    
  } catch (error) {
    console.error(`Error in executeAIToolWithFallback for ${geminiFunction}:`, error);
    
    // Final fallback to OpenAI/Python implementation
    try {
      console.log(`Final fallback to ${fallbackFunction}`);
      return await executeAITool(fallbackFunction);
    } catch (fallbackError) {
      console.error(`Fallback also failed for ${fallbackFunction}:`, fallbackError);
      return { 
        status: 'error', 
        message: 'Both Gemini and fallback methods failed', 
        error: String(error) 
      };
    }
  }
}

/**
 * Execute a Python AI tool function directly using child_process
 * @param tool The AI tool function to execute
 * @returns The JSON result from the Python function
 */
async function executeAITool(tool: string): Promise<any> {
  try {
    // Run the Python script with the specified tool
    const command = `python3 -c "import sys; sys.path.append('backend/python/tools'); import ai_tools; import json; result = ai_tools.${tool}(); print(json.dumps(result))"`;
    const { stdout, stderr } = await execPromise(command);
    
    if (stderr) {
      console.error(`Error executing AI tool ${tool}:`, stderr);
      return { status: 'error', message: 'Error executing AI tool' };
    }
    
    // Parse the JSON output
    const result = JSON.parse(stdout.trim());
    return { status: 'ok', ...result };
  } catch (error) {
    console.error(`Exception executing AI tool ${tool}:`, error);
    return { status: 'error', message: 'Failed to execute AI tool', error: String(error) };
  }
}

/**
 * AI Trade Suggester
 * Suggests one up/one down combination for trades
 * Uses Gemini AI with fallback to OpenAI if unavailable
 */
export async function ai_trade_suggester(playerData?: any[], currentTeam?: string[]) {
  // Prepare parameters for Gemini if provided
  const params = (playerData || currentTeam) ? { playerData, currentTeam } : undefined;
  
  return executeAIToolWithFallback(
    'get_gemini_trade_analysis',
    'ai_trade_suggester',
    params
  );
}

/**
 * AI Captain Advisor
 * Recommends top 3 captains based on average and volatility
 * Uses Gemini AI with fallback to OpenAI if unavailable
 */
export async function ai_captain_advisor(availablePlayers?: any[], roundInfo?: any) {
  // Prepare parameters for Gemini if provided
  const params = (availablePlayers || roundInfo) ? { availablePlayers, roundInfo } : undefined;
  
  return executeAIToolWithFallback(
    'get_gemini_captain_advice',
    'ai_captain_advisor',
    params
  );
}

/**
 * Team Structure Analyzer
 * Provides a summary of team structure by price tiers
 * Uses Gemini AI with fallback to OpenAI if unavailable
 */
export async function team_structure_analyzer(currentTeam?: any[], budget?: number) {
  // Prepare parameters for Gemini if provided
  const params = (currentTeam || budget !== undefined) ? { currentTeam, budget } : undefined;
  
  return executeAIToolWithFallback(
    'get_gemini_team_analysis',
    'team_structure_analyzer',
    params
  );
}

/**
 * Ownership Risk Monitor
 * Flags common high-priced underperformers
 * Currently uses OpenAI/Python implementation - could be enhanced with Gemini breakout predictions
 */
export async function ownership_risk_monitor(playerData?: any[]) {
  // TODO: Future enhancement - integrate with get_gemini_breakout_predictions
  // For now, use existing implementation
  return executeAITool('ownership_risk_monitor');
}

/**
 * Form vs Price Scanner
 * Identifies over- or under-valued players
 * Currently uses OpenAI/Python implementation - could be enhanced with Gemini breakout predictions
 */
export async function form_vs_price_scanner(playerData?: any[], seasonContext?: any) {
  // TODO: Future enhancement - integrate with get_gemini_breakout_predictions
  // For now, use existing implementation
  return executeAITool('form_vs_price_scanner');
}

/**
 * Gemini Breakout Predictions
 * Predicts potential breakout players using Gemini AI
 * This is a new function that leverages Gemini's advanced analysis capabilities
 */
export async function gemini_breakout_predictions(playerData?: any[], seasonContext?: any) {
  const params = (playerData || seasonContext) ? { playerData, seasonContext } : undefined;
  
  try {
    if (await isGeminiAvailable()) {
      console.log('Using Gemini for breakout predictions');
      
      const geminiCommand = params 
        ? `python3 -c "import sys; sys.path.append('backend/python/tools'); import gemini_tools; import json; result = gemini_tools.get_gemini_breakout_predictions(${JSON.stringify(params).replace(/"/g, '\\"')}); print(json.dumps(result))"`
        : `python3 -c "import sys; sys.path.append('backend/python/tools'); import gemini_tools; import json; result = gemini_tools.get_gemini_breakout_predictions([], {}); print(json.dumps(result))"`;
      
      const { stdout, stderr } = await execPromise(geminiCommand);
      
      if (!stderr) {
        const result = JSON.parse(stdout.trim());
        if (result.status === 'success') {
          return result;
        }
      }
    }
    
    return {
      status: 'error',
      message: 'Gemini API not available for breakout predictions',
      generated_at: new Date().toISOString()
    };
  } catch (error) {
    console.error('Error in gemini_breakout_predictions:', error);
    return {
      status: 'error',
      message: 'Failed to get breakout predictions',
      error: String(error),
      generated_at: new Date().toISOString()
    };
  }
}

/**
 * Gemini Injury Impact Analysis
 * Analyzes the fantasy impact of injuries using Gemini AI
 * This is a new function that leverages Gemini's advanced analysis capabilities
 */
export async function gemini_injury_analysis(injuryReports?: any[], affectedPlayers?: string[]) {
  const params = (injuryReports || affectedPlayers) ? { injuryReports, affectedPlayers } : undefined;
  
  try {
    if (await isGeminiAvailable()) {
      console.log('Using Gemini for injury impact analysis');
      
      const geminiCommand = params 
        ? `python3 -c "import sys; sys.path.append('backend/python/tools'); import gemini_tools; import json; result = gemini_tools.get_gemini_injury_analysis(${JSON.stringify(params).replace(/"/g, '\\"')}); print(json.dumps(result))"`
        : `python3 -c "import sys; sys.path.append('backend/python/tools'); import gemini_tools; import json; result = gemini_tools.get_gemini_injury_analysis([], []); print(json.dumps(result))"`;
      
      const { stdout, stderr } = await execPromise(geminiCommand);
      
      if (!stderr) {
        const result = JSON.parse(stdout.trim());
        if (result.status === 'success') {
          return result;
        }
      }
    }
    
    return {
      status: 'error',
      message: 'Gemini API not available for injury analysis',
      generated_at: new Date().toISOString()
    };
  } catch (error) {
    console.error('Error in gemini_injury_analysis:', error);
    return {
      status: 'error',
      message: 'Failed to get injury analysis',
      error: String(error),
      generated_at: new Date().toISOString()
    };
  }
}

/**
 * Test Gemini Connection
 * Tests the connection to Gemini API
 * Useful for debugging and health checks
 */
export async function test_gemini_connection() {
  try {
    if (await isGeminiAvailable()) {
      console.log('Testing Gemini API connection');
      
      const geminiCommand = `python3 -c "import sys; sys.path.append('backend/python/tools'); import gemini_tools; import json; result = gemini_tools.test_gemini_connection(); print(json.dumps(result))"`;
      
      const { stdout, stderr } = await execPromise(geminiCommand);
      
      if (!stderr) {
        const result = JSON.parse(stdout.trim());
        return result;
      }
    }
    
    return {
      status: 'error',
      message: 'Gemini API not configured or available'
    };
  } catch (error) {
    console.error('Error testing Gemini connection:', error);
    return {
      status: 'error',
      message: 'Failed to test Gemini connection',
      error: String(error)
    };
  }
}
