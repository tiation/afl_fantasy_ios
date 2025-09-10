import express from "express";
import * as fs from "fs";
import * as path from "path";

const router = express.Router();

/**
 * Get real AFL Fantasy player data from the scraped JSON file
 */
router.get("/players", async (req, res) => {
  try {
    const jsonPath = path.join(process.cwd(), 'player_data.json');
    
    if (!fs.existsSync(jsonPath)) {
      return res.status(404).json({ 
        status: "error",
        message: "AFL Fantasy player data not found" 
      });
    }
    
    const playerData = fs.readFileSync(jsonPath, 'utf8');
    const players = JSON.parse(playerData);
    
    res.json({ 
      status: "success", 
      data: players,
      count: players.length 
    });
  } catch (error) {
    console.error("Error reading AFL Fantasy player data:", error);
    res.status(500).json({ 
      status: "error", 
      message: "Failed to read player data" 
    });
  }
});

/**
 * Calculate user's team value from real AFL Fantasy prices
 */
router.post("/team/calculate-value", async (req, res) => {
  try {
    const { playerNames } = req.body;
    
    if (!playerNames || !Array.isArray(playerNames)) {
      return res.status(400).json({
        status: "error",
        message: "Player names array required"
      });
    }

    const jsonPath = path.join(process.cwd(), 'player_data.json');
    const playerData = fs.readFileSync(jsonPath, 'utf8');
    const allPlayers = JSON.parse(playerData);
    
    let totalValue = 0;
    const foundPlayers = [];
    const notFoundPlayers = [];
    
    playerNames.forEach(name => {
      const player = allPlayers.find(p => 
        p.name.toLowerCase().includes(name.toLowerCase()) || 
        name.toLowerCase().includes(p.name.toLowerCase())
      );
      
      if (player) {
        totalValue += player.price;
        foundPlayers.push({
          name: player.name,
          price: player.price,
          avg: player.avg
        });
      } else {
        notFoundPlayers.push(name);
      }
    });
    
    res.json({
      status: "success",
      data: {
        totalValue,
        foundPlayers: foundPlayers.length,
        notFoundPlayers: notFoundPlayers.length,
        playerDetails: foundPlayers
      }
    });
  } catch (error) {
    console.error("Error calculating team value:", error);
    res.status(500).json({
      status: "error", 
      message: "Failed to calculate team value"
    });
  }
});

/**
 * Get specific player data by name
 */
router.get("/player/:name", async (req, res) => {
  try {
    const playerName = req.params.name;
    const jsonPath = path.join(process.cwd(), 'player_data.json');
    const playerData = fs.readFileSync(jsonPath, 'utf8');
    const allPlayers = JSON.parse(playerData);
    
    const player = allPlayers.find(p => 
      p.name.toLowerCase() === playerName.toLowerCase() ||
      p.name.toLowerCase().includes(playerName.toLowerCase())
    );
    
    if (!player) {
      return res.status(404).json({
        status: "error",
        message: "Player not found"
      });
    }
    
    res.json({
      status: "success",
      data: player
    });
  } catch (error) {
    console.error("Error finding player:", error);
    res.status(500).json({
      status: "error",
      message: "Failed to find player"
    });
  }
});

export default router;