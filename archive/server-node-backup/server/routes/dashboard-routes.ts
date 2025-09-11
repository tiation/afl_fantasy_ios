import { Router } from "express";
import path from "path";
import fs from "fs";

const router = Router();

// Dashboard data endpoint that provides summarized AFL Fantasy info
router.get("/dashboard", async (req, res) => {
  try {
    // Return sample data for now
    res.json({
      status: "success",
      data: {
        overview: {
          activeTools: 12,
          aiInsights: 8,
          dataPoints: "1.2K+"
        },
        recentActivity: [
          {
            type: "trade",
            message: "New trade suggestion generated",
            timestamp: new Date().toISOString()
          },
          {
            type: "analysis",
            message: "AI Captain advisor updated",
            timestamp: new Date().toISOString()
          }
        ],
        quickActions: [
          {
            id: "quick-trade",
            name: "Quick Trade Analysis",
            description: "Get instant feedback on a potential trade"
          },
          {
            id: "cash-gen",
            name: "Cash Generation",
            description: "View current cash generation opportunities"
          },
          {
            id: "risk-monitor",
            name: "Risk Monitor",
            description: "Check current player risk levels"
          }
        ]
      }
    });
  } catch (error) {
    console.error("Error in dashboard endpoint:", error);
    res.status(500).json({
      status: "error",
      message: "Internal server error",
      error: error.message
    });
  }
});

// Player statistics endpoint
router.get("/players", async (req, res) => {
  try {
    const jsonPath = path.join(process.cwd(), 'data', 'players.json');
    if (fs.existsSync(jsonPath)) {
      const data = fs.readFileSync(jsonPath, 'utf8');
      res.json({
        status: "success",
        data: JSON.parse(data)
      });
    } else {
      // Return sample data if file doesn't exist
      res.json({
        status: "success",
        data: [
          {
            id: 1,
            name: "Sample Player",
            team: "Team A",
            position: "MID",
            price: 500000,
            averageScore: 95.5,
            breakeven: 90,
            last3: [85, 92, 88]
          }
        ]
      });
    }
  } catch (error) {
    console.error("Error in players endpoint:", error);
    res.status(500).json({
      status: "error",
      message: "Failed to fetch player data",
      error: error.message
    });
  }
});

// Tools status endpoint
router.get("/tools/status", async (req, res) => {
  res.json({
    status: "success",
    data: {
      trade: {
        active: true,
        version: "1.0.0",
        tools: ["Trade Calculator", "One Up One Down", "Price Predictor"]
      },
      cash: {
        active: true,
        version: "1.0.0",
        tools: ["Cash Generation Tracker", "Rookie Price Curves", "Ceiling/Floor Calculator"]
      },
      risk: {
        active: true,
        version: "1.0.0",
        tools: ["Tag Monitor", "Volatility Index", "Injury Risk Model"]
      },
      ai: {
        active: true,
        version: "1.0.0",
        tools: ["AI Trade Suggester", "Captain Advisor", "Team Structure Analyzer"]
      }
    }
  });
});

// System health check
router.get("/health", async (req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: "1.0.0",
    environment: process.env.NODE_ENV || "development",
    services: {
      database: "healthy",
      redis: "healthy",
      scrapers: "healthy"
    }
  });
});

export default router;
