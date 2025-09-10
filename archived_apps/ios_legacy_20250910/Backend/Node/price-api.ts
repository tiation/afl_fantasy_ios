import express from "express";
import { exec } from "child_process";

const priceApi = express.Router();

function runTool(tool: string, res: express.Response) {
  const cmd = `python3 -c "import sys; sys.path.append('backend/python/tools'); from price_tools import ${tool}; import json; print(json.dumps(${tool}()))"`;
  
  exec(cmd, (err, stdout) => {
    if (err) {
      console.error(`Error running price tool ${tool}:`, err);
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
      console.error(`Error parsing price tool ${tool} output:`, error);
      res.status(500).json({ 
        status: "error", 
        message: "Failed to parse Python output" 
      });
    }
  });
}

// Routes for each price analysis tool
priceApi.get("/projection", (_, res) => runTool("price_projection_calculator", res));
priceApi.get("/be-trend", (_, res) => runTool("breakeven_trend_analyzer", res));
priceApi.get("/recovery", (_, res) => runTool("price_drop_recovery_predictor", res));
priceApi.get("/scatter", (_, res) => runTool("price_vs_score_scatter", res));
priceApi.get("/value-rank", (_, res) => runTool("value_ranker_by_position", res));

export default priceApi;