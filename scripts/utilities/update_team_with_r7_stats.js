/**
 * Update Team with Round 7 Stats
 * 
 * This script directly maps players in the team lineup to their 
 * corresponding entries in the Round 7 CSV data.
 */

import fs from 'fs';
import readline from 'readline';

// Path to files
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

// Parse CSV file
async function parseCSV() {
  try {
    const fileStream = fs.createReadStream(CSV_FILE_PATH);
    const rl = readline.createInterface({
      input: fileStream,
      crlfDelay: Infinity
    });
    
    const players = [];
    let isFirstRow = true;
    
    for await (const line of rl) {
      if (isFirstRow) {
        isFirstRow = false;
        continue;
      }
      
      const columns = line.split(',');
      if (columns.length < 8) continue;
      
      // Create player object from CSV data
      const player = {
        name: columns[0].trim(),
        team: columns[1].trim(),
        games: parseInt(columns[2]) || 0,
        price: parseInt(columns[3]) || 0,
        totalPoints: parseInt(columns[4]) || 0,
        avg: parseFloat(columns[5]) || 0,
        valuePerK: parseFloat(columns[6]) || 0,
        breakeven: columns[7] && columns[7].trim() !== '' ? parseInt(columns[7]) : null
      };
      
      // Store the player data
      players.push(player);
    }
    
    console.log(`Loaded ${players.length} players from CSV`);
    return players;
  } catch (error) {
    console.error('Failed to parse CSV:', error);
    return [];
  }
}

// Normalize name for comparison
function normalizeName(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]/g, '')
    .replace(/\s+/g, '');
}

// Find a player match in the CSV data
function findPlayerInCSV(name, csvPlayers) {
  // Direct mappings for problematic players
  const directMappings = {
    'Tom de konning': 'Tom De Koning',
    'Tom De Koning': 'Tom De Koning',
    'Hugh boxshall': 'Hugh McCluggage',
    'Hugh Boxshall': 'Hugh McCluggage',
    'Isaac Kako': 'Isaac Cumming',
    'San Davidson': 'Sam Davidson',
    'Sam Davidson': 'Sam Davidson',
    'Finn OSullivan': 'Finn Sullivan',
    'Finn O\'Sullivan': 'Finn Sullivan'
  };
  
  // Check direct mapping
  if (directMappings[name]) {
    const mappedName = directMappings[name];
    for (const player of csvPlayers) {
      if (player.name === mappedName) {
        console.log(`Direct mapping: "${name}" -> "${player.name}"`);
        return player;
      }
    }
  }
  
  // Try exact name match
  const exactMatch = csvPlayers.find(p => p.name === name);
  if (exactMatch) {
    console.log(`Exact match for "${name}"`);
    return exactMatch;
  }
  
  // Try normalized name match
  const normalizedName = normalizeName(name);
  for (const player of csvPlayers) {
    if (normalizeName(player.name) === normalizedName) {
      console.log(`Normalized match: "${name}" -> "${player.name}"`);
      return player;
    }
  }
  
  // Try to match the part after injury/suspension tags
  const nameWithoutTags = name.replace(/\\s+INJ$|\\s+SUS$/, '');
  for (const player of csvPlayers) {
    const csvNameWithoutTags = player.name.replace(/\\s+INJ$|\\s+SUS$/, '');
    if (csvNameWithoutTags === nameWithoutTags) {
      console.log(`Match after removing tags: "${name}" -> "${player.name}"`);
      return player;
    }
  }
  
  // Try last name matching as a fallback
  const teamNameParts = name.split(' ');
  const lastName = teamNameParts[teamNameParts.length - 1].toLowerCase();
  
  const matchesByLastName = csvPlayers.filter(p => {
    const csvNameParts = p.name.split(' ');
    const csvLastName = csvNameParts[csvNameParts.length - 1].toLowerCase();
    return csvLastName === lastName;
  });
  
  if (matchesByLastName.length === 1) {
    console.log(`Last name match: "${name}" -> "${matchesByLastName[0].name}"`);
    return matchesByLastName[0];
  }
  
  if (matchesByLastName.length > 1) {
    const firstInitial = name.charAt(0).toLowerCase();
    const narrowedMatches = matchesByLastName.filter(p => 
      p.name.charAt(0).toLowerCase() === firstInitial
    );
    
    if (narrowedMatches.length === 1) {
      console.log(`First initial and last name match: "${name}" -> "${narrowedMatches[0].name}"`);
      return narrowedMatches[0];
    }
  }
  
  console.log(`No match found for "${name}"`);
  return null;
}

// Update a single player in the team
function updatePlayerWithCSVData(player, csvPlayer) {
  if (!player || !csvPlayer) return player;
  
  // Create a new player with updated data
  return {
    ...player,
    team: csvPlayer.team,
    price: csvPlayer.price,
    // Use breakeven from CSV or default to 0
    breakeven: csvPlayer.breakeven !== null ? csvPlayer.breakeven : 0,
    breakEven: csvPlayer.breakeven !== null ? csvPlayer.breakeven : 0,
    // Set average points
    avg: csvPlayer.avg,
    averagePoints: csvPlayer.avg,
    // Set last 3 and last 5 averages to the average from CSV
    last3_avg: csvPlayer.avg,
    last5_avg: csvPlayer.avg,
    l3Average: csvPlayer.avg,
    l5Average: csvPlayer.avg,
    // Set games played
    games: csvPlayer.games,
    roundsPlayed: csvPlayer.games,
    // Set projected score to 5% above average
    projScore: Math.round(csvPlayer.avg * 1.05),
    projected_score: Math.round(csvPlayer.avg * 1.05),
    // Set total points
    totalPoints: csvPlayer.totalPoints
  };
}

// Update player data in a section of the team
function updateTeamSection(section, csvPlayers) {
  if (!Array.isArray(section)) return section;
  
  return section.map(player => {
    if (!player || !player.name) return player;
    
    const csvPlayer = findPlayerInCSV(player.name, csvPlayers);
    if (csvPlayer) {
      return updatePlayerWithCSVData(player, csvPlayer);
    }
    return player;
  });
}

// Main function to update team data
async function updateTeamWithCSVData() {
  try {
    // Load team data
    const teamData = loadTeamData();
    if (!teamData) {
      throw new Error('Failed to load team data');
    }
    
    // Parse CSV
    const csvPlayers = await parseCSV();
    if (csvPlayers.length === 0) {
      throw new Error('Failed to parse CSV data');
    }
    
    // Create backup
    const backupPath = `${TEAM_FILE_PATH}.r7backup`;
    fs.writeFileSync(backupPath, JSON.stringify(teamData, null, 2));
    console.log(`Created backup at ${backupPath}`);
    
    // Update main positions
    const positions = ['defenders', 'midfielders', 'rucks', 'forwards'];
    for (const position of positions) {
      if (teamData[position]) {
        teamData[position] = updateTeamSection(teamData[position], csvPlayers);
      }
    }
    
    // Update bench positions
    if (teamData.bench) {
      for (const position of [...positions, 'utility']) {
        if (teamData.bench[position]) {
          teamData.bench[position] = updateTeamSection(teamData.bench[position], csvPlayers);
        }
      }
    }
    
    // Save updated team data
    fs.writeFileSync(TEAM_FILE_PATH, JSON.stringify(teamData, null, 2));
    console.log('Team data updated with Round 7 stats');
    
  } catch (error) {
    console.error('Error updating team data:', error);
  }
}

// Run the update process
updateTeamWithCSVData().then(() => {
  console.log('Team update completed');
}).catch(error => {
  console.error('Update failed:', error);
});