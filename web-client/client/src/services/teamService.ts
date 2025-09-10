import { TeamPlayer } from "@/components/lineup/team-types";

/**
 * Fetch the user's team from the API
 */
export const fetchUserTeam = async (): Promise<any> => {
  try {
    const response = await fetch('/api/team/data');
    const result = await response.json();
    
    if (result.status !== 'ok') {
      throw new Error(result.message || 'Failed to fetch team data');
    }
    
    return result.data;
  } catch (error) {
    console.error('Error fetching user team:', error);
    throw error;
  }
};

/**
 * Convert the team data from the API to the format expected by the lineup components
 */
export const convertTeamDataToLineupFormat = (teamData: any): Record<string, TeamPlayer[]> => {
  if (!teamData || typeof teamData !== 'object') {
    return {
      midfielders: [],
      defenders: [],
      forwards: [],
      rucks: []
    };
  }
  
  const result: Record<string, TeamPlayer[]> = {
    midfielders: [],
    defenders: [],
    forwards: [],
    rucks: []
  };
  
  // Process each position
  for (const position of ['midfielders', 'defenders', 'forwards', 'rucks']) {
    // Add regular players
    if (Array.isArray(teamData[position])) {
      result[position] = teamData[position].map((player: any) => 
        transformPlayerData(player, false) // Main players are not on bench
      );
    }
    
    // Add bench players from new format (v2 API)
    if (teamData.bench && teamData.bench[position] && Array.isArray(teamData.bench[position])) {
      const benchPlayers = teamData.bench[position].map((player: any) => 
        transformPlayerData(player, true) // Explicitly mark as on bench
      );
      result[position] = [...result[position], ...benchPlayers];
    }
    
    // Also support older format for backward compatibility
    const benchKey = `bench_${position}`;
    if (teamData[benchKey] && Array.isArray(teamData[benchKey])) {
      const benchPlayers = teamData[benchKey].map((player: any) => 
        transformPlayerData(player, true)
      );
      result[position] = [...result[position], ...benchPlayers];
    }
  }
  
  // Handle the utility player if present (both formats)
  // New format (inside bench object)
  if (teamData.bench?.utility && Array.isArray(teamData.bench.utility) && teamData.bench.utility.length > 0) {
    for (const utilityPlayer of teamData.bench.utility) {
      const transformedPlayer = transformPlayerData(utilityPlayer, true);
      
      // Add to the appropriate position array based on the player's position
      const posMap: Record<string, string> = {
        'MID': 'midfielders',
        'DEF': 'defenders',
        'FWD': 'forwards',
        'RUCK': 'rucks'
      };
      
      const targetPosition = posMap[transformedPlayer.position] || 'midfielders';
      result[targetPosition].push(transformedPlayer);
    }
  }
  
  // Old format (direct utility property)
  if (teamData.utility && typeof teamData.utility === 'object') {
    const utilityPlayer = transformPlayerData(teamData.utility, true);
    
    // Add to the appropriate position array based on the player's position
    const posMap: Record<string, string> = {
      'MID': 'midfielders',
      'DEF': 'defenders',
      'FWD': 'forwards',
      'RUCK': 'rucks'
    };
    
    const targetPosition = posMap[utilityPlayer.position] || 'midfielders';
    result[targetPosition].push(utilityPlayer);
  }
  
  console.log("Converted team data:", result);
  return result;
};

/**
 * Transform a player object to the TeamPlayer format
 */
const transformPlayerData = (player: any, isOnBench: boolean = false): TeamPlayer => {
  // Convert source data fields to target schema
  const avgPoints = getFirstDefined(
    player.averagePoints,  // Original field
    player.avg,            // From FootyWire data
    player.last3_avg,      // Also from FootyWire data
    0                      // Default fallback
  );
  
  const breakEven = getFirstDefined(
    player.breakEven,      // Original field with camelCase
    player.breakeven,      // From FootyWire data (lowercase)
    Math.round(avgPoints * 0.9), // Estimate from average
    0                      // Default fallback
  );
  
  const projectedScore = getFirstDefined(
    player.projScore,      // Original field
    player.projected_score, // From FootyWire data
    Math.round(avgPoints + 5), // Estimate from average
    null                   // Default fallback
  );
  
  // Generate a deterministic ID based on the player name and position
  const generateStableId = (name: string, position: string) => {
    // Simple hash function to create a stable ID
    const str = `${name}:${position}`;
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return Math.abs(hash);
  };

  return {
    id: player.id || generateStableId(player.name || '', player.position || 'MID'),
    name: player.name || 'Unknown Player',
    position: player.position || 'MID',
    team: player.team || '',
    isCaptain: player.isCaptain || false,
    price: player.price || 0,
    breakEven: breakEven,
    lastScore: player.lastScore || null,
    averagePoints: avgPoints,
    liveScore: player.liveScore || null,
    isOnBench,
    projScore: projectedScore,
    nextOpponent: player.nextOpponent || '',
    l3Average: player.l3Average || player.last3_avg || avgPoints || null,
    roundsPlayed: player.roundsPlayed || player.games || 0,
    secondaryPositions: player.secondaryPositions || []
  };
};

/**
 * Utility function to get the first defined value from a list
 * Returns the first value that's not undefined or null
 */
function getFirstDefined<T>(...values: T[]): T | null {
  for (const value of values) {
    if (value !== undefined && value !== null) {
      return value;
    }
  }
  return null;
}

/**
 * Upload the team text to the API
 */
export const uploadTeam = async (teamText: string): Promise<any> => {
  try {
    const response = await fetch('/api/team/upload', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ teamText }),
    });
    
    const result = await response.json();
    
    if (!response.ok) {
      throw new Error(result.message || 'Failed to upload team');
    }
    
    return result.data;
  } catch (error) {
    console.error('Error uploading team:', error);
    throw error;
  }
};