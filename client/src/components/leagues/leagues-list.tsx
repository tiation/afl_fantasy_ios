import React, { useState } from 'react';
import { useQuery } from "@tanstack/react-query";
import { queryClient } from "@/lib/queryClient";
import { ChevronDown, ChevronUp, Trophy, Users, Calendar, Swords } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';

interface LeagueTeam {
  id: number;
  teamId: number;
  leagueId: number;
  name: string;
  wins: number;
  losses: number;
  pointsFor: number;
}

interface Matchup {
  id: number;
  round: number;
  team1Id: number;
  team2Id: number;
  team1Score: number;
  team2Score: number;
  team1: {
    id: number;
    name: string;
  };
  team2: {
    id: number;
    name: string;
  };
}

interface TeamDetail extends LeagueTeam {
  pointsAgainst?: number;
  percentage?: number;
  rank?: number;
}

interface League {
  id: number;
  name: string;
  creatorId: number;
  code: string;
  // Custom properties for UI
  rank?: number;
  totalTeams?: number;
}

interface LeaguesListProps {
  leagues: League[];
  isLoading: boolean;
  onSelectLeague: (leagueId: number) => void;
}

// Helper function to get ordinal suffix (1st, 2nd, 3rd, etc.)
function getOrdinal(n: number): string {
  const s = ["th", "st", "nd", "rd"];
  const v = n % 100;
  return n + (s[(v - 20) % 10] || s[v] || s[0]);
}

// League detail component that handles its own data fetching
interface LeagueDetailProps {
  leagueId: number;
  league: League & { totalTeams?: number };
  currentRound: number;
  userTeamId: number;
  onSelectLeague: (leagueId: number) => void;
}

