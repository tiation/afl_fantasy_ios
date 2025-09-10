import express from "express";
import { exec } from "child_process";
import * as fs from "fs";
import { getPlayerByName, normalizeName as normalizePlayerName } from './footywire-integration';

const teamApi = express.Router();

// Upload team - simplified version that doesn't rely on Python
teamApi.post("/upload", async (req, res) => {
  const teamText = req.body.teamText;
  
  if (!teamText) {
    return res.status(400).json({
      status: "error",
      message: "Team text is required"
    });
  }
  
  try {
    // Use regex to parse the team input directly in JavaScript
    const parseTeam = async (text: string) => {
      const result: any = {
        defenders: [],
        midfielders: [],
        rucks: [],
        forwards: [],
        bench: {
          defenders: [],
          midfielders: [],
          rucks: [],
          forwards: [],
          utility: []
        }
      };
      
      let currentSection: string | null = null;
      let onBench = false;
      
      // Split into lines and process each line
      const lines = text.split('\n');
      
      for (const line of lines) {
        const trimmedLine = line.trim().toLowerCase();
        if (!trimmedLine) continue;
        
        // Detect section headers
        if (trimmedLine.includes('bench')) {
          // Bench headers take priority for detection
          onBench = true;
          
          if (trimmedLine.includes('defender')) {
            currentSection = 'defenders';
            continue;
          } else if (trimmedLine.includes('midfielder')) {
            currentSection = 'midfielders';
            continue;
          } else if (trimmedLine.includes('ruck')) {
            currentSection = 'rucks';
            continue;
          } else if (trimmedLine.includes('forward')) {
            currentSection = 'forwards';
            continue;
          } else if (trimmedLine.includes('utility')) {
            currentSection = 'utility';
            continue;
          } else {
            // Just "Bench" without a position specified - keep the current section but mark as bench
            // This supports format like "Defenders\nPlayer1\nPlayer2\nBench\nPlayer3\nPlayer4"
            continue;
          }
        } else if (trimmedLine.includes('defender')) {
          currentSection = 'defenders';
          onBench = false;
          continue;
        } else if (trimmedLine.includes('midfielder')) {
          currentSection = 'midfielders';
          onBench = false;
          continue;
        } else if (trimmedLine.includes('ruck')) {
          currentSection = 'rucks';
          onBench = false;
          continue;
        } else if (trimmedLine.includes('forward')) {
          currentSection = 'forwards';
          onBench = false;
          continue;
        }
        
        // If we have a section and this isn't a header, it's a player
        if (currentSection) {
          // Get player data from the FootyWire integration
          const playerName = line.trim();
          const playerData = await getPlayerData(playerName);
          
          if (onBench) {
            // Add to bench
            if (currentSection === 'utility') {
              result.bench.utility.push(playerData);
            } else {
              result.bench[currentSection].push(playerData);
            }
          } else {
            // Add to main position
            result[currentSection].push(playerData);
          }
        }
      }
      
      return result;
    };
    
    // Helper function to get player data using the FootyWire integration
    const getPlayerData = async (name: string) => {
      try {
        // Try to get player data from FootyWire integration
        const playerData = await getPlayerByName(name);
        
        if (playerData) {
          console.log(`Found data for ${name}:`, playerData);
          
          // Calculate additional fields for better UI display
          const avgScore = playerData.last3_avg || 0;
          const projectedScore = Math.round(avgScore + 5); // Simple projection
          
          return {
            name: playerData.name,
            team: playerData.team,
            price: playerData.price,
            position: playerData.position,
            breakEven: playerData.breakEven,
            breakeven: playerData.breakEven, // Add lowercase version for compatibility
            last3_avg: playerData.last3_avg,
            last5_avg: playerData.last5_avg,
            avg: playerData.last3_avg, // This is used in some UI components
            averagePoints: playerData.last3_avg,
            projScore: projectedScore,
            projected_score: projectedScore,
            games: 12, // Approximate for mid-season
            status: 'Available'
          };
        } else {
          console.log(`No data found for ${name}`);
        }
      } catch (err) {
        console.error(`Error getting player data for ${name}: ${err}`);
      }
      
      // Return minimal data if no match
      return { 
        name: name, 
        team: '', 
        price: 0, 
        position: 'UNKNOWN',
        breakEven: 0, 
        breakeven: 0,
        last3_avg: 0, 
        last5_avg: 0,
        avg: 0,
        averagePoints: 0,
        projScore: 0,
        projected_score: 0,
        games: 0,
        status: 'Unknown'
      };
    };
    
    // Parse the team
    const team = await parseTeam(teamText);
    
    // Save team data to a file for future use
    try {
      fs.writeFileSync('./user_team.json', JSON.stringify(team, null, 2));
    } catch (saveErr) {
      console.error('Error saving team data to file:', saveErr);
    }
    
    // Return success
    res.json({
      status: "ok",
      message: "Team uploaded successfully",
      data: team
    });
    
  } catch (error) {
    console.error("Error processing team:", error);
    // Return a minimal error response
    res.status(500).json({
      status: "error",
      message: "Failed to process team data",
      data: {
        defenders: [],
        midfielders: [],
        rucks: [],
        forwards: [],
        bench: {
          defenders: [],
          midfielders: [],
          rucks: [],
          forwards: [],
          utility: []
        }
      }
    });
  }
});

