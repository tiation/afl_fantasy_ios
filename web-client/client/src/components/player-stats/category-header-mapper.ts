// Map from category ID to display title
export const categoryTitleMap: Record<string, string> = {
  "rd-key-stats": "RD 8 KEY STATS",
  "projections": "PROJECTIONS",
  "break-evens": "BREAK EVENS",
  "cash-cows": "CASH COWS",
  "coaches-choice": "COACHES' CHOICE",
  "teams-venues": "TEAMS & VENUES",
  "consistency-ratings": "CONSISTENCY RATINGS",
  "injury-report": "INJURY REPORT",
  "notes-alerts": "NOTES & ALERTS"
};

// Define column configurations for each category with abbreviations
export type ColumnDef = {
  label: string;
  key: string;
  span?: number;
  abbr?: string; // Abbreviated header for mobile
};

// Category configurations
export const categoryConfigs: Record<string, ColumnDef[]> = {
  "rd-key-stats": [
    { label: "Proj. Rd 8 Score", key: "projectedScore", span: 2, abbr: "Proj. R8" },
    { label: "BE", key: "breakeven", abbr: "BE" },
    { label: "Proj. Rd 8 Price Chg.", key: "projectedPriceChange", abbr: "Proj. $ Ch." },
    { label: "Avg. Against Rd 8 Opp.", key: "avgVsOpponent", abbr: "Avg. vs Opp." },
    { label: "Avg. At Rd 8 Venue", key: "avgAtVenue", abbr: "Avg. at Venue" },
    { label: "Most Popular Capt. Rd %", key: "captainPercentage", abbr: "Capt. %" },
    { label: "Own %", key: "ownershipPercentage", abbr: "Own %" },
    { label: "Cons. Rating", key: "consistencyRating", abbr: "Cons." }
  ],
  "projections": [
    { label: "Proj. Rd 8 Score", key: "projectedScore", abbr: "Proj. R8" },
    { label: "Proj. Rd 9 Score", key: "projectedR9Score", abbr: "Proj. R9" },
    { label: "Proj. Rd 10 Score", key: "projectedR10Score", abbr: "Proj. R10" },
    { label: "Proj. 3 Rd Avg.", key: "projected3RoundAvg", abbr: "Proj. 3R Avg" },
    { label: "Avg. (3/5 Rd)", key: "lastThreeAvg", abbr: "Avg. 3/5R" },
    { label: "BE", key: "breakeven", abbr: "BE" },
    { label: "Played", key: "roundsPlayed", abbr: "GP" },
    { label: "Points", key: "totalPoints", abbr: "Pts" }
  ],
  "break-evens": [
    { label: "Played", key: "roundsPlayed", abbr: "GP" },
    { label: "BE", key: "breakeven", abbr: "BE" },
    { label: "Proj. Rd 8 BE", key: "projectedR8BE", abbr: "Proj. R8 BE" },
    { label: "Proj. Rd 9 BE %", key: "projectedR9BEPercent", abbr: "Proj. R9 BE%" },
    { label: "Proj. Rd 9 BE", key: "projectedR9BE", abbr: "Proj. R9 BE" },
    { label: "Proj. Rd 10 BE %", key: "projectedR10BEPercent", abbr: "Proj. R10 BE%" },
    { label: "Proj. Rd 10 BE", key: "projectedR10BE", abbr: "Proj. R10 BE" }
  ],
  "cash-cows": [
    { label: "Played", key: "roundsPlayed", abbr: "GP" },
    { label: "BE", key: "breakeven", abbr: "BE" },
    { label: "Proj. Rd 8 Price Chg.", key: "projectedR8PriceChange", abbr: "Proj. R8 $ Ch." },
    { label: "Proj. Rd 9 Price Chg.", key: "projectedR9PriceChange", abbr: "Proj. R9 $ Ch." },
    { label: "Proj. Rd 10 Price Chg.", key: "projectedR10PriceChange", abbr: "Proj. R10 $ Ch." },
    { label: "Proj. Season Price Chg.", key: "projectedSeasonPriceChange", abbr: "Proj. Season $ Ch." },
    { label: "Last/Total /Avg.", key: "lastScore", abbr: "Last/Avg." }
  ],
  "coaches-choice": [
    { label: "Played", key: "roundsPlayed", abbr: "GP" },
    { label: "Cons. Rating", key: "consistencyRating", abbr: "Cons." },
    { label: "Score Range", key: "scoreRange", abbr: "Range" },
    { label: "Last/Total /Avg.", key: "lastScore", abbr: "Last/Avg." },
    { label: "BE", key: "breakeven", abbr: "BE" }
  ],
  "teams-venues": [
    { label: "Avg. Against Rd 8 Opp.", key: "avgVsCurrentOpponent", abbr: "Avg. vs R8 Opp." },
    { label: "Avg. At Rd 8 Venue", key: "avgAtCurrentVenue", abbr: "Avg. at R8 Venue" },
    { label: "Avg. At Rd 9 Venue", key: "avgAtR9Venue", abbr: "Avg. at R9 Venue" },
    { label: "Avg. At Rd 10 Venue", key: "avgAtR10Venue", abbr: "Avg. at R10 Venue" }
  ],
  "consistency-ratings": [
    { label: "Played", key: "roundsPlayed", abbr: "GP" },
    { label: "Cons. Rating", key: "consistencyRating", abbr: "Cons." },
    { label: "Score Range", key: "scoreRange", abbr: "Range" },
    { label: "Last/Total /Avg.", key: "lastScore", abbr: "Last/Avg." },
    { label: "BE", key: "breakeven", abbr: "BE" },
    { label: "Proj. Rd 8 Score", key: "projectedScore", abbr: "Proj. R8" },
    { label: "3 Rd Avg.", key: "lastThreeAvg", abbr: "3R Avg." },
    { label: "5 Rd Avg.", key: "lastFiveAvg", abbr: "5R Avg." }
  ],
  "injury-report": [
    { label: "Expected Return", key: "expectedReturn", span: 3, abbr: "Exp. Return" }
  ],
  "notes-alerts": [
    { label: "Latest Player Note/Alert", key: "playerNotes", span: 3, abbr: "Notes/Alerts" }
  ]
};

