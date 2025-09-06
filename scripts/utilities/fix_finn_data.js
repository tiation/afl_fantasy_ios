/**
 * Fix Finn Sullivan Data
 * 
 * This script directly updates Finn Sullivan's data in the team JSON file
 * based on the Round 7 stats CSV.
 */

import fs from 'fs';
import readline from 'readline';

// Team data file
const TEAM_FILE_PATH = './user_team.json';
const CSV_FILE_PATH = './attached_assets/AFL_Fantasy_R7_Stats.csv';

// Load team data
function loadTeamData() {
  try {
    const data = fs.readFileSync(TEAM_FILE_PATH, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Failed to load team data:', error);
    return null;
  }
}

// Save team data
function saveTeamData(teamData) {
  try {
    fs.writeFileSync(TEAM_FILE_PATH, JSON.stringify(teamData, null, 2));
    console.log('Team data saved successfully');
  } catch (error) {
    console.error('Failed to save team data:', error);
  }
}

// Find Finn Sullivan in CSV data
async function findSullivanInCSV() {
  try {
    const fileStream = fs.createReadStream(CSV_FILE_PATH);
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity
    });
    
    let isFirstRow = true;
    
    for await (const line of rl) {
      if (isFirstRow) {
        isFirstRow = false;
        continue;
      }
      
      const columns = line.split(',');
      if (columns.length < 8) continue;
      
      const playerName = columns[0].trim();
      // Check various possible names
      if (playerName === 'Finn Sullivan' || playerName === 'Finn O\'Sullivan') {
        // Found Finn Sullivan in the CSV
        return {
          name: 'Finn Sullivan',
          team: columns[1].trim(),
          games: parseInt(columns[2]) || 0,
          price: parseInt(columns[3]) || 0,
          totalPoints: parseInt(columns[4]) || 0,
          avg: parseFloat(columns[5]) || 0,
          valuePerK: parseFloat(columns[6]) || 0,
          breakeven: columns[7] && columns[7].trim() !== '' ? parseInt(columns[7]) : -28
        };
      }
    }
    
    console.log('Finn Sullivan not found in CSV, using manual data');
    // If not found, provide the data manually
    return {
      name: 'Finn Sullivan',
      team: 'Western Bulldogs',
      games: 0,
      price: 205000,
      totalPoints: 0,
      avg: 0,
      valuePerK: 0,
      breakeven: -28
    };
    
  } catch (error) {
    console.error('Failed to parse CSV:', error);
    return null;
  }
}

// Update Finn Sullivan's data across the entire team
async function updateSullivanData(teamData) {
  // Get Finn Sullivan's data from CSV
  const sullivanData = await findSullivanInCSV();
  if (!sullivanData) {
    console.error('Failed to get Finn Sullivan data');
    return teamData;
  }
  
  console.log('Found Finn Sullivan data:', sullivanData);
  
  // Create the complete player data object
  const updatedData = {
    name: "Finn Sullivan",
    team: sullivanData.team,
    position: "DEF",
    price: sullivanData.price,
    breakeven: sullivanData.breakeven,
    breakEven: sullivanData.breakeven,
    avg: sullivanData.avg,
    averagePoints: sullivanData.avg,
    last3_avg: sullivanData.avg,
    l3Average: sullivanData.avg,
    last5_avg: sullivanData.avg,
    l5Average: sullivanData.avg, 
    games: sullivanData.games,
    roundsPlayed: sullivanData.games,
    projScore: Math.max(45, Math.round(sullivanData.avg * 1.05)), // Use 45 if avg is 0
    projected_score: Math.max(45, Math.round(sullivanData.avg * 1.05)),
    totalPoints: sullivanData.totalPoints,
    status: 'fit'
  };

  // Process main positions (find "Finn O'Sullivan" or any variation)
  const positions = ['defenders', 'midfielders', 'rucks', 'forwards'];
  for (const position of positions) {
    if (Array.isArray(teamData[position])) {
      for (let i = 0; i < teamData[position].length; i++) {
        const player = teamData[position][i];
        if (player && player.name && 
            (player.name.toLowerCase().includes('finn') || 
             player.name.toLowerCase().includes('sullivan'))) {
          console.log(`Found Finn Sullivan in ${position} at index ${i}`);
          // Keep the original ID and any other fields not in updatedData
          teamData[position][i] = {
            ...player,
            ...updatedData
          };
          console.log(`Updated ${position} player ${i + 1}: ${player.name} with accurate data`);
        }
      }
    }
  }
  
  // Process bench positions
  if (teamData.bench) {
    for (const position of [...positions, 'utility']) {
      if (Array.isArray(teamData.bench[position])) {
        for (let i = 0; i < teamData.bench[position].length; i++) {
          const player = teamData.bench[position][i];
          if (player && player.name && 
              (player.name.toLowerCase().includes('finn') || 
               player.name.toLowerCase().includes('sullivan'))) {
            console.log(`Found Finn Sullivan in bench.${position} at index ${i}`);
            // Keep the original ID and any other fields not in updatedData
            teamData.bench[position][i] = {
              ...player,
              ...updatedData,
              isOnBench: true
            };
            console.log(`Updated bench.${position} player ${i + 1}: ${player.name} with accurate data`);
          }
        }
      }
    }
  }
  
  return teamData;
}

// Main function to fix Finn Sullivan's data
async function fixSullivanData() {
  try {
    // Load team data
    const teamData = loadTeamData();
    if (!teamData) {
      throw new Error('Failed to load team data');
    }
    
    // Create backup
    const backupPath = `${TEAM_FILE_PATH}.sullivan_backup`;
    fs.writeFileSync(backupPath, JSON.stringify(teamData, null, 2));
    console.log(`Created backup at ${backupPath}`);
    
    // Update Finn Sullivan's data
    const updatedTeamData = await updateSullivanData(teamData);
    
    // Save updated team data
    saveTeamData(updatedTeamData);
    console.log('Finn Sullivan data has been updated with accurate information');
    
  } catch (error) {
    console.error('Error updating Finn Sullivan data:', error);
  }
}

// Run the fix
fixSullivanData().then(() => {
  console.log('Data fix completed');
}).catch(error => {
  console.error('Fix failed:', error);
});