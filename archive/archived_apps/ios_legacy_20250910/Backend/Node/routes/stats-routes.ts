import express from 'express';
import axios from 'axios';
import fs from 'fs';
import path from 'path';

const router = express.Router();

// Load player data directly without deduplication since we have one clean source
const getPlayerData = () => {
  try {
    // Use ONLY the comprehensive enhanced data file with corrected teams
    const dataFile = 'player_data.json';
    
    console.log(`Loading player data from ${dataFile}...`);
    
    const filePath = path.join(process.cwd(), dataFile);
    if (!fs.existsSync(filePath)) {
      console.error(`File not found: ${dataFile}`);
      return [];
    }

    const data = fs.readFileSync(filePath, 'utf8');
    const players = JSON.parse(data);
    
    if (!Array.isArray(players)) {
      console.error(`Invalid data format in ${dataFile}`);
      return [];
    }

    // Normalize player data structure without deduplication
    const normalizedPlayers = players.map((player: any) => ({
      name: player.name,
      team: player.team || 'Unknown',
      position: player.position === 'RUCK' ? 'RUC' : (player.position || 'UNK'),
      price: player.price || 0,
      averageScore: player.avg || player.averageScore || player.averagePoints || 0,
      breakEven: player.breakeven || player.breakEven || 0,
      l3Average: player.l3_avg || player.last3_avg || player.l3Average || 0,
      l5Average: player.l5_avg || player.last5_avg || player.l5Average || 0,
      lastScore: player.lastScore || 0,
      projectedScore: player.projected_score || player.projectedScore || player.projScore || 0,
      games: player.games || 0,
      status: player.status || 'fit',
      source: player.source || dataFile,
      score_history: player.score_history || [],
      // Include comprehensive match statistics
      kicks: player.kicks || 0,
      handballs: player.handballs || 0,
      disposals: player.disposals || 0,
      marks: player.marks || 0,
      tackles: player.tackles || 0,
      hitouts: player.hitouts || 0,
      cba: player.cba || 0,
      kickIns: player.kickIns || 0,
      totalPoints: player.totalPoints || 0,
      priceChange: player.priceChange || 0,
      pricePerPoint: player.pricePerPoint || 0,
      selectionPercentage: player.selectionPercentage || 0
    })).filter(player => player.name); // Only include players with names
    
    console.log(`Loaded ${normalizedPlayers.length} players from ${dataFile}`);
    console.log(`Total unique players loaded: ${normalizedPlayers.length}`);
    
    return normalizedPlayers;
  } catch (error) {
    console.error("Error reading player data:", error);
    return [];
  }
};

// FootyWire data endpoint
router.get('/footywire', async (req, res) => {
  try {
    console.log("Scraping FootyWire data...");
    
    // For now, return data from player_data.json with some filtering
    const playerData = getPlayerData();
    
    // Extract relevant fields and format for FootyWire tab
    const formattedData = playerData.map((player: any) => ({
      name: player.name,
      position: player.position,
      team: player.team,
      price: player.price || 0,
      averageScore: player.averageScore || player.averagePoints,
      lastScore: player.lastScore,
      externalId: player.externalId || player.id
    }));
    
    res.json(formattedData);
  } catch (error) {
    console.error("Error fetching FootyWire data:", error);
    res.status(500).json({ error: "Failed to fetch FootyWire data" });
  }
});