const LeagueDetail: React.FC<LeagueDetailProps> = ({ 
  leagueId,
  league,
  currentRound,
  userTeamId,
  onSelectLeague
}) => {
  // Fetch teams for this league
  const { data: leagueTeams = [], isLoading: isLoadingTeams } = useQuery<LeagueTeam[]>({
    queryKey: [`/api/leagues/${leagueId}/teams`],
    enabled: true,
  });

  // Fetch current round matchups for this league
  const { data: matchups = [], isLoading: isLoadingMatchups } = useQuery<Matchup[]>({
    queryKey: [`/api/leagues/${leagueId}/matchups/${currentRound}`],
    enabled: true,
  });
  
  // Find the user's current matchup
  const userMatchup = matchups.find(m => 
    m.team1Id === userTeamId || m.team2Id === userTeamId
  );
  
  // Determine if user is team1 or team2
  const isUserTeam1 = userMatchup?.team1Id === userTeamId;

  // Get user team and opponent details
  const userTeam = isUserTeam1 ? userMatchup?.team1 : userMatchup?.team2;
  const opponentTeam = isUserTeam1 ? userMatchup?.team2 : userMatchup?.team1;
  const userScore = (isUserTeam1 ? userMatchup?.team1Score : userMatchup?.team2Score) || 0;
  const opponentScore = (isUserTeam1 ? userMatchup?.team2Score : userMatchup?.team1Score) || 0;

  // Calculate score percentages for visual representation
  const totalScore = userScore + opponentScore;
  const userScorePercent = totalScore > 0 ? (userScore / totalScore) * 100 : 50;
  const opponentScorePercent = totalScore > 0 ? (opponentScore / totalScore) * 100 : 50;
  
  // Team player data (would normally come from API)
  const userTotalPlayers = 22;
  const opponentTotalPlayers = 22;
  const userPlayedPlayers = 14;
  const opponentPlayedPlayers = 18;
  const userRemainingPlayers = userTotalPlayers - userPlayedPlayers;
  const opponentRemainingPlayers = opponentTotalPlayers - opponentPlayedPlayers;
  const userPlayedPercent = (userPlayedPlayers / userTotalPlayers) * 100;
  const opponentPlayedPercent = (opponentPlayedPlayers / opponentTotalPlayers) * 100;
  const userCaptainActive = true;
  const opponentCaptainActive = false;
  
  // Calculate win probability based on various factors
  let userWinProb = 50; // Default even probability
  let opponentWinProb = 50;
  
  // Factor 1: Current score advantage (+/- 15%)
  if (userScore > opponentScore) {
    const scoreAdvantage = Math.min(15, Math.floor((userScore - opponentScore) / 50));
    userWinProb += scoreAdvantage;
    opponentWinProb -= scoreAdvantage;
  } else if (opponentScore > userScore) {
    const scoreAdvantage = Math.min(15, Math.floor((opponentScore - userScore) / 50));
    opponentWinProb += scoreAdvantage;
    userWinProb -= scoreAdvantage;
  }
  
  // Factor 2: Remaining players advantage (+/- 10% max)
  if (userRemainingPlayers > opponentRemainingPlayers) {
    const playerAdvantage = Math.min(10, (userRemainingPlayers - opponentRemainingPlayers) * 2);
    userWinProb += playerAdvantage;
    opponentWinProb -= playerAdvantage;
  } else if (opponentRemainingPlayers > userRemainingPlayers) {
    const playerAdvantage = Math.min(10, (opponentRemainingPlayers - userRemainingPlayers) * 2);
    opponentWinProb += playerAdvantage;
    userWinProb -= playerAdvantage;
  }
  
  // Factor 3: Captain status (+10% if active)
  if (userCaptainActive && !opponentCaptainActive) {
    userWinProb += 10;
    opponentWinProb -= 10;
  } else if (opponentCaptainActive && !userCaptainActive) {
    opponentWinProb += 10;
    userWinProb -= 10;
  }
  
  // Ensure probabilities stay within 5-95% range (never show 0% or 100%)
  userWinProb = Math.max(5, Math.min(95, userWinProb));
  opponentWinProb = 100 - userWinProb;
  
  // Define the factor type
  interface Factor {
    color: string;
    text: string;
  }
  
  // Factor descriptions for display
  const userFactors: Factor[] = [];
  const opponentFactors: Factor[] = [];
  
  if (userScore > opponentScore) {
    userFactors.push({
      color: "bg-green-500",
      text: `Higher current score (+${Math.min(15, Math.floor((userScore - opponentScore) / 50))}%)`
    });
  } else if (opponentScore > userScore) {
    opponentFactors.push({
      color: "bg-green-500",
      text: `Higher current score (+${Math.min(15, Math.floor((opponentScore - userScore) / 50))}%)`
    });
  }
  
  if (userRemainingPlayers > opponentRemainingPlayers) {
    userFactors.push({
      color: "bg-blue-500",
      text: `More players remaining (+${Math.min(10, (userRemainingPlayers - opponentRemainingPlayers) * 2)}%)`
    });
  } else if (opponentRemainingPlayers > userRemainingPlayers) {
    opponentFactors.push({
      color: "bg-blue-500",
      text: `More players remaining (+${Math.min(10, (opponentRemainingPlayers - userRemainingPlayers) * 2)}%)`
    });
  }
  
  if (userCaptainActive) {
    userFactors.push({
      color: "bg-amber-500",
      text: "Captain active (+10%)"
    });
  }
  
  if (opponentCaptainActive) {
    opponentFactors.push({
      color: "bg-amber-500",
      text: "Captain active (+10%)"
    });
  }
  
  // Process the league teams data for the ladder
  const processedTeams: TeamDetail[] = leagueTeams.map((team, index) => {
    // In a real app, pointsAgainst would come from the API
    const pointsAgainst = Math.floor(Math.random() * 2000) + 1000;
    const percentage = team.pointsFor / (pointsAgainst || 1) * 100;
    
    return {
      ...team,
      pointsAgainst,
      percentage,
      rank: index + 1
    };
  });

  // Sort teams by wins (descending), then by percentage (descending)
  const sortedTeams = [...processedTeams].sort((a, b) => {
    if (a.wins !== b.wins) return b.wins - a.wins;
    return (b.percentage || 0) - (a.percentage || 0);
  });
  
  return (
    <CardContent className="p-4 pt-0 bg-gray-900/95 border-t border-gray-700 text-white">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4">
        <div className="flex items-center">
          <Users className="h-5 w-5 mr-2 text-primary" />
          <div>
            <div className="text-sm font-medium text-gray-300">League Size</div>
            <div className="text-lg text-white">{league.totalTeams} Teams</div>
          </div>
        </div>
        <div className="flex items-center">
          <Calendar className="h-5 w-5 mr-2 text-primary" />
          <div>
            <div className="text-sm font-medium text-gray-300">Current Round</div>
            <div className="text-lg text-white">Round {currentRound}</div>
          </div>
        </div>
      </div>
      
      {/* Current Matchup Section */}
      <div className="mt-6 overflow-hidden">
        <div className="flex items-center mb-3">
          <Swords className="h-5 w-5 mr-2 text-primary" />
          <div className="text-base font-medium text-white">Your Current Matchup</div>
        </div>
        
        {isLoadingMatchups ? (
          <div className="py-8 text-center text-muted-foreground">
            Loading matchup...
          </div>
        ) : userMatchup ? (
          <Card className="border border-gray-700 bg-gray-800/50 rounded-md overflow-hidden">
            <CardContent className="p-4 text-white">
              <div className="flex flex-col space-y-4">
                {/* Team Names and Scores Header */}
                <div className="flex justify-between items-center">
                  <div className="flex-1 text-left">
                    <div className="flex items-center">
                      <span className="font-medium text-primary">{userTeam?.name}</span>
                      <Trophy className="h-4 w-4 ml-1 text-amber-500" aria-label="Captain active" />
                    </div>
                    <div className="text-2xl font-bold">{userScore}</div>
                  </div>
                  <div className="px-4 py-1 text-center">
                    <div className="text-xs text-muted-foreground uppercase">vs</div>
                  </div>
                  <div className="flex-1 text-right">
                    <div className="flex items-center justify-end">
                      <span className="font-medium">{opponentTeam?.name}</span>
                    </div>
                    <div className="text-2xl font-bold">{opponentScore}</div>
                  </div>
                </div>
                
                {/* Visual Score Comparison */}
                <div className="h-4 bg-gray-700 rounded-full overflow-hidden flex">
                  <div 
                    className="bg-primary rounded-l-full h-full"
                    style={{ width: `${userScorePercent}%` }}
                  ></div>
                  <div 
                    className="bg-red-500 rounded-r-full h-full"
                    style={{ width: `${opponentScorePercent}%` }}
                  ></div>
                </div>
                
                {/* Score Differential */}
                <div className="text-center text-sm text-gray-300">
                  {userScore > opponentScore ? (
                    <span className="text-green-600">
                      Leading by {userScore - opponentScore} points
                    </span>
                  ) : userScore < opponentScore ? (
                    <span className="text-amber-600">
                      Trailing by {opponentScore - userScore} points
                    </span>
                  ) : (
                    <span>Scores level</span>
                  )}
                </div>
                
                {/* Player Status */}
                <div className="grid grid-cols-2 gap-4 mt-2">
                  {/* User's team player status */}
                  <div className="space-y-1">
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-gray-400">Players</span>
                      <span className="font-medium text-white">{userPlayedPlayers}/{userTotalPlayers} played</span>
                    </div>
                    <div className="h-2 bg-gray-700 rounded-full overflow-hidden">
                      <div 
                        className="bg-primary h-full rounded-full"
                        style={{ width: `${userPlayedPercent}%` }}
                      ></div>
                    </div>
                    <div className="text-xs text-primary font-medium text-center">
                      {userRemainingPlayers} remaining
                      {userCaptainActive && (
                        <span className="ml-1 text-xs opacity-75">
                          (Capt. active)
                        </span>
                      )}
                    </div>
                  </div>
                  
                  {/* Opponent's team player status */}
                  <div className="space-y-1">
                    <div className="flex justify-between items-center text-xs">
                      <span className="text-gray-400">Players</span>
                      <span className="font-medium text-white">{opponentPlayedPlayers}/{opponentTotalPlayers} played</span>
                    </div>
                    <div className="h-2 bg-gray-700 rounded-full overflow-hidden">
                      <div 
                        className="bg-red-500 h-full rounded-full"
                        style={{ width: `${opponentPlayedPercent}%` }}
                      ></div>
                    </div>
                    <div className="text-xs text-red-400 font-medium text-center">
                      {opponentRemainingPlayers} remaining
                      {opponentCaptainActive && (
                        <span className="ml-1 text-xs opacity-75">
                          (Capt. active)
                        </span>
                      )}
                    </div>
                  </div>
                </div>
                
                {/* Win Probability Section */}
                <div className="mt-4 pt-4 border-t border-gray-700">
                  <div className="flex justify-between items-center text-xs mb-2">
                    <span className="font-medium text-white">Live Win Probability</span>
                    <div className="flex space-x-3">
                      <span className="text-primary font-semibold">You: {Math.round(userWinProb)}%</span>
                      <span className="text-red-400 font-semibold">Opponent: {Math.round(opponentWinProb)}%</span>
                    </div>
                  </div>
                  
                  {/* Win Probability Bar */}
                  <div className="h-3 bg-gray-700 rounded-full overflow-hidden flex">
                    <div 
                      className="bg-primary/90 rounded-l-full h-full"
                      style={{ width: `${userWinProb}%` }}
                    ></div>
                    <div 
                      className="bg-red-500/90 rounded-r-full h-full"
                      style={{ width: `${opponentWinProb}%` }}
                    ></div>
                  </div>
                  
                  {/* Win Probability Details */}
                  <div className="mt-2 text-xs text-gray-300">
                    <div className="flex justify-between items-center">
                      <div>
                        {userFactors.length > 0 && (
                          <>
                            <span className="font-medium text-primary">Factors:</span>
                            <ul className="list-none pl-0 mt-1">
                              {userFactors.map((factor, idx) => (
                                <li key={idx} className="flex items-center">
                                  <span className={`inline-block w-2 h-2 ${factor.color} rounded-full mr-1.5`}></span>
                                  {factor.text}
                                </li>
                              ))}
                            </ul>
                          </>
                        )}
                      </div>
                      <div className="text-right">
                        {opponentFactors.length > 0 && (
                          <>
                            <span className="font-medium text-secondary">Factors:</span>
                            <ul className="list-none pl-0 mt-1 text-right">
                              {opponentFactors.map((factor, idx) => (
                                <li key={idx} className="flex items-center justify-end">
                                  <span className={`inline-block w-2 h-2 ${factor.color} rounded-full mr-1.5`}></span>
                                  {factor.text}
                                </li>
                              ))}
                            </ul>
                          </>
                        )}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        ) : (
          <div className="py-4 text-center text-muted-foreground border rounded-md">
            No current matchup found for this round.
          </div>
        )}
      </div>

      {/* League Ladder Table */}
      <div className="mt-6 overflow-hidden">
        <div className="text-base font-medium mb-3">League Ladder</div>
        {isLoadingTeams ? (
          <div className="py-8 text-center text-muted-foreground">
            Loading ladder...
          </div>
        ) : (
          <div className="overflow-auto max-h-[400px] border border-gray-700 rounded-md bg-gray-800/30">
            <Table>
              <TableHeader className="sticky top-0 bg-gray-900 z-10">
                <TableRow>
                  <TableHead className="w-[60px] py-3 text-white">Rank</TableHead>
                  <TableHead className="text-white">Team</TableHead>
                  <TableHead className="w-[60px] text-center text-white">W</TableHead>
                  <TableHead className="w-[60px] text-center text-white">L</TableHead>
                  <TableHead className="text-right text-white">PF</TableHead>
                  <TableHead className="text-right text-white">PA</TableHead>
                  <TableHead className="text-right w-[80px] text-white">%</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {sortedTeams.map((team) => {
                  // Check if this is the user's team
                  const isUserTeam = team.teamId === userTeamId;
                  
                  return (
                    <TableRow 
                      key={team.id}
                      className={isUserTeam ? 'bg-primary/5 font-medium' : ''}
                    >
                      <TableCell className="py-3">{team.rank}</TableCell>
                      <TableCell className={isUserTeam ? 'font-medium' : ''}>
                        {team.name}
                        {isUserTeam && (
                          <span className="ml-2 text-xs text-primary">(You)</span>
                        )}
                      </TableCell>
                      <TableCell className="text-center">{team.wins}</TableCell>
                      <TableCell className="text-center">{team.losses}</TableCell>
                      <TableCell className="text-right">{team.pointsFor}</TableCell>
                      <TableCell className="text-right">{team.pointsAgainst}</TableCell>
                      <TableCell className="text-right">
                        {team.percentage?.toFixed(1)}%
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </div>
        )}
      </div>

      <div className="mt-4 flex justify-end">
        <button 
          className="text-sm text-primary hover:text-primary/80 font-medium bg-gray-800/50 px-3 py-2 rounded-md border border-gray-600 hover:bg-gray-700/50 transition-colors"
          onClick={(e) => {
            e.stopPropagation();
            onSelectLeague(leagueId);
          }}
        >
          View Full League Details →
        </button>
      </div>
    </CardContent>
  );
};

const LeaguesList: React.FC<LeaguesListProps> = ({ 
  leagues, 
  isLoading, 
  onSelectLeague 
}) => {
  const [expandedLeagueId, setExpandedLeagueId] = useState<number | null>(null);
  const currentRound = 7; // Hardcoded for now
  const userTeamId = 1; // Hardcoded for this example, would normally be derived from user data

  const toggleLeague = (leagueId: number) => {
    // If already expanded, close it
    if (expandedLeagueId === leagueId) {
      setExpandedLeagueId(null);
    } else {
      // Otherwise, expand the clicked league
      setExpandedLeagueId(leagueId);
      
      // Force refetch the matchups for this league to ensure we get the latest data
      queryClient.invalidateQueries({
        queryKey: [`/api/leagues/${leagueId}/matchups/${currentRound}`]
      });
      
      queryClient.invalidateQueries({
        queryKey: [`/api/leagues/${leagueId}/teams`]
      });
    }
  };

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[...Array(3)].map((_, index) => (
          <Card key={index} className="animate-pulse">
            <CardContent className="p-4">
              <div className="h-6 bg-gray-200 rounded w-3/4 mb-3"></div>
              <div className="h-4 bg-gray-200 rounded w-1/4"></div>
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  if (!leagues || leagues.length === 0) {
    return (
      <Card>
        <CardContent className="p-6 text-center">
          <p className="text-muted-foreground">You are not part of any leagues.</p>
        </CardContent>
      </Card>
    );
  }

  // Add rank and total teams to leagues
  const leaguesWithRank = leagues.map(league => ({
    ...league,
    rank: Math.floor(Math.random() * 20) + 1, // Random rank between 1-20
    totalTeams: Math.floor(Math.random() * 15) + 5 // Random team count between 5-20
  }));

  return (
    <div className="space-y-4">
      {leaguesWithRank.map((league) => {
        const isExpanded = expandedLeagueId === league.id;
        
        return (
          <Card 
            key={league.id} 
            className={`overflow-hidden transition-all duration-200 bg-gray-800 border-2 ${
              isExpanded ? 'border-green-500' : 'border-green-500'
            }`}
          >
            <div 
              className="p-4 cursor-pointer flex items-center justify-between hover:bg-gray-700/50"
              onClick={() => toggleLeague(league.id)}
            >
              <div>
                <h3 className="font-medium text-lg text-white">{league.name}</h3>
                <div className="flex items-center text-sm text-gray-400 mt-1">
                  <Trophy className="h-4 w-4 mr-1" />
                  <span>{getOrdinal(league.rank)} of {league.totalTeams}</span>
                </div>
              </div>
              <div className="flex items-center">
                <Badge variant="outline" className="mr-3 bg-green-500/20 border-green-500 text-green-400">
                  {league.rank <= 3 ? 'Top 3' : (league.rank <= 10 ? 'Top 10' : 'Challenger')}
                </Badge>
                {isExpanded ? 
                  <ChevronUp className="h-5 w-5 text-green-400" /> : 
                  <ChevronDown className="h-5 w-5 text-green-400" />
                }
              </div>
            </div>
            
            {isExpanded && (
              <div className="border-t border-green-500/30 bg-gray-900">
                <LeagueDetail 
                  leagueId={league.id}
                  league={league}
                  currentRound={currentRound}
                  userTeamId={userTeamId}
                  onSelectLeague={onSelectLeague}
                />
              </div>
            )}
          </Card>
        );
      })}
    </div>
  );
};

export default LeaguesList;