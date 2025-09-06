/**
 * Create Authentic Team Data with User's Actual Players
 * Uses real AFL Fantasy data where available and reasonable estimates for missing players
 */

const fs = require('fs');

function loadPlayerData() {
  try {
    const data = fs.readFileSync('./player_data.json', 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error('Error loading player data:', error);
    return [];
  }
}

function findPlayer(playerName, allPlayers) {
  return allPlayers.find(p => 
    p.name && playerName && 
    (p.name.toLowerCase() === playerName.toLowerCase() ||
     p.name.toLowerCase().includes(playerName.toLowerCase()) ||
     playerName.toLowerCase().includes(p.name.toLowerCase()))
  );
}

function createPlayerObject(playerName, position, allPlayers, estimatedPrice = null) {
  const playerData = findPlayer(playerName, allPlayers);
  
  const basePlayer = {
    name: playerName,
    position: position,
    price: estimatedPrice || 0,
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
      price: playerData.price || estimatedPrice || 0,
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

  // Use estimated price for missing players
  if (estimatedPrice) {
    console.log(`Using estimated price for ${playerName}: $${(estimatedPrice/1000).toFixed(0)}k`);
    return {
      ...basePlayer,
      price: estimatedPrice,
      avg: 85, // Reasonable estimate
      averagePoints: 85,
      projScore: 85,
      projected_score: 85,
      games: 7,
      breakEven: 90,
      breakeven: 90
    };
  }

  console.log(`Warning: No data or estimate for player: ${playerName}`);
  return basePlayer;
}

function createAuthenticTeam() {
  const allPlayers = loadPlayerData();
  
  // Your actual team with estimated prices for missing players
  const teamComposition = {
    defenders: [
      { name: "Harry Sheezel", estimate: null },
      { name: "Lachie Whitfield", estimate: 850000 }, // Premium defender
      { name: "Matt Roberts", estimate: null },
      { name: "Riley Bice", estimate: null },
      { name: "Jaxon Prior", estimate: null },
      { name: "Joe Fonti", estimate: 300000 } // Rookie defender
    ],
    midfielders: [
      { name: "Andrew Brayshaw", estimate: null },
      { name: "Jordan Dawson", estimate: null },
      { name: "Zach Merrett", estimate: null },
      { name: "Levi Ashcroft", estimate: null },
      { name: "Hugh Boxshall", estimate: null },
      { name: "Chad Warner", estimate: 750000 }, // Premium midfielder
      { name: "Max Holmes", estimate: 650000 } // Mid-tier midfielder
    ],
    rucks: [
      { name: "Harry Boyd", estimate: null },
      { name: "Rowan Marshall", estimate: 950000 } // Premium ruck
    ],
    forwards: [
      { name: "Izak Rankine", estimate: null },
      { name: "Christian Petracca", estimate: null },
      { name: "Campbell Gray", estimate: null },
      { name: "Bailey Smith", estimate: null },
      { name: "Nick Martin", estimate: 450000 }, // Mid-tier forward
      { name: "Xavier O'Halloran", estimate: 280000 } // Rookie forward
    ],
    bench: {
      defenders: [
        { name: "Angus Clarke", estimate: 180000 }, // Rookie
        { name: "James Leake", estimate: null }
      ],
      midfielders: [
        { name: "Finn O'Sullivan", estimate: null },
        { name: "Saad El-Hawll", estimate: 170000 } // Rookie
      ],
      rucks: [
        { name: "Tristan Xerri", estimate: null }
      ],
      forwards: [
        { name: "Isaac Kako", estimate: null },
        { name: "Jack Macrae", estimate: null }
      ],
      utility: [
        { name: "Connor Rozee", estimate: null }
      ]
    }
  };

  // Build team data
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
    teamComposition[position].forEach(playerInfo => {
      const player = createPlayerObject(
        playerInfo.name, 
        position.slice(0, -1).toUpperCase(), 
        allPlayers,
        playerInfo.estimate
      );
      if (position === 'rucks') player.position = 'RUC';
      teamData[position].push(player);
    });
  });

  // Add bench players
  Object.keys(teamComposition.bench).forEach(position => {
    teamComposition.bench[position].forEach(playerInfo => {
      const player = createPlayerObject(
        playerInfo.name,
        position.slice(0, -1).toUpperCase(),
        allPlayers,
        playerInfo.estimate
      );
      player.isOnBench = true;
      if (position === 'rucks') player.position = 'RUC';
      if (position === 'utility') player.position = 'UTIL';
      teamData.bench[position].push(player);
    });
  });

  // Save updated team data
  try {
    fs.writeFileSync('./user_team.json', JSON.stringify(teamData, null, 2));
    console.log('✓ Updated team with authentic player composition');
    
    // Calculate total team value
    let totalValue = 0;
    let playerCount = 0;
    
    // Count on-field players
    ['defenders', 'midfielders', 'rucks', 'forwards'].forEach(position => {
      teamData[position].forEach(player => {
        totalValue += player.price;
        playerCount++;
        console.log(`${player.name} (${position}): $${(player.price/1000).toFixed(0)}k`);
      });
    });
    
    // Count bench players
    Object.keys(teamData.bench).forEach(position => {
      teamData.bench[position].forEach(player => {
        totalValue += player.price;
        playerCount++;
        console.log(`${player.name} (bench ${position}): $${(player.price/1000).toFixed(0)}k`);
      });
    });
    
    const remainingSalary = 16000;
    totalValue += remainingSalary;
    
    console.log(`\n✓ Team Summary:`);
    console.log(`  Players: ${playerCount}/26`);
    console.log(`  Total value: $${(totalValue/1000000).toFixed(1)}M`);
    console.log(`  Remaining salary: $${(remainingSalary/1000).toFixed(0)}k`);
    
    return true;
  } catch (error) {
    console.error('Error saving team data:', error);
    return false;
  }
}

// Run the update
createAuthenticTeam();