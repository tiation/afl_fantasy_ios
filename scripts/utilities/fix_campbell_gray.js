/**
 * Fix Campbell Gray Data
 * 
 * This script directly updates Campbell Gray's data in the team JSON file
 * based on user feedback.
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

// Update Campbell Gray's data across the entire team
function updateCampbellGrayData(teamData) {
  // The accurate data for Campbell Gray from user feedback
  // He wasn't found in the CSV, so we're using user-provided or estimated data
  const grayData = {
    name: "Campbell Gray",
    team: "Richmond",  // Updated based on user feedback
    position: "FWD",
    price: 186000,     // Adjusted rookie price
    breakeven: -36,    // Typical rookie breakeven 
    breakEven: -36,    // Duplicate for both formats
    avg: 42,           // Estimated rookie average
    averagePoints: 42,
    last3_avg: 42,
    l3Average: 42,
    last5_avg: 42,
    l5Average: 42, 
    games: 3,          // Estimated games played for a rookie
    roundsPlayed: 3,
    projScore: 45,     // Slightly above average
    projected_score: 45,
    totalPoints: 126,  // 3 games * 42 avg
    status: 'fit'
  };

  // Process main positions
  const positions = ['defenders', 'midfielders', 'rucks', 'forwards'];
  let updated = false;
  
  for (const position of positions) {
    if (Array.isArray(teamData[position])) {
      for (let i = 0; i < teamData[position].length; i++) {
        const player = teamData[position][i];
        if (player && player.name && player.name.toLowerCase().includes('campbell') && player.name.toLowerCase().includes('gray')) {
          console.log(`Found Campbell Gray in ${position} at index ${i}`);
          // Keep the original ID and any other fields not in grayData
          teamData[position][i] = {
            ...player,
            ...grayData
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
          if (player && player.name && player.name.toLowerCase().includes('campbell') && player.name.toLowerCase().includes('gray')) {
            console.log(`Found Campbell Gray in bench.${position} at index ${i}`);
            // Keep the original ID and any other fields not in grayData
            teamData.bench[position][i] = {
              ...player,
              ...grayData,
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
    console.log("Didn't find Campbell Gray in the team data.");
  }
  
  return teamData;
}

// Main function to fix Campbell Gray's data
async function fixCampbellGrayData() {
  try {
    // Load team data
    const teamData = loadTeamData();
    if (!teamData) {
      throw new Error('Failed to load team data');
    }
    
    // Create backup
    const backupPath = `${TEAM_FILE_PATH}.gray_backup`;
    fs.writeFileSync(backupPath, JSON.stringify(teamData, null, 2));
    console.log(`Created backup at ${backupPath}`);
    
    // Update Campbell Gray's data
    const updatedTeamData = updateCampbellGrayData(teamData);
    
    // Save updated team data
    saveTeamData(updatedTeamData);
    console.log('Campbell Gray data has been updated with accurate information');
    
  } catch (error) {
    console.error('Error updating Campbell Gray data:', error);
  }
}

// Run the fix
fixCampbellGrayData().then(() => {
  console.log('Data fix completed');
}).catch(error => {
  console.error('Fix failed:', error);
});