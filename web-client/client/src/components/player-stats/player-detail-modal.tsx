import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogClose,
  DialogDescription 
} from "@/components/ui/dialog";
import { 
  Card, 
  CardContent, 
  CardHeader, 
  CardTitle 
} from "@/components/ui/card";
import { X, ChevronRight, Star, TrendingUp, TrendingDown, Minus, Loader2 } from "lucide-react";
import { Player } from "./player-types";
import { formatCurrency } from "@/lib/utils";
import { getTeamGuernsey, getTeamColors } from "@/lib/team-utils";
import { useState, useEffect } from "react";
import ScoreBreakdownModule from "./score-breakdown-module";
import { getPlayerGameData } from "./mock-game-data";
import { useQuery } from "@tanstack/react-query";

// Generate fixture difficulty helper functions
interface Fixture {
  round: string;
  opponent: string;
  difficulty: number;
  positionDifficulty?: {
    FWD: number;
    MID: number;
    DEF: number;
    RUCK: number;
  };
}

interface MatchupData {
  playerId: number;
  playerName: string;
  team: string;
  position: string;
  upcomingMatchups: Fixture[];
  teamDVPRating: {
    FWD: number;
    MID: number;
    DEF: number;
    RUCK: number;
  };
}

// Get difficulty color based on rating
const getDifficultyColor = (difficulty: number): string => {
  if (difficulty <= 3) return "#16a34a"; // Green for easy matchups
  if (difficulty <= 6) return "#f59e0b"; // Amber for medium difficulty
  if (difficulty <= 8) return "#ef4444"; // Red for hard matchups
  return "#991b1b"; // Dark red for very hard matchups
}

// Get difficulty color class based on rating
const getDifficultyColorClass = (difficulty: number): string => {
  if (difficulty <= 3) return "bg-green-600 text-white"; // Green for easy matchups
  if (difficulty <= 6) return "bg-amber-600 text-white"; // Amber for medium difficulty
  if (difficulty <= 8) return "bg-red-600 text-white"; // Red for hard matchups
  return "bg-red-800 text-white"; // Dark red for very hard matchups
}

// Get score color based on points
const getScoreColor = (score: number): string => {
  if (score <= 60) return "#ef4444"; // Red for low scores
  if (score <= 80) return "#f59e0b"; // Amber for medium scores
  if (score <= 100) return "#16a34a"; // Green for good scores
  return "#3b82f6"; // Blue for excellent scores
}

// Get position value based on position
const getPositionValue = (position: string): number => {
  switch (position) {
    case "MID": return 85;
    case "RUCK": return 78;
    case "DEF": return 72;
    case "FWD": return 68;
    default: return 75;
  }
}



// Get position value text
const getPositionValueText = (position: string): string => {
  switch (position) {
    case "MID": return "premium";
    case "RUCK": return "high value";
    case "DEF": return "solid";
    case "FWD": return "value";
    default: return "average";
  }
}

// Generate position vs opposition text
const getPositionVsOppositionText = (player: Player): string => {
  const positionMap: Record<string, string> = {
    "MID": "Midfielders have historically scored well against this team with an average of 95 points per game.",
    "RUCK": "Rucks tend to dominate against this opponent with hitout and clearance opportunities.",
    "DEF": "Defenders typically score above average against this team due to their high possession game.",
    "FWD": "Forwards have struggled to put up big scores against this defensive unit.",
  };
  
  return positionMap[player.position] || "This position has average scoring against the upcoming opponents.";
}

type PlayerDetailModalProps = {
  player: Player | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
};

