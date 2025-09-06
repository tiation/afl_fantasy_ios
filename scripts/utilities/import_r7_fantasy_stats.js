/**
 * AFL Fantasy Round 7 Stats Importer
 * 
 * This script imports the AFL Fantasy Round 7 statistics from a CSV file
 * and updates the player_data.json file with the latest data.
 */

import fs from 'fs';
import path from 'path';
import readline from 'readline';

// Path to the CSV file
const CSV_FILE_PATH = './attached_assets/AFL_Fantasy_R7_Stats.csv';
// Path to the player data file
const PLAYER_DATA_FILE_PATH = './player_data.json';

// Create a backup of the current player data
function backupPlayerData() {
  try {
    if (fs.existsSync(PLAYER_DATA_FILE_PATH)) {
      const timestamp = new Date().toISOString().replace(/[:.]/g, '').slice(0, 14);
      const backupPath = `./player_data_backup_${timestamp}.json`;
      fs.copyFileSync(PLAYER_DATA_FILE_PATH, backupPath);
      console.log(`Created backup at ${backupPath}`);
    }
  } catch (error) {
    console.error('Failed to create backup:', error);
  }
}

// Load the existing player data
function loadPlayerData() {
  try {
    if (fs.existsSync(PLAYER_DATA_FILE_PATH)) {
      const data = fs.readFileSync(PLAYER_DATA_FILE_PATH, 'utf8');
      const players = JSON.parse(data);
      // Ensure we have an array of players
      return Array.isArray(players) ? players : [];
    }
  } catch (error) {
    console.error('Failed to load player data:', error);
  }
  return [];
}

// Parse player name to handle different formats
function normalizePlayerName(name) {
  // Remove injury/suspension tags
  name = name.replace(/\s+INJ$|\s+SUS$/, '');
  
  // Handle first initial format (e.g., "M. Bontempelli")
  if (name.includes('.')) {
    const parts = name.split(' ');
    if (parts.length > 1 && parts[0].endsWith('.')) {
      return parts.slice(1).join(' ');
    }
  }
  
  return name;
}

// Find a player in the existing data by name
function findPlayerByName(players, name) {
  const normalizedName = normalizePlayerName(name);
  
  // Try direct match
  let player = players.find(p => 
    normalizePlayerName(p.name).toLowerCase() === normalizedName.toLowerCase()
  );
  
  // Try matching last name if no direct match
  if (!player) {
    const lastName = normalizedName.split(' ').pop();
    const potentialMatches = players.filter(p => {
      const normalizedPlayerName = normalizePlayerName(p.name);
      return normalizedPlayerName.toLowerCase().endsWith(lastName.toLowerCase());
    });
    
    if (potentialMatches.length === 1) {
      player = potentialMatches[0];
    }
  }
  
  return player;
}

// Process the CSV file
async function processCSV() {
  console.log(`Reading data from ${CSV_FILE_PATH}...`);
  
  // Create a read stream for the CSV file
  const fileStream = fs.createReadStream(CSV_FILE_PATH);
  const rl = readline.createInterface({
    input: fileStream,
    crlfDelay: Infinity
  });
  
  const rows = [];
  let isFirstRow = true;
  
  // Read the CSV file line by line
  for await (const line of rl) {
    if (isFirstRow) {
      isFirstRow = false;
      continue; // Skip the header row
    }
    
    // Split the line by comma
    const columns = line.split(',');
    
    // Skip if we don't have enough columns
    if (columns.length < 8) continue;
    
    // Extract data from columns
    const playerData = {
      name: columns[0],
      team: columns[1],
      games: parseInt(columns[2]) || 0,
      price: parseInt(columns[3]) || 0,
      totalPoints: parseInt(columns[4]) || 0,
      avg: parseFloat(columns[5]) || 0,
      valuePerK: parseFloat(columns[6]) || 0,
      breakeven: columns[7] ? parseInt(columns[7]) : null
    };
    
    // Add the player data to the rows array
    rows.push(playerData);
  }
  
  console.log(`Processed ${rows.length} players from CSV.`);
  return rows;
}

