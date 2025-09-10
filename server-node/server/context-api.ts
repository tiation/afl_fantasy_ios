import express from "express";
import { exec } from "child_process";

const contextApi = express.Router();

function runTool(tool: string, res: express.Response) {
  const cmd = `python3 -c "import sys; sys.path.append('backend/python/tools'); from context_tools import ${tool}; import json; print(json.dumps(${tool}()))"`;
  
  exec(cmd, (err, stdout) => {
    if (err) {
      console.error(`Error running context tool ${tool}:`, err);
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
      console.error(`Error parsing context tool ${tool} output:`, error);
      res.status(500).json({ 
        status: "error", 
        message: "Failed to parse Python output" 
      });
    }
  });
}

// Routes for context analysis tools
contextApi.get("/bye-optimizer", (_, res) => runTool("bye_round_optimizer", res));
contextApi.get("/late-season-taper", (_, res) => runTool("late_season_taper_flagger", res));
contextApi.get("/fast-start-profiles", (_, res) => runTool("fast_start_profile_scanner", res));
contextApi.get("/venue-bias", (_, res) => runTool("venue_bias_detector", res));
contextApi.get("/contract-motivation", (_, res) => runTool("contract_year_motivation_checker", res));

export default contextApi;