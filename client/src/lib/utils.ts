import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function formatCurrency(value: number): string {
  // Format currency without brackets and plus signs, showing whole dollars
  // Handle values over $999,999 as "1.0M" instead of "1000K"
  if (value >= 1000000) {
    return `$${(value / 1000000).toFixed(1)}M`;
  } else if (value >= 999999) {
    return `$${(value / 1000000).toFixed(1)}M`;
  } else if (value >= 1000) {
    return `$${(value / 1000).toFixed(0)}K`;
  } else {
    return `$${value}`;
  }
}

export function formatScore(value: number | null | undefined): string {
  if (value === undefined || value === null) return "-";
  return value.toString();
}

export function getPositionColor(position: string): string {
  switch (position) {
    case "MID":
      return "text-blue-500";
    case "FWD":
      return "text-green-500";
    case "DEF":
      return "text-red-500";
    case "RUCK":
      return "text-purple-500";
    default:
      return "text-gray-500";
  }
}

export function getCategoryColor(category: string): string {
  switch (category) {
    case "Premium":
      return "text-accent";
    case "Mid-Pricer":
      return "text-yellow-500";
    case "Rookie":
      return "text-blue-500";
    default:
      return "text-gray-500";
  }
}

export const playerCategories = ["Premium", "Mid-Pricer", "Rookie"];
export const playerPositions = ["MID", "FWD", "DEF", "RUCK"];

export type PlayerPosition = "MID" | "FWD" | "DEF" | "RUCK";
export type PlayerCategory = "Premium" | "Mid-Pricer" | "Rookie";

// Calculate total team value from all player prices in the lineup
export function calculateTeamValue(teamData: any): number {
  if (!teamData) return 0;
  
  let totalValue = 0;
  
  // Add up prices from all 18 on-field AFL Fantasy players
  ['defenders', 'midfielders', 'rucks', 'forwards'].forEach(position => {
    if (Array.isArray(teamData[position])) {
      teamData[position].forEach((player: any) => {
        if (player && typeof player.price === 'number') {
          totalValue += player.price;
        }
      });
    }
  });
  
  // Add all 8 bench players
  if (teamData.bench) {
    ['defenders', 'midfielders', 'rucks', 'forwards', 'utility'].forEach(position => {
      if (Array.isArray(teamData.bench[position])) {
        teamData.bench[position].forEach((player: any) => {
          if (player && typeof player.price === 'number') {
            totalValue += player.price;
          }
        });
      }
    });
  }
  
  // Add remaining salary cap money ($16K from screenshot)
  const remainingSalary = 16000;
  totalValue += remainingSalary;
  
  return totalValue;
}

// Categorize players by price brackets
export function categorizePlayersByPrice(teamData: any) {
  if (!teamData) return { premium: 0, midPricer: 0, rookie: 0 };
  
  const premiumThreshold = 900000;
  const midPricerThreshold = 450000;
  const rookieMinimum = 230000;
  
  let premium = 0;
  let midPricer = 0;
  let rookie = 0;
  
  // Count players in each price bracket from starting lineup
  ['defenders', 'midfielders', 'rucks', 'forwards'].forEach(position => {
    if (Array.isArray(teamData[position])) {
      teamData[position].forEach((player: any) => {
        if (player && typeof player.price === 'number') {
          if (player.price >= premiumThreshold) {
            premium++;
          } else if (player.price >= midPricerThreshold) {
            midPricer++;
          } else if (player.price >= rookieMinimum) {
            rookie++;
          }
        }
      });
    }
  });
  
  return { premium, midPricer, rookie };
}

// Calculate player types by position for the team structure graph
export function calculatePlayerTypesByPosition(teamData: any) {
  if (!teamData) return {
    midfield: { premium: 0, midPricer: 0, rookie: 0 },
    forward: { premium: 0, midPricer: 0, rookie: 0 },
    defense: { premium: 0, midPricer: 0, rookie: 0 },
    ruck: { premium: 0, midPricer: 0, rookie: 0 }
  };
  
  const premiumThreshold = 900000;
  const midPricerThreshold = 450000;
  const rookieMinimum = 230000;
  
  const result = {
    midfield: { premium: 0, midPricer: 0, rookie: 0 },
    forward: { premium: 0, midPricer: 0, rookie: 0 },
    defense: { premium: 0, midPricer: 0, rookie: 0 },
    ruck: { premium: 0, midPricer: 0, rookie: 0 }
  };
  
  // Map position names to result property names
  const positionMap = {
    'midfielders': 'midfield',
    'forwards': 'forward',
    'defenders': 'defense',
    'rucks': 'ruck'
  };
  
  // Count players in each position and price bracket from starting lineup
  Object.keys(positionMap).forEach(position => {
    const resultKey = positionMap[position as keyof typeof positionMap];
    
    if (Array.isArray(teamData[position])) {
      teamData[position].forEach((player: any) => {
        if (player && typeof player.price === 'number') {
          if (player.price >= premiumThreshold) {
            result[resultKey as keyof typeof result].premium++;
          } else if (player.price >= midPricerThreshold) {
            result[resultKey as keyof typeof result].midPricer++;
          } else if (player.price >= rookieMinimum) {
            result[resultKey as keyof typeof result].rookie++;
          }
        }
      });
    }
  });
  
  return result;
}

// Calculate live team score with captain points doubled
export function calculateLiveTeamScore(teamData: any): number {
  if (!teamData) return 0;
  
  let totalScore = 0;
  let captainScore = 0;
  
  // Find the captain and calculate total score from all positions
  ['defenders', 'midfielders', 'rucks', 'forwards'].forEach(position => {
    if (Array.isArray(teamData[position])) {
      teamData[position].forEach((player: any) => {
        if (player && typeof player.liveScore === 'number') {
          if (player.isCaptain) {
            captainScore = player.liveScore;
          } else {
            totalScore += player.liveScore;
          }
        }
      });
    }
  });
  
  // Add doubled captain score
  totalScore += captainScore * 2;
  
  return totalScore;
}
