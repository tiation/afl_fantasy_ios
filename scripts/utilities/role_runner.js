// role_runner.js
import { exec } from 'child_process';

function runTool(toolName) {
  exec(`python3 -c "from role_tools import ${toolName}; import json; print(json.dumps(${toolName}()))"`, (err, stdout, stderr) => {
    if (err) {
      console.error("Error:", err);
      return;
    }
    try {
      const data = JSON.parse(stdout);
      console.log(`\n=== ${toolName} ===\n`, data);
    } catch (e) {
      console.error("JSON parse error:", e.message, stdout);
    }
  });
}

// Available tools
const tools = [
  "role_change_detector",
  "cba_trend_analyzer",
  "positional_impact_scoring",
  "possession_type_profiler"
];

// Example: Run all
tools.forEach(runTool);