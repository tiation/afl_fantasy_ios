/**
 * Direct Cash Tools Integration
 * 
 * This module provides direct access to the Python cash tools via child process
 * instead of using the Flask API, to avoid networking issues in Replit.
 */

import { spawn } from 'child_process';
import * as fs from 'fs';

// Helper function to run a Python script and get JSON result
function runPythonScript(scriptPath: string, args: string[] = []): Promise<any> {
  return new Promise((resolve, reject) => {
    const process = spawn('python', [scriptPath, ...args]);
    
    let stdout = '';
    let stderr = '';
    
    process.stdout.on('data', (data) => {
      stdout += data.toString();
    });
    
    process.stderr.on('data', (data) => {
      stderr += data.toString();
    });
    
    process.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(`Python script exited with code ${code}: ${stderr}`));
      } else {
        try {
          const result = JSON.parse(stdout);
          resolve(result);
        } catch (error) {
          reject(new Error(`Failed to parse Python output as JSON: ${stdout}`));
        }
      }
    });
  });
}

// Create a Python script wrapper for our tools
export async function setupCashTools(): Promise<void> {
  const cashToolScript = `
import json
import sys
from cash_tools import (
    cash_generation_tracker,
    rookie_price_curve_model,
    downgrade_target_finder, 
    cash_gen_ceiling_floor,
    price_predictor_calculator,
    price_ceiling_floor_estimator
)

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "No tool specified"}))
        return
        
    tool = sys.argv[1]
    
    try:
        if tool == "cash_generation_tracker":
            result = cash_generation_tracker()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "rookie_price_curve":
            result = rookie_price_curve_model()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "downgrade_targets":
            result = downgrade_target_finder()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "ceiling_floor":
            result = cash_gen_ceiling_floor()
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "price_predictor":
            if len(sys.argv) < 4:
                print(json.dumps({"error": "Missing player_name or scores"}))
                return
                
            player_name = sys.argv[2]
            scores = json.loads(sys.argv[3])
            result = price_predictor_calculator(player_name, scores)
            print(json.dumps({"status": "ok", "data": result}))
            
        elif tool == "price_ceiling_floor":
            result = price_ceiling_floor_estimator()
            print(json.dumps({"status": "ok", "data": result}))
            
        else:
            print(json.dumps({"error": f"Unknown tool: {tool}"}))
            
    except Exception as e:
        print(json.dumps({"error": str(e)}))

if __name__ == "__main__":
    main()
  `;
  
  // Write the script to file
  fs.writeFileSync('cash_tools_runner.py', cashToolScript);
  
  console.log('Cash tools direct integration set up');
}

// Export cash tools services with direct Python execution
export const directCashToolsService = {
  // Get cash generation tracker data
  async getCashGenerationTrackerData() {
    return await runPythonScript('cash_tools_runner.py', ['cash_generation_tracker']);
  },

  // Get rookie price curve data
  async getRookiePriceCurveData() {
    return await runPythonScript('cash_tools_runner.py', ['rookie_price_curve']);
  },

  // Get downgrade targets data
  async getDowngradeTargets() {
    return await runPythonScript('cash_tools_runner.py', ['downgrade_targets']);
  },

  // Get cash generation ceiling/floor data
  async getCashGenCeilingFloor() {
    return await runPythonScript('cash_tools_runner.py', ['ceiling_floor']);
  },

  // Calculate price predictions for a player
  async calculatePricePredictions(playerName: string, scores: number[]) {
    return await runPythonScript('cash_tools_runner.py', [
      'price_predictor', 
      playerName, 
      JSON.stringify(scores)
    ]);
  },

  // Get price ceiling and floor estimates
  async getPriceCeilingFloor() {
    return await runPythonScript('cash_tools_runner.py', ['price_ceiling_floor']);
  }
};