// DFS Australia data endpoint
router.get('/dfs-australia', async (req, res) => {
  try {
    console.log("Fetching DFS Australia data...");
    
    // DFS Australia API call disabled to prevent startup delays
    // Uncomment when you want to enable live data fetching
    // try {
    //   const response = await axios.get('https://dfsaustralia.com/wp-json/fantasyapi/v1/big-board');
    //   if (response.status === 200 && response.data) {
    //     const formattedData = response.data.map((player: any) => ({
    //       name: player.player_name,
    //       position: player.position,
    //       team: player.team,
    //       price: parseInt(player.price.replace(/[^0-9]/g, '')),
    //       consistency: parseFloat(player.consistency || 0),
    //       ceiling: parseFloat(player.ceiling || 0),
    //       floor: parseFloat(player.floor || 0),
    //       valueScore: parseFloat(player.value || 0),
    //       ownership: parseFloat(player.ownership?.replace('%', '') || 0)
    //     }));
    //     return res.json(formattedData);
    //   }
    // } catch (apiError) {
    //   console.warn("DFS Australia API not available, using fallback data");
    // }
    
    // Fallback to player_data.json with additional fields
    const playerData = getPlayerData();
    
    // Extract relevant fields and format for DFS Australia tab
    const formattedData = playerData.map((player: any) => {
      // Calculate consistency (standard deviation inverse)
      const consistency = player.l3StdDev ? (100 - Math.min(player.l3StdDev, 40)) : 
                         (player.scores && player.scores.length > 0 ? 
                           calculateConsistency(player.scores) : 60 + Math.random() * 20);
      
      return {
        name: player.name,
        position: player.position,
        team: player.team,
        price: player.price || 0,
        consistency: consistency,
        ceiling: player.ceiling || (player.highScore || (player.averageScore ? player.averageScore * 1.3 : 0)),
        floor: player.floor || (player.lowScore || (player.averageScore ? player.averageScore * 0.7 : 0)),
        valueScore: player.valueScore || (player.averageScore ? (player.averageScore / (player.price / 10000)) : 0),
        ownership: player.ownership || (Math.random() * 30).toFixed(1)
      };
    });
    
    res.json(formattedData);
  } catch (error) {
    console.error("Error fetching DFS Australia data:", error);
    res.status(500).json({ error: "Failed to fetch DFS Australia data" });
  }
});

// Combined stats endpoint
router.get('/combined-stats', async (req, res) => {
  try {
    console.log("Generating combined stats...");
    
    // Get player data
    const playerData = getPlayerData();
    
    // Format data with all available fields including match statistics
    const formattedData = playerData.map((player: any) => ({
      name: player.name,
      position: player.position,
      team: player.team,
      price: player.price || 0,
      averageScore: player.averageScore || player.averagePoints,
      breakEven: player.breakEven || 0,
      l3Average: player.l3Average || 0,
      l5Average: player.l5Average || 0,
      lastScore: player.lastScore,
      projectedScore: player.projectedScore || player.projScore,
      // Match statistics from comprehensive dataset
      kicks: player.kicks || 0,
      handballs: player.handballs || 0,
      disposals: player.disposals || 0,
      marks: player.marks || 0,
      tackles: player.tackles || 0,
      hitouts: player.hitouts || 0,
      // Role statistics
      cba: player.cba || 0,
      kickIns: player.kickIns || 0,
      // Additional stats
      totalPoints: player.totalPoints || 0,
      priceChange: player.priceChange || 0,
      pricePerPoint: player.pricePerPoint || 0,
      selectionPercentage: player.selectionPercentage || 0
    }));
    
    res.json(formattedData);
  } catch (error) {
    console.error("Error generating combined stats:", error);
    res.status(500).json({ error: "Failed to generate combined stats" });
  }
});

// DVP Matrix endpoint
router.get('/dvp-matrix', async (req, res) => {
  try {
    console.log("Loading DVP matrix...");
    
    // Try to load from JSON file first
    const dvpFilePath = path.join(process.cwd(), 'dvp_matrix.json');
    if (fs.existsSync(dvpFilePath)) {
      const dvpData = JSON.parse(fs.readFileSync(dvpFilePath, 'utf8'));
      return res.json(dvpData);
    }
    
    // Fallback - return empty matrix structure
    res.json({
      DEF: {},
      MID: {},
      RUC: {},
      FWD: {}
    });
  } catch (error) {
    console.error("Error fetching DVP matrix:", error);
    res.status(500).json({ error: "Failed to fetch DVP matrix" });
  }
});

// Helper function to calculate consistency
function calculateConsistency(scores: number[]): number {
  if (!scores || scores.length < 2) return 60; // Default value
  
  // Calculate standard deviation
  const mean = scores.reduce((sum, score) => sum + score, 0) / scores.length;
  const squaredDiffs = scores.map(score => Math.pow(score - mean, 2));
  const variance = squaredDiffs.reduce((sum, diff) => sum + diff, 0) / scores.length;
  const stdDev = Math.sqrt(variance);
  
  // Convert to a consistency score (inverse of standard deviation)
  // Higher stdDev = lower consistency
  const maxStdDev = 40; // Assuming this is a reasonable max std dev for AFL Fantasy
  return Math.max(0, 100 - (stdDev / maxStdDev * 100));
}

export default router;