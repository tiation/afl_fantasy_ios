/**
 * Fix Isaac Kako Data with Updated Information
 * 
 * This script updates Isaac Kako's data in the team JSON file
 * with accurate information from the user.
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

// Update Isaac Kako's data across the entire team
function updateKakoData(teamData) {
  // The accurate data directly from the user
  const kakoData = {
    name: "Isaac Kako",
    team: "Essendon",
    position: "MID/FWD",
    price: 220000,
    breakeven: -22,
    breakEven: -22,
    avg: 46,
    averagePoints: 46,
    last3_avg: 44,
    l3Average: 44,
    last5_avg: 43,
    l5Average: 43, 
    games: 6,
    roundsPlayed: 6,
    projScore: 48,
    projected_score: 48,
    totalPoints: 276,
    status: 'fit'
  };

  // Ensure this script doesn't change "Jako" to "Isaac Kako"
  // Only update entries that already have "Kako" in the name
  // Process main positions
  const positions = ['defenders', 'midfielders', 'rucks', 'forwards'];
  let updated = false;
  
  for (const position of positions) {
    if (Array.isArray(teamData[position])) {
      for (let i = 0; i < teamData[position].length; i++) {
        const player = teamData[position][i];
        if (player && player.name && player.name.includes('Kako')) {
          console.log(`Found Isaac Kako in ${position} at index ${i}`);
          // Keep the original ID and any other fields not in kakoData
          teamData[position][i] = {
            ...player,
            ...kakoData
          };
          console.log(`Updated ${position} player ${i + 1}: ${player.name} with accurate data`);
          updated = true;
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
          if (player && player.name && player.name.includes('Kako')) {
            console.log(`Found Isaac Kako in bench.${position} at index ${i}`);
            // Keep the original ID and any other fields not in kakoData
            teamData.bench[position][i] = {
              ...player,
              ...kakoData,
              isOnBench: true
            };
            console.log(`Updated bench.${position} player ${i + 1}: ${player.name} with accurate data`);
            updated = true;
          }
        }
      }
    }
  }
  
  if (!updated) {
    console.log("Didn't find Isaac Kako in the team data.");
  }
  
  return teamData;
}

// Main function to fix Isaac Kako's data
async function fixKakoData() {
  try {
    // Load team data
    const teamData = loadTeamData();
    if (!teamData) {
      throw new Error('Failed to load team data');
    }
    
    // Create backup
    const backupPath = `${TEAM_FILE_PATH}.kako_final_backup`;
    fs.writeFileSync(backupPath, JSON.stringify(teamData, null, 2));
    console.log(`Created backup at ${backupPath}`);
    
    // Update Isaac Kako's data
    const updatedTeamData = updateKakoData(teamData);
    
    // Save updated team data
    saveTeamData(updatedTeamData);
    console.log('Isaac Kako data has been updated with accurate information');
    
  } catch (error) {
    console.error('Error updating Isaac Kako data:', error);
  }
}

// Run the fix
fixKakoData().then(() => {
  console.log('Data fix completed');
}).catch(error => {
  console.error('Fix failed:', error);
});