// Mapping for stats key explanations
export type StatsKeyMapping = Record<string, Record<string, string>>;

export const statsKeyExplanations: StatsKeyMapping = {
  "rd-key-stats": {
    "BE": "Break Even - score needed to maintain price",
    "Proj. R8": "Projected score for Round 8",
    "Proj. $ Ch.": "Projected price change after Round 8",
    "Avg. vs Opp.": "Player's average score against Round 8 opponent",
    "Avg. at Venue": "Player's average score at Round 8 venue",
    "Capt. %": "Percentage of teams that captain this player",
    "Own %": "Selection percentage across all teams",
    "Cons.": "Consistency rating (higher is more consistent)",
    "CBA%": "Center Bounce Attendance percentage",
    "KI": "Kick-ins taken after opposition behinds"
  },
  "projections": {
    "Proj. R8": "Projected score for Round 8",
    "Proj. R9": "Projected score for Round 9",
    "Proj. R10": "Projected score for Round 10",
    "Proj. 3R Avg": "Average of projected scores for next 3 rounds",
    "Avg. 3/5R": "Average from last 3 or 5 rounds",
    "BE": "Break Even - score needed to maintain price",
    "GP": "Games played this season",
    "Pts": "Total points scored this season"
  },
  "break-evens": {
    "GP": "Games played this season",
    "BE": "Break Even - score needed to maintain price",
    "Proj. R8 BE": "Projected break even for Round 8",
    "Proj. R9 BE%": "Projected break even as percentage of average for Round 9",
    "Proj. R9 BE": "Projected break even for Round 9",
    "Proj. R10 BE%": "Projected break even as percentage of average for Round 10",
    "Proj. R10 BE": "Projected break even for Round 10"
  },
  "cash-cows": {
    "GP": "Games played this season",
    "BE": "Break Even - score needed to maintain price",
    "Proj. R8 $ Ch.": "Projected price change after Round 8",
    "Proj. R9 $ Ch.": "Projected price change after Round 9",
    "Proj. R10 $ Ch.": "Projected price change after Round 10",
    "Proj. Season $ Ch.": "Projected total price change for the season",
    "Last/Avg.": "Last score and season average"
  },
  "coaches-choice": {
    "GP": "Games played this season",
    "Cons.": "Consistency rating (higher is more consistent)",
    "Range": "Range between lowest and highest scores",
    "Last/Avg.": "Last score and season average",
    "BE": "Break Even - score needed to maintain price"
  },
  "teams-venues": {
    "Avg. vs R8 Opp.": "Player's average score against Round 8 opponent",
    "Avg. at R8 Venue": "Player's average score at Round 8 venue",
    "Avg. at R9 Venue": "Player's average score at Round 9 venue",
    "Avg. at R10 Venue": "Player's average score at Round 10 venue"
  },
  "consistency-ratings": {
    "GP": "Games played this season",
    "Cons.": "Consistency rating (higher is more consistent)",
    "Range": "Range between lowest and highest scores",
    "Last/Avg.": "Last score and season average",
    "BE": "Break Even - score needed to maintain price",
    "Proj. R8": "Projected score for Round 8",
    "3R Avg.": "Average from last 3 rounds",
    "5R Avg.": "Average from last 5 rounds"
  },
  "injury-report": {
    "Exp. Return": "Expected return date from injury"
  },
  "notes-alerts": {
    "Notes/Alerts": "Latest player notes and alerts"
  }
};