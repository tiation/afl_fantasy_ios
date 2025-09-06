/**
 * Update team with correct AFL Fantasy players
 * Based on user's actual team composition provided
 */

const fs = require('fs');

// Load current player data for price matching
function loadPlayerData() {
  try {
    const data = fs.readFileSync('./player_data.json', 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error loading player data:', error);
    return [];
  }
}

// Find player by name in AFL Fantasy data
function findPlayer(playerName, allPlayers) {
  return allPlayers.find(p => 
    p.name && playerName && 
    (p.name.toLowerCase() === playerName.toLowerCase() ||
     p.name.toLowerCase().includes(playerName.toLowerCase()) ||
     playerName.toLowerCase().includes(p.name.toLowerCase()))
  );
}

// Create player object with current AFL Fantasy data
function createPlayerObject(playerName, position, allPlayers) {
  const playerData = findPlayer(playerName, allPlayers);
  
  const basePlayer = {
    name: playerName,
    position: position,
    price: 0,
    breakEven: 0,
    breakeven: 0,
    last3_avg: 0,
    last5_avg: 0,
    avg: 0,
    averagePoints: 0,
    projScore: 0,
    projected_score: 0,
    games: 0,
    status: "Available",
    team: "",
    isOnBench: false
  };

  if (playerData) {
    return {
      ...basePlayer,
      price: playerData.price || 0,
      team: playerData.team || "",
      breakEven: playerData.breakeven || 0,
      breakeven: playerData.breakeven || 0,
      last3_avg: playerData.last3_avg || 0,
      last5_avg: playerData.last5_avg || 0,
      avg: parseFloat(playerData.avg) || 0,
      averagePoints: parseFloat(playerData.avg) || 0,
      projScore: playerData.projected_score || 0,
      projected_score: playerData.projected_score || 0,
      games: playerData.games || 0,
      status: playerData.status || "Available"
    };
  }

  console.log(`Warning: Could not find data for player: ${playerName}`);
  return basePlayer;
}

function updateTeamWithCorrectPlayers() {
  const allPlayers = loadPlayerData();
  
  // Your actual team composition
  const correctTeam = {
    defenders: [
      "Harry Sheezel",
      "Lachie Whitfield", 
      "Matt Roberts",
      "Riley Bice",
      "Jaxon Prior",
      "Joe Fonti"
    ],
    midfielders: [
      "Andrew Brayshaw",
      "Jordan Dawson",
      "Zach Merrett",
      "Levi Ashcroft",
      "Hugh Boxshall",
      "Chad Warner",
      "Max Holmes"
    ],
    rucks: [
      "Harry Boyd",
      "Rowan Marshall"
    ],
    forwards: [
      "Izak Rankine",
      "Christian Petracca",
      "Campbell Gray",
      "Bailey Smith",
      "Nick Martin",
      "Xavier O'Halloran"
    ],
    bench: {
      defenders: [
        "Angus Clarke",
        "James Leake"
      ],
      midfielders: [
        "Finn O'Sullivan",
        "Saad El-Hawll"
      ],
      rucks: [
        "Tristan Xerri"
      ],
      forwards: [
        "Isaac Kako",
        "Jack Macrae"
      ],
      utility: [
        "Connor Rozee"
      ]
    }
  };

  // Build team data with current AFL Fantasy prices
  const teamData = {
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

  // Add on-field players
  ['defenders', 'midfielders', 'rucks', 'forwards'].forEach(position => {
    correctTeam[position].forEach(playerName => {
      const player = createPlayerObject(playerName, position.slice(0, -1).toUpperCase(), allPlayers);
      if (position === 'rucks') player.position = 'RUC';
      teamData[position].push(player);
    });
  });

  // Add bench players
  Object.keys(correctTeam.bench).forEach(position => {
    correctTeam.bench[position].forEach(playerName => {
      const player = createPlayerObject(playerName, position.slice(0, -1).toUpperCase(), allPlayers);
      player.isOnBench = true;
      if (position === 'rucks') player.position = 'RUC';
      if (position === 'utility') player.position = 'UTIL';
      teamData.bench[position].push(player);
    });
  });

  // Save updated team data
  try {
    fs.writeFileSync('./user_team.json', JSON.stringify(teamData, null, 2));
    console.log('Team data updated successfully with correct players and current AFL Fantasy prices');
    
    // Calculate and display total team value
    let totalValue = 0;
    
    // Count players and add their values
    ['defenders', 'midfielders', 'rucks', 'forwards'].forEach(position => {
      teamData[position].forEach(player => {
        totalValue += player.price;
        console.log(`${player.name} (${position}): $${(player.price/1000).toFixed(0)}k`);
      });
    });
    
    Object.keys(teamData.bench).forEach(position => {
      teamData.bench[position].forEach(player => {
        totalValue += player.price;
        console.log(`${player.name} (bench ${position}): $${(player.price/1000).toFixed(0)}k`);
      });
    });
    
    // Add remaining salary cap
    const remainingSalary = 16000;
    totalValue += remainingSalary;
    
    console.log(`\nTotal team value: $${(totalValue/1000000).toFixed(3)}M`);
    console.log(`Remaining salary: $${(remainingSalary/1000).toFixed(0)}k`);
    
    return true;
  } catch (error) {
    console.error('Error saving team data:', error);
    return false;
  }
}

// Run the update
updateTeamWithCorrectPlayers();