export default function PlayerDetailModal({
  player,
  open,
  onOpenChange
}: PlayerDetailModalProps) {
  const [activeSection, setActiveSection] = useState<"performance" | "projections" | "news">("performance");
  
  // Helper function to get player's primary position for DVP analysis
  const getPlayerPrimaryPosition = (positions: string) => {
    if (!positions) return 'MID';
    const posArray = positions.split(/[,/]/).map(p => p.trim());
    // Priority: RUCK > MID > DEF > FWD (as per requirements)
    if (posArray.includes('RUCK') || posArray.includes('RUC')) return 'RUC';
    if (posArray.includes('MID')) return 'MID';
    if (posArray.includes('DEF')) return 'DEF';
    if (posArray.includes('FWD')) return 'FWD';
    return posArray[0] || 'MID';
  };
  
  // Get player's primary position and team for fixture data (with null checks)
  const selectedPlayerPrimaryPos = player ? getPlayerPrimaryPosition(player.position) : 'MID';
  const selectedPlayerTeam = player?.team;
  
  console.log(`Player: ${player?.name}, Team: ${selectedPlayerTeam}, Position: ${selectedPlayerPrimaryPos}`);
  
  // Fetch real matchup difficulty data using team and position with proper cache invalidation
  const { data: matchupData, isLoading: matchupLoading, refetch: refetchMatchupData } = useQuery({
    queryKey: [`/api/stats-tools/stats/team-fixtures/${selectedPlayerTeam}/${selectedPlayerPrimaryPos}`],
    enabled: !!player && !!selectedPlayerTeam && open,
    staleTime: 1000 * 60 * 2, // 2 minutes cache (shorter for fresh difficulty data)
    cacheTime: 1000 * 60 * 5, // 5 minutes in cache
    refetchOnWindowFocus: true, // Refetch when window regains focus
    refetchOnMount: true, // Always refetch on mount to ensure fresh data
  });
  
  console.log('Matchup data received:', matchupData);

  // Fetch projected scores for upcoming rounds with cache invalidation
  const { data: projectionData, isLoading: projectionLoading, refetch: refetchProjectionData } = useQuery({
    queryKey: [`/api/score-projection/player/${encodeURIComponent(player?.name || '')}`],
    queryFn: async () => {
      if (!player?.name) return null;
      const responses = await Promise.all([
        fetch(`/api/score-projection/player/${encodeURIComponent(player.name)}?round=20`).then(r => r.json()),
        fetch(`/api/score-projection/player/${encodeURIComponent(player.name)}?round=21`).then(r => r.json()),
        fetch(`/api/score-projection/player/${encodeURIComponent(player.name)}?round=22`).then(r => r.json()),
        fetch(`/api/score-projection/player/${encodeURIComponent(player.name)}?round=23`).then(r => r.json()),
        fetch(`/api/score-projection/player/${encodeURIComponent(player.name)}?round=24`).then(r => r.json())
      ]);
      return responses.map((resp, index) => ({
        round: 20 + index,
        projection: resp.success ? resp.data : null
      }));
    },
    enabled: !!player?.name && open,
    staleTime: 1000 * 60 * 5, // 5 minutes cache
    cacheTime: 1000 * 60 * 10, // 10 minutes in cache
    refetchOnWindowFocus: false, // Don't refetch projections on focus
    refetchOnMount: true, // Refetch on mount for fresh data
  });
  
  if (!player) return null;
  
  // Calculate performance metrics
  const lastScores = [
    player.last1, 
    player.last2, 
    player.last3
  ].filter(score => score !== undefined && score !== null) as number[];
  
  const avgLastGames = lastScores.length > 0 
    ? Math.round(lastScores.reduce((a, b) => a + b, 0) / lastScores.length * 10) / 10
    : player.averagePoints;
    
  // Format last 3 games with round numbers
  const lastGames = [
    { round: "R5", score: player.last1 || 0 },
    { round: "R4", score: player.last2 || 0 },
    { round: "R3", score: player.last3 || 0 },
  ];
  
  // Player status indicator
  const playerStatus = player.isInjured ? "injured" : player.isSuspended ? "suspended" : "fit";
  
  // Determine if breakeven is achievable
  const breakEvenDiff = (player.breakEven || 0) - player.averagePoints;
  let breakEvenStatus = <Minus className="h-4 w-4 text-gray-500" />;
  
  if (breakEvenDiff > 10) {
    breakEvenStatus = <TrendingUp className="h-4 w-4 text-red-500" />;
  } else if (breakEvenDiff < -10) {
    breakEvenStatus = <TrendingDown className="h-4 w-4 text-green-500" />;
  }
  
  const teamColors = getTeamColors(player.team || '');
  
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md max-h-[90vh] p-0 overflow-y-auto bg-gray-900 border-gray-700">
        <DialogTitle className="sr-only">Player Details</DialogTitle>
        <DialogDescription className="sr-only">View detailed statistics and information for {player.name}</DialogDescription>
        
        {/* Team colored header with gradient */}
        <div 
          className="relative h-32 px-4 pt-4"
          style={{ 
            background: `linear-gradient(135deg, ${teamColors.primary} 0%, ${teamColors.secondary} 100%)` 
          }}
        >
          <DialogClose className="absolute left-4 top-4 rounded-sm opacity-70 transition-opacity hover:opacity-100 focus:outline-none z-10">
            <X className="h-6 w-6 text-white" />
          </DialogClose>
          
          {/* Status indicator */}
          <div className="absolute top-4 right-4">
            <div className={`px-2 py-1 rounded-full text-xs font-medium ${
              playerStatus === 'injured' ? 'bg-red-500 text-white' : 
              playerStatus === 'suspended' ? 'bg-yellow-500 text-black' : 
              'bg-green-500 text-white'
            }`}>
              {playerStatus.toUpperCase()}
            </div>
          </div>
          
          {/* Player info header */}
          <div className="flex items-start justify-between mt-6">
            <div className="flex-1">
              <h2 className="text-xl font-bold text-white mb-1">{player.name}</h2>
              <div className="flex items-center gap-2 mb-3">
                <span className="text-white/80 text-sm font-medium">{player.position}</span>
                <span className="text-white/60">•</span>
                <span className="text-white/80 text-sm">{player.team}</span>
              </div>
              
              {/* Price and Breakeven */}
              <div className="flex items-center gap-4">
                <div>
                  <div className="text-white/60 text-xs uppercase tracking-wide">Price</div>
                  <div className="text-white font-bold text-lg">{formatCurrency(player.price || 0)}</div>
                </div>
                <div>
                  <div className="text-white/60 text-xs uppercase tracking-wide">Breakeven</div>
                  <div className="flex items-center gap-1">
                    <span className="text-white font-bold text-lg">{player.breakEven || 0}</span>
                    {breakEvenStatus}
                  </div>
                </div>
              </div>
            </div>
            
            {/* Team guernsey */}
            <div className="w-16 h-16 rounded-full overflow-hidden border-2 border-white/20 bg-gray-800">
              {getTeamGuernsey(player.team || '') ? (
                <img
                  src={getTeamGuernsey(player.team || '')}
                  alt={`${player.team} guernsey`}
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    console.log('Image failed to load:', getTeamGuernsey(player.team || ''));
                    e.currentTarget.style.display = 'none';
                    e.currentTarget.nextElementSibling?.setAttribute('style', 'display: flex');
                  }}
                />
              ) : null}
              <div 
                className="w-full h-full flex items-center justify-center"
                style={{ 
                  backgroundColor: teamColors.accent,
                  display: getTeamGuernsey(player.team || '') ? 'none' : 'flex'
                }}
              >
                <span className="text-lg font-bold" style={{ color: teamColors.primary }}>
                  {player.team?.substring(0, 3).toUpperCase()}
                </span>
              </div>
            </div>
          </div>
        </div>
        
        {/* Stats overview cards */}
        <div className="px-4 py-3 bg-gray-800/50">
          <div className="grid grid-cols-4 gap-2">
            <div className="text-center">
              <div className="text-xs text-gray-400 uppercase tracking-wide">Avg</div>
              <div className="text-lg font-bold text-white">{player.averagePoints}</div>
            </div>
            <div className="text-center">
              <div className="text-xs text-gray-400 uppercase tracking-wide">L3</div>
              <div className="text-lg font-bold text-blue-400">{player.l3Average || player.averagePoints}</div>
            </div>
            <div className="text-center">
              <div className="text-xs text-gray-400 uppercase tracking-wide">Proj</div>
              <div className="text-lg font-bold text-green-400">{player.projScore || Math.round(player.averagePoints * 1.05)}</div>
            </div>
            <div className="text-center">
              <div className="text-xs text-gray-400 uppercase tracking-wide">Own%</div>
              <div className="text-lg font-bold text-yellow-400">{player.ownership || '12'}%</div>
            </div>
          </div>
        </div>
        
        <nav className="border-t border-gray-700 px-4">
          <div className="flex justify-between -mb-px">
            <button 
              className={`py-3 px-1 font-medium text-sm relative ${activeSection === "performance" ? "text-blue-400 border-b-2 border-blue-400" : "text-gray-400"}`}
              onClick={() => setActiveSection("performance")}
            >
              PERFORMANCE
            </button>
            <button 
              className={`py-3 px-1 font-medium text-sm relative ${activeSection === "projections" ? "text-blue-400 border-b-2 border-blue-400" : "text-gray-400"}`}
              onClick={() => setActiveSection("projections")}
            >
              PROJECTIONS
            </button>
            <button 
              className={`py-3 px-1 font-medium text-sm relative ${activeSection === "news" ? "text-blue-400 border-b-2 border-blue-400" : "text-gray-400"}`}
              onClick={() => setActiveSection("news")}
            >
              NEWS
            </button>
          </div>
        </nav>
        
        {activeSection === "performance" && (
          <div className="px-4 pb-4">
            {/* Quick Stats Summary */}
            <Card className="mb-4 bg-gray-800 border-gray-700">
              <CardContent className="px-4 py-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="border border-gray-600 bg-gray-700 rounded-md p-3">
                    <div className="text-xs text-gray-400 uppercase mb-1">Score Last Game</div>
                    <div className="text-2xl font-bold text-white">{player.lastScore || player.last1 || 0}</div>
                  </div>
                  <div className="border border-gray-600 bg-gray-700 rounded-md p-3">
                    <div className="text-xs text-gray-400 uppercase mb-1">Season Average</div>
                    <div className="text-2xl font-bold text-white">{player.averagePoints || 0}</div>
                  </div>
                  <div className="border border-gray-600 bg-gray-700 rounded-md p-3">
                    <div className="text-xs text-gray-400 uppercase mb-1">Price</div>
                    <div className="text-2xl font-bold text-green-400">{formatCurrency(player.price || 0)}</div>
                  </div>
                  <div className="border border-gray-600 bg-gray-700 rounded-md p-3 flex flex-col">
                    <div className="text-xs text-gray-400 uppercase mb-1">Breakeven</div>
                    <div className="flex items-center">
                      <div className="text-2xl font-bold text-white mr-2">{player.breakEven || 0}</div>
                      {breakEvenStatus}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* Score Breakdown Module */}
            <ScoreBreakdownModule 
              playerName={player.name}
              gameData={getPlayerGameData(player.name)}
            />
          </div>
        )}
      
        {activeSection === "projections" && (
          <div className="px-4 pb-4">
            <Card className="mb-4 bg-gray-800 border-gray-700">
              <CardHeader className="px-4 py-2">
                <div className="flex justify-between items-center">
                  <CardTitle className="text-base font-bold text-white">FIXTURE DIFFICULTY</CardTitle>
                </div>
              </CardHeader>
              <CardContent className="px-4 py-2">
                <div className="mb-4">
                  <div className="font-medium mb-2 text-white">Upcoming Fixtures</div>
                  {matchupLoading ? (
                    <div className="flex items-center justify-center py-4">
                      <Loader2 className="h-6 w-6 animate-spin text-gray-400" />
                    </div>
                  ) : matchupData?.fixtures?.length ? (
                    <>
                      <div className="grid grid-cols-5 gap-1">
                        {matchupData.fixtures.map((fixture, index) => (
                          <div key={index} className="text-center border border-gray-600 bg-gray-700 rounded p-1">
                            <div className="font-medium text-xs text-gray-400">R{fixture.round}</div>
                            <div className="font-medium text-xs text-white mt-1">{fixture.opponent}</div>
                            <div className="mx-auto mt-1 mb-1 relative">
                              {/* Team guernsey */}
                              <div className="h-8 w-8 rounded-full overflow-hidden border border-gray-500 bg-gray-800 mx-auto">
                                {(() => {
                                  const guernseyUrl = getTeamGuernsey(fixture.opponent);
                                  return guernseyUrl ? (
                                    <img
                                      src={guernseyUrl}
                                      alt={`${fixture.opponent} guernsey`}
                                      className="w-full h-full object-cover"
                                      onError={(e) => {
                                        e.currentTarget.style.display = 'none';
                                        (e.currentTarget.nextElementSibling as HTMLElement).style.display = 'flex';
                                      }}
                                    />
                                  ) : null;
                                })()}
                                <div 
                                  className="w-full h-full flex items-center justify-center text-white text-xs font-bold"
                                  style={{ display: getTeamGuernsey(fixture.opponent) ? 'none' : 'flex' }}
                                >
                                  {fixture.opponent?.substring(0, 3).toUpperCase()}
                                </div>
                              </div>
                              {/* Difficulty rating overlay */}
                              <div 
                                className="absolute -bottom-1 -right-1 rounded-full h-4 w-4 flex items-center justify-center text-xs font-bold text-white border border-gray-600"
                                style={{ backgroundColor: getDifficultyColor(fixture.difficulty) }}
                              >
                                {fixture.difficulty.toFixed(0)}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                      <div className="text-xs text-gray-400 mt-2 text-center">
                        Difficulty rating: 0 (easiest) to 10 (hardest) for {player.position}s against opposition
                      </div>
                    </>
                  ) : (
                    <div className="text-sm text-gray-400 text-center py-4">
                      No upcoming fixtures data available
                    </div>
                  )}
                </div>
                
                <div className="mt-4">
                  <div className="font-medium mb-2 text-white">Position vs Opposition Analysis</div>
                  <div className="bg-gray-700 border border-gray-600 p-2 rounded-lg mb-2">
                    {matchupData?.dvpRatings && (
                      <div className="mb-3">
                        <div className="text-sm font-medium text-white mb-2">Team DVP Ratings (Defense vs Position)</div>
                        <div className="grid grid-cols-4 gap-2">
                          <div className="text-center">
                            <div className="text-xs text-gray-400">FWD</div>
                            <div className={`text-lg font-bold ${getDifficultyColorClass(matchupData.dvpRatings.FWD || 5)} rounded px-1 py-0.5`}>
                              {(matchupData.dvpRatings.FWD || 5).toFixed(1)}
                            </div>
                          </div>
                          <div className="text-center">
                            <div className="text-xs text-gray-400">MID</div>
                            <div className={`text-lg font-bold ${getDifficultyColorClass(matchupData.dvpRatings.MID || 5)} rounded px-1 py-0.5`}>
                              {(matchupData.dvpRatings.MID || 5).toFixed(1)}
                            </div>
                          </div>
                          <div className="text-center">
                            <div className="text-xs text-gray-400">DEF</div>
                            <div className={`text-lg font-bold ${getDifficultyColorClass(matchupData.dvpRatings.DEF || 5)} rounded px-1 py-0.5`}>
                              {(matchupData.dvpRatings.DEF || 5).toFixed(1)}
                            </div>
                          </div>
                          <div className="text-center">
                            <div className="text-xs text-gray-400">RUCK</div>
                            <div className={`text-lg font-bold ${getDifficultyColorClass(matchupData.dvpRatings.RUCK || 5)} rounded px-1 py-0.5`}>
                              {(matchupData.dvpRatings.RUCK || 5).toFixed(1)}
                            </div>
                          </div>
                        </div>
                        <div className="text-xs text-gray-400 mt-1 text-center">How difficult each position is to score against</div>
                      </div>
                    )}
                    <div className="text-sm text-gray-300">
                      <span className="font-medium text-white">
                        {player.position}s vs {matchupData?.fixtures?.[0]?.opponent || "upcoming opponents"}:
                      </span> {getPositionVsOppositionText(player)}
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
            
            {/* Projected Scores by Fixture */}
            <Card className="mb-4 bg-gray-800 border-gray-700">
              <CardHeader className="px-4 py-2">
                <div className="flex justify-between items-center">
                  <CardTitle className="text-base font-bold text-white">PROJECTED SCORES</CardTitle>
                  <div className="text-xs text-blue-400 bg-blue-900/30 px-2 py-1 rounded">
                    v3.4.4 Algorithm
                  </div>
                </div>
              </CardHeader>
              <CardContent className="px-4 py-2">
                {matchupLoading ? (
                  <div className="flex items-center justify-center py-4">
                    <Loader2 className="h-6 w-6 animate-spin text-gray-400" />
                  </div>
                ) : matchupData?.fixtures?.length ? (
                  <div className="space-y-2">
                    {matchupData.fixtures.map((fixture, index) => {
                      // Get actual projected score from v3.4.4 algorithm
                      const roundNumber = parseInt(fixture.round.replace('R', '')); // Convert "R20" to 20
                      const roundProjection = projectionData?.find(p => p.round === roundNumber);
                      const projectedScore = roundProjection?.projection?.projectedScore || null;
                      

                      
                      // Use authentic difficulty data from API - ensure proper mapping
                      const difficulty = fixture.difficulty; // Use actual API difficulty value without fallback
                      const difficultyCategory = 
                        difficulty <= 3 ? "EASY" :
                        difficulty >= 7 ? "HARD" : "MED";
                      
                      // Apply correct difficulty color mapping (Easy, Medium, Hard) as per requirements
                      let difficultyColor = "bg-yellow-500"; // Medium (yellow)
                      if (difficulty <= 3) {
                        difficultyColor = "bg-green-500"; // Easy (green)
                      } else if (difficulty >= 7) {
                        difficultyColor = "bg-red-500"; // Hard (red)
                      }
                      
                      // Debug logging to verify correct difficulty values
                      console.log(`Fixture ${fixture.round} vs ${fixture.opponent}: difficulty=${difficulty} (${difficultyCategory})`);
                      
                      return (
                        <div key={index} className="flex items-center justify-between bg-gray-700 border border-gray-600 p-3 rounded">
                          <div className="flex items-center gap-3">
                            <div className="text-sm font-medium text-gray-400">{fixture.round}</div>
                            <div className="flex items-center gap-2">
                              <span className="text-white text-sm">vs</span>
                              <div className="h-6 w-6 rounded-full overflow-hidden border border-gray-500 bg-gray-800">
                                {(() => {
                                  const guernseyUrl = getTeamGuernsey(fixture.opponent);
                                  return guernseyUrl ? (
                                    <img
                                      src={guernseyUrl}
                                      alt={`${fixture.opponent} guernsey`}
                                      className="w-full h-full object-cover"
                                      onError={(e) => {
                                        e.currentTarget.style.display = 'none';
                                        (e.currentTarget.nextElementSibling as HTMLElement).style.display = 'flex';
                                      }}
                                    />
                                  ) : null;
                                })()}
                                <div 
                                  className="w-full h-full flex items-center justify-center text-white text-xs font-bold"
                                  style={{ display: getTeamGuernsey(fixture.opponent) ? 'none' : 'flex' }}
                                >
                                  {fixture.opponent?.substring(0, 2).toUpperCase()}
                                </div>
                              </div>
                              <span className="text-white text-sm font-medium">{fixture.opponent}</span>
                            </div>
                          </div>
                          <div className="flex items-center gap-3">
                            <div className="text-right">
                              {projectedScore ? (
                                <div className="text-white font-bold text-lg">{Math.round(projectedScore)}</div>
                              ) : (
                                <div className="text-gray-500 text-lg">
                                  {projectionLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : '—'}
                                </div>
                              )}
                              <div className="text-xs text-gray-400">v3.4.4 projected</div>
                            </div>
                            <div className={`px-2 py-1 rounded text-xs font-bold text-white ${difficultyColor}`}>
                              {difficultyCategory}
                            </div>
                          </div>
                        </div>
                      );
                    })}
                    <div className="text-xs text-gray-400 mt-3 text-center">
                      v3.4.4 algorithm projections for {player.position}s • Season Average: {player.averagePoints}
                    </div>
                  </div>
                ) : (
                  <div className="text-sm text-gray-400 text-center py-4">
                    No fixture data available for projections
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
