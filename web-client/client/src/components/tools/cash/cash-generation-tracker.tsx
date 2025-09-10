import { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { 
  Card, 
  CardContent, 
  CardDescription, 
  CardHeader, 
  CardTitle 
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Button } from "@/components/ui/button";
import { Slider } from "@/components/ui/slider";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { 
  CircleDollarSign, 
  Loader2, 
  TrendingUp, 
  TrendingDown, 
  Search,
  Filter,
  X
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/lib/utils";
import { getTeamGuernsey, getTeamColors } from "@/lib/team-utils";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip as RechartsTooltip,
  ResponsiveContainer,
  Area,
  AreaChart,
  ComposedChart
} from "recharts";

type CashGenPlayer = {
  id: string;
  name: string;
  team: string;
  position: string;
  price: number;
  breakeven?: number;
  projectedScores: number[];
  projectedPrices: number[];
  threeGameAvg?: number;
  upcomingOpponents: string[];
  // Additional fields from API
  averagePoints?: number;
  lastScore?: number;
  l3Average?: number;
  l5Average?: number;
  averageScore?: string;
  projectedScore?: number;
  externalId?: string;
  // DVP and fixture data
  fixtures?: any[];
  nextOpponents?: string[];
  dvpDifficulty?: number[];
};

type ChartDataPoint = {
  round: string;
  roundNumber: number;
  price: number;
  breakeven: number;
  change: number;
  opponent: string;
};

// Generate upcoming opponents for a player (mock data for now)
const generateUpcomingOpponents = (playerTeam: string): string[] => {
  const allTeams = [
    "Adelaide", "Brisbane", "Carlton", "Collingwood", "Essendon", "Fremantle",
    "Geelong", "Gold Coast", "GWS", "Hawthorn", "Melbourne", "North Melbourne",
    "Port Adelaide", "Richmond", "St Kilda", "Sydney", "West Coast", "Western Bulldogs"
  ];
  
  // Filter out the player's own team and randomly select 5 opponents
  const otherTeams = allTeams.filter(team => team !== playerTeam);
  const shuffled = [...otherTeams].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, 5);
};

// Generate projected scores and prices based on player stats and optional DVP difficulty
const generateProjections = (player: any, dvpFixtures?: any[]): { projectedScores: number[], projectedPrices: number[] } => {
  // Handle price conversion - if price is in cents, convert to thousands
  let currentPrice = player.price || 200;
  if (currentPrice > 100000) {
    currentPrice = currentPrice / 1000; // Convert from cents to thousands
  }
  
  // Handle averagePoints properly - could be string or number
  let averagePointsValue = 0;
  if (typeof player.averagePoints === 'number') {
    averagePointsValue = player.averagePoints;
  } else if (typeof player.averagePoints === 'string') {
    averagePointsValue = parseFloat(player.averagePoints) || 0;
  } else if (player.avg) {
    averagePointsValue = typeof player.avg === 'number' ? player.avg : parseFloat(player.avg) || 0;
  }
  
  const averageScore = averagePointsValue || 50;
  const breakeven = player.breakeven || player.breakEven || Math.round(averageScore * 0.9);
  
  // Use recent scores if available for more realistic projections
  const recentScores = player.score_history || [];
  const l3Avg = player.l3_avg || player.l3Average || averageScore;
  
  // Generate 5 projected scores with variation based on recent form and DVP difficulty
  const projectedScores = Array.from({ length: 5 }, (_, i) => {
    // Use weighted average of overall average and L3 average
    const baseScore = (averageScore * 0.4 + l3Avg * 0.6);
    const variation = (Math.random() - 0.5) * 20; // ±10 point variation
    const trendFactor = 1 - (i * 0.01); // Slight trend factor
    
    // Apply DVP difficulty adjustment if available
    let dvpAdjustment = 1.0;
    if (dvpFixtures && dvpFixtures[i]) {
      const difficulty = dvpFixtures[i].difficulty;
      // Convert 0-10 scale to multiplier: 0 = 1.15 (easy), 5 = 1.0 (neutral), 10 = 0.85 (hard)
      dvpAdjustment = 1.15 - (difficulty * 0.03);
    }
    
    return Math.round((baseScore + variation) * trendFactor * dvpAdjustment);
  });
  
  // Calculate price changes based on projected scores vs breakeven
  const projectedPrices = [currentPrice];
  for (let i = 0; i < projectedScores.length - 1; i++) {
    const scoreVsBreakeven = projectedScores[i] - breakeven;
    const priceChange = Math.round(scoreVsBreakeven * 1); // $1k per point above/below breakeven  
    const newPrice = Math.max(100, Math.min(2000, projectedPrices[i] + priceChange));
    projectedPrices.push(newPrice);
  }
  
  return { projectedScores, projectedPrices };
};

