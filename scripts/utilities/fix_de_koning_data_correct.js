/**
 * Fix Tom De Koning Data with Correct Information
 * 
 * This script directly updates Tom De Koning's data in the team JSON file
 * with accurate information.
 */

import fs from 'fs';

// Team data file
const TEAM_FILE_PATH = './user_team.json';

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

// Update Tom De Koning's data
function updateDeKoningData(teamData) {
  // The accurate data directly from the user
  const deKoningData = {
    name: "Tom De Koning",
    team: "Blues",
    position: "RUCK",
    price: 940000,
    breakeven: 94,
    breakEven: 94,
    avg: 100.7,
    averagePoints: 100.7,
    last3_avg: 100.7,
    l3Average: 100.7,
    last5_avg: 100.7,
    l5Average: 100.7, 
    games: 12,
    roundsPlayed: 12,
    projScore: 106,
    projected_score: 106,
    totalPoints: 1208,
    status: 'Available'
  };

  // Find De Koning in rucks, accounting for various spellings
  let updated = false;
  
  // Check in main rucks
  if (Array.isArray(teamData.rucks)) {
    for (let i = 0; i < teamData.rucks.length; i++) {
      const player = teamData.rucks[i];
      if (player && player.name) {
        const playerName = player.name.toLowerCase();
        // Check for various spellings and typos
        if (playerName.includes('de koning') || 
            playerName.includes('dekon') || 
            playerName.includes('koning') || 
            playerName.includes('tom de') ||
            playerName.includes('konning')) {
          console.log(`Found Tom De Koning in rucks at index ${i}`);
          // Keep the original ID and any other fields not in deKoningData
          teamData.rucks[i] = {
            ...player,
            ...deKoningData
          };
          console.log(`Updated rucks player ${i + 1}: ${player.name} with accurate data`);
          updated = true;
        }
      }
    }
  }
  
  // Check in bench rucks
  if (teamData.bench && Array.isArray(teamData.bench.rucks)) {
    for (let i = 0; i < teamData.bench.rucks.length; i++) {
      const player = teamData.bench.rucks[i];
      if (player && player.name) {
        const playerName = player.name.toLowerCase();
        // Check for various spellings and typos
        if (playerName.includes('de koning') || 
            playerName.includes('dekon') || 
            playerName.includes('koning') || 
            playerName.includes('tom de') ||
            playerName.includes('konning')) {
          console.log(`Found Tom De Koning in bench.rucks at index ${i}`);
          // Keep the original ID and any other fields not in deKoningData
          teamData.bench.rucks[i] = {
            ...player,
            ...deKoningData,
            isOnBench: true
          };
          console.log(`Updated bench.rucks player ${i + 1}: ${player.name} with accurate data`);
          updated = true;
        }
      }
    }
  }
  
  if (!updated) {
    console.log("Didn't find Tom De Koning in the team data.");
  }
  
  return teamData;
}

// Main function
async function fixDeKoningData() {
  try {
    // Load team data
    const teamData = loadTeamData();
    if (!teamData) {
      throw new Error('Failed to load team data');
    }
    
    // Create backup
    const backupPath = `${TEAM_FILE_PATH}.dekoning_backup_correct`;
    fs.writeFileSync(backupPath, JSON.stringify(teamData, null, 2));
    console.log(`Created backup at ${backupPath}`);
    
    // Update De Koning's data
    const updatedTeamData = updateDeKoningData(teamData);
    
    // Save updated team data
    saveTeamData(updatedTeamData);
    console.log('Tom De Koning data has been updated with accurate information');
    
  } catch (error) {
    console.error('Error updating Tom De Koning data:', error);
  }
}

// Run the fix
fixDeKoningData().then(() => {
  console.log('Data fix completed');
}).catch(error => {
  console.error('Fix failed:', error);
});