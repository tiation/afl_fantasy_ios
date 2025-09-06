import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { useToast } from "@/hooks/use-toast";
import TeamSummaryNew from "@/components/lineup/team-summary-new";
import TeamSummaryGrid from "@/components/lineup/team-summary-grid";
import TeamLineup from "@/components/lineup/team-lineup";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Player as BasePlayer } from "@/components/player-stats/player-table";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import PlayerDetailModal from "@/components/player-stats/player-detail-modal";
import { Player as DetailPlayer } from "@/components/player-stats/player-types";
import { TradeCalculatorModal } from "@/components/trade/trade-calculator-modal";
import { TeamPlayer } from "@/components/lineup/team-types";
import { fetchUserTeam, convertTeamDataToLineupFormat, uploadTeam } from "@/services/teamService";
import { Textarea } from "@/components/ui/textarea";
import { AlertCircle, UploadCloud, RefreshCw } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";

// Extend Player type for lineup view
type Player = BasePlayer & {
  isCaptain?: boolean;
  isOnBench?: boolean;
  secondaryPositions?: string[];
  nextOpponent?: string;
  l3Average?: number;
  roundsPlayed?: number;
};

export default function Lineup() {
  const { toast } = useToast();
  
  // UI states
  const [view, setView] = useState<"cards" | "list">("cards");
  const [selectedPlayer, setSelectedPlayer] = useState<DetailPlayer | null>(null);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState<boolean>(false);
  const [isTradeCalculatorOpen, setIsTradeCalculatorOpen] = useState<boolean>(false);
  
  // Team data states
  const [enhancedPlayers, setEnhancedPlayers] = useState<Player[]>([]);
  const [userTeam, setUserTeam] = useState<any>(null);
  const [userTeamPlayers, setUserTeamPlayers] = useState<{
    midfielders: TeamPlayer[],
    defenders: TeamPlayer[],
    forwards: TeamPlayer[],
    rucks: TeamPlayer[]
  } | null>(null);
  const [isLoadingUserTeam, setIsLoadingUserTeam] = useState<boolean>(false);
  const [hasUserTeamError, setHasUserTeamError] = useState<boolean>(false);
  
  // Sample team text for the textarea
  const [teamText, setTeamText] = useState<string>(`Defenders
Harry sheezel
Jayden short
Matt roberts
Riley bice
Jaxon prior
Zach Reid
Defenders bench 
Finn O'Sullivan 
Connor stone 

Midfielders 
Jordan Dawson 
Andrew Brayshaw 
Nick daicos 
Connor rozee
Zach Merrett
Clayton Oliver
Levi Ashcroft 
Xavier Lindsay
Midfielders bench 
Hugh boxshall
Isaac Kako

Rucks 
Tristan xerri
Tom de konning 
Bench ruck
Harry Boyd

Forwards 
Isaac Rankine 
Christian petracca
Bailey Smith 
Jack MacRae
Caleb Daniel
San Davidson 
Forward bench
Caiden Cleary
Campbell gray

Bench utility 
James leake`);

  // API data for the demo team
  type Team = {
    id: number;
    userId: number;
    name: string;
    value: number;
    score: number;
    overallRank: number;
    trades: number;
    captainId: number;
  };

  type TeamPlayer = {
    teamId: number;
    playerId: number;
    position: string;
    player: BasePlayer;
  };

  const { data: team, isLoading: isLoadingTeam } = useQuery<Team>({
    queryKey: ["/api/teams/user/1"],
  });

  const { data: teamPlayers, isLoading: isLoadingPlayers } = useQuery<TeamPlayer[]>({
    queryKey: ["/api/teams/1/players"],
    enabled: !!team,
  });
  
  // When teamPlayers data is loaded, process it to get enhanced player info
  useEffect(() => {
    if (teamPlayers && Array.isArray(teamPlayers)) {
      // Map the teamPlayers data to match the Player type needed for TeamLineup
      const players = teamPlayers.map((tp: any, index) => {
        // Add on bench status for some players
        const isOnBench = index % 4 === 3; // Every 4th player is on bench
        
        // Add secondary positions for some players
        const secondaryMap: {[key: string]: string[]} = {
          "MID": ["F"],  // Midfielders can play as Forwards
          "FWD": ["M"],  // Forwards can play as Midfielders
          "DEF": ["M"],  // Defenders can play as Midfielders
          "RUCK": ["F"]  // Rucks can play as Forwards
        };
        
        // Only some players have secondary positions
        const secondaryPositions = (tp.player.id % 3 === 0)
          ? secondaryMap[tp.position] || []
          : undefined;
          
        // Add live score simulation for demo
        const liveScore = Math.floor(Math.random() * 100);
        
        // Add team abbreviation and next opponent (for display purposes)
        const teamAbbrevs = ["COL", "HAW", "GWS", "CAR", "NTH", "WCE", "ESS", "RIC", "SYD", "STK", "ADE", "MEL", "GEE", "PTA", "BRL", "WBD", "GCS"];
        const opponentAbbrevs = ["WBD", "ESS", "CAR", "HAW", "GCS", "GEE", "COL", "PTA", "NTH", "BRL", "GWS", "ADE", "WCE", "RIC", "STK", "SYD", "MEL"];
        
        const teamIndex = tp.player.id % teamAbbrevs.length;
        const teamAbbr = teamAbbrevs[teamIndex];
        const nextOpponent = opponentAbbrevs[teamIndex];
        
        return {
          ...tp.player,
          position: tp.position,
          isCaptain: team?.captainId === tp.player.id,
          isOnBench,
          secondaryPositions,
          liveScore,
          team: teamAbbr,
          nextOpponent,
          l3Average: (tp.player.averagePoints || 80) + (Math.random() * 10 - 5),
          roundsPlayed: 7 + (tp.player.id % 3)
        };
      });
      
      setEnhancedPlayers(players);
    }
  }, [teamPlayers, team]);

  const handleMakeTrade = () => {
    setIsTradeCalculatorOpen(true);
  };
  
  // Handler for opening player detail modal
  const openPlayerDetailModal = (player: any) => {
    // Convert player data to the format expected by PlayerDetailModal
    const detailPlayer = {
      id: player.id,
      name: player.name,
      team: player.team || "",
      position: player.position,
      price: player.price || 0,
      breakEven: player.breakEven || 0,
      category: player.position || "",
      averagePoints: player.averagePoints || 0,
      lastScore: player.lastScore || null,
      projectedScore: player.projScore || null,
      roundsPlayed: player.roundsPlayed || 0,
      l3Average: player.l3Average || null,
      nextOpponent: player.nextOpponent || null,
      // Add other fields from player-types.ts with null values
      l5Average: null,
      priceChange: 0,
      pricePerPoint: null,
      totalPoints: player.averagePoints ? player.averagePoints * (player.roundsPlayed || 7) : 0,
      selectionPercentage: null,
      // Basic stats
      kicks: null,
      handballs: null,
      disposals: null,
      marks: null,
      tackles: null,
      freeKicksFor: null,
      freeKicksAgainst: null,
      clearances: null,
      hitouts: null,
      cba: null,
      kickIns: null,
      uncontestedMarks: null,
      contestedMarks: null,
      uncontestedDisposals: null,
      contestedDisposals: null,
      // Status
      isSelected: true,
      isInjured: false,
      isSuspended: false,
    };
    
    setSelectedPlayer(detailPlayer);
    setIsDetailModalOpen(true);
  };
  
  // Load user team
  const loadUserTeam = async () => {
    setIsLoadingUserTeam(true);
    setHasUserTeamError(false);
    
    try {
      const teamData = await fetchUserTeam();
      setUserTeam(teamData);
      
      if (teamData) {
        const formatted = convertTeamDataToLineupFormat(teamData);
        setUserTeamPlayers({
          midfielders: formatted.midfielders || [],
          forwards: formatted.forwards || [],
          defenders: formatted.defenders || [],
          rucks: formatted.rucks || []
        });
      }
    } catch (error) {
      console.error('Error loading user team:', error);
      setHasUserTeamError(true);
    } finally {
      setIsLoadingUserTeam(false);
    }
  };
  
  // Upload team
  const handleUploadTeam = async () => {
    if (!teamText) {
      toast({
        title: "Error",
        description: "Please enter your team data",
        variant: "destructive"
      });
      return;
    }
    
    setIsLoadingUserTeam(true);
    setHasUserTeamError(false);
    
    try {
      const uploadedTeam = await uploadTeam(teamText);
      setUserTeam(uploadedTeam);
      
      if (uploadedTeam) {
        const formatted = convertTeamDataToLineupFormat(uploadedTeam);
        setUserTeamPlayers({
          midfielders: formatted.midfielders || [],
          forwards: formatted.forwards || [],
          defenders: formatted.defenders || [],
          rucks: formatted.rucks || []
        });
        
        toast({
          title: "Success",
          description: "Your team has been uploaded with accurate data",
          variant: "default"
        });
      }
    } catch (error) {
      console.error('Error uploading team:', error);
      setHasUserTeamError(true);
      
      toast({
        title: "Error",
        description: "Failed to upload team. Please try again.",
        variant: "destructive"
      });
    } finally {
      setIsLoadingUserTeam(false);
    }
  };
  
  // Effect to try loading the user team on component mount
  useEffect(() => {
    loadUserTeam();
  }, []);

  const isLoading = isLoadingTeam || isLoadingPlayers;

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-40">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full"></div>
      </div>
    );
  }

  // Define a helper function to add isOnBench flag (alternating players for demonstration)
  const assignBenchStatus = (players: any[], mainCount: number, benchCount: number) => {
    return players.map((p, index) => ({
      ...p,
      isOnBench: index >= mainCount
    })).slice(0, mainCount + benchCount);
  };

  // Add secondary positions to some players (for demonstration)
  const addSecondaryPositions = (player: any) => {
    const secondaryMap: {[key: string]: string[]} = {
      "MID": ["F"],  // Midfielders can play as Forwards
      "FWD": ["M"],  // Forwards can play as Midfielders
      "DEF": ["M"],  // Defenders can play as Midfielders
      "RUCK": ["F"]  // Rucks can play as Forwards
    };
    
    // Randomly assign secondary positions to some players
    if (player.id % 3 === 0) {
      return {
        ...player,
        secondaryPositions: secondaryMap[player.position] || []
      };
    }
    
    return player;
  };
  
  // Function to add team information and next opponent
  const addTeamInfo = (player: any) => {
    const teamAbbrevs = ["COL", "HAW", "GWS", "CAR", "NTH", "WCE", "ESS", "RIC", "SYD", "STK", "ADE", "MEL", "GEE", "PTA", "BRL", "WBD", "GCS"];
    const opponentAbbrevs = ["WBD", "ESS", "CAR", "HAW", "GCS", "GEE", "COL", "PTA", "NTH", "BRL", "GWS", "ADE", "WCE", "RIC", "STK", "SYD", "MEL"];
    
    const teamIndex = player.id % teamAbbrevs.length;
    const team = teamAbbrevs[teamIndex];
    const nextOpponent = opponentAbbrevs[teamIndex];
    
    return {
      ...player,
      team,
      nextOpponent,
      l3Average: (player.averagePoints || 80) + (Math.random() * 10 - 5),
      roundsPlayed: 7 + (player.id % 3)
    };
  };

  // Organize players by position for traditional view with all necessary stats
  const midfielders = assignBenchStatus(
    (teamPlayers || [])
      .filter((tp: any) => tp.position === "MID")
      .map((tp: any) => addTeamInfo(addSecondaryPositions({
        id: tp.player.id,
        name: tp.player.name,
        position: tp.position,
        price: tp.player.price,
        breakEven: tp.player.breakEven,
        lastScore: tp.player.lastScore,
        averagePoints: tp.player.averagePoints,
        liveScore: Math.floor(Math.random() * 100), // Simulated live score
        isCaptain: team?.captainId === tp.player.id
      }))),
    8, // 8 on field
    2  // 2 on bench
  );

  const forwards = assignBenchStatus(
    (teamPlayers || [])
      .filter((tp: any) => tp.position === "FWD")
      .map((tp: any) => addTeamInfo(addSecondaryPositions({
        id: tp.player.id,
        name: tp.player.name,
        position: tp.position,
        price: tp.player.price,
        breakEven: tp.player.breakEven,
        lastScore: tp.player.lastScore,
        averagePoints: tp.player.averagePoints,
        liveScore: Math.floor(Math.random() * 100), // Simulated live score
        isCaptain: team?.captainId === tp.player.id
      }))),
    6, // 6 on field
    2  // 2 on bench
  );

  const defenders = assignBenchStatus(
    (teamPlayers || [])
      .filter((tp: any) => tp.position === "DEF")
      .map((tp: any) => addTeamInfo(addSecondaryPositions({
        id: tp.player.id,
        name: tp.player.name,
        position: tp.position,
        price: tp.player.price,
        breakEven: tp.player.breakEven,
        lastScore: tp.player.lastScore,
        averagePoints: tp.player.averagePoints,
        liveScore: Math.floor(Math.random() * 100), // Simulated live score
        isCaptain: team?.captainId === tp.player.id
      }))),
    6, // 6 on field
    2  // 2 on bench
  );

  const rucks = assignBenchStatus(
    (teamPlayers || [])
      .filter((tp: any) => tp.position === "RUCK")
      .map((tp: any) => addTeamInfo(addSecondaryPositions({
        id: tp.player.id,
        name: tp.player.name,
        position: tp.position,
        price: tp.player.price,
        breakEven: tp.player.breakEven,
        lastScore: tp.player.lastScore,
        averagePoints: tp.player.averagePoints,
        liveScore: Math.floor(Math.random() * 100), // Simulated live score
        isCaptain: team?.captainId === tp.player.id
      }))),
    2, // 2 on field
    1  // 1 on bench
  );

  // Calculate additional statistics for the summary grid
  const totalValue = team?.value || 0;
  const totalPlayers = midfielders.length + forwards.length + defenders.length + rucks.length;
  const remainingSalary = 10000000 - totalValue; // Assuming 10M salary cap
  const liveScore = midfielders.concat(forwards, defenders, rucks)
    .reduce((sum, player) => sum + (player.liveScore || 0), 0);
  const projectedScore = Math.floor(liveScore * 1.2); // Simple projection for demo
  
  // Determine which team data to use (user team or demo team)
  const activeTeamData = userTeamPlayers ? {
    midfielders: userTeamPlayers.midfielders,
    forwards: userTeamPlayers.forwards,
    defenders: userTeamPlayers.defenders,
    rucks: userTeamPlayers.rucks
  } : {
    midfielders,
    forwards,
    defenders,
    rucks
  };
  
  return (
    <div className="container mx-auto px-3 py-6">
      <div className="mb-4">
        <Card className="bg-gray-900 border-gray-700 shadow-lg">
          <div className="p-4">
            <h1 className="text-xl font-bold mb-4 text-white">My Lineup</h1>
            
            {/* Team loading button */}
            <div className="mb-4 flex justify-end">
              <Button 
                variant="outline" 
                className="border-gray-600 bg-gray-800 text-white hover:bg-gray-700"
                onClick={loadUserTeam} 
                disabled={isLoadingUserTeam}
              >
                {isLoadingUserTeam ? (
                  <>
                    <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                    Loading...
                  </>
                ) : (
                  <>
                    <RefreshCw className="mr-2 h-4 w-4" />
                    Refresh Team Data
                  </>
                )}
              </Button>
              
              {hasUserTeamError && (
                <Alert variant="destructive" className="mt-3">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>
                    Failed to load team data. Please try again.
                  </AlertDescription>
                </Alert>
              )}
            </div>
            
            {/* 3x2 Stats Grid */}
            <TeamSummaryGrid
              liveScore={liveScore}
              projectedScore={projectedScore}
              teamValue={totalValue}
              remainingSalary={remainingSalary}
              tradesLeft={team?.trades || 0}
              overallRank={team?.overallRank || 0}
            />
            
            {/* Lineup Display */}
            <div className="mt-6">
              <TeamSummaryNew 
                midfielders={activeTeamData.midfielders}
                forwards={activeTeamData.forwards}
                defenders={activeTeamData.defenders}
                rucks={activeTeamData.rucks}
                tradesAvailable={team?.trades || 0}
                onMakeTrade={handleMakeTrade}
                onPlayerClick={openPlayerDetailModal}
              />
            </div>
          </div>
        </Card>
      </div>
      
      {/* Player Detail Modal */}
      <PlayerDetailModal 
        player={selectedPlayer}
        open={isDetailModalOpen}
        onOpenChange={setIsDetailModalOpen}
      />
      
      {/* Trade Calculator Modal */}
      <TradeCalculatorModal
        open={isTradeCalculatorOpen}
        onOpenChange={setIsTradeCalculatorOpen}
        onPlayerDetailClick={openPlayerDetailModal}
        initialTeamValue={totalValue}
        initialLeagueAvgValue={8500000}
        initialRound={8}
      />
    </div>
  );
}