// Transform API player data to CashGenPlayer format
// Helper function to get player's primary position for DVP lookup
const getPlayerPrimaryPosition = (position: string) => {
  if (!position) return 'MID';
  const posArray = position.split('/').map(p => p.trim().toUpperCase());
  // Priority: RUCK > MID > DEF > FWD
  if (posArray.includes('RUCK') || posArray.includes('RUC')) return 'RUC';
  if (posArray.includes('MID')) return 'MID';
  if (posArray.includes('DEF')) return 'DEF';
  if (posArray.includes('FWD')) return 'FWD';
  return posArray[0] || 'MID';
};

const transformPlayerData = (apiPlayers: any[], dvpData?: any): CashGenPlayer[] => {
  return apiPlayers.map((player, index) => {
    // Get DVP fixture difficulty for enhanced projections
    const primaryPos = getPlayerPrimaryPosition(player.position);
    let dvpFixtures = [];
    let upcomingOpponents = [];
    
    if (dvpData && player.team) {
      const positionData = dvpData[primaryPos];
      if (positionData) {
        const teamData = positionData.find((team: any) => 
          team.team === player.team || team.team.toLowerCase() === player.team.toLowerCase()
        );
        
        if (teamData?.fixtures) {
          dvpFixtures = teamData.fixtures.map((fixture: any) => ({
            round: fixture.round,
            opponent: fixture.opponent,
            difficulty: fixture.difficulty || 5
          }));
          upcomingOpponents = dvpFixtures.map(f => f.opponent);
        }
      }
    }
    
    // Generate projections with DVP data
    const { projectedScores, projectedPrices } = generateProjections(player, dvpFixtures);
    
    // Handle price conversion - if price is in cents, convert to thousands
    let price = player.price || 200;
    if (price > 100000) {
      price = price / 1000; // Convert from cents to thousands
    }
    
    // Handle averagePoints properly - could be string or number
    let averagePointsValue = 0;
    if (typeof player.averagePoints === 'number') {
      averagePointsValue = player.averagePoints;
    } else if (typeof player.averagePoints === 'string') {
      averagePointsValue = parseFloat(player.averagePoints) || 0;
    } else if (player.avg) {
      averagePointsValue = typeof player.avg === 'number' ? player.avg : parseFloat(player.avg) || 0;
    }
    
    return {
      // Create a unique ID by combining name, team, and index to ensure no duplicates
      id: `${player.name}-${player.team}-${player.externalId || player.id || index}`.replace(/\s+/g, '-'),
      name: player.name || "Unknown Player",
      team: player.team || "Unknown",
      position: player.position || "MID", 
      price: price,
      breakeven: player.breakeven || player.breakEven || Math.round(averagePointsValue * 0.9),
      projectedScores,
      projectedPrices,
      threeGameAvg: player.l3_avg || player.l3Average || player.threeGameAvg || averagePointsValue,
      upcomingOpponents: upcomingOpponents.length > 0 ? upcomingOpponents : generateUpcomingOpponents(player.team || "Unknown"),
      averagePoints: averagePointsValue,
      lastScore: player.lastScore || (player.score_history?.[0] || 0),
      l3Average: player.l3_avg || player.l3Average,
      l5Average: player.l5Average,
      projectedScore: player.projectedScore,
      externalId: player.externalId,
      // DVP and fixture data
      fixtures: dvpFixtures,
      dvpDifficulty: dvpFixtures.map(f => f.difficulty)
    };
  });
};

