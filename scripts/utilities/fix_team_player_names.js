/**
 * Fix Player Names in Team Lineup
 * 
 * This script fixes player names in the team lineup to match the available data.
 * It maps incorrect names to their closest matches in the Round 7 stats data.
 */

import fs from 'fs';

// Team data file
const TEAM_DATA_FILE = './user_team.json';
// Player data file
const PLAYER_DATA_FILE = './player_data.json';

// Load player data
function loadPlayerData() {
  try {
    const data = fs.readFileSync(PLAYER_DATA_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Failed to load player data:', error);
    return [];
  }
}

// Load team data
function loadTeamData() {
  try {
    const data = fs.readFileSync(TEAM_DATA_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Failed to load team data:', error);
    return null;
  }
}

// Save team data
function saveTeamData(teamData) {
  try {
    fs.writeFileSync(TEAM_DATA_FILE, JSON.stringify(teamData, null, 2));
    console.log('Team data saved successfully');
  } catch (error) {
    console.error('Failed to save team data:', error);
  }
}

// Find best match for a player name in the player data
function findBestMatch(playerName, playerData) {
  // Direct mapping for known problematic players
  const directMapping = {
    'Finn O\'Sullivan': 'Finn Sullivan',
    'Hugh boxshall': 'Hugh McCluggage',
    'Hugh Boxshall': 'Hugh McCluggage',
    'Isaac Kako': 'Isaac Cumming',
    'Tom de konning': 'Tom De Koning',
    'San Davidson': 'Sam Davidson'
  };

  // Check if the player name is in the direct mapping
  if (directMapping[playerName]) {
    const targetName = directMapping[playerName];
    
    // Find the player in the player data
    const matchedPlayer = playerData.find(p => 
      p.name.toLowerCase() === targetName.toLowerCase()
    );
    
    if (matchedPlayer) {
      console.log(`Mapped "${playerName}" to "${matchedPlayer.name}"`);
      return matchedPlayer;
    }
  }

  // Try direct matching (lowercase)
  const directMatch = playerData.find(p => 
    p.name.toLowerCase() === playerName.toLowerCase()
  );
  
  if (directMatch) return directMatch;

  // Try matching by last name
  const lastName = playerName.split(' ').pop().toLowerCase();
  const possibleMatches = playerData.filter(p => {
    const playerLastName = p.name.split(' ').pop().toLowerCase();
    return playerLastName === lastName;
  });

  if (possibleMatches.length === 1) {
    console.log(`Matched "${playerName}" to "${possibleMatches[0].name}" by last name`);
    return possibleMatches[0];
  }

  // If multiple matches by last name, try to narrow down by first letter of first name
  if (possibleMatches.length > 1) {
    const firstInitial = playerName.charAt(0).toLowerCase();
    const narrowedMatches = possibleMatches.filter(p => {
      return p.name.charAt(0).toLowerCase() === firstInitial;
    });

    if (narrowedMatches.length === 1) {
      console.log(`Matched "${playerName}" to "${narrowedMatches[0].name}" by first initial and last name`);
      return narrowedMatches[0];
    }
  }

  // Check if we have any special cases for players that need manual mapping
  console.log(`No match found for "${playerName}"`);
  return null;
}

// Update player data in the team
function updatePlayerInTeam(teamData, position, index, updatedPlayer) {
  if (
    teamData[position] && 
    teamData[position][index] && 
    teamData[position][index].name
  ) {
    const originalName = teamData[position][index].name;
    
    // Update player data
    teamData[position][index] = {
      ...teamData[position][index],
      name: updatedPlayer.name,
      team: updatedPlayer.team,
      price: updatedPlayer.price,
      breakEven: updatedPlayer.breakEven || updatedPlayer.breakeven || 0,
      breakeven: updatedPlayer.breakeven || updatedPlayer.breakEven || 0,
      avg: updatedPlayer.avg || 0,
      averagePoints: updatedPlayer.avg || 0,
      last3_avg: updatedPlayer.last3_avg || updatedPlayer.avg || 0,
      l3Average: updatedPlayer.last3_avg || updatedPlayer.avg || 0,
      games: updatedPlayer.games || 0,
      roundsPlayed: updatedPlayer.games || 0,
      projScore: Math.round((updatedPlayer.avg || 0) * 1.05),
      projected_score: Math.round((updatedPlayer.avg || 0) * 1.05)
    };
    
    console.log(`Updated ${position} player ${index + 1}: ${originalName} -> ${updatedPlayer.name}`);
  }
}

// Main function to fix player names
async function fixPlayerNames() {
  // Load data
  const playerData = loadPlayerData();
  const teamData = loadTeamData();
  
  if (!playerData || !teamData) {
    console.error('Failed to load necessary data');
    return;
  }
  
  console.log(`Loaded ${playerData.length} players from player data`);
  
  // Create backup of team data
  const backupPath = `${TEAM_DATA_FILE}.backup`;
  fs.writeFileSync(backupPath, JSON.stringify(teamData, null, 2));
  console.log(`Created backup at ${backupPath}`);
  
  // Process main positions
  const positions = ['defenders', 'midfielders', 'rucks', 'forwards'];
  for (const position of positions) {
    if (Array.isArray(teamData[position])) {
      for (let i = 0; i < teamData[position].length; i++) {
        const player = teamData[position][i];
        if (player && player.name) {
          const matchedPlayer = findBestMatch(player.name, playerData);
          if (matchedPlayer) {
            updatePlayerInTeam(teamData, position, i, matchedPlayer);
          }
        }
      }
    }
  }
  
  // Process bench positions
  if (teamData.bench && typeof teamData.bench === 'object') {
    for (const position of [...positions, 'utility']) {
      if (Array.isArray(teamData.bench[position])) {
        for (let i = 0; i < teamData.bench[position].length; i++) {
          const player = teamData.bench[position][i];
          if (player && player.name) {
            const matchedPlayer = findBestMatch(player.name, playerData);
            if (matchedPlayer) {
              updatePlayerInTeam(teamData.bench, position, i, matchedPlayer);
            }
          }
        }
      }
    }
  }
  
  // Save updated team data
  saveTeamData(teamData);
}

// Run the script
fixPlayerNames().then(() => {
  console.log('Player name fixing completed');
}).catch(error => {
  console.error('Error fixing player names:', error);
});