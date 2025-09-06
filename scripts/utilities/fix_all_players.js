/**
 * Fix All Player Data
 * 
 * This script creates a completely new user_team.json with all correct player data
 * rather than trying to patch individual players.
 */

import fs from 'fs';

// Team data file
const TEAM_FILE_PATH = './user_team.json';

// Create a backup of the current team data
function createBackup() {
  try {
    if (fs.existsSync(TEAM_FILE_PATH)) {
      const backupPath = `${TEAM_FILE_PATH}.fullbackup`;
      fs.copyFileSync(TEAM_FILE_PATH, backupPath);
      console.log(`Created backup at ${backupPath}`);
    }
  } catch (error) {
    console.error('Error creating backup:', error);
  }
}

// Save the new team data
function saveTeamData(teamData) {
  try {
    fs.writeFileSync(TEAM_FILE_PATH, JSON.stringify(teamData, null, 2));
    console.log('Team data saved successfully');
  } catch (error) {
    console.error('Failed to save team data:', error);
  }
}

// Create a complete, correct team data object
function createCorrectTeamData() {
  // Define the specific player data we need to fix
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

  const osullivanData = {
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
  };

  const grayData = {
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
  };

  const boxshallData = {
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
  };

  // Create a complete team structure with all correct data
  return {
    "defenders": [
      {
        "name": "Harry Sheezel",
        "team": "Kangaroos",
        "price": 1038000,
        "position": "DEF",
        "breakEven": 123,
        "breakeven": 123,
        "last3_avg": 106.4,
        "last5_avg": 106.4,
        "avg": 106.4,
        "averagePoints": 106.4,
        "projScore": 111,
        "projected_score": 111,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Jayden Short",
        "team": "Tigers",
        "price": 881000,
        "position": "DEF",
        "breakEven": 98,
        "breakeven": 98,
        "last3_avg": 89.9,
        "last5_avg": 89.9,
        "avg": 89.9,
        "averagePoints": 89.9,
        "projScore": 95,
        "projected_score": 95,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Matt Roberts",
        "team": "Sydney",
        "price": 785000,
        "position": "DEF",
        "breakEven": 89,
        "breakeven": 89,
        "last3_avg": 95.6,
        "last5_avg": 92.73,
        "avg": 95.6,
        "averagePoints": 95.6,
        "projScore": 101,
        "projected_score": 101,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Riley Bice",
        "team": "Swans",
        "price": 653000,
        "position": "DEF",
        "breakEven": -24,
        "breakeven": -24,
        "last3_avg": 78.7,
        "last5_avg": 78.7,
        "avg": 78.7,
        "averagePoints": 78.7,
        "projScore": 84,
        "projected_score": 84,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Jaxon Prior",
        "team": "Bombers",
        "price": 536000,
        "position": "DEF",
        "breakEven": 72,
        "breakeven": 72,
        "last3_avg": 59,
        "last5_avg": 59,
        "avg": 59,
        "averagePoints": 59,
        "projScore": 64,
        "projected_score": 64,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Zach Reid",
        "team": "Bombers",
        "price": 546000,
        "position": "DEF",
        "breakEven": 65,
        "breakeven": 65,
        "last3_avg": 69.6,
        "last5_avg": 69.6,
        "avg": 69.6,
        "averagePoints": 69.6,
        "projScore": 75,
        "projected_score": 75,
        "games": 12,
        "status": "Available"
      }
    ],
    "midfielders": [
      {
        "name": "Jordan Dawson",
        "team": "Crows",
        "price": 1080000,
        "position": "MID",
        "breakEven": 115,
        "breakeven": 115,
        "last3_avg": 111.1,
        "last5_avg": 111.1,
        "avg": 111.1,
        "averagePoints": 111.1,
        "projScore": 116,
        "projected_score": 116,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Andrew Brayshaw",
        "team": "Dockers",
        "price": 1080000,
        "position": "MID",
        "breakEven": 105,
        "breakeven": 105,
        "last3_avg": 108.1,
        "last5_avg": 108.1,
        "avg": 108.1,
        "averagePoints": 108.1,
        "projScore": 113,
        "projected_score": 113,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Nick Daicos",
        "team": "Magpies",
        "price": 1092000,
        "position": "MID",
        "breakEven": 132,
        "breakeven": 132,
        "last3_avg": 107.7,
        "last5_avg": 107.7,
        "avg": 107.7,
        "averagePoints": 107.7,
        "projScore": 113,
        "projected_score": 113,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Connor Rozee",
        "team": "Power",
        "price": 1042000,
        "position": "MID",
        "breakEven": 108,
        "breakeven": 108,
        "last3_avg": 108.6,
        "last5_avg": 108.6,
        "avg": 108.6,
        "averagePoints": 108.6,
        "projScore": 114,
        "projected_score": 114,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Zach Merrett",
        "team": "Essendon",
        "price": 967000,
        "position": "MID",
        "breakEven": 120,
        "breakeven": 120,
        "last3_avg": 122.1,
        "last5_avg": 118.44,
        "avg": 122.1,
        "averagePoints": 122.1,
        "projScore": 127,
        "projected_score": 127,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Clayton Oliver",
        "team": "Demons",
        "price": 928000,
        "position": "MID",
        "breakEven": 112,
        "breakeven": 112,
        "last3_avg": 96.7,
        "last5_avg": 96.7,
        "avg": 96.7,
        "averagePoints": 96.7,
        "projScore": 102,
        "projected_score": 102,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Levi Ashcroft",
        "team": "Lions",
        "price": 658000,
        "position": "MID",
        "breakEven": 38,
        "breakeven": 38,
        "last3_avg": 74.9,
        "last5_avg": 74.9,
        "avg": 74.9,
        "averagePoints": 74.9,
        "projScore": 80,
        "projected_score": 80,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Xavier Lindsay",
        "team": "Demons",
        "price": 528000,
        "position": "MID",
        "breakEven": -36,
        "breakeven": -36,
        "last3_avg": 66,
        "last5_avg": 66,
        "avg": 66,
        "averagePoints": 66,
        "projScore": 71,
        "projected_score": 71,
        "games": 12,
        "status": "Available"
      }
    ],
    "rucks": [
      {
        "name": "Tristan Xerri",
        "team": "Kangaroos",
        "price": 974000,
        "position": "RUCK",
        "breakEven": 92,
        "breakeven": 92,
        "last3_avg": 100.8,
        "last5_avg": 100.8,
        "avg": 100.8,
        "averagePoints": 100.8,
        "projScore": 106,
        "projected_score": 106,
        "games": 12,
        "status": "Available"
      },
      deKoningData // Use our corrected data
    ],
    "forwards": [
      {
        "name": "Isaac Rankine",
        "team": "Gold Coast",
        "price": 739000,
        "position": "FWD",
        "breakEven": 88,
        "breakeven": 88,
        "last3_avg": 99.5,
        "last5_avg": 96.52,
        "avg": 99.5,
        "averagePoints": 99.5,
        "projScore": 105,
        "projected_score": 105,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Christian Petracca",
        "team": "Demons",
        "price": 919000,
        "position": "FWD",
        "breakEven": 102,
        "breakeven": 102,
        "last3_avg": 94.1,
        "last5_avg": 94.1,
        "avg": 94.1,
        "averagePoints": 94.1,
        "projScore": 99,
        "projected_score": 99,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Bailey Smith",
        "team": "Cats",
        "price": 972000,
        "position": "FWD",
        "breakEven": 95,
        "breakeven": 95,
        "last3_avg": 113.8,
        "last5_avg": 113.8,
        "avg": 113.8,
        "averagePoints": 113.8,
        "projScore": 119,
        "projected_score": 119,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Jack Macrae",
        "team": "Saints",
        "price": 901000,
        "position": "FWD",
        "breakEven": 92,
        "breakeven": 92,
        "last3_avg": 99.4,
        "last5_avg": 99.4,
        "avg": 99.4,
        "averagePoints": 99.4,
        "projScore": 104,
        "projected_score": 104,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "Caleb Daniel",
        "team": "Kangaroos",
        "price": 852000,
        "position": "FWD",
        "breakEven": 85,
        "breakeven": 85,
        "last3_avg": 92.2,
        "last5_avg": 92.2,
        "avg": 92.2,
        "averagePoints": 92.2,
        "projScore": 97,
        "projected_score": 97,
        "games": 12,
        "status": "Available"
      },
      {
        "name": "San Davidson",
        "team": "Geelong",
        "price": 236000,
        "position": "FWD",
        "breakEven": -15,
        "breakeven": -15,
        "last3_avg": 55.2,
        "last5_avg": 53.54,
        "avg": 55.2,
        "averagePoints": 55.2,
        "projScore": 60,
        "projected_score": 60,
        "games": 12,
        "status": "Available"
      }
    ],
    "bench": {
      "defenders": [
        osullivanData, // Use our corrected data
        {
          "name": "Connor Stone",
          "team": "Giants",
          "price": 441000,
          "position": "DEF",
          "breakEven": -15,
          "breakeven": -15,
          "last3_avg": 50.9,
          "last5_avg": 50.9,
          "avg": 50.9,
          "averagePoints": 50.9,
          "projScore": 56,
          "projected_score": 56,
          "games": 12,
          "isOnBench": true,
          "status": "Available"
        }
      ],
      "midfielders": [
        boxshallData, // Use our corrected data
        kakoData // Use our corrected data
      ],
      "rucks": [
        {
          "name": "Harry Boyd",
          "team": "Saints",
          "price": 268000,
          "position": "RUCK",
          "breakEven": -12,
          "breakeven": -12,
          "last3_avg": 68,
          "last5_avg": 68,
          "avg": 68,
          "averagePoints": 68,
          "projScore": 73,
          "projected_score": 73,
          "games": 12,
          "isOnBench": true,
          "status": "Available"
        }
      ],
      "forwards": [
        {
          "name": "Caiden Cleary",
          "team": "Swans",
          "price": 457000,
          "position": "FWD",
          "breakEven": -38,
          "breakeven": -38,
          "last3_avg": 66.5,
          "last5_avg": 66.5,
          "avg": 66.5,
          "averagePoints": 66.5,
          "projScore": 72,
          "projected_score": 72,
          "games": 12,
          "isOnBench": true,
          "status": "Available"
        },
        grayData // Use our corrected data
      ],
      "utility": [
        {
          "name": "James Leake",
          "team": "Adelaide",
          "price": 172000,
          "position": "FWD",
          "breakEven": -44,
          "breakeven": -44,
          "last3_avg": 38.4,
          "last5_avg": 37.25,
          "avg": 38.4,
          "averagePoints": 38.4,
          "projScore": 43,
          "projected_score": 43,
          "games": 12,
          "isOnBench": true,
          "status": "Available"
        }
      ]
    }
  };
}

// Main function
async function fixAllPlayers() {
  try {
    // Create backup
    createBackup();
    
    // Generate correct team data
    const correctedTeamData = createCorrectTeamData();
    
    // Set isOnBench for all bench players
    for (const position in correctedTeamData.bench) {
      for (const player of correctedTeamData.bench[position]) {
        player.isOnBench = true;
      }
    }
    
    // Save the corrected team data
    saveTeamData(correctedTeamData);
    console.log('All player data has been replaced with accurate information');
    
  } catch (error) {
    console.error('Error fixing player data:', error);
  }
}

// Run the fix
fixAllPlayers().then(() => {
  console.log('Complete team data fix completed');
}).catch(error => {
  console.error('Fix failed:', error);
});