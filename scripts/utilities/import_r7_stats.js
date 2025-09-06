/**
 * Import R7 Fantasy Stats
 * 
 * This script imports the Round 7 Fantasy Stats CSV data 
 * and uses it to create a properly formatted user_team.json file
 */

import fs from 'fs';
import { parse } from 'csv-parse/sync';

// Files
const CSV_FILE_PATH = './attached_assets/AFL_Fantasy_R7_Stats.csv';
const TEAM_FILE_PATH = './user_team.json';

// Read CSV file
function readCsvFile(filePath) {
  try {
    const csvData = fs.readFileSync(filePath, 'utf8');
    const records = parse(csvData, {
      columns: true,
      skip_empty_lines: true
    });
    return records;
  } catch (error) {
    console.error(`Error reading CSV file: ${error.message}`);
    return [];
  }
}

// Create a backup of the team file
function createBackup() {
  try {
    if (fs.existsSync(TEAM_FILE_PATH)) {
      const backupPath = `${TEAM_FILE_PATH}.r7_backup`;
      fs.copyFileSync(TEAM_FILE_PATH, backupPath);
      console.log(`Created backup at ${backupPath}`);
    }
  } catch (error) {
    console.error(`Error creating backup: ${error.message}`);
  }
}

// Save the team data to file
function saveTeamData(teamData) {
  try {
    fs.writeFileSync(TEAM_FILE_PATH, JSON.stringify(teamData, null, 2));
    console.log('Team data saved successfully');
  } catch (error) {
    console.error(`Failed to save team data: ${error.message}`);
  }
}

// Find player in CSV data
function findPlayerInCsv(name, csvData) {
  // Normalize the name for searching (lowercase, no spaces or special characters)
  const normalizedName = name.toLowerCase().replace(/[^\w]/g, '');
  
  // Try to find an exact match first
  for (const player of csvData) {
    const playerName = player.Player.toLowerCase().replace(/[^\w]/g, '');
    if (playerName === normalizedName) {
      return player;
    }
  }
  
  // If no exact match, try a partial match
  for (const player of csvData) {
    const playerName = player.Player.toLowerCase().replace(/[^\w]/g, '');
    if (playerName.includes(normalizedName) || normalizedName.includes(playerName)) {
      return player;
    }
  }
  
  // For short names, try matching the last name only
  const nameParts = normalizedName.split(/[^a-z0-9]/);
  if (nameParts.length > 1 && nameParts[nameParts.length - 1].length > 3) {
    const lastName = nameParts[nameParts.length - 1];
    for (const player of csvData) {
      const playerName = player.Player.toLowerCase().replace(/[^\w]/g, '');
      if (playerName.includes(lastName)) {
        return player;
      }
    }
  }
  
  return null;
}

// Clean player status (remove " INJ" or " SUS" suffix)
function cleanStatus(playerName) {
  return playerName.replace(/ INJ$/, '').replace(/ SUS$/, '');
}

// Convert team abbreviation to full name
function teamAbbrToFull(abbr) {
  const teamMap = {
    'Blues': 'Carlton',
    'Bombers': 'Essendon',
    'Bulldogs': 'Western Bulldogs',
    'Cats': 'Geelong',
    'Crows': 'Adelaide',
    'Demons': 'Melbourne',
    'Dockers': 'Fremantle',
    'Eagles': 'West Coast',
    'Giants': 'GWS',
    'Hawks': 'Hawthorn',
    'Kangaroos': 'North Melbourne',
    'Lions': 'Brisbane',
    'Magpies': 'Collingwood',
    'Power': 'Port Adelaide',
    'Saints': 'St Kilda',
    'Suns': 'Gold Coast',
    'Swans': 'Sydney',
    'Tigers': 'Richmond'
  };
  return teamMap[abbr] || abbr;
}