const AFL_TEAMS = [
  "Adelaide", "Brisbane", "Carlton", "Collingwood", "Essendon", "Fremantle",
  "Geelong", "Gold Coast", "GWS", "Hawthorn", "Melbourne", "North Melbourne",
  "Port Adelaide", "Richmond", "St Kilda", "Sydney", "West Coast", "Western Bulldogs"
];

const POSITIONS = ["DEF", "MID", "RUC", "FWD"];

export function CashGenerationTracker() {
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [selectedPlayer, setSelectedPlayer] = useState<CashGenPlayer | null>(null);
  const [teamFilter, setTeamFilter] = useState<string>("ALL");
  const [positionFilter, setPositionFilter] = useState<string>("ALL");
  const [priceRange, setPriceRange] = useState<number[]>([0, 2000]);
  const [showBreakeven, setShowBreakeven] = useState<boolean>(false);
  const [showSuggestions, setShowSuggestions] = useState<boolean>(false);
  const [inputFocused, setInputFocused] = useState<boolean>(false);

  // Fetch player data from combined stats API (uses all backup files)
  const { data: combinedStatsData = [], isLoading: isCombinedLoading } = useQuery<any[]>({
    queryKey: ["/api/stats/combined-stats"],
    refetchOnWindowFocus: false,
  });

  // Fetch DVP fixture data for enhanced analysis
  const { data: dvpData = {}, isLoading: isDvpLoading } = useQuery<any>({
    queryKey: ["/api/stats-tools/stats/dvp-enhanced"],
    refetchOnWindowFocus: false,
  });

  // Use combined stats data that includes all backup files
  const rawPlayerData = combinedStatsData;
  const isLoading = isCombinedLoading || isDvpLoading;

  // Transform API data to our format
  const allPlayers = useMemo(() => {
    if (!rawPlayerData || rawPlayerData.length === 0) return [];
    return transformPlayerData(rawPlayerData, dvpData);
  }, [rawPlayerData, dvpData]);
  // Filter players based on search and filters
  const filteredPlayers = useMemo(() => {
    if (!allPlayers || allPlayers.length === 0) return [];
    let filtered = allPlayers;
    
    // Apply search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter((player) => 
        player.name.toLowerCase().includes(query) || 
        player.team.toLowerCase().includes(query)
      );
    }
    
    // Apply team filter
    if (teamFilter !== "ALL") {
      filtered = filtered.filter((player) => player.team === teamFilter);
    }
    
    // Apply position filter
    if (positionFilter !== "ALL") {
      filtered = filtered.filter((player) => player.position === positionFilter);
    }
    
    // Apply price range filter
    filtered = filtered.filter((player) => 
      player.price >= priceRange[0] && player.price <= priceRange[1]
    );
    
    return filtered;
  }, [allPlayers, searchQuery, teamFilter, positionFilter, priceRange]);

  // Get search suggestions - players whose names start with the search query
  const searchSuggestions = useMemo(() => {
    if (!searchQuery || searchQuery.length < 2 || !inputFocused) return [];
    
    const query = searchQuery.toLowerCase();
    const suggestions = allPlayers
      .filter(player => {
        const firstName = player.name.split(' ')[0]?.toLowerCase() || '';
        const lastName = player.name.split(' ').slice(-1)[0]?.toLowerCase() || '';
        return firstName.startsWith(query) || lastName.startsWith(query);
      })
      .sort((a, b) => b.price - a.price) // Sort by highest price first
      .slice(0, 5); // Show top 5 suggestions
    
    return suggestions;
  }, [allPlayers, searchQuery, inputFocused]);

  // Generate chart data for selected player
  const chartData = useMemo(() => {
    if (!selectedPlayer) return [];
    
    // Calculate projected breakevens based on projected scores
    const projectedBreakevens = selectedPlayer.projectedScores.map((score, index) => {
      // Breakeven changes based on recent performance
      const currentBE = selectedPlayer.breakeven || 80;
      const scoreDiff = score - currentBE;
      // Breakeven adjusts gradually based on performance
      const adjustment = scoreDiff * 0.15; // 15% adjustment factor
      return Math.round(Math.max(0, Math.min(180, currentBE - adjustment)));
    });
    
    return selectedPlayer.projectedPrices.map((price, index) => ({
      round: `R${20 + index}`, // Assuming current round is 20
      roundNumber: 20 + index,
      price: price,
      breakeven: projectedBreakevens[index],
      projectedScore: selectedPlayer.projectedScores[index],
      change: index === 0 ? 0 : price - selectedPlayer.projectedPrices[index - 1],
      opponent: selectedPlayer.upcomingOpponents[index] || ""
    }));
  }, [selectedPlayer]);

  // Calculate price changes for display
  const priceChanges = useMemo(() => {
    if (!selectedPlayer) return [];
    
    return selectedPlayer.projectedPrices.slice(1).map((price, index) => ({
      round: `R${21 + index}`,
      change: price - selectedPlayer.projectedPrices[index],
      projectedScore: selectedPlayer.projectedScores[index + 1]
    }));
  }, [selectedPlayer]);

  // Clear all filters
  const clearFilters = () => {
    setSearchQuery("");
    setTeamFilter("ALL");
    setPositionFilter("ALL");
    setPriceRange([0, 2000000]);
  };

  // Custom tooltip for the chart
  const CustomTooltip = ({ active, payload, label, chartType }: any) => {
    if (active && payload && payload.length && payload[0].payload) {
      const data = payload[0].payload;
      const guernseyUrl = getTeamGuernsey(data.opponent);
      const teamColors = getTeamColors(data.opponent);
      
      return (
        <div className="bg-gray-800 border border-gray-600 rounded-lg p-3 shadow-lg">
          <p className="text-white font-medium">{label}</p>
          {chartType === 'breakeven' ? (
            <p className="text-orange-400">
              BE: {payload[0].value}
            </p>
          ) : (
            <p className="text-cyan-400">
              Price: {formatCurrency(payload[0].value)}
            </p>
          )}
          {showBreakeven && payload[1] && chartType !== 'breakeven' && (
            <p className="text-orange-400">
              Breakeven: {payload[1].value}
            </p>
          )}
          {data.projectedScore && (
            <p className="text-green-400">
              Projected Score: {data.projectedScore}
            </p>
          )}
          {data.opponent && (
            <div className="flex items-center gap-2 mt-2">
              {guernseyUrl && (
                <img 
                  src={guernseyUrl} 
                  alt={data.opponent}
                  className="w-5 h-5 object-contain"
                />
              )}
              <span className="text-gray-300">
                vs <span style={{ color: teamColors.primary }}>
                  {data.opponent}
                </span>
              </span>
            </div>
          )}
        </div>
      );
    }
    return null;
  };

  // Custom X-axis tick with opponent guernseys
  const CustomXAxisTick = (props: any) => {
    const { x, y, payload } = props;
    const data = chartData.find(d => d.round === payload.value);
    const opponent = data?.opponent || "";
    const guernseyUrl = getTeamGuernsey(opponent);
    
    return (
      <g transform={`translate(${x},${y})`}>
        <text 
          x={0} 
          y={0} 
          dy={16} 
          textAnchor="middle" 
          fill="#9CA3AF" 
          fontSize="12"
        >
          {payload.value}
        </text>
        {opponent && guernseyUrl && (
          <foreignObject x={-12} y={20} width={24} height={24}>
            <img 
              src={guernseyUrl} 
              alt={opponent}
              style={{ width: '24px', height: '24px', objectFit: 'contain' }}
            />
          </foreignObject>
        )}
        {opponent && !guernseyUrl && (
          <text 
            x={0} 
            y={0} 
            dy={32} 
            textAnchor="middle" 
            fill="#9CA3AF" 
            fontSize="8"
            fontWeight="bold"
          >
            vs {opponent}
          </text>
        )}
      </g>
    );
  };

  // Show loading state
  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin text-cyan-400" />
        <span className="ml-2 text-gray-400">Loading player data...</span>
      </div>
    );
  }

  // Show error state if no data
  if (!allPlayers || allPlayers.length === 0) {
    return (
      <div className="flex items-center justify-center p-8 text-gray-400">
        <CircleDollarSign className="h-8 w-8 mr-2" />
        <span>No player data available. Please try again later.</span>
      </div>
    );
  }

  return (
    <div className="space-y-6 bg-gray-900 min-h-screen">
      {/* Sticky Filter Bar */}
      <Card className="bg-gray-800 border-gray-700 sticky top-0 z-10 rounded-none border-x-0">
        <CardHeader className="pb-4">
          <CardTitle className="flex items-center gap-2 text-white">
            <CircleDollarSign className="h-5 w-5 text-cyan-400" />
            Cash Generation Tracker
          </CardTitle>
          <CardDescription className="text-gray-400">
            Project price changes for individual players over the next 5 rounds
          </CardDescription>
        </CardHeader>
        
        <CardContent className="space-y-4">
          {/* Search Bar with Autocomplete */}
          <div className="relative">
            <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
            <Input
              placeholder="Search by player name (first or last)..."
              className="pl-10 bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onFocus={() => setInputFocused(true)}
              onBlur={() => setTimeout(() => setInputFocused(false), 200)}
            />
            
            {/* Autocomplete Suggestions Dropdown */}
            {searchSuggestions.length > 0 && (
              <div className="absolute top-full left-0 right-0 mt-1 bg-gray-800 border border-gray-600 rounded-md shadow-lg z-50 max-h-64 overflow-y-auto">
                {searchSuggestions.map((player) => (
                  <button
                    key={player.id}
                    className="w-full px-4 py-3 hover:bg-gray-700 text-left border-b border-gray-700 last:border-b-0"
                    onClick={() => {
                      setSelectedPlayer(player);
                      setSearchQuery(player.name);
                      setInputFocused(false);
                    }}
                  >
                    <div className="flex justify-between items-center">
                      <div>
                        <div className="text-white font-medium">{player.name}</div>
                        <div className="text-sm text-gray-400">
                          {player.team} | {player.position}
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-cyan-400 font-medium">
                          {formatCurrency(player.price)}
                        </div>
                        {player.breakeven && (
                          <div className="text-xs text-gray-400">
                            BE: {player.breakeven}
                          </div>
                        )}
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            )}
          </div>
          
          {/* Filters Row */}
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1">
              <label className="text-sm text-gray-400 mb-2 block">Team</label>
              <Select value={teamFilter} onValueChange={setTeamFilter}>
                <SelectTrigger className="bg-gray-700 border-gray-600 text-white">
                  <SelectValue placeholder="All Teams" />
                </SelectTrigger>
                <SelectContent className="bg-gray-700 border-gray-600">
                  <SelectItem value="ALL">All Teams</SelectItem>
                  {AFL_TEAMS.map((team) => (
                    <SelectItem key={team} value={team}>{team}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div className="flex-1">
              <label className="text-sm text-gray-400 mb-2 block">Position</label>
              <Select value={positionFilter} onValueChange={setPositionFilter}>
                <SelectTrigger className="bg-gray-700 border-gray-600 text-white">
                  <SelectValue placeholder="All Positions" />
                </SelectTrigger>
                <SelectContent className="bg-gray-700 border-gray-600">
                  <SelectItem value="ALL">All Positions</SelectItem>
                  {POSITIONS.map((position) => (
                    <SelectItem key={position} value={position}>{position}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            
            <div className="flex-1">
              <label className="text-sm text-gray-400 mb-2 block">
                Price Range: {formatCurrency(priceRange[0])} - {formatCurrency(priceRange[1])}
              </label>
              <Slider
                value={priceRange}
                onValueChange={setPriceRange}
                max={2000000}
                min={0}
                step={50000}
                className="w-full"
              />
            </div>
            
            <div className="flex items-end">
              <Button
                onClick={clearFilters}
                variant="outline"
                size="sm"
                className="border-gray-600 text-gray-400 hover:text-white"
              >
                <X className="h-4 w-4 mr-2" />
                Clear
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Player Selection - Show ALL filtered players */}
      {filteredPlayers.length > 0 && (
        <Card className="bg-gray-800 border-gray-700 mx-4 rounded-lg">
          <CardHeader>
            <CardTitle className="text-white">
              Select Player ({filteredPlayers.length} {filteredPlayers.length === 1 ? 'player' : 'players'} found)
            </CardTitle>
            <CardDescription className="text-gray-400">
              {searchQuery ? `Showing players matching "${searchQuery}"` : 'Choose a player to view their price projection'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3 max-h-96 overflow-y-auto">
              {filteredPlayers.map((player) => (
                <Button
                  key={player.id}
                  onClick={() => setSelectedPlayer(player)}
                  variant={selectedPlayer?.id === player.id ? "default" : "outline"}
                  className={`justify-start p-3 h-auto ${
                    selectedPlayer?.id === player.id 
                      ? "bg-cyan-600 hover:bg-cyan-700 text-white" 
                      : "bg-gray-700 border-gray-600 text-gray-300 hover:bg-gray-600"
                  }`}
                >
                  <div className="text-left w-full">
                    <div className="font-medium">{player.name}</div>
                    <div className="flex justify-between items-center mt-1">
                      <div className="text-sm opacity-75">{player.team} - {player.position}</div>
                      <div className="text-sm font-medium">{formatCurrency(player.price)}</div>
                    </div>
                    {player.breakeven && (
                      <div className="text-xs opacity-60 mt-1">BE: {player.breakeven}</div>
                    )}
                  </div>
                </Button>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
      
      {/* Show message if no players match filters */}
      {filteredPlayers.length === 0 && allPlayers.length > 0 && (
        <Card className="bg-gray-800 border-gray-700 mx-4 rounded-lg">
          <CardContent className="text-center py-8">
            <p className="text-gray-400">No players match the current filters.</p>
            <Button 
              onClick={clearFilters} 
              variant="link" 
              className="text-cyan-400 hover:text-cyan-300 mt-2"
            >
              Clear all filters
            </Button>
          </CardContent>
        </Card>
      )}

      {/* Price Projection Chart */}
      {selectedPlayer && (
        <Card className="bg-gray-800 border-gray-700 rounded-none border-x-0">
          <CardHeader className="mx-4">
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
              <div>
                <CardTitle className="text-white">
                  {selectedPlayer.name} - Price Projection
                </CardTitle>
                <CardDescription className="text-gray-400">
                  {selectedPlayer.team} | {selectedPlayer.position} | Current: {formatCurrency(selectedPlayer.price)}
                </CardDescription>
              </div>
              <div className="flex items-center space-x-2">
                <Switch
                  id="show-breakeven"
                  checked={showBreakeven}
                  onCheckedChange={setShowBreakeven}
                />
                <Label htmlFor="show-breakeven" className="text-gray-400">
                  Show Breakeven Line
                </Label>
              </div>
            </div>
          </CardHeader>
          <CardContent className="px-0">
            {/* Main Price Chart */}
            <div className="h-96 w-full mb-6">
              <div className="px-4 mb-2">
                <h5 className="text-white font-medium">Price Projection</h5>
              </div>
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 60 }}>
                  <defs>
                    <linearGradient id="priceGradient" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#06b6d4" stopOpacity={0.8}/>
                      <stop offset="95%" stopColor="#06b6d4" stopOpacity={0.1}/>
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                  <XAxis 
                    dataKey="round" 
                    axisLine={false}
                    tickLine={false}
                    tick={<CustomXAxisTick />}
                    height={60}
                  />
                  <YAxis 
                    axisLine={false}
                    tickLine={false}
                    tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    tickFormatter={(value) => `$${(value / 1000).toFixed(0)}k`}
                  />
                  <RechartsTooltip content={<CustomTooltip />} />
                  <Area
                    type="monotone"
                    dataKey="price"
                    stroke="#06b6d4"
                    strokeWidth={3}
                    fill="url(#priceGradient)"
                  />
                </AreaChart>
              </ResponsiveContainer>
            </div>

            {/* Breakeven Chart (if enabled) */}
            {showBreakeven && (
              <div className="h-80 w-full">
                <div className="px-4 mb-2">
                  <h5 className="text-white font-medium">Breakeven Line</h5>
                </div>
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 60 }}>
                    <defs>
                      <linearGradient id="breakevenGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#f97316" stopOpacity={0.3}/>
                        <stop offset="95%" stopColor="#f97316" stopOpacity={0.1}/>
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                    <XAxis 
                      dataKey="round" 
                      axisLine={false}
                      tickLine={false}
                      tick={<CustomXAxisTick />}
                      height={60}
                    />
                    <YAxis 
                      axisLine={false}
                      tickLine={false}
                      tick={{ fill: '#9CA3AF', fontSize: 12 }}
                      domain={[0, 180]}
                      ticks={[0, 30, 60, 90, 120, 150, 180]}
                    />
                    <RechartsTooltip content={(props) => <CustomTooltip {...props} chartType="breakeven" />} />
                    <Line
                      type="monotone"
                      dataKey="breakeven"
                      stroke="#f97316"
                      strokeWidth={3}
                      dot={{ fill: '#f97316', strokeWidth: 2, r: 4 }}
                    />
                    <Area
                      type="monotone"
                      dataKey="breakeven"
                      stroke="transparent"
                      fill="url(#breakevenGradient)"
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            )}
          </CardContent>
          
          {/* Price Changes Display */}
          <div className="bg-gray-800 border-t border-gray-700 px-4 py-6">
            <h4 className="text-white font-medium mb-4">Projected Price Changes</h4>
            <div className="grid grid-cols-2 sm:grid-cols-5 gap-4">
              {priceChanges.map((change, index) => {
                const opponent = selectedPlayer.upcomingOpponents[index + 1] || "";
                const guernseyUrl = getTeamGuernsey(opponent);
                const teamColors = getTeamColors(opponent);
                return (
                  <div key={change.round} className="bg-gray-700 rounded-lg p-4 text-center">
                    <div className="text-gray-400 text-sm mb-2">{change.round}</div>
                    {opponent && (
                      <div className="flex items-center justify-center mb-2">
                        {guernseyUrl ? (
                          <div className="flex flex-col items-center">
                            <img 
                              src={guernseyUrl} 
                              alt={opponent}
                              className="w-8 h-8 object-contain mb-1"
                            />
                            <span className="text-xs text-gray-300">vs {opponent}</span>
                          </div>
                        ) : (
                          <div 
                            className="text-xs font-medium px-2 py-1 rounded"
                            style={{ 
                              backgroundColor: teamColors.primary + '20',
                              color: teamColors.primary
                            }}
                          >
                            vs {opponent}
                          </div>
                        )}
                      </div>
                    )}
                    {change.projectedScore && (
                      <div className="text-sm text-purple-400 mb-1">
                        Score: {change.projectedScore}
                      </div>
                    )}
                    <div className={`font-bold text-lg ${
                      change.change > 0 ? 'text-green-400' : change.change < 0 ? 'text-red-400' : 'text-gray-400'
                    }`}>
                      {change.change > 0 ? '+' : ''}{formatCurrency(change.change, 1)}
                    </div>
                    {change.change > 0 && <TrendingUp className="h-4 w-4 text-green-400 mx-auto mt-1" />}
                    {change.change < 0 && <TrendingDown className="h-4 w-4 text-red-400 mx-auto mt-1" />}
                  </div>
                );
              })}
            </div>
          </div>
          
          {/* DVP Fixture Analysis (if DVP data available) */}
          {selectedPlayer.fixtures && selectedPlayer.fixtures.length > 0 && (
            <div className="bg-gray-800 border-t border-gray-700 px-4 py-6">
              <h4 className="text-white font-medium mb-4">DVP Fixture Analysis</h4>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-gray-600">
                      <th className="text-left text-gray-400 pb-2">Round</th>
                      <th className="text-left text-gray-400 pb-2">Opponent</th>
                      <th className="text-center text-gray-400 pb-2">Difficulty</th>
                      <th className="text-center text-gray-400 pb-2">Expected Score</th>
                      <th className="text-center text-gray-400 pb-2">Price Impact</th>
                    </tr>
                  </thead>
                  <tbody>
                    {selectedPlayer.fixtures.map((fixture, index) => {
                      const difficulty = fixture.difficulty || 5;
                      const expectedScore = selectedPlayer.projectedScores[index] || 0;
                      const priceChange = index < priceChanges.length ? priceChanges[index].change : 0;
                      
                      // Color coding based on difficulty
                      const getDifficultyColor = (diff: number) => {
                        if (diff <= 3) return 'text-green-400'; // Easy
                        if (diff <= 7) return 'text-yellow-400'; // Medium
                        return 'text-red-400'; // Hard
                      };
                      
                      const getDifficultyBg = (diff: number) => {
                        if (diff <= 3) return 'bg-green-900/30'; // Easy
                        if (diff <= 7) return 'bg-yellow-900/30'; // Medium
                        return 'bg-red-900/30'; // Hard
                      };
                      
                      return (
                        <tr key={fixture.round} className="border-b border-gray-700/50">
                          <td className="py-3 text-white">R{fixture.round}</td>
                          <td className="py-3">
                            <div className="flex items-center space-x-2">
                              <span className="text-gray-300">{fixture.opponent}</span>
                            </div>
                          </td>
                          <td className="py-3 text-center">
                            <span className={`px-2 py-1 rounded text-xs font-medium ${getDifficultyColor(difficulty)} ${getDifficultyBg(difficulty)}`}>
                              {difficulty.toFixed(1)}
                            </span>
                          </td>
                          <td className="py-3 text-center text-purple-400 font-medium">
                            {expectedScore}
                          </td>
                          <td className="py-3 text-center">
                            <span className={`font-medium ${priceChange > 0 ? 'text-green-400' : priceChange < 0 ? 'text-red-400' : 'text-gray-400'}`}>
                              {priceChange > 0 ? '+' : ''}{formatCurrency(priceChange, 1)}
                            </span>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
              <div className="mt-4 flex items-center justify-center space-x-6 text-xs">
                <div className="flex items-center space-x-1">
                  <div className="w-3 h-3 bg-green-400 rounded"></div>
                  <span className="text-gray-400">Easy (0-3)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <div className="w-3 h-3 bg-yellow-400 rounded"></div>
                  <span className="text-gray-400">Medium (4-7)</span>
                </div>
                <div className="flex items-center space-x-1">
                  <div className="w-3 h-3 bg-red-400 rounded"></div>
                  <span className="text-gray-400">Hard (8-10)</span>
                </div>
              </div>
            </div>
          )}
        </Card>
      )}

      {/* No Player Selected State */}
      {!selectedPlayer && filteredPlayers.length === 0 && (
        <Card className="bg-gray-800 border-gray-700 mx-4 rounded-lg">
          <CardContent className="text-center py-12">
            <CircleDollarSign className="h-16 w-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-white text-lg font-medium mb-2">No Players Found</h3>
            <p className="text-gray-400 mb-4">
              Try adjusting your search criteria or filters to find players.
            </p>
            <Button onClick={clearFilters} variant="outline" className="border-gray-600 text-gray-400">
              Clear All Filters
            </Button>
          </CardContent>
        </Card>
      )}

      {!selectedPlayer && filteredPlayers.length > 0 && (
        <Card className="bg-gray-800 border-gray-700 mx-4 rounded-lg">
          <CardContent className="text-center py-12">
            <Filter className="h-16 w-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-white text-lg font-medium mb-2">Select a Player</h3>
            <p className="text-gray-400">
              Choose a player above to view their price projection over the next 5 rounds.
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}