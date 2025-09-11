// role-api.ts
import { Router } from 'express';
import { exec } from 'child_process';

const router = Router();

// Helper function to run a Python role tool
function runPythonTool(toolName: string, res: any) {
  const cmd = `python3 -c "import sys; sys.path.append('backend/python/tools'); from role_tools import ${toolName}; import json; print(json.dumps(${toolName}()))"`;

  exec(cmd, (err, stdout, stderr) => {
    if (err) return res.status(500).json({ error: stderr || err.message });

    try {
      const data = JSON.parse(stdout);
      res.json(data);
    } catch (e) {
      res.status(500).json({ error: "Failed to parse Python output" });
    }
  });
}

// Endpoints
router.get("/role-change", (_, res) => runPythonTool("role_change_detector", res));
router.get("/cba-trends", (_, res) => runPythonTool("cba_trend_analyzer", res));
router.get("/positional-impact", (_, res) => runPythonTool("positional_impact_scoring", res));
router.get("/possession-profile", (_, res) => runPythonTool("possession_type_profiler", res));

export default router;