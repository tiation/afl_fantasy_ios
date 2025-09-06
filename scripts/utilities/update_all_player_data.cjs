/**
 * Update All Player Data with Exact Values from AFL Fantasy App
 * 
 * This script updates the user_team.json with exact values from the AFL Fantasy app
 * screenshots to ensure 100% data accuracy for all players in the team.
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

function updateTeamWithExactData(teamData) {
  // Update with exact data from screenshots
  
  // DEFENDERS
  updatePlayer(teamData.defenders, "Harry Sheezel", {
    price: 1038000,
    team: "Kangaroos",
    position: "DEF",
    breakEven: 127,
    last3_avg: 107,
    last5_avg: 107,
    avg: 106,
    averagePoints: 106,
    projScore: 102,
    projected_score: 102,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.defenders, "Jayden Short", {
    price: 881000,
    team: "Tigers",
    position: "DEF",
    breakEven: 100,
    last3_avg: 87,
    last5_avg: 90,
    avg: 90,
    averagePoints: 90,
    projScore: 86,
    projected_score: 86,
    games: 7,
    status: "Available"
  });

  updatePlayer(teamData.defenders, "Matt Roberts", {
    price: 681000,
    team: "Giants",
    position: "DEF",
    breakEven: 75,
    last3_avg: 99,
    last5_avg: 94,
    avg: 93,
    averagePoints: 93,
    projScore: 74,
    projected_score: 74,
    games: 7,
    status: "Available"
  });

  updatePlayer(teamData.defenders, "Riley Bice", {
    price: 653000,
    team: "Giants",
    position: "DEF",
    breakEven: 31,
    last3_avg: 83,
    last5_avg: 87,
    avg: 79,
    averagePoints: 79,
    projScore: 75,
    projected_score: 75,
    games: 6,
    status: "Available"
  });

  updatePlayer(teamData.defenders, "Zach Reid", {
    price: 546000,
    team: "Bombers",
    position: "DEF",
    breakEven: 36,
    last3_avg: 67,
    last5_avg: 75,
    avg: 70,
    averagePoints: 70,
    projScore: 55,
    projected_score: 55,
    games: 7,
    status: "Available"
  });

  updatePlayer(teamData.defenders, "Jaxon Prior", {
    price: 536000,
    team: "Lions",
    position: "DEF",
    breakEven: 49,
    last3_avg: 58,
    last5_avg: 58,
    avg: 59,
    averagePoints: 59,
    projScore: 52,
    projected_score: 52,
    games: 7,
    status: "Available"
  });

  // MIDFIELDERS
  updatePlayer(teamData.midfielders, "Andrew Brayshaw", {
    price: 1080000,
    team: "Dockers",
    position: "MID",
    breakEven: 97,
    last3_avg: 104,
    last5_avg: 111,
    avg: 104,
    averagePoints: 104,
    projScore: 107,
    projected_score: 107,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.midfielders, "Jordan Dawson", {
    price: 1080000,
    team: "Crows",
    position: "MID",
    breakEven: 120,
    last3_avg: 115,
    last5_avg: 111,
    avg: 113,
    averagePoints: 113,
    projScore: 102,
    projected_score: 102,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.midfielders, "Zach Merrett", {
    price: 1106000,
    team: "Bombers",
    position: "MID",
    breakEven: 134,
    last3_avg: 101,
    last5_avg: 109,
    avg: 111,
    averagePoints: 111,
    projScore: 108,
    projected_score: 108,
    games: 7,
    status: "Available"
  });

  updatePlayer(teamData.midfielders, "Connor Rozee", {
    price: 1042000,
    team: "Power",
    position: "MID",
    breakEven: 109,
    last3_avg: 99,
    last5_avg: 101,
    avg: 106,
    averagePoints: 106,
    projScore: 97,
    projected_score: 97,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.midfielders, "Nick Daicos", {
    price: 1092000,
    team: "Magpies",
    position: "MID",
    breakEven: 95,
    last3_avg: 114,
    last5_avg: 111,
    avg: 106,
    averagePoints: 106,
    projScore: 105,
    projected_score: 105,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.midfielders, "Clayton Oliver", {
    price: 928000,
    team: "Demons",
    position: "MID",
    breakEven: 109,
    last3_avg: 89,
    last5_avg: 96,
    avg: 97,
    averagePoints: 97,
    projScore: 91,
    projected_score: 91,
    games: 7,
    status: "Available"
  });

  updatePlayer(teamData.midfielders, "Xavier Lindsay", {
    price: 528000,
    team: "Eagles",
    position: "MID",
    breakEven: 26,
    last3_avg: 65,
    last5_avg: 51,
    avg: 61,
    averagePoints: 61,
    projScore: 62,
    projected_score: 62,
    games: 7,
    status: "Available"
  });

  updatePlayer(teamData.midfielders, "Levi Ashcroft", {
    price: 658000,
    team: "Lions",
    position: "MID",
    breakEven: 61,
    last3_avg: 74,
    last5_avg: 72,
    avg: 74,
    averagePoints: 74,
    projScore: 70,
    projected_score: 70,
    games: 7,
    status: "Available"
  });

  // RUCKS
  updatePlayer(teamData.rucks, "Tristan Xerri", {
    price: 974000,
    team: "Kangaroos",
    position: "RUC",
    breakEven: 90,
    last3_avg: 120,
    last5_avg: 102,
    avg: 101,
    averagePoints: 101,
    projScore: 172,
    projected_score: 172,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.rucks, "Tom De Koning", {
    price: 940000,
    team: "Blues",
    position: "RUC",
    breakEven: 115,
    last3_avg: 81,
    last5_avg: 80,
    avg: 96,
    averagePoints: 96,
    projScore: 77,
    projected_score: 77,
    games: 8,
    status: "Available"
  });

  // FORWARDS
  updatePlayer(teamData.forwards, "Christian Petracca", {
    price: 919000,
    team: "Demons",
    position: "FWD",
    breakEven: 77,
    last3_avg: 112,
    last5_avg: 103,
    avg: 98,
    averagePoints: 98,
    projScore: 92,
    projected_score: 92,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.forwards, "Caleb Daniel", {
    price: 852000,
    team: "Bulldogs",
    position: "FWD",
    breakEven: 99,
    last3_avg: 77,
    last5_avg: 84,
    avg: 92,
    averagePoints: 92,
    projScore: 85,
    projected_score: 85,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.forwards, "Jack Macrae", {
    price: 901000,
    team: "Bulldogs",
    position: "FWD",
    breakEven: 114,
    last3_avg: 106,
    last5_avg: 92,
    avg: 104,
    averagePoints: 104,
    projScore: 93,
    projected_score: 93,
    games: 8,
    status: "Available"
  });

  updatePlayer(teamData.forwards, "Bailey Smith", {
    price: 972000,
    team: "Bulldogs",
    position: "FWD",
    breakEven: 79,
    last3_avg: 112,
    last5_avg: 113,
    avg: 115,
    averagePoints: 115,
    projScore: 100,
    projected_score: 100,
    games: 7,
    status: "Available"
  });

  // BENCH - DEFENDERS
  updatePlayer(teamData.bench.defenders, "Finn O'Sullivan", {
    price: 397000,
    team: "Kangaroos",
    position: "DEF",
    breakEven: 45,
    last3_avg: 37,
    last5_avg: 44,
    avg: 43,
    averagePoints: 43,
    projScore: 39,
    projected_score: 39,
    games: 7,
    status: "Available"
  });

  updatePlayer(teamData.bench.defenders, "Connor Stone", {
    price: 441000,
    team: "Giants",
    position: "DEF",
    breakEven: 25,
    last3_avg: 57,
    last5_avg: 53,
    avg: 51,
    averagePoints: 51,
    projScore: 46,
    projected_score: 46,
    games: 7,
    status: "Available"
  });

  // BENCH - MIDFIELDERS
  updatePlayer(teamData.bench.midfielders, "Hugh Boxshall", {
    price: 230000,
    team: "Kangaroos",
    position: "MID",
    breakEven: 43,
    last3_avg: 74,
    last5_avg: 74,
    avg: 74,
    averagePoints: 74,
    projScore: 74,
    projected_score: 74,
    games: 1,
    status: "Available"
  });

  updatePlayer(teamData.bench.midfielders, "Isaac Kako", {
    price: 397000,
    team: "Kangaroos",
    position: "MID",
    breakEven: 29,
    last3_avg: 41,
    last5_avg: 42,
    avg: 44,
    averagePoints: 44,
    projScore: 45,
    projected_score: 45,
    games: 7,
    status: "Available"
  });

  // BENCH - RUCKS
  updatePlayer(teamData.bench.rucks, "Harry Boyd", {
    price: 268000,
    team: "Bulldogs",
    position: "RUC",
    breakEven: -4,
    last3_avg: 68,
    last5_avg: 68,
    avg: 68,
    averagePoints: 68,
    projScore: 57,
    projected_score: 57,
    games: 1,
    status: "Available"
  });

  // BENCH - FORWARDS
  updatePlayer(teamData.bench.forwards, "Caiden Cleary", {
    price: 457000,
    team: "Giants",
    position: "FWD",
    breakEven: 10,
    last3_avg: 66,
    last5_avg: 67,
    avg: 67,
    averagePoints: 67,
    projScore: 39,
    projected_score: 39,
    games: 4,
    status: "Available"
  });

  updatePlayer(teamData.bench.forwards, "Campbell Gray", {
    price: 236000,
    team: "Hawks",
    position: "FWD",
    breakEven: 21,
    last3_avg: 30,
    last5_avg: 30,
    avg: 30,
    averagePoints: 30,
    projScore: 37,
    projected_score: 37,
    games: 1,
    status: "Available"
  });

  // BENCH - UTILITY
  updatePlayer(teamData.bench.utility, "James Leake", {
    price: 246000,
    team: "Swans",
    position: "DEF",
    breakEven: 24,
    last3_avg: 28,
    last5_avg: 28,
    avg: 28,
    averagePoints: 28,
    projScore: 33,
    projected_score: 33,
    games: 2,
    status: "Available"
  });

  // Update the player data in the main data file too
  updatePlayersInMainDataFile();

  return teamData;
}

function updatePlayer(positionList, playerName, newData) {
  if (!positionList) {
    console.log(`Position list is undefined for player ${playerName}`);
    return;
  }
  
  const playerIndex = positionList.findIndex(player => player.name === playerName);
  
  if (playerIndex !== -1) {
    // Merge new data with existing player data
    positionList[playerIndex] = { 
      ...positionList[playerIndex], 
      ...newData,
      // Ensure these critical fields are set correctly
      breakeven: newData.breakEven,
      broke: newData.breakEven,
      breakEven: newData.breakEven,
      team: newData.team,
      price: newData.price
    };
    console.log(`Updated ${playerName} with accurate data`);
  } else {
    console.log(`Player ${playerName} not found in this position group`);
  }
}

// Also update the main player_data.json file to ensure consistency
function updatePlayersInMainDataFile() {
  try {
    const filePath = './player_data.json';
    if (!fs.existsSync(filePath)) {
      console.log('player_data.json file not found, skipping main data update');
      return;
    }
    
    const playerData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    const updatedPlayerData = [...playerData];
    
    // Define player updates based on screenshot data
    const playerUpdates = [
      {
        name: "Harry Sheezel",
        price: 1038000,
        breakeven: 127,
        breakEven: 127,
        avg: 106,
        last3_avg: 107,
        last5_avg: 107,
        games: 8
      },
      {
        name: "Tom De Koning",
        price: 940000,
        breakeven: 115,
        breakEven: 115,
        avg: 96,
        last3_avg: 81,
        last5_avg: 80,
        games: 8
      },
      {
        name: "Tristan Xerri",
        price: 974000,
        breakeven: 90,
        breakEven: 90,
        avg: 101,
        last3_avg: 120,
        last5_avg: 102,
        games: 8
      },
      {
        name: "Hugh Boxshall",
        price: 230000,
        breakeven: 43,
        breakEven: 43,
        avg: 74,
        last3_avg: 74,
        last5_avg: 74,
        games: 1
      },
      {
        name: "Campbell Gray",
        price: 236000,
        breakeven: 21,
        breakEven: 21,
        avg: 30,
        last3_avg: 30,
        last5_avg: 30,
        games: 1
      },
      {
        name: "Finn O'Sullivan",
        price: 397000,
        breakeven: 45,
        breakEven: 45,
        avg: 43,
        last3_avg: 37,
        last5_avg: 44,
        games: 7
      },
      {
        name: "Christian Petracca",
        price: 919000,
        breakeven: 77,
        breakEven: 77,
        avg: 98,
        last3_avg: 112,
        last5_avg: 103,
        games: 8
      },
      {
        name: "Caleb Daniel",
        price: 852000,
        breakeven: 99,
        breakEven: 99,
        avg: 92,
        last3_avg: 77,
        last5_avg: 84,
        games: 8
      },
      {
        name: "Bailey Smith",
        price: 972000,
        breakeven: 79,
        breakEven: 79,
        avg: 115,
        last3_avg: 112,
        last5_avg: 113,
        games: 7
      }
    ];
    
    // Update each player in the main data file
    for (const update of playerUpdates) {
      const index = updatedPlayerData.findIndex(player => 
        player.name && player.name.toLowerCase() === update.name.toLowerCase());
      
      if (index !== -1) {
        updatedPlayerData[index] = {
          ...updatedPlayerData[index],
          ...update
        };
        console.log(`Updated ${update.name} in main player data file`);
      } else {
        console.log(`Player ${update.name} not found in main player data file`);
      }
    }
    
    // Save updated player data back to file
    fs.writeFileSync(filePath, JSON.stringify(updatedPlayerData, null, 2));
    console.log(`Updated ${playerUpdates.length} players in main player data file`);
    
  } catch (error) {
    console.error('Error updating main player data file:', error);
  }
}

async function updateAllPlayers() {
  try {
    console.log('Starting exact player data update...');
    const teamData = loadTeamData();
    const updatedTeamData = updateTeamWithExactData(teamData);
    saveTeamData(updatedTeamData);
    console.log('Exact player data update completed successfully');
    
    console.log('\nThe player data has been updated with exact values from the AFL Fantasy app. Please refresh the lineup tab to see the updated data.');
  } catch (error) {
    console.error('Error during exact player data update:', error);
  }
}

// Run the update
updateAllPlayers();