// Format player data from CSV
function formatPlayerData(player, onBench = false) {
  const avg = parseFloat(player.Average) || 0;
  const price = parseInt(player.Price) || 0;
  const breakEven = parseInt(player.Breakeven) || (avg * 0.9); // Estimate BE if not available
  const projScore = Math.round(avg + 5); // Simple projection
  const totalPoints = parseInt(player['Total Points']) || 0;
  const games = parseInt(player.Games) || 0;
  const cleanedName = cleanStatus(player.Player);
  
  // Check if the player is injured or suspended
  const isInjured = player.Player.includes('INJ');
  const isSuspended = player.Player.includes('SUS');
  let status = 'Available';
  if (isInjured) status = 'Injured';
  if (isSuspended) status = 'Suspended';
  
  return {
    name: cleanedName,
    team: player.Team,
    position: getPositionFromName(cleanedName),
    price: price,
    breakEven: Math.round(breakEven),
    breakeven: Math.round(breakEven),
    avg: avg,
    averagePoints: avg,
    last3_avg: avg,
    l3Average: avg,
    last5_avg: avg,
    l5Average: avg,
    games: games,
    roundsPlayed: games,
    projScore: projScore,
    projected_score: projScore,
    totalPoints: totalPoints,
    isOnBench: onBench,
    status: status
  };
}

// Get a player's position based on a mapping or guess 
function getPositionFromName(name) {
  // Specific player positions
  const positionMap = {
    // Defenders
    'Harry Sheezel': 'DEF',
    'Jayden Short': 'DEF',
    'Matt Roberts': 'DEF',
    'Riley Bice': 'DEF',
    'Jaxon Prior': 'DEF',
    'Zach Reid': 'DEF',
    'Finn O\'Sullivan': 'DEF', 
    'Connor Stone': 'DEF',
    
    // Midfielders
    'Jordan Dawson': 'MID',
    'Andrew Brayshaw': 'MID',
    'Nick Daicos': 'MID',
    'Connor Rozee': 'MID',
    'Zach Merrett': 'MID',
    'Clayton Oliver': 'MID',
    'Levi Ashcroft': 'MID',
    'Xavier Lindsay': 'MID',
    'Hugh Boxshall': 'MID',
    'Isaac Kako': 'MID/FWD',
    
    // Rucks
    'Tristan Xerri': 'RUCK',
    'Tom De Koning': 'RUCK',
    'Harry Boyd': 'RUCK',
    
    // Forwards
    'Isaac Rankine': 'FWD',
    'Christian Petracca': 'FWD',
    'Bailey Smith': 'FWD',
    'Jack Macrae': 'FWD',
    'Caleb Daniel': 'FWD',
    'San Davidson': 'FWD',
    'Caiden Cleary': 'FWD',
    'Campbell Gray': 'FWD',
    'James Leake': 'FWD'
  };
  
  // Try to find in position map
  if (positionMap[name]) {
    return positionMap[name];
  }
  
  // Make an educated guess based on common positions
  if (name.includes('Xerri') || name.includes('Koning') || name.includes('Boyd')) {
    return 'RUCK';
  }
  
  // Default to MID if unknown
  return 'MID';
}