// Update the player data
async function updatePlayerData() {
  try {
    // Backup the current player data
    backupPlayerData();
    
    // Load the existing player data
    const playerData = loadPlayerData();
    
    // Process the CSV file
    const csvRows = await processCSV();
    
    // Keep track of stats
    let updated = 0;
    let added = 0;
    let unchanged = 0;
    
    // Convert price from displayed price (e.g. 1084000) to internal format (1084)
    const priceMultiplier = 1000;
    
    // Update existing players or add new ones
    for (const row of csvRows) {
      // Find the player in the existing data
      const player = findPlayerByName(playerData, row.name);
      
      if (player) {
        // Set injury/suspended status
        const isInjured = row.name.includes('INJ');
        const isSuspended = row.name.includes('SUS');
        
        // Update player data
        const originalValues = {
          price: player.price,
          avg: player.avg,
          breakeven: player.breakeven,
          games: player.games,
          team: player.team
        };
        
        // Update the player's data
        player.price = row.price;
        player.team = row.team;
        player.games = row.games;
        player.avg = row.avg;
        player.breakeven = row.breakeven !== null ? row.breakeven : player.breakeven;
        player.breakEven = player.breakeven; // Ensure both formats exist
        player.totalPoints = row.totalPoints;
        player.status = isInjured ? 'injured' : (isSuspended ? 'suspended' : 'fit');
        
        // Calculate derived values
        if (row.avg) {
          player.last3_avg = row.avg; // Approximate last 3 average with the overall average
          player.last5_avg = row.avg; // Approximate last 5 average with the overall average
          player.projected_score = Math.round(row.avg * 1.05); // Slight boost for projected score
        }
        
        // Update timestamp
        player.timestamp = Math.floor(Date.now() / 1000);
        player.source = "r7_stats_import";
        
        // Check if any key values changed
        if (originalValues.price !== player.price || 
            originalValues.avg !== player.avg || 
            originalValues.breakeven !== player.breakeven || 
            originalValues.games !== player.games ||
            originalValues.team !== player.team) {
          updated++;
        } else {
          unchanged++;
        }
      } else {
        // Determine the position based on some heuristics
        // This is approximate since the CSV doesn't contain position information
        let position = "";
        // In a real implementation, we would have a more sophisticated approach
        // For this prototype, we'll use a very simple heuristic
        const playerName = row.name.toLowerCase();
        if (playerName.includes('ruckman') || playerName.includes('ruck')) {
          position = 'RUCK';
        } else if (playerName.includes('defender') || playerName.includes('back')) {
          position = 'DEF';
        } else if (playerName.includes('forward') || playerName.includes('striker')) {
          position = 'FWD';
        } else {
          position = 'MID'; // Default to MID as most players are midfielders
        }
        
        // Set injury/suspended status
        const status = row.name.includes('INJ') ? 'injured' : 
                      (row.name.includes('SUS') ? 'suspended' : 'fit');
        
        // Create a new player
        const newPlayer = {
          name: normalizePlayerName(row.name),
          team: row.team,
          position: position,
          price: row.price,
          avg: row.avg,
          breakeven: row.breakeven !== null ? row.breakeven : 0,
          breakEven: row.breakeven !== null ? row.breakeven : 0,
          games: row.games,
          totalPoints: row.totalPoints,
          status: status,
          timestamp: Math.floor(Date.now() / 1000),
          source: "r7_stats_import"
        };
        
        // Calculate derived values
        if (row.avg) {
          newPlayer.last3_avg = row.avg; // Approximate last 3 average with the overall average
          newPlayer.last5_avg = row.avg; // Approximate last 5 average with the overall average
          newPlayer.projected_score = Math.round(row.avg * 1.05); // Slight boost for projected score
        }
        
        // Add the new player to the player data
        playerData.push(newPlayer);
        added++;
      }
    }
    
    // Save the updated player data
    fs.writeFileSync(PLAYER_DATA_FILE_PATH, JSON.stringify(playerData, null, 2));
    
    console.log(`Updated player data with stats:`);
    console.log(`- Updated: ${updated} players`);
    console.log(`- Added: ${added} players`);
    console.log(`- Unchanged: ${unchanged} players`);
    console.log(`- Total players: ${playerData.length}`);
    
  } catch (error) {
    console.error('Failed to update player data:', error);
  }
}

// Run the update process
updatePlayerData().then(() => {
  console.log('Player data update completed.');
}).catch(error => {
  console.error('Player data update failed:', error);
});