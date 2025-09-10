import express from "express";
import { exec } from "child_process";

const fixtureApi = express.Router();

function runTool(tool: string, res: express.Response) {
  const cmd = `python3 -c "import sys; sys.path.append('backend/python/tools'); from fixture_tools import ${tool}; import json; print(json.dumps(${tool}()))"`;
  
  exec(cmd, (err, stdout) => {
    if (err) {
      console.error(`Error running fixture tool ${tool}:`, err);
      return res.status(500).json({ 
        status: "error", 
        message: err.message 
      });
    }
    
    try {
      const data = JSON.parse(stdout);
      res.json({ 
        status: "ok", 
        data 
      });
    } catch (error) {
      console.error(`Error parsing fixture tool ${tool} output:`, error);
      res.status(500).json({ 
        status: "error", 
        message: "Failed to parse Python output" 
      });
    }
  });
}

// Routes for fixture analysis tools
fixtureApi.get("/fixture-difficulty", async (_, res) => {
  try {
    // Import the matchup data processor
    const { matchupDataProcessor } = await import('./matchup-data-processor');
    
    // Get real fixture difficulty data from Excel file
    const teamFixtureDifficulty = await matchupDataProcessor.getAllTeamFixtureDifficulty();
    
    // Sort by average difficulty (easiest fixtures first)
    teamFixtureDifficulty.sort((a, b) => a.averageDifficulty - b.averageDifficulty);
    
    // Format data to match expected structure
    const formattedData = teamFixtureDifficulty.map(team => ({
      team: team.team,
      fixtures: team.fixtures.map(f => ({
        round: f.round,
        opponent: f.opponent,
        is_home: true, // This would need to be determined from actual fixture data
        difficulty: f.difficulty
      })),
      avg_difficulty: team.averageDifficulty
    }));
    
    res.json({ 
      status: "ok", 
      data: formattedData 
    });
  } catch (error) {
    console.error('Error loading fixture difficulty:', error);
    res.status(500).json({ 
      status: "error", 
      message: "Failed to load fixture difficulty data" 
    });
  }
});

fixtureApi.get("/matchup-dvp", async (_, res) => {
  try {
    const { matchupDataProcessor } = await import('./matchup-data-processor');
    const data = await matchupDataProcessor.loadMatchupData();
    
    res.json({ 
      status: "ok", 
      data: {
        dvpRatings: data.dvpRatings,
        positionMatchups: {
          FWD: data.fwdMatchups,
          MID: data.midMatchups,
          DEF: data.defMatchups,
          RUCK: data.ruckMatchups
        }
      }
    });
  } catch (error) {
    console.error('Error loading matchup DVP:', error);
    res.status(500).json({ 
      status: "error", 
      message: "Failed to load matchup DVP data" 
    });
  }
});

fixtureApi.get("/fixture-swing", (_, res) => runTool("fixture_swing_radar", res));
fixtureApi.get("/travel-impact", (_, res) => runTool("travel_impact_estimator", res));
fixtureApi.get("/weather-risk", (_, res) => runTool("weather_forecast_risk_model", res));

export default fixtureApi;