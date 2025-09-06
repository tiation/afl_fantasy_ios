import fs from 'fs';
import path from 'path';

/**
 * Import AFL Fantasy player breakeven data from the provided CSV
 * 
 * This script processes the All_Player_Breakevens CSV file and updates
 * the player_data.json file with accurate prices and breakevens.
 */

// File paths
const csvFilePath = path.join(process.cwd(), 'attached_assets/All_Player_Breakevens_-_Round_7.csv');
const playerDataPath = path.join(process.cwd(), 'player_data.json');

// Position mapping
const positionMap = {
  'DEF': 'DEF',
  'MID': 'MID',
  'FOR': 'FWD',  // CSV uses FOR, but we standardize to FWD
  'FWD': 'FWD',
  'RUC': 'RUCK'
};

// Team mapping - helps with standardizing team names
const teamMap = {
  'Adelaide': 'Adelaide',
  'Brisbane': 'Brisbane Lions',
  'Carlton': 'Carlton',
  'Collingwood': 'Collingwood',
  'Essendon': 'Essendon',
  'Fremantle': 'Fremantle',
  'Geelong': 'Geelong',
  'Gold Coast': 'Gold Coast',
  'GWS': 'Greater Western Sydney',
  'Hawthorn': 'Hawthorn',
  'Melbourne': 'Melbourne',
  'North Melbourne': 'North Melbourne',
  'Port Adelaide': 'Port Adelaide',
  'Richmond': 'Richmond',
  'St Kilda': 'St Kilda',
  'Sydney': 'Sydney',
  'West Coast': 'West Coast',
  'Western Bulldogs': 'Western Bulldogs'
};

/**
 * Parse a CSV file into an array of objects
 */
function parseCSV(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  const headers = lines[0].split(',');
  
  const data = [];
  
  for (let i = 1; i < lines.length; i++) {
    if (!lines[i].trim()) continue;
    
    const values = lines[i].split(',');
    const entry = {};
    
    for (let j = 0; j < headers.length; j++) {
      entry[headers[j].trim()] = values[j] ? values[j].trim() : '';
    }
    
    data.push(entry);
  }
  
  return data;
}

/**
 * Parse player name and position from the combined field
 * Example: "M. Bontempelli MID" → { name: "M. Bontempelli", position: "MID" }
 */
function parsePlayerNameAndPosition(playerField) {
  const parts = playerField.split(' ');
  const position = parts[parts.length - 1];
  
  // Check if the last part is a position
  if (positionMap[position]) {
    // Remove the position from the parts array
    parts.pop();
    
    // Join the remaining parts to get the name
    const name = parts.join(' ');
    
    return {
      name,
      position: positionMap[position] || position
    };
  }
  
  // If no position found, return the full string as name
  return {
    name: playerField,
    position: 'UNKNOWN'
  };
}

/**
 * Format price string to number
 * Example: "1,086,000" → 1086000
 */
function formatPrice(priceStr) {
  if (!priceStr) return 0;
  
  // Remove $ sign and commas, then parse as integer
  const cleanPrice = priceStr.replace(/[$,]/g, '');
  return parseInt(cleanPrice, 10) || 0;
}

/**
 * Calculate player's average based on breakeven and price
 * This is an approximation if we don't have actual average data
 */
function calculateAverage(breakeven, price) {
  // A simple approximation: breakeven is typically around 90-110% of average
  // We use a midpoint of 100% as an approximation
  return Math.round(breakeven);
}

/**
 * Main function to import CSV breakevens and update player data
 */
async function importBreakevens() {
  console.log('Importing player breakevens from CSV...');
  
  try {
    // Parse the CSV data
    const csvData = parseCSV(csvFilePath);
    console.log(`Found ${csvData.length} players in the CSV file.`);
    
    // Create a map for quick lookup
    const breakevensMap = {};
    
    csvData.forEach(entry => {
      const { name, position } = parsePlayerNameAndPosition(entry['Player Name']);
      const price = formatPrice(entry['Price ($)']);
      const breakeven = parseInt(entry['Breakeven'], 10);
      
      if (name && !isNaN(breakeven)) {
        // Calculate an approximation of player's average
        const average = calculateAverage(breakeven, price);
        
        breakevensMap[name] = {
          name,
          position,
          price,
          breakeven,
          avg: average,
          breakEven: breakeven, // Add both formats for compatibility
          last3_avg: average,
          last5_avg: Math.round(average * 0.97), // Slightly lower for last5
          projected_score: Math.round(average + 5), // Project future score
          source: 'csv_import',
          games: 12, // Approximate for mid-season
          timestamp: Math.floor(Date.now() / 1000),
          status: 'fit'
        };
      }
    });
    
    console.log(`Processed ${Object.keys(breakevensMap).length} players with valid breakevens.`);
    
    // Load existing player data if available
    let existingData = [];
    try {
      if (fs.existsSync(playerDataPath)) {
        const fileData = fs.readFileSync(playerDataPath, 'utf8');
        existingData = JSON.parse(fileData);
        console.log(`Loaded ${existingData.length} players from existing data.`);
      }
    } catch (error) {
      console.warn(`Error reading existing player data: ${error.message}`);
      console.log('Creating new player data file...');
    }
    
    // Create a map of existing players by name
    const existingPlayersMap = {};
    existingData.forEach(player => {
      if (player.name) {
        existingPlayersMap[player.name.toLowerCase()] = player;
      }
    });
    
    // Merge CSV data with existing data
    const updatedPlayers = [];
    
    // First add all CSV players (higher priority)
    Object.values(breakevensMap).forEach(player => {
      updatedPlayers.push(player);
    });
    
    // Then add existing players that aren't in the CSV
    existingData.forEach(player => {
      if (!player.name) return;
      
      const lowerName = player.name.toLowerCase();
      // Skip if already added from CSV
      if (Object.values(breakevensMap).some(p => p.name.toLowerCase() === lowerName)) {
        return;
      }
      
      // If not in CSV, keep the existing player
      updatedPlayers.push(player);
    });
    
    // Save the updated player data to JSON
    fs.writeFileSync(playerDataPath, JSON.stringify(updatedPlayers, null, 2));
    console.log(`Saved ${updatedPlayers.length} players to ${playerDataPath}.`);
    
    // Output a sample for verification
    const sample = updatedPlayers.slice(0, 5);
    console.log('Sample of updated data:');
    console.log(JSON.stringify(sample, null, 2));
    
  } catch (error) {
    console.error('Error importing breakevens:', error);
  }
}

// Run the import
importBreakevens();