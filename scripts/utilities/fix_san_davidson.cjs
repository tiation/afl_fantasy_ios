/**
 * Fix San Davidson to Sam Davidson
 * 
 * This script corrects the name from "San Davidson" to "Sam Davidson"
 * and updates all his stats with accurate values.
 */

const fs = require('fs');

function loadTeamData() {
  try {
    const teamData = JSON.parse(fs.readFileSync('./user_team.json', 'utf8'));
    console.log('Team data loaded successfully');
    return teamData;
  } catch (error) {
    console.error('Error loading team data:', error);
    process.exit(1);
  }
}

function saveTeamData(teamData) {
  try {
    // Create a backup first
    const timestamp = new Date().toISOString().replace(/:/g, '').split('.')[0];
    const backupPath = `./user_team.json.backup_${timestamp}`;
    fs.copyFileSync('./user_team.json', backupPath);
    console.log(`Created backup at ${backupPath}`);
    
    // Save the updated data
    fs.writeFileSync('./user_team.json', JSON.stringify(teamData, null, 2));
    console.log('Team data saved successfully');
  } catch (error) {
    console.error('Error saving team data:', error);
    process.exit(1);
  }
}

function fixSamDavidson(teamData) {
  let found = false;
  
  // Check forwards for "San Davidson"
  for (let i = 0; i < teamData.forwards.length; i++) {
    const player = teamData.forwards[i];
    if (player.name === "San Davidson") {
      console.log(`Fixing San Davidson -> Sam Davidson in forwards`);
      
      // Update all of Sam Davidson's data
      teamData.forwards[i] = {
        ...player,
        name: "Sam Davidson",
        price: 626000,
        team: "Brisbane",
        position: "FWD",
        breakEven: 65,
        breakeven: 65,
        broke: 65,
        last3_avg: 65,
        last5_avg: 63,
        avg: 69,
        averagePoints: 69,
        projScore: 75,
        projected_score: 75,
        games: 8,
        status: "Available"
      };
      found = true;
    }
  }
  
  if (!found) {
    console.log("San Davidson not found in forwards");
  }
  
  return teamData;
}

// Also update the main player_data.json file
function updateMainDataFile() {
  try {
    const filePath = './player_data.json';
    if (!fs.existsSync(filePath)) {
      console.log('player_data.json file not found, skipping main data update');
      return;
    }
    
    const playerData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    let updated = false;
    
    // Find and fix Sam/San Davidson in main data file
    for (let i = 0; i < playerData.length; i++) {
      const player = playerData[i];
      if (player.name === "San Davidson") {
        playerData[i] = {
          ...player,
          name: "Sam Davidson",
          price: 626000,
          team: "Brisbane",
          position: "FWD",
          breakEven: 65,
          breakeven: 65,
          broke: 65,
          last3_avg: 65,
          last5_avg: 63,
          avg: 69,
          games: 8,
          status: "fit"
        };
        updated = true;
        console.log(`Updated San Davidson to Sam Davidson in main player data file`);
      }
    }
    
    if (!updated) {
      console.log("San Davidson not found in main player data file");
    }
    
    // Save updated player data back to file
    fs.writeFileSync(filePath, JSON.stringify(playerData, null, 2));
    
  } catch (error) {
    console.error('Error updating main player data file:', error);
  }
}

async function fixDavidson() {
  try {
    console.log('Starting Sam Davidson fix...');
    const teamData = loadTeamData();
    const updatedTeamData = fixSamDavidson(teamData);
    saveTeamData(updatedTeamData);
    
    // Update the main data file too
    updateMainDataFile();
    
    console.log('Sam Davidson data fix completed successfully');
    console.log('\nThe name has been corrected from "San Davidson" to "Sam Davidson" with accurate stats.');
  } catch (error) {
    console.error('Error during Sam Davidson fix:', error);
  }
}

// Run the update
fixDavidson();