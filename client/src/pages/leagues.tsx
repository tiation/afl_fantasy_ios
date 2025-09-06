import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import LeagueLadder from "@/components/leagues/league-ladder";
import LiveMatchups from "@/components/leagues/live-matchups";
import LeaguesList from "@/components/leagues/leagues-list";
import { Card } from "@/components/ui/card";

interface League {
  id: number;
  name: string;
  creatorId: number;
  code: string;
}

interface LeagueTeam {
  id: number;
  teamId: number;
  leagueId: number;
  wins: number;
  losses: number;
  pointsFor: number;
  team: {
    id: number;
    name: string;
  };
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

export default function Leagues() {
  const [activeTab, setActiveTab] = useState("ladder");
  const [selectedLeagueId, setSelectedLeagueId] = useState<number | null>(null);
  const [showLeagueDetails, setShowLeagueDetails] = useState(false);

  const { data: leagues = [], isLoading: isLoadingLeagues } = useQuery<League[]>({
    queryKey: ["/api/leagues/user/1"],
  });
  
  // Set the selected league when leagues are loaded
  useEffect(() => {
    if (!isLoadingLeagues && leagues.length > 0 && !selectedLeagueId) {
      setSelectedLeagueId(leagues[0].id);
    }
  }, [leagues, isLoadingLeagues, selectedLeagueId]);

  const { data: leagueTeams = [], isLoading: isLoadingTeams } = useQuery<LeagueTeam[]>({
    queryKey: [`/api/leagues/${selectedLeagueId}/teams`],
    enabled: !!selectedLeagueId,
  });

  const currentRound = 7; // Hardcoded for now
  
  const { data: matchups = [], isLoading: isLoadingMatchups } = useQuery<Matchup[]>({
    queryKey: [`/api/leagues/${selectedLeagueId}/matchups/${currentRound}`],
    enabled: !!selectedLeagueId,
  });

  const formattedLeagueTeams = leagueTeams.map((lt) => ({
    id: lt.id,
    teamId: lt.teamId,
    name: lt.team.name,
    wins: lt.wins,
    losses: lt.losses,
    pointsFor: lt.pointsFor
  }));

  const formattedMatchups = matchups.map((m) => ({
    id: m.id,
    round: m.round,
    team1: {
      id: m.team1?.id,
      name: m.team1?.name,
      score: m.team1Score
    },
    team2: {
      id: m.team2?.id,
      name: m.team2?.name,
      score: m.team2Score
    }
  }));

  const isLoading = isLoadingLeagues || (!!selectedLeagueId && (isLoadingTeams || isLoadingMatchups));

  const handleSelectLeague = (leagueId: number) => {
    // This should only be called when user explicitly clicks the "View Full League Details" link
    // Not when just expanding a card
    setSelectedLeagueId(leagueId);
    setShowLeagueDetails(true);
  };

  const handleBackToLeagues = () => {
    setShowLeagueDetails(false);
  };

  if (isLoadingLeagues) {
    return <div className="p-4">Loading leagues...</div>;
  }

  const selectedLeague = leagues.find(l => l.id === selectedLeagueId);

  return (
    <div className="p-2 md:p-4">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">
          {showLeagueDetails ? 
            selectedLeague?.name || "League Details" : 
            "My Leagues"
          }
        </h1>
        
        {showLeagueDetails && (
          <button 
            onClick={handleBackToLeagues}
            className="text-sm font-medium text-primary hover:underline flex items-center"
          >
            ← Back to leagues
          </button>
        )}
      </div>
      
      {!showLeagueDetails ? (
        // Use our new accordion-style leagues list with win probability
        <LeaguesList 
          leagues={leagues} 
          isLoading={isLoadingLeagues}
          onSelectLeague={handleSelectLeague}
        />
      ) : (
        // Show the selected league details when a user clicks "View Full League Details"
        <Card className="mb-4 shadow-sm bg-gray-900/95 border-gray-700 text-white">
          <Tabs 
            defaultValue="ladder" 
            value={activeTab}
            onValueChange={setActiveTab}
          >
            <div className="flex border-b border-gray-700">
              <TabsList className="bg-transparent h-auto">
                <TabsTrigger 
                  value="ladder" 
                  className="px-4 py-2 data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:font-medium data-[state=active]:text-primary rounded-none text-gray-300 data-[state=active]:text-white"
                >
                  League Ladder
                </TabsTrigger>
                <TabsTrigger 
                  value="matchups" 
                  className="px-4 py-2 data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:font-medium data-[state=active]:text-primary rounded-none text-gray-300 data-[state=active]:text-white"
                >
                  Live Matchups
                </TabsTrigger>
              </TabsList>
            </div>
            
            <TabsContent value="ladder" className="p-0 border-none">
              <LeagueLadder 
                teams={formattedLeagueTeams} 
                isLoading={isLoading} 
              />
            </TabsContent>
            
            <TabsContent value="matchups" className="p-0 border-none">
              <LiveMatchups 
                matchups={formattedMatchups} 
                round={currentRound}
                isLoading={isLoading} 
              />
            </TabsContent>
          </Tabs>
        </Card>
      )}
    </div>
  );
}