// Get team data - simplified version that doesn't rely on Python
teamApi.get("/data", (_, res) => {
  try {
    // Read the team data directly from the JSON file
    let teamData;
    try {
      const fileData = fs.readFileSync('./user_team.json', 'utf8');
      teamData = JSON.parse(fileData);
    } catch (readErr) {
      console.error("Error reading team data file:", readErr);
      // Return an empty team structure if file doesn't exist or can't be parsed
      teamData = {
        defenders: [],
        midfielders: [],
        rucks: [],
        forwards: [],
        bench: {
          defenders: [],
          midfielders: [],
          rucks: [],
          forwards: [],
          utility: []
        }
      };
    }
    
    // Filter out any placeholder players and ensure proper data structure
    for (const position of ['defenders', 'midfielders', 'rucks', 'forwards']) {
      if (Array.isArray(teamData[position])) {
        // Filter out placeholders
        teamData[position] = teamData[position].filter((p: any) => {
          if (!p || typeof p !== 'object' || !p.name) return false;
          const name = p.name.toLowerCase();
          return !name.startsWith('player') && !name.includes('placeholder');
        });
        
        // Ensure all players have proper properties and update with latest AFL Fantasy data
        teamData[position] = teamData[position].map((p: any) => {
          const enhanced = { ...p };
          
          // Try to find current AFL Fantasy data for this player
          try {
            const playerDataPath = './player_data.json';
            if (fs.existsSync(playerDataPath)) {
              const currentPlayerData = JSON.parse(fs.readFileSync(playerDataPath, 'utf8'));
              const currentData = currentPlayerData.find((cp: any) => 
                cp.name && p.name && 
                (cp.name.toLowerCase() === p.name.toLowerCase() ||
                 cp.name.toLowerCase().includes(p.name.toLowerCase()) ||
                 p.name.toLowerCase().includes(cp.name.toLowerCase()))
              );
              
              if (currentData) {
                // Update with current AFL Fantasy prices and stats
                enhanced.price = currentData.price || enhanced.price;
                enhanced.avg = parseFloat(currentData.avg) || enhanced.avg;
                enhanced.averagePoints = parseFloat(currentData.avg) || enhanced.averagePoints;
                enhanced.breakEven = currentData.breakeven || enhanced.breakEven;
                enhanced.breakeven = currentData.breakeven || enhanced.breakeven;
                enhanced.last3_avg = currentData.last3_avg || enhanced.last3_avg;
                enhanced.last5_avg = currentData.last5_avg || enhanced.last5_avg;
                enhanced.projected_score = currentData.projected_score || enhanced.projected_score;
                enhanced.projScore = currentData.projected_score || enhanced.projScore;
                enhanced.status = currentData.status || enhanced.status;
                enhanced.games = currentData.games || enhanced.games;
              }
            }
          } catch (dataError) {
            console.log(`Could not update data for player ${p.name}:`, dataError.message);
          }
          
          // Normalize average points
          if (typeof enhanced.avg === 'string') {
            enhanced.avg = parseFloat(enhanced.avg);
          }
          
          if (typeof enhanced.last3_avg === 'string') {
            enhanced.last3_avg = parseFloat(enhanced.last3_avg);
          }
          
          if (typeof enhanced.last5_avg === 'string') {
            enhanced.last5_avg = parseFloat(enhanced.last5_avg);
          }
          
          // Copy breakeven to breakEven if needed
          if ('breakeven' in enhanced && !('breakEven' in enhanced)) {
            enhanced.breakEven = enhanced.breakeven;
          }
          
          // Additional fields expected by client
          enhanced.averagePoints = enhanced.avg || enhanced.last3_avg || 0;
          enhanced.l3Average = enhanced.last3_avg || enhanced.avg || 0;
          
          // Calculate projected score if not present
          if (!enhanced.projScore && !enhanced.projected_score) {
            enhanced.projScore = Math.round((enhanced.averagePoints || 0) + 5);
            enhanced.projected_score = enhanced.projScore;
          } else if (enhanced.projScore && !enhanced.projected_score) {
            enhanced.projected_score = enhanced.projScore;
          } else if (!enhanced.projScore && enhanced.projected_score) {
            enhanced.projScore = enhanced.projected_score;
          }
          
          // Ensure mandatory fields exist
          if (!('breakEven' in enhanced)) enhanced.breakEven = 0;
          if (!('price' in enhanced)) enhanced.price = 0;
          if (!('team' in enhanced)) enhanced.team = '';
          if (!('games' in enhanced)) enhanced.games = 0;
          if (!('roundsPlayed' in enhanced)) enhanced.roundsPlayed = enhanced.games || 0;
          
          // Set position based on the section they're in
          if (!('position' in enhanced)) {
            if (position === 'defenders') enhanced.position = 'DEF';
            else if (position === 'midfielders') enhanced.position = 'MID';
            else if (position === 'rucks') enhanced.position = 'RUCK';
            else if (position === 'forwards') enhanced.position = 'FWD';
          }
          
          return enhanced;
        });
      }
    }
    
    // Process bench positions
    if (teamData.bench && typeof teamData.bench === 'object') {
      for (const position of ['defenders', 'midfielders', 'rucks', 'forwards', 'utility']) {
        if (Array.isArray(teamData.bench[position])) {
          // Filter out placeholders
          teamData.bench[position] = teamData.bench[position].filter((p: any) => {
            if (!p || typeof p !== 'object' || !p.name) return false;
            const name = p.name.toLowerCase();
            return !name.startsWith('player') && !name.includes('placeholder');
          });
          
          // Ensure all players have proper properties
          teamData.bench[position] = teamData.bench[position].map((p: any) => {
            const enhanced = { ...p };
          
            // Normalize average points
            if (typeof enhanced.avg === 'string') {
              enhanced.avg = parseFloat(enhanced.avg);
            }
            
            if (typeof enhanced.last3_avg === 'string') {
              enhanced.last3_avg = parseFloat(enhanced.last3_avg);
            }
            
            if (typeof enhanced.last5_avg === 'string') {
              enhanced.last5_avg = parseFloat(enhanced.last5_avg);
            }
            
            // Copy breakeven to breakEven if needed
            if ('breakeven' in enhanced && !('breakEven' in enhanced)) {
              enhanced.breakEven = enhanced.breakeven;
            }
            
            // Additional fields expected by client
            enhanced.averagePoints = enhanced.avg || enhanced.last3_avg || 0;
            enhanced.l3Average = enhanced.last3_avg || enhanced.avg || 0;
            
            // Add isOnBench flag for UI
            enhanced.isOnBench = true;
            
            // Calculate projected score if not present
            if (!enhanced.projScore && !enhanced.projected_score) {
              enhanced.projScore = Math.round((enhanced.averagePoints || 0) + 5);
              enhanced.projected_score = enhanced.projScore;
            } else if (enhanced.projScore && !enhanced.projected_score) {
              enhanced.projected_score = enhanced.projScore;
            } else if (!enhanced.projScore && enhanced.projected_score) {
              enhanced.projScore = enhanced.projected_score;
            }
            
            // Ensure mandatory fields exist
            if (!('breakEven' in enhanced)) enhanced.breakEven = 0;
            if (!('price' in enhanced)) enhanced.price = 0;
            if (!('team' in enhanced)) enhanced.team = '';
            if (!('games' in enhanced)) enhanced.games = 0;
            if (!('roundsPlayed' in enhanced)) enhanced.roundsPlayed = enhanced.games || 0;
            
            // Set position based on bench section if not present
            if (!('position' in enhanced)) {
              if (position === 'defenders') enhanced.position = 'DEF';
              else if (position === 'midfielders') enhanced.position = 'MID';
              else if (position === 'rucks') enhanced.position = 'RUCK';
              else if (position === 'forwards') enhanced.position = 'FWD';
              else if (position === 'utility') enhanced.position = 'UTIL';
            }
            
            return enhanced;
          });
        }
      }
    }
    
    // Return the team data
    res.json({
      status: "ok",
      data: teamData
    });
    
  } catch (error) {
    console.error("Error getting team data:", error);
    res.status(500).json({
      status: "error",
      message: "Failed to get team data",
      data: {
        defenders: [],
        midfielders: [],
        rucks: [],
        forwards: [],
        bench: {
          defenders: [],
          midfielders: [],
          rucks: [],
          forwards: [],
          utility: []
        }
      }
    });
  }
});

// Get team stats - simplified version
teamApi.get("/stats", (_, res) => {
  try {
    const stats = {
      team_data_exists: fs.existsSync('./user_team.json'),
      player_data_exists: fs.existsSync('./player_data.json')
    };
    
    res.json({
      status: "ok",
      data: stats
    });
  } catch (error) {
    console.error("Error getting team stats:", error);
    res.status(500).json({
      status: "error",
      message: "Failed to get team stats"
    });
  }
});

export default teamApi;