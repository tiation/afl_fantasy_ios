/**
 * Fix Hugh Boxshall Data
 * 
 * This script directly updates Hugh Boxshall's data in the team JSON file
 * based on the actual AFL Fantasy screenshot provided.
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

// Update Hugh Boxshall's data across the entire team
function updateBoxshallData(teamData) {
  // The correct data for Hugh Boxshall from the screenshot
  const boxshallData = {
    name: "Hugh Boxshall",
    team: "St Kilda",
    position: "MID",
    price: 230000,
    breakeven: 25,
    breakEven: 25,
    avg: 0,
    averagePoints: 0,
    last3_avg: 0,
    l3Average: 0,
    last5_avg: 0,
    l5Average: 0, 
    games: 0,
    roundsPlayed: 0,
    projScore: 43,
    projected_score: 43,
    totalPoints: 0,
    status: 'fit'
  };

  // Process main positions
  const positions = ['defenders', 'midfielders', 'rucks', 'forwards'];
  for (const position of positions) {
    if (Array.isArray(teamData[position])) {
      for (let i = 0; i < teamData[position].length; i++) {
        const player = teamData[position][i];
        if (player && player.name && player.name.toLowerCase().includes('boxshall')) {
          console.log(`Found Hugh Boxshall in ${position} at index ${i}`);
          // Keep the original ID and any other fields not in boxshallData
          teamData[position][i] = {
            ...player,
            ...boxshallData
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
          if (player && player.name && player.name.toLowerCase().includes('boxshall')) {
            console.log(`Found Hugh Boxshall in bench.${position} at index ${i}`);
            // Keep the original ID and any other fields not in boxshallData
            teamData.bench[position][i] = {
              ...player,
              ...boxshallData,
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

// Main function to fix Hugh Boxshall's data
async function fixBoxshallData() {
  try {
    // Load team data
    const teamData = loadTeamData();
    if (!teamData) {
      throw new Error('Failed to load team data');
    }
    
    // Create backup
    const backupPath = `${TEAM_FILE_PATH}.boxshall_backup`;
    fs.writeFileSync(backupPath, JSON.stringify(teamData, null, 2));
    console.log(`Created backup at ${backupPath}`);
    
    // Update Hugh Boxshall's data
    const updatedTeamData = updateBoxshallData(teamData);
    
    // Save updated team data
    saveTeamData(updatedTeamData);
    console.log('Hugh Boxshall data has been updated with accurate information');
    
  } catch (error) {
    console.error('Error updating Hugh Boxshall data:', error);
  }
}

// Run the fix
fixBoxshallData().then(() => {
  console.log('Data fix completed');
}).catch(error => {
  console.error('Fix failed:', error);
});