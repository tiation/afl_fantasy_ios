import express from "express";
import { exec } from "child_process";

const captainApi = express.Router();

function runTool(tool, res) {
  const cmd = `python3 -c "from captain_tools import ${tool}; import json; print(json.dumps(${tool}()))"`;
  exec(cmd, (err, stdout) => {
    if (err) return res.status(500).json({ status: "error", message: err.message });
    try {
      const data = JSON.parse(stdout);
      res.json({ status: "ok", ...data });
    } catch (error) {
      res.status(500).json({ status: "error", message: "Invalid JSON from Python" });
    }
  });
}

captainApi.get("/score-predictor", (_, res) => runTool("captain_score_predictor", res));
captainApi.get("/vice-captain-optimizer", (_, res) => runTool("vice_captain_optimizer", res));
captainApi.get("/loophole-detector", (_, res) => runTool("loophole_detector", res));
captainApi.get("/form-based-analyzer", (_, res) => runTool("form_based_captain_analyzer", res));
captainApi.get("/matchup-based-advisor", (_, res) => runTool("matchup_based_captain_advisor", res));

export default captainApi;