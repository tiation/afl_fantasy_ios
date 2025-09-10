import { useState, useEffect } from "react";
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogFooter,
  DialogDescription
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Search, Calculator, ArrowLeftRight, TrendingUp, Trash2 } from "lucide-react";
import { formatCurrency, formatScore } from "@/lib/utils";
import { Player as DetailPlayer } from "@/components/player-stats/player-types";
import { useToast } from "@/hooks/use-toast";
import { apiRequest } from "@/lib/queryClient";
import { useQuery } from "@tanstack/react-query";

export type TradingPlayer = {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  averagePoints: number;
  breakEven: number;
  projectedPoints: number;
  lastScore: number;
  selectedBy?: number;
};

type TradeCalculatorModalProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onPlayerDetailClick?: (player: DetailPlayer) => void;
  initialTeamValue?: number;
  initialLeagueAvgValue?: number;
  initialRound?: number;
};

export function TradeCalculatorModal({
  open,
  onOpenChange,
  onPlayerDetailClick,
  initialTeamValue = 15200000,
  initialLeagueAvgValue = 14800000,
  initialRound = 8
}: TradeCalculatorModalProps) {
  const [selectedOutPlayers, setSelectedOutPlayers] = useState<TradingPlayer[]>([]);
  const [selectedInPlayers, setSelectedInPlayers] = useState<TradingPlayer[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [showResults, setShowResults] = useState(false);
  const [isSearching, setIsSearching] = useState(false);
  const [searchResults, setSearchResults] = useState<TradingPlayer[]>([]);
  const [selectingFor, setSelectingFor] = useState<"in" | "out">("out");
  const [isLoading, setIsLoading] = useState(false);
  const [tradeScore, setTradeScore] = useState<any>(null);
  const { toast } = useToast();

  // Fetch players from API
  const { data: scrapedPlayers = [], isLoading: isScrapedLoading } = useQuery<any[]>({
    queryKey: ["/api/scraped-players"],
    enabled: open, // Only fetch when modal is open
  });
  
  // Fallback to standard player API if scraped data is not available
  const { data: dbPlayers = [], isLoading: isDbLoading } = useQuery<any[]>({
    queryKey: ["/api/players"],
    enabled: open && (!scrapedPlayers || scrapedPlayers.length === 0), // Only fetch if scraped data is empty
  });

  // Transform API players to TradingPlayer format
  const transformApiPlayers = (apiPlayers: any[]): TradingPlayer[] => {
    if (!apiPlayers || apiPlayers.length === 0) return [];
    
    return apiPlayers.map(player => ({
      id: player.id,
      name: player.name || "Unknown Player",
      position: player.position || "NA",
      team: player.team || "NA",
      price: player.price || 0,
      averagePoints: player.averagePoints || player.average || 0,
      breakEven: player.breakEven || player.breakeven || 0,
      projectedPoints: player.projectedScore || player.projectedPoints || player.averagePoints || player.average || 0,
      lastScore: player.lastScore || player.last1 || 0,
      selectedBy: player.selectionPercentage || 0
    }));
  };
  
  // Combine the players from either source
  const allPlayers: TradingPlayer[] = (scrapedPlayers && scrapedPlayers.length > 0) ? 
    transformApiPlayers(scrapedPlayers) : 
    (dbPlayers && dbPlayers.length > 0) ? 
      transformApiPlayers(dbPlayers) : 
      [];

  // Handle search using real player data from API
  const handleSearch = () => {
    if (searchQuery.trim().length < 2) return;
    
    setIsSearching(true);
    
    // Search through fetched players
    setTimeout(() => {
      // Allow partial name matching and ignore trailing spaces
      const query = searchQuery.trim().toLowerCase();
      
      // Filter the real players data
      const results = allPlayers.filter(player => 
        (player.name?.toLowerCase().includes(query)) ||
        (player.team?.toLowerCase().includes(query)) ||
        (player.position?.toLowerCase().includes(query))
      );
      
      setSearchResults(results);
      setShowResults(true);
      setIsSearching(false);
    }, 300);
  };

  // Convert trading player to detail player format for modal
  const convertToDetailPlayer = (player: TradingPlayer): DetailPlayer => {
    return {
      id: player.id,
      name: player.name,
      team: player.team,
      position: player.position,
      price: player.price,
      breakEven: player.breakEven,
      category: player.position,
      averagePoints: player.averagePoints,
      lastScore: player.lastScore,
      projectedScore: player.projectedPoints,
      // Status flags
      isSelected: true,
      isInjured: false,
      isSuspended: false,
      // Fill in other required fields with null values
      priceChange: 0,
      roundsPlayed: 7,
      l3Average: player.averagePoints,
      selectionPercentage: player.selectedBy || null,
      totalPoints: player.averagePoints * 7,
      nextOpponent: null,
      pricePerPoint: null,
      l5Average: null,
      kicks: null,
      handballs: null,
      disposals: null,
      marks: null,
      tackles: null,
      freeKicksFor: null,
      freeKicksAgainst: null, 
      clearances: null,
      cba: null,
      kickIns: null,
      uncontestedMarks: null,
      contestedMarks: null,
      uncontestedDisposals: null,
      contestedDisposals: null,
      hitouts: null,
      last1: player.lastScore,
      last2: null,
      last3: null,
    };
  };

  const handlePlayerDetailClick = (player: TradingPlayer) => {
    if (onPlayerDetailClick) {
      onPlayerDetailClick(convertToDetailPlayer(player));
    }
  };

  // Add player to selected list
  const addPlayer = (player: TradingPlayer, type: "in" | "out") => {
    if (type === "in") {
      setSelectedInPlayers([...selectedInPlayers, player]);
    } else {
      setSelectedOutPlayers([...selectedOutPlayers, player]);
    }
    
    setShowResults(false);
    setSearchQuery("");
  };

  // Remove player from selected list
  const removePlayer = (index: number, type: "in" | "out") => {
    if (type === "in") {
      setSelectedInPlayers(selectedInPlayers.filter((_, i) => i !== index));
    } else {
      setSelectedOutPlayers(selectedOutPlayers.filter((_, i) => i !== index));
    }
    
    // Reset trade score when players change
    setTradeScore(null);
  };

  // Calculate the differences
  const calculateTrade = async () => {
    if (selectedInPlayers.length === 0 || selectedOutPlayers.length === 0) {
      toast({
        title: "Incomplete Trade",
        description: "Please select at least one player to trade in and one player to trade out.",
        variant: "destructive"
      });
      return;
    }
    
    setIsLoading(true);
    
    try {
      // Create a payload for the trade score API
      const playerIn = {
        price: selectedInPlayers[0].price,
        breakeven: selectedInPlayers[0].breakEven,
        proj_scores: [selectedInPlayers[0].projectedPoints, selectedInPlayers[0].projectedPoints * 0.95, 
                    selectedInPlayers[0].projectedPoints * 1.05, selectedInPlayers[0].projectedPoints * 0.98, 
                    selectedInPlayers[0].projectedPoints],
        is_red_dot: false
      };
      
      const playerOut = {
        price: selectedOutPlayers[0].price,
        breakeven: selectedOutPlayers[0].breakEven,
        proj_scores: [selectedOutPlayers[0].projectedPoints, selectedOutPlayers[0].projectedPoints * 0.97, 
                    selectedOutPlayers[0].projectedPoints * 1.02, selectedOutPlayers[0].projectedPoints * 0.99, 
                    selectedOutPlayers[0].projectedPoints],
        is_red_dot: false
      };
      
      const payload = {
        player_in: playerIn,
        player_out: playerOut,
        round_number: initialRound,
        team_value: initialTeamValue,
        league_avg_value: initialLeagueAvgValue
      };
      
      // Make API request
      try {
        const response = await apiRequest("POST", "/api/trade_score", payload);
        const data = await response.json();
        
        if (data.status === "ok") {
          setTradeScore(data);
        } else {
          // If API fails, use a basic calculation
          const totalInPrice = selectedInPlayers.reduce((sum, p) => sum + p.price, 0);
          const totalOutPrice = selectedOutPlayers.reduce((sum, p) => sum + p.price, 0);
          const priceDifference = totalInPrice - totalOutPrice;
          
          const totalInPoints = selectedInPlayers.reduce((sum, p) => sum + (p.projectedPoints || 0), 0);
          const totalOutPoints = selectedOutPlayers.reduce((sum, p) => sum + (p.projectedPoints || 0), 0);
          const pointsDifference = totalInPoints - totalOutPoints;
          
          const valuePerPoint = Math.abs(priceDifference) / Math.abs(pointsDifference || 1);
          
          setTradeScore({
            status: "ok",
            trade_score: pointsDifference > 0 && priceDifference <= 0 ? 85 : pointsDifference > 0 ? 75 : 40,
            priceDifference,
            pointsDifference,
            valuePerPoint: isFinite(valuePerPoint) ? valuePerPoint : 0,
            isAffordable: priceDifference <= 0,
            _fallback: true,
            recommendation: pointsDifference > 5 ? "Good trade that improves your scoring potential" : 
                          pointsDifference > 0 ? "Slight scoring improvement" : 
                          "Not recommended - scoring will decrease"
          });
        }
      } catch (err) {
        console.error("Trade analysis error:", err);
        toast({
          title: "Analysis Failed",
          description: "Unable to analyze the trade at this time. Please try again later.",
          variant: "destructive"
        });
      }
    } finally {
      setIsLoading(false);
    }
  };

  // Helper to get score color
  const getScoreColor = (score: number) => {
    if (score >= 80) return "text-green-600";
    if (score >= 60) return "text-emerald-500";
    if (score >= 40) return "text-amber-500";
    return "text-red-500";
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl overflow-y-auto max-h-[90vh]">
        <DialogHeader>
          <DialogTitle>Trade Calculator</DialogTitle>
          <DialogDescription>
            Calculate the points impact and value of potential trades by selecting players to trade in and out.
          </DialogDescription>
        </DialogHeader>
        
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="border rounded-md overflow-hidden">
              <div className="bg-red-100 py-2 px-3 font-medium flex items-center text-sm">
                <Trash2 className="h-4 w-4 mr-2 text-red-600" />
                <span>Players to Trade Out</span>
              </div>
              
              <div className="p-3 space-y-2">
                {selectedOutPlayers.length === 0 ? (
                  <div className="text-sm text-gray-400 text-center py-4">
                    No players selected to trade out yet
                  </div>
                ) : (
                  <div className="space-y-2">
                    {selectedOutPlayers.map((player, index) => (
                      <div key={player.id} className="flex justify-between items-center bg-gray-50 rounded-md p-2 text-sm">
                        <div>
                          <div 
                            className="font-medium cursor-pointer hover:text-primary"
                            onClick={() => handlePlayerDetailClick(player)}
                          >
                            {player.name}
                          </div>
                          <div className="text-xs text-gray-600">
                            {player.position} | {player.team} | {formatCurrency(player.price)}
                          </div>
                        </div>
                        <div className="flex space-x-3 items-center">
                          <div className="text-right">
                            <div className="font-medium">
                              {player.projectedPoints !== undefined ? player.projectedPoints.toFixed(1) : "0.0"}
                            </div>
                            <div className="text-xs text-gray-600">Proj. Pts</div>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 w-8 p-0"
                            onClick={() => removePlayer(index, "out")}
                          >
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
                
                <Button
                  className="w-full text-sm h-8 mt-2"
                  variant="outline"
                  onClick={() => {
                    setSelectingFor("out");
                    setShowResults(false);
                  }}
                >
                  <Search className="h-4 w-4 mr-2" />
                  Add Player to Trade Out
                </Button>
              </div>
            </div>
            
            <div className="border rounded-md overflow-hidden">
              <div className="bg-green-100 py-2 px-3 font-medium flex items-center text-sm">
                <TrendingUp className="h-4 w-4 mr-2 text-green-600" />
                <span>Players to Trade In</span>
              </div>
              
              <div className="p-3 space-y-2">
                {selectedInPlayers.length === 0 ? (
                  <div className="text-sm text-gray-400 text-center py-4">
                    No players selected to trade in yet
                  </div>
                ) : (
                  <div className="space-y-2">
                    {selectedInPlayers.map((player, index) => (
                      <div key={player.id} className="flex justify-between items-center bg-gray-50 rounded-md p-2 text-sm">
                        <div>
                          <div 
                            className="font-medium cursor-pointer hover:text-primary"
                            onClick={() => handlePlayerDetailClick(player)}
                          >
                            {player.name}
                          </div>
                          <div className="text-xs text-gray-600">
                            {player.position} | {player.team} | {formatCurrency(player.price)}
                          </div>
                        </div>
                        <div className="flex space-x-3 items-center">
                          <div className="text-right">
                            <div className="font-medium">
                              {player.projectedPoints !== undefined ? player.projectedPoints.toFixed(1) : "0.0"}
                            </div>
                            <div className="text-xs text-gray-600">Proj. Pts</div>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 w-8 p-0"
                            onClick={() => removePlayer(index, "in")}
                          >
                            <Trash2 className="h-4 w-4 text-red-500" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
                
                <Button
                  className="w-full text-sm h-8 mt-2"
                  variant="outline"
                  onClick={() => {
                    setSelectingFor("in");
                    setShowResults(false);
                  }}
                >
                  <Search className="h-4 w-4 mr-2" />
                  Add Player to Trade In
                </Button>
              </div>
            </div>
          </div>
          
          {(selectingFor === "in" || selectingFor === "out") && (
            <div className="border rounded-md overflow-hidden">
              <div className="bg-gray-100 py-2 px-3 font-medium text-sm flex items-center justify-between">
                <div>
                  Search for players to trade {selectingFor}
                </div>
                <Button 
                  variant="ghost" 
                  size="sm" 
                  className="h-6" 
                  onClick={() => setSelectingFor(selectingFor === "in" ? "out" : "in")}
                >
                  Switch to {selectingFor === "in" ? "Out" : "In"}
                </Button>
              </div>
              <div className="p-3">
                <div className="flex mb-3">
                  <Input 
                    placeholder="Search players by name, team or position..." 
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleSearch()}
                    className="mr-2"
                  />
                  <Button variant="default" onClick={handleSearch} disabled={isSearching}>
                    {isSearching ? (
                      <div className="h-4 w-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    ) : (
                      <Search className="h-4 w-4" />
                    )}
                  </Button>
                </div>
                
                {isScrapedLoading || isDbLoading ? (
                  <div className="flex justify-center items-center py-4">
                    <div className="animate-spin w-5 h-5 border-2 border-primary border-t-transparent rounded-full mr-2"></div>
                    <span className="text-sm text-gray-500">Loading player data...</span>
                  </div>
                ) : showResults && (
                  <div className="max-h-60 overflow-y-auto">
                    {searchResults.length === 0 ? (
                      <div className="text-center py-4 text-gray-500">
                        No players found matching your search.
                      </div>
                    ) : (
                      <div className="divide-y">
                        {searchResults.map(player => (
                          <div key={player.id} className="py-2 px-1 hover:bg-gray-50 cursor-pointer" onClick={() => addPlayer(player, selectingFor)}>
                            <div className="font-medium text-sm flex items-center">
                              {player.name}
                              <span className="ml-2 px-1.5 py-0.5 bg-gray-100 rounded text-xs font-normal">
                                {player.position}
                              </span>
                            </div>
                            <div className="flex justify-between items-center mt-1">
                              <div className="text-xs text-gray-500">{player.team} | {formatCurrency(player.price)}</div>
                              <div className="text-xs">
                                {player.averagePoints !== undefined ? `Avg: ${player.averagePoints.toFixed(1)}` : 'Avg: N/A'}
                              </div>
                            </div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
              </div>
            </div>
          )}
          
          <div className="border rounded-md overflow-hidden">
            <div className="bg-blue-100 py-2 px-3 font-medium flex items-center justify-between text-sm">
              <div className="flex items-center">
                <Calculator className="h-4 w-4 mr-2 text-blue-600" />
                <span>Trade Analysis</span>
              </div>
              
              <Button
                variant="default"
                size="sm"
                className="bg-blue-600 h-7 text-xs"
                onClick={calculateTrade}
                disabled={selectedInPlayers.length === 0 || selectedOutPlayers.length === 0 || isLoading}
              >
                {isLoading ? (
                  <div className="h-4 w-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                ) : (
                  "Calculate"
                )}
              </Button>
            </div>
            
            <div className="p-3">
              {!tradeScore ? (
                <div className="text-sm text-gray-400 text-center py-4">
                  Select players and click Calculate to analyze trade
                </div>
              ) : (
                <div className="space-y-4">
                  <div className="text-center">
                    <div className="text-xs text-gray-500 mb-1">Trade Score</div>
                    <div 
                      className={`text-3xl font-bold ${getScoreColor(tradeScore.trade_score)}`}
                    >
                      {typeof tradeScore.trade_score === 'number' ? tradeScore.trade_score : 0}
                    </div>
                    
                    {tradeScore.recommendation && (
                      <div className="text-sm mt-1">
                        {tradeScore.recommendation}
                      </div>
                    )}
                  </div>
                  
                  <div className="grid grid-cols-3 gap-3">
                    <div className="bg-gray-50 rounded-md p-3 text-center">
                      <div className="text-xs text-gray-500 mb-1">Price Difference</div>
                      <div className={`font-medium ${tradeScore.priceDifference > 0 ? 'text-red-600' : 'text-green-600'}`}>
                        {formatCurrency(tradeScore.priceDifference || 0)}
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-3 text-center">
                      <div className="text-xs text-gray-500 mb-1">Points Impact</div>
                      <div className={`font-medium ${(tradeScore.pointsDifference || 0) < 0 ? 'text-red-600' : 'text-green-600'}`}>
                        {!tradeScore.pointsDifference ? 'Even' : 
                          `${(tradeScore.pointsDifference || 0) > 0 ? '+' : ''}${
                            typeof tradeScore.pointsDifference === 'number' ? 
                            tradeScore.pointsDifference.toFixed(1) : '0.0'
                          }`
                        }
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-3 text-center">
                      <div className="text-xs text-gray-500 mb-1">$/Point</div>
                      <div className="font-medium">
                        {tradeScore.valuePerPoint ? formatCurrency(tradeScore.valuePerPoint) : 'N/A'}
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-3 text-center">
                      <div className="text-xs text-gray-500 mb-1">Affordability</div>
                      <div className={`font-medium ${tradeScore.isAffordable ? 'text-green-600' : 'text-red-600'}`}>
                        {tradeScore.isAffordable ? 'Affordable' : 'Requires Funds'}
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
        
        <DialogFooter>
          <Button 
            variant="outline" 
            onClick={() => {
              setSelectedInPlayers([]);
              setSelectedOutPlayers([]);
              setTradeScore(null);
              setSearchQuery("");
              setShowResults(false);
            }}
          >
            Reset
          </Button>
          <Button onClick={() => onOpenChange(false)}>Close</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}