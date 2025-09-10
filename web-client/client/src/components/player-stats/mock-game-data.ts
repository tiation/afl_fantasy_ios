// Mock game data for testing the score breakdown module
export interface GameData {
  round: number;
  opponent: string;
  venue: string;
  homeAway: 'home' | 'away';
  score: number;
  season: string;
  date: string;
}

// Generate realistic AFL Fantasy scores for a player
export const generateMockGameData = (playerName: string): GameData[] => {
  const teams = [
    'Adelaide', 'Brisbane', 'Carlton', 'Collingwood', 'Essendon', 'Fremantle',
    'Geelong', 'Gold Coast', 'GWS', 'Hawthorn', 'Melbourne', 'North Melbourne',
    'Port Adelaide', 'Richmond', 'St Kilda', 'Sydney', 'West Coast', 'Western Bulldogs'
  ];

  const venues = [
    'MCG', 'Marvel Stadium', 'Adelaide Oval', 'Gabba', 'Optus Stadium', 'SCG',
    'ANZ Stadium', 'GMHBA Stadium', 'Metricon Stadium', 'York Park', 'TIO Stadium'
  ];

  const games: GameData[] = [];

  // Generate 2023 season (22 rounds)
  for (let round = 1; round <= 22; round++) {
    const opponent = teams[Math.floor(Math.random() * teams.length)];
    const venue = venues[Math.floor(Math.random() * venues.length)];
    const homeAway = Math.random() > 0.5 ? 'home' : 'away';
    
    // Generate realistic AFL Fantasy scores (usually 50-130, with occasional higher scores)
    let baseScore = 65 + Math.random() * 45; // Base range 65-110
    
    // Add some variance based on position and form
    if (Math.random() < 0.15) { // 15% chance of really good game
      baseScore += 20 + Math.random() * 20;
    }
    if (Math.random() < 0.10) { // 10% chance of poor game
      baseScore -= 20 + Math.random() * 15;
    }
    
    // Ensure minimum score of 30
    const score = Math.max(30, Math.round(baseScore));

    games.push({
      round,
      opponent,
      venue,
      homeAway,
      score,
      season: '2023',
      date: `2023-${String(Math.floor(round / 4) + 3).padStart(2, '0')}-${String((round % 4 + 1) * 7).padStart(2, '0')}`
    });
  }

  // Generate 2024 season (22 rounds)
  for (let round = 1; round <= 22; round++) {
    const opponent = teams[Math.floor(Math.random() * teams.length)];
    const venue = venues[Math.floor(Math.random() * venues.length)];
    const homeAway = Math.random() > 0.5 ? 'home' : 'away';
    
    let baseScore = 70 + Math.random() * 40; // Slightly improved base range
    
    if (Math.random() < 0.18) { // Slightly more good games
      baseScore += 25 + Math.random() * 20;
    }
    if (Math.random() < 0.08) { // Fewer poor games (improvement)
      baseScore -= 15 + Math.random() * 15;
    }
    
    const score = Math.max(35, Math.round(baseScore));

    games.push({
      round,
      opponent,
      venue,
      homeAway,
      score,
      season: '2024',
      date: `2024-${String(Math.floor(round / 4) + 3).padStart(2, '0')}-${String((round % 4 + 1) * 7).padStart(2, '0')}`
    });
  }

  // Generate 2025 season (current - 8 rounds so far)
  for (let round = 1; round <= 8; round++) {
    const opponent = teams[Math.floor(Math.random() * teams.length)];
    const venue = venues[Math.floor(Math.random() * venues.length)];
    const homeAway = Math.random() > 0.5 ? 'home' : 'away';
    
    let baseScore = 75 + Math.random() * 35; // Current form
    
    if (Math.random() < 0.20) { // In good form
      baseScore += 30 + Math.random() * 25;
    }
    if (Math.random() < 0.05) { // Very few poor games this year
      baseScore -= 20 + Math.random() * 10;
    }
    
    const score = Math.max(40, Math.round(baseScore));

    games.push({
      round,
      opponent,
      venue,
      homeAway,
      score,
      season: '2025',
      date: `2025-${String(Math.floor(round / 4) + 3).padStart(2, '0')}-${String((round % 4 + 1) * 7).padStart(2, '0')}`
    });
  }

  return games.sort((a, b) => {
    // Sort by season then by round
    if (a.season !== b.season) {
      return a.season.localeCompare(b.season);
    }
    return a.round - b.round;
  });
};

// Pre-generated data for common players
export const mockPlayerGameData: Record<string, GameData[]> = {
  "Marcus Bontempelli": generateMockGameData("Marcus Bontempelli"),
  "Lachie Neale": generateMockGameData("Lachie Neale"),
  "Clayton Oliver": generateMockGameData("Clayton Oliver"),
  "Andrew Brayshaw": generateMockGameData("Andrew Brayshaw"),
  "Zach Merrett": generateMockGameData("Zach Merrett"),
  "Christian Petracca": generateMockGameData("Christian Petracca"),
  "Jordan Dawson": generateMockGameData("Jordan Dawson"),
  "Max Gawn": generateMockGameData("Max Gawn"),
  "Harry Sheezel": generateMockGameData("Harry Sheezel"),
  "Nick Daicos": generateMockGameData("Nick Daicos")
};

// Helper function to get game data for any player
export const getPlayerGameData = (playerName: string): GameData[] => {
  if (mockPlayerGameData[playerName]) {
    return mockPlayerGameData[playerName];
  }
  
  // Generate new data for unknown players
  return generateMockGameData(playerName);
};