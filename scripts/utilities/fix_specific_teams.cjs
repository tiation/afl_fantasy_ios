/**
 * Fix Specific Player Teams
 * 
 * This script updates specific players with their correct teams
 * based on the actual AFL Fantasy app data.
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

// Player team corrections from user
const playerTeamCorrections = {
  "Matt Roberts": "Sydney",
  "Riley Bice": "Sydney",
  "Jaxon Prior": "Essendon",
  "Zach Reid": "Essendon",
  "Xavier Lindsay": "Melbourne",
  "Hugh Boxshall": "St Kilda",
  "Isaac Kako": "Essendon",
  "Harry Boyd": "St Kilda",
  "Isaac Rankine": "Adelaide",
  "Jack Macrae": "St Kilda",
  "Caleb Daniel": "North Melbourne",
  "Caiden Cleary": "Sydney",
  "Campbell Gray": "Richmond"
};

function fixSpecificPlayerTeams(teamData) {
  // Update teams for starting players
  updateTeamsInGroup(teamData.defenders);
  updateTeamsInGroup(teamData.midfielders);
  updateTeamsInGroup(teamData.rucks);
  updateTeamsInGroup(teamData.forwards);
  
  // Update teams for bench players
  updateTeamsInGroup(teamData.bench.defenders);
  updateTeamsInGroup(teamData.bench.midfielders);
  updateTeamsInGroup(teamData.bench.rucks);
  updateTeamsInGroup(teamData.bench.forwards);
  updateTeamsInGroup(teamData.bench.utility);
  
  return teamData;
}

function updateTeamsInGroup(players) {
  if (!players || !Array.isArray(players)) return;
  
  for (const player of players) {
    if (player.name && playerTeamCorrections[player.name]) {
      console.log(`Fixing team for ${player.name}: ${player.team} -> ${playerTeamCorrections[player.name]}`);
      player.team = playerTeamCorrections[player.name];
    }
  }
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
    
    // Update specific player teams in main data file
    for (const player of playerData) {
      if (player.name && playerTeamCorrections[player.name]) {
        console.log(`Fixing team for ${player.name} in main data file: ${player.team} -> ${playerTeamCorrections[player.name]}`);
        player.team = playerTeamCorrections[player.name];
        updateCount++;
      }
    }
    
    // Save updated player data back to file
    fs.writeFileSync(filePath, JSON.stringify(playerData, null, 2));
    console.log(`Updated ${updateCount} player teams in main player data file`);
    
  } catch (error) {
    console.error('Error updating main player data file:', error);
  }
}

async function fixSpecificTeams() {
  try {
    console.log('Starting specific player team fixes...');
    const teamData = loadTeamData();
    const updatedTeamData = fixSpecificPlayerTeams(teamData);
    saveTeamData(updatedTeamData);
    
    // Update the main data file too
    updateMainDataFile();
    
    console.log('Specific player team fixes completed successfully');
    console.log('\nAll specified players now have their correct teams as per the AFL Fantasy app.');
  } catch (error) {
    console.error('Error during specific player team fixes:', error);
  }
}

// Run the update
fixSpecificTeams();