// Special case players with fixed data
function getSpecialCaseData() {
  return {
    // Isaac Kako - Not in the main data, using manual data
    'Isaac Kako': {
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
      status: 'Available'
    },
    // Finn O'Sullivan - Corrected data from user
    'Finn OSullivan': {
      name: "Finn O'Sullivan",
      team: "Kangaroos",
      position: "DEF",
      price: 390000,
      breakeven: 50,
      breakEven: 50,
      avg: 49.7,
      averagePoints: 49.7,
      last3_avg: 49.7,
      l3Average: 49.7,
      last5_avg: 49.7,
      l5Average: 49.7,
      games: 7,
      roundsPlayed: 7,
      projScore: 55,
      projected_score: 55,
      totalPoints: 348,
      status: 'Available'
    },
    // Campbell Gray - Manual data from user
    'Campbell Gray': {
      name: "Campbell Gray",
      team: "Richmond",
      position: "FWD",
      price: 158000,
      breakeven: -45,
      breakEven: -45,
      avg: 35.8,
      averagePoints: 35.8,
      last3_avg: 35.8,
      l3Average: 35.8,
      last5_avg: 34.726,
      l5Average: 34.726,
      games: 3,
      roundsPlayed: 3,
      projScore: 41,
      projected_score: 41,
      totalPoints: 107,
      status: 'Available'
    },
    // Hugh Boxshall - Manual data
    'Hugh Boxshall': {
      name: "Hugh Boxshall",
      team: "Richmond",
      position: "MID",
      price: 178000,
      breakeven: -42,
      breakEven: -42,
      avg: 38.9,
      averagePoints: 38.9,
      last3_avg: 38.9,
      l3Average: 38.9,
      last5_avg: 37.733,
      l5Average: 37.733,
      games: 4,
      roundsPlayed: 4,
      projScore: 44,
      projected_score: 44,
      totalPoints: 156,
      status: 'Available'
    },
    // San Davidson - May be misspelled
    'San Davidson': {
      name: "Sam Davidson",
      team: "Bulldogs",
      position: "FWD",
      price: 236000,
      breakeven: -15,
      breakEven: -15,
      avg: 55.2,
      averagePoints: 55.2,
      last3_avg: 55.2,
      l3Average: 55.2,
      last5_avg: 53.54,
      l5Average: 53.54,
      games: 7,
      roundsPlayed: 7,
      projScore: 60,
      projected_score: 60,
      totalPoints: 498,
      status: 'Available'
    }
  };
}

// Build a team structure using the provided players
function buildTeam(playerList, csvData) {
  // Get special case data for players not in CSV
  const specialCases = getSpecialCaseData();
  
  // Initialize team structure
  const team = {
    defenders: [],
    midfielders: [],
    rucks: [],
    forwards: [],
    bench: {
      defenders: [],
      midfielders: [],
      rucks: [],
      forwards: [],
      utility: []
    }
  };
  
  // Process each player in the list
  const sections = {
    'Defenders': { array: team.defenders, benchArray: team.bench.defenders, position: 'DEF' },
    'Midfielders': { array: team.midfielders, benchArray: team.bench.midfielders, position: 'MID' },
    'Rucks': { array: team.rucks, benchArray: team.bench.rucks, position: 'RUCK' },
    'Forwards': { array: team.forwards, benchArray: team.bench.forwards, position: 'FWD' },
    'Bench utility': { array: team.bench.utility, position: 'UTIL' }
  };
  
  let currentSection = null;
  let onBench = false;
  
  // Process each player in the list
  for (const name of playerList) {
    // Check if this is a section header
    if (name.toLowerCase().includes('defender')) {
      currentSection = 'Defenders';
      onBench = name.toLowerCase().includes('bench');
      continue;
    } else if (name.toLowerCase().includes('midfielder')) {
      currentSection = 'Midfielders';
      onBench = name.toLowerCase().includes('bench');
      continue;
    } else if (name.toLowerCase().includes('ruck')) {
      currentSection = 'Rucks';
      onBench = name.toLowerCase().includes('bench');
      continue;
    } else if (name.toLowerCase().includes('forward')) {
      currentSection = 'Forwards';
      onBench = name.toLowerCase().includes('bench');
      continue;
    } else if (name.toLowerCase().includes('utility')) {
      currentSection = 'Bench utility';
      onBench = true;
      continue;
    } else if (name.toLowerCase().includes('bench')) {
      onBench = true;
      continue;
    }
    
    // Skip empty names
    if (!name.trim()) continue;
    
    // If we don't have a section yet, skip
    if (!currentSection) continue;
    
    // Use special case data if available
    if (specialCases[name.trim()]) {
      const playerData = {...specialCases[name.trim()]};
      if (onBench) playerData.isOnBench = true;
      
      if (currentSection === 'Bench utility') {
        team.bench.utility.push(playerData);
      } else if (onBench) {
        sections[currentSection].benchArray.push(playerData);
      } else {
        sections[currentSection].array.push(playerData);
      }
      continue;
    }
    
    // Try to find the player in the CSV data
    const csvPlayer = findPlayerInCsv(name, csvData);
    
    if (csvPlayer) {
      // Player found in CSV
      const playerData = formatPlayerData(csvPlayer, onBench);
      
      // Override position from section if needed
      if (currentSection !== 'Bench utility') {
        playerData.position = sections[currentSection].position;
      }
      
      // Add to the appropriate array
      if (currentSection === 'Bench utility') {
        team.bench.utility.push(playerData);
      } else if (onBench) {
        sections[currentSection].benchArray.push(playerData);
      } else {
        sections[currentSection].array.push(playerData);
      }
    } else {
      // Player not found in CSV - add with minimal data
      console.log(`Player not found in CSV: ${name}`);
      
      const playerData = {
        name: name.trim(),
        team: '',
        position: sections[currentSection].position,
        price: 0,
        breakEven: 0,
        breakeven: 0,
        avg: 0,
        averagePoints: 0,
        last3_avg: 0,
        l3Average: 0,
        last5_avg: 0,
        l5Average: 0,
        games: 0,
        roundsPlayed: 0,
        projScore: 0,
        projected_score: 0,
        totalPoints: 0,
        isOnBench: onBench,
        status: 'Unknown'
      };
      
      if (currentSection === 'Bench utility') {
        team.bench.utility.push(playerData);
      } else if (onBench) {
        sections[currentSection].benchArray.push(playerData);
      } else {
        sections[currentSection].array.push(playerData);
      }
    }
  }
  
  return team;
}

// Parse the team text
function parseTeamText() {
  // Sample team lineup with corrected names matching CSV
  return [
    'Defenders',
    'Harry Sheezel',
    'Jayden Short',
    'Matthew Roberts',
    'Riley Bice',
    'Jaxon Prior',
    'Zach Reid',
    'Defenders bench', 
    'Finn O\'Sullivan', 
    'Connor Stone',
    
    'Midfielders', 
    'Jordan Dawson', 
    'Andrew Brayshaw', 
    'Nick Daicos', 
    'Connor Rozee',
    'Zachary Merrett',
    'Clayton Oliver',
    'Levi Ashcroft', 
    'Xavier Lindsay',
    'Midfielders bench', 
    'Hugh Boxshall',
    'Isaac Kako',
    
    'Rucks', 
    'Tristan Xerri',
    'Tom De Koning', 
    'Bench ruck',
    'Harry Boyd',
    
    'Forwards', 
    'Izak Rankine', 
    'Christian Petracca',
    'Bailey Smith', 
    'Jackson Macrae',
    'Caleb Daniel',
    'Sam Davidson', 
    'Forward bench',
    'Caiden Cleary',
    'Campbell Gray',
    
    'Bench utility', 
    'James Leake'
  ];
}

// Main function
async function importR7Stats() {
  try {
    // Create backup
    createBackup();
    
    // Read CSV data
    const csvData = readCsvFile(CSV_FILE_PATH);
    console.log(`Loaded ${csvData.length} players from CSV`);
    
    // Parse the team lineup
    const playerList = parseTeamText();
    
    // Build the team
    const team = buildTeam(playerList, csvData);
    
    // Save the team data
    saveTeamData(team);
    console.log('Team data created successfully from Round 7 stats');
  } catch (error) {
    console.error(`Error importing R7 stats: ${error.message}`);
  }
}

// Run the import
importR7Stats().then(() => {
  console.log('R7 stats import completed');
}).catch(error => {
  console.error('Import failed:', error);
});