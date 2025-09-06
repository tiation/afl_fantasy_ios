/**
 * Fix Team Names and Sam Davidson Data
 * 
 * This script updates team names to match the official AFL names
 * and fixes Sam Davidson's data in the lineup.
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

// Map for correcting team names to official AFL names
const teamNameMap = {
  "Kangaroos": "North Melbourne",
  "Bombers": "Essendon",
  "Blues": "Carlton",
  "Bulldogs": "Western Bulldogs",
  "Lions": "Brisbane",
  "Tigers": "Richmond",
  "Magpies": "Collingwood",
  "Dockers": "Fremantle",
  "Power": "Port Adelaide",
  "Crows": "Adelaide",
  "Demons": "Melbourne",
  "Giants": "GWS",
  "Swans": "Sydney",
  "Eagles": "West Coast",
  "Hawks": "Hawthorn",
  "Suns": "Gold Coast",
  "Saints": "St Kilda",
  "Cats": "Geelong"
};

function fixTeamNamesAndDavidson(teamData) {
  // Fix team names for all players
  fixTeamNames(teamData.defenders);
  fixTeamNames(teamData.midfielders);
  fixTeamNames(teamData.rucks);
  fixTeamNames(teamData.forwards);
  
  // Fix bench players' team names
  fixTeamNames(teamData.bench.defenders);
  fixTeamNames(teamData.bench.midfielders);
  fixTeamNames(teamData.bench.rucks);
  fixTeamNames(teamData.bench.forwards);
  fixTeamNames(teamData.bench.utility);

  // Fix Sam Davidson specifically
  fixSamDavidson(teamData);
  
  return teamData;
}

function fixTeamNames(players) {
  if (!players || !Array.isArray(players)) return;
  
  for (const player of players) {
    if (player.team && teamNameMap[player.team]) {
      console.log(`Fixing team name for ${player.name}: ${player.team} -> ${teamNameMap[player.team]}`);
      player.team = teamNameMap[player.team];
    }
  }
}

function fixSamDavidson(teamData) {
  // Check all positions for Sam Davidson
  const positions = [
    teamData.forwards,
    teamData.bench.forwards
  ];
  
  for (const positionList of positions) {
    if (!positionList) continue;
    
    for (let i = 0; i < positionList.length; i++) {
      const player = positionList[i];
      if (player.name === "Sam Davidson") {
        // Update with exact values from screenshots
        console.log(`Fixing Sam Davidson's data...`);
        positionList[i] = {
          ...player,
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
        return true;
      }
    }
  }
  
  console.log("Sam Davidson not found in any position");
  return false;
}

// Also update the main player_data.json file to ensure consistency
function updateMainDataFile() {
  try {
    const filePath = './player_data.json';
    if (!fs.existsSync(filePath)) {
      console.log('player_data.json file not found, skipping main data update');
      return;
    }
    
    const playerData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    let updateCount = 0;
    
    // Fix team names in main data file
    for (const player of playerData) {
      if (player.team && teamNameMap[player.team]) {
        player.team = teamNameMap[player.team];
        updateCount++;
      }
      
      // Fix Sam Davidson specifically
      if (player.name === "Sam Davidson") {
        player.price = 626000;
        player.team = "Brisbane";
        player.position = "FWD";
        player.breakEven = 65;
        player.breakeven = 65;
        player.last3_avg = 65;
        player.last5_avg = 63;
        player.avg = 69;
        player.games = 8;
        console.log(`Updated Sam Davidson in main player data file`);
      }
    }
    
    // Save updated player data back to file
    fs.writeFileSync(filePath, JSON.stringify(playerData, null, 2));
    console.log(`Updated ${updateCount} team names in main player data file`);
    
  } catch (error) {
    console.error('Error updating main player data file:', error);
  }
}

async function fixTeamsAndDavidson() {
  try {
    console.log('Starting team name and player data fix...');
    const teamData = loadTeamData();
    const updatedTeamData = fixTeamNamesAndDavidson(teamData);
    saveTeamData(updatedTeamData);
    
    // Update the main data file too
    updateMainDataFile();
    
    console.log('Team names and Sam Davidson data fix completed successfully');
    console.log('\nAll team names now match the official AFL team names and Sam Davidson data has been fixed.');
  } catch (error) {
    console.error('Error during team name and player data fix:', error);
  }
}

// Run the update
fixTeamsAndDavidson();