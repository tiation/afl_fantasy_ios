import { useState, useMemo, useCallback } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { calculatePricePredictor, fetchPlayerData } from "@/services/cashService";
import { useToast } from "@/hooks/use-toast";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "@/components/ui/table";
import { TrendingUp, TrendingDown, LineChart, Search, Edit3 } from "lucide-react";
import { Label } from "@/components/ui/label";
import { 
  Select, 
  SelectContent, 
  SelectGroup, 
  SelectItem, 
  SelectLabel, 
  SelectTrigger, 
  SelectValue 
} from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";

type Player = {
  name: string;
  team: string;
  price: number;
  breakeven: number;
  position: string;
  l3_avg: number;
  avg: number;
  games: number;
};

type PricePrediction = {
  player: string;
  starting_price: number;
  starting_breakeven: number;
  price_changes: {
    round: number;
    score: number;
    price_change: number;
    new_price: number;
  }[];
  final_price: number;
};

export function PricePredictorCalculator() {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  const [selectedPosition, setSelectedPosition] = useState<string>("all");
  const [predictedScores, setPredictedScores] = useState<number[]>([0, 0, 0]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [prediction, setPrediction] = useState<PricePrediction | null>(null);
  const { toast } = useToast();
  
  // Fetch player data
  const { data: playerData, isLoading } = useQuery({
    queryKey: ['/api/fantasy/player_data'],
    queryFn: async () => {
      return await fetchPlayerData();
    },
    staleTime: 1000 * 60 * 5, // Cache for 5 minutes
  });
  
  // Define type for API response
  type PlayerDataResponse = {
    players: Player[];
  }
  
  // Filtered players based on search and position
  const filteredPlayers = useMemo(() => {
    if (!playerData) return [];
    
    const typedData = playerData as PlayerDataResponse;
    let filtered = typedData.players;
    
    // Filter by position
    if (selectedPosition !== "all") {
      filtered = filtered.filter(p => p.position.toUpperCase() === selectedPosition.toUpperCase());
    }
    
    // Filter by search term
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      filtered = filtered.filter(p => 
        p.name.toLowerCase().includes(term) || 
        p.team.toLowerCase().includes(term)
      );
    }
    
    return filtered;
  }, [playerData, searchTerm, selectedPosition]);
  
  // Update individual score
  const updateScore = (index: number, value: string) => {
    const newScores = [...predictedScores];
    newScores[index] = parseInt(value) || 0;
    setPredictedScores(newScores);
  };
  
  // Set scores based on average
  const setScoresFromAverage = () => {
    if (!selectedPlayer) return;
    
    // Use last 3 game average if available, otherwise use season average
    const avgScore = Math.round(selectedPlayer.l3_avg || selectedPlayer.avg || 0);
    setPredictedScores([avgScore, avgScore, avgScore]);
  };
  
  // Calculate price prediction
  const calculatePrediction = async () => {
    if (!selectedPlayer) {
      toast({
        title: "Error",
        description: "Please select a player first",
        variant: "destructive",
      });
      return;
    }
    
    if (predictedScores.some(score => score <= 0)) {
      toast({
        title: "Error",
        description: "Please enter valid scores (greater than 0)",
        variant: "destructive",
      });
      return;
    }
    
    setIsSubmitting(true);
    
    try {
      const result = await calculatePricePredictor(selectedPlayer.name, predictedScores);
      
      if (result.error) {
        toast({
          title: "Error",
          description: result.error,
          variant: "destructive",
        });
      } else {
        setPrediction(result.data);
      }
    } catch (error) {
      console.error("Error calculating price prediction:", error);
      toast({
        title: "Error",
        description: "Failed to calculate price prediction",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };
  
  // Helper function to format currency
  const formatCurrency = (value: number) => {
    return `$${(value / 1000).toFixed(1)}k`;
  };
  
  // Format change with +/- sign
  const formatChange = (value: number) => {
    const sign = value >= 0 ? "+" : "";
    return `${sign}${formatCurrency(value)}`;
  };
  
  // Get change icon
  const getChangeIcon = (value: number) => {
    if (value > 0) return <TrendingUp className="h-4 w-4 text-green-500 mr-1" />;
    if (value < 0) return <TrendingDown className="h-4 w-4 text-red-500 mr-1" />;
    return null;
  };
  
  // Calculate total price change
  const totalPriceChange = useMemo(() => {
    if (!prediction) return 0;
    return prediction.final_price - prediction.starting_price;
  }, [prediction]);
  
  // Calculate percentage change
  const percentageChange = useMemo(() => {
    if (!prediction) return 0;
    return (totalPriceChange / prediction.starting_price) * 100;
  }, [prediction, totalPriceChange]);

  return (
    <div className="space-y-6">
      <div className="space-y-2">
        <h2 className="text-2xl font-bold">Price Predictor Calculator</h2>
        <p className="text-sm text-gray-600">
          Predict a player's future price changes based on projected scores. This helps you estimate
          how much value a player might gain or lose in the coming rounds, informing your trade decisions.
        </p>
      </div>
      
      <Tabs defaultValue="search">
        <TabsList>
          <TabsTrigger value="search">Select Player</TabsTrigger>
          <TabsTrigger value="prediction" disabled={!selectedPlayer}>Prediction</TabsTrigger>
        </TabsList>
        
        <TabsContent value="search" className="space-y-4">
          {/* Search and filters */}
          <Card>
            <CardContent className="pt-4 space-y-4">
              <div className="flex flex-wrap gap-4">
                <div className="flex-1 min-w-[200px]">
                  <Label htmlFor="search">Search Players</Label>
                  <div className="relative">
                    <Search className="absolute left-2 top-2.5 h-4 w-4 text-gray-400" />
                    <Input
                      id="search"
                      placeholder="Player name or team..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-8"
                    />
                  </div>
                </div>
                
                <div className="w-full md:w-auto">
                  <Label htmlFor="position">Position</Label>
                  <Select
                    value={selectedPosition}
                    onValueChange={setSelectedPosition}
                  >
                    <SelectTrigger id="position" className="w-full md:w-[180px]">
                      <SelectValue placeholder="Position" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Positions</SelectItem>
                      <SelectItem value="DEF">Defenders</SelectItem>
                      <SelectItem value="MID">Midfielders</SelectItem>
                      <SelectItem value="RUC">Rucks</SelectItem>
                      <SelectItem value="FWD">Forwards</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardContent>
          </Card>
          
          {/* Player list */}
          <Card>
            <CardContent className="p-0">
              <div className="overflow-x-auto max-h-[400px] overflow-y-auto">
                <Table>
                  <TableHeader className="sticky top-0 bg-white">
                    <TableRow>
                      <TableHead>Player</TableHead>
                      <TableHead>Team</TableHead>
                      <TableHead>Position</TableHead>
                      <TableHead className="text-right">Price</TableHead>
                      <TableHead className="text-right">Breakeven</TableHead>
                      <TableHead className="text-right">Avg</TableHead>
                      <TableHead></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {isLoading ? (
                      // Skeleton loading state
                      Array.from({ length: 5 }).map((_, index) => (
                        <TableRow key={`skeleton-${index}`}>
                          <TableCell><Skeleton className="h-5 w-32" /></TableCell>
                          <TableCell><Skeleton className="h-5 w-24" /></TableCell>
                          <TableCell><Skeleton className="h-5 w-16" /></TableCell>
                          <TableCell className="text-right"><Skeleton className="h-5 w-16 ml-auto" /></TableCell>
                          <TableCell className="text-right"><Skeleton className="h-5 w-12 ml-auto" /></TableCell>
                          <TableCell className="text-right"><Skeleton className="h-5 w-12 ml-auto" /></TableCell>
                          <TableCell className="text-right"><Skeleton className="h-7 w-16 ml-auto" /></TableCell>
                        </TableRow>
                      ))
                    ) : filteredPlayers.length > 0 ? (
                      filteredPlayers.map((player, index) => (
                        <TableRow 
                          key={`${player.name}-${index}`}
                          className={selectedPlayer?.name === player.name ? "bg-blue-50" : ""}
                        >
                          <TableCell className="font-medium">{player.name}</TableCell>
                          <TableCell>{player.team}</TableCell>
                          <TableCell>{player.position}</TableCell>
                          <TableCell className="text-right">{formatCurrency(player.price)}</TableCell>
                          <TableCell className="text-right">{player.breakeven}</TableCell>
                          <TableCell className="text-right">{player.l3_avg || player.avg || "-"}</TableCell>
                          <TableCell className="text-right">
                            <Button 
                              variant="ghost" 
                              size="sm"
                              onClick={() => setSelectedPlayer(player)}
                            >
                              <Edit3 className="h-4 w-4 mr-1" />
                              Select
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))
                    ) : (
                      <TableRow>
                        <TableCell colSpan={7} className="text-center py-4 text-gray-500">
                          No players found. Try refining your search.
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
          
          {/* Selected player info and prediction setup */}
          {selectedPlayer && (
            <Card>
              <CardHeader>
                <CardTitle>Predict Price Changes</CardTitle>
                <CardDescription>
                  Enter projected scores for the next 3 rounds to calculate price changes
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {/* Player info summary */}
                <div className="bg-gray-50 p-4 rounded-md flex flex-col md:flex-row md:items-center gap-4">
                  <div className="space-y-1">
                    <div className="font-bold text-lg">{selectedPlayer.name}</div>
                    <div className="text-sm text-gray-600">{selectedPlayer.team} | {selectedPlayer.position}</div>
                  </div>
                  <div className="space-y-1 md:ml-auto md:text-right">
                    <div className="font-medium">Current Price: {formatCurrency(selectedPlayer.price)}</div>
                    <div className="text-sm text-gray-600">Breakeven: {selectedPlayer.breakeven}</div>
                  </div>
                </div>
                
                {/* Score inputs */}
                <div>
                  <Label>Projected Scores</Label>
                  <div className="mt-2 flex flex-col md:flex-row gap-4">
                    <div className="flex-1 space-y-1">
                      <Label htmlFor="round1" className="text-xs">Round 1</Label>
                      <Input 
                        id="round1" 
                        type="number" 
                        min="0"
                        max="200"
                        value={predictedScores[0] || ''}
                        onChange={(e) => updateScore(0, e.target.value)}
                      />
                    </div>
                    <div className="flex-1 space-y-1">
                      <Label htmlFor="round2" className="text-xs">Round 2</Label>
                      <Input 
                        id="round2" 
                        type="number"
                        min="0"
                        max="200"
                        value={predictedScores[1] || ''}
                        onChange={(e) => updateScore(1, e.target.value)}
                      />
                    </div>
                    <div className="flex-1 space-y-1">
                      <Label htmlFor="round3" className="text-xs">Round 3</Label>
                      <Input 
                        id="round3" 
                        type="number"
                        min="0"
                        max="200"
                        value={predictedScores[2] || ''}
                        onChange={(e) => updateScore(2, e.target.value)}
                      />
                    </div>
                  </div>
                  
                  <Button
                    variant="outline"
                    className="mt-2"
                    onClick={setScoresFromAverage}
                  >
                    Use Average Score
                  </Button>
                </div>
                
                <Button 
                  className="w-full" 
                  onClick={calculatePrediction}
                  disabled={isSubmitting || predictedScores.some(score => !score)}
                >
                  {isSubmitting ? "Calculating..." : "Calculate Price Prediction"}
                </Button>
              </CardContent>
            </Card>
          )}
        </TabsContent>
        
        <TabsContent value="prediction" className="space-y-4">
          {prediction ? (
            <>
              <Card>
                <CardHeader>
                  <CardTitle>Price Prediction Results</CardTitle>
                  <CardDescription>
                    Projected price changes for {prediction.player} over the next 3 rounds
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex flex-col md:flex-row gap-4 mb-4">
                    <div className="bg-gray-50 p-4 rounded-md flex-1">
                      <div className="text-sm text-gray-600">Starting Price</div>
                      <div className="text-xl font-bold">{formatCurrency(prediction.starting_price)}</div>
                      <div className="text-sm text-gray-600 mt-1">Breakeven: {prediction.starting_breakeven}</div>
                    </div>
                    
                    <div className="bg-gray-50 p-4 rounded-md flex-1">
                      <div className="text-sm text-gray-600">Final Price</div>
                      <div className="text-xl font-bold flex items-center">
                        {formatCurrency(prediction.final_price)}
                        <span className="ml-2 flex items-center text-base">
                          {getChangeIcon(totalPriceChange)}
                          <span className={totalPriceChange > 0 ? "text-green-600" : "text-red-600"}>
                            {formatChange(totalPriceChange)} ({percentageChange > 0 ? "+" : ""}{percentageChange.toFixed(1)}%)
                          </span>
                        </span>
                      </div>
                    </div>
                  </div>
                  
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>Round</TableHead>
                        <TableHead className="text-right">Score</TableHead>
                        <TableHead className="text-right">Price Change</TableHead>
                        <TableHead className="text-right">New Price</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {prediction.price_changes.map((change, index) => (
                        <TableRow key={`change-${index}`}>
                          <TableCell>Round {change.round}</TableCell>
                          <TableCell className="text-right">{change.score}</TableCell>
                          <TableCell className="text-right">
                            <div className="flex items-center justify-end">
                              {change.price_change > 0 ? (
                                <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
                              ) : change.price_change < 0 ? (
                                <TrendingDown className="h-4 w-4 text-red-500 mr-1" />
                              ) : null}
                              {formatChange(change.price_change)}
                            </div>
                          </TableCell>
                          <TableCell className="text-right">{formatCurrency(change.new_price)}</TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </CardContent>
              </Card>
              
              <Card>
                <CardHeader>
                  <CardTitle>Recommendation</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="p-4 rounded-md border">
                    {totalPriceChange > 15000 ? (
                      <div className="text-green-700">
                        <p className="font-bold">Strong Buy/Hold</p>
                        <p className="mt-1">This player is projected to generate significant value over the next 3 rounds. Consider buying or holding.</p>
                      </div>
                    ) : totalPriceChange > 5000 ? (
                      <div className="text-green-600">
                        <p className="font-bold">Buy/Hold</p>
                        <p className="mt-1">This player is projected to increase in value over the next 3 rounds. Consider buying or holding.</p>
                      </div>
                    ) : totalPriceChange > -5000 ? (
                      <div className="text-blue-600">
                        <p className="font-bold">Neutral</p>
                        <p className="mt-1">This player's price is projected to remain relatively stable. Make decision based on other factors.</p>
                      </div>
                    ) : totalPriceChange > -15000 ? (
                      <div className="text-orange-600">
                        <p className="font-bold">Consider Selling</p>
                        <p className="mt-1">This player is projected to lose some value. Consider selling if you have better options.</p>
                      </div>
                    ) : (
                      <div className="text-red-600">
                        <p className="font-bold">Strong Sell</p>
                        <p className="mt-1">This player is projected to lose significant value. Consider selling to protect team value.</p>
                      </div>
                    )}
                  </div>
                </CardContent>
              </Card>
              
              <div className="flex justify-between">
                <Button variant="outline" onClick={() => setPrediction(null)}>
                  Reset
                </Button>
                <Button 
                  variant="outline" 
                  onClick={() => {
                    setPredictedScores([0, 0, 0]);
                    setPrediction(null);
                    setSelectedPlayer(null);
                  }}
                >
                  Start Over
                </Button>
              </div>
            </>
          ) : (
            <Card>
              <CardContent className="pt-6">
                <div className="text-center text-gray-500 py-8">
                  <LineChart className="h-12 w-12 mx-auto mb-4 text-gray-400" />
                  <p className="text-lg font-medium">No prediction results yet</p>
                  <p className="mt-1">Select a player and enter projected scores to calculate price predictions.</p>
                </div>
              </CardContent>
            </Card>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}