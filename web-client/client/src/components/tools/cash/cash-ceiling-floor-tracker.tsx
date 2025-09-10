import React, { useState, useMemo, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Slider } from '@/components/ui/slider';
import { 
  Search, 
  TrendingUp, 
  TrendingDown, 
  CircleDollarSign, 
  Filter,
  X
} from 'lucide-react';
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip as RechartsTooltip, 
  ResponsiveContainer,
  Legend
} from 'recharts';
import { useQuery } from '@tanstack/react-query';
import { getTeamGuernsey, getTeamColors } from '@/lib/team-utils';

interface Player {
  id: string;
  name: string;
  team: string;
  position: string;
  price: number;
  breakeven: number;
  projectedScores: number[];
  projectedPrices: number[];
  upcomingOpponents: string[];
  avg: number;
  last3: number;
}

interface CashCeilingFloorTrackerProps {
  className?: string;
}

const formatCurrency = (value: number, decimals: number = 0): string => {
  if (value >= 1000000) {
    return `$${(value / 1000000).toFixed(decimals)}M`;
  } else if (value >= 1000) {
    return `$${(value / 1000).toFixed(decimals)}K`;
  }
  return `$${value.toFixed(decimals)}`;
};

// AFL Fantasy price calculation formula
const calculatePriceChange = (currentPrice: number, actualScore: number, breakeven: number): number => {
  const scoreDiff = actualScore - breakeven;
  const priceChange = scoreDiff * 3500; // Approximate AFL Fantasy formula
  return Math.round(currentPrice + priceChange);
};

export const CashCeilingFloorTracker: React.FC<CashCeilingFloorTrackerProps> = ({ className }) => {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  const [teamFilter, setTeamFilter] = useState("ALL");
  const [positionFilter, setPositionFilter] = useState("ALL");
  const [priceRange, setPriceRange] = useState([0, 2000000]);
  const [inputFocused, setInputFocused] = useState(false);
  
  // Ceiling and floor scores for next 3 rounds
  const [ceilingScores, setCeilingScores] = useState([130, 130, 130]);
  const [floorScores, setFloorScores] = useState([60, 60, 60]);

  // Fetch all players data
  const { data: allPlayers = [] } = useQuery<Player[]>({
    queryKey: ['/api/scraped-players'],
  });

  // Get unique teams and positions for filters
  const uniqueTeams = useMemo(() => {
    const teams = [...new Set(allPlayers.map(p => p.team))].sort();
    return teams;
  }, [allPlayers]);

  const uniquePositions = useMemo(() => {
    const positions = [...new Set(allPlayers.map(p => p.position))].sort();
    return positions;
  }, [allPlayers]);

  // Filter players based on search and filters
  const filteredPlayers = useMemo(() => {
    return allPlayers.filter(player => {
      const matchesSearch = !searchQuery || 
        player.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        player.name.toLowerCase().split(' ').some(part => 
          part.startsWith(searchQuery.toLowerCase())
        );
      
      const matchesTeam = teamFilter === "ALL" || player.team === teamFilter;
      const matchesPosition = positionFilter === "ALL" || player.position === positionFilter;
      const matchesPrice = player.price >= priceRange[0] && player.price <= priceRange[1];
      
      return matchesSearch && matchesTeam && matchesPosition && matchesPrice;
    }).sort((a, b) => b.price - a.price);
  }, [allPlayers, searchQuery, teamFilter, positionFilter, priceRange]);

  // Generate search suggestions
  const searchSuggestions = useMemo(() => {
    if (!searchQuery.trim() || !inputFocused) return [];
    
    const suggestions = allPlayers
      .filter(player => 
        player.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        player.name.toLowerCase().split(' ').some(part => 
          part.startsWith(searchQuery.toLowerCase())
        )
      )
      .sort((a, b) => b.price - a.price) // Sort by highest price first
      .slice(0, 5); // Show top 5 suggestions
    
    return suggestions;
  }, [allPlayers, searchQuery, inputFocused]);

  // Generate chart data with ceiling, baseline, and floor projections
  const chartData = useMemo(() => {
    if (!selectedPlayer) return [];
    
    const rounds = 4; // Current round + next 3 rounds
    const data = [];
    
    for (let i = 0; i < rounds; i++) {
      const roundNumber = 20 + i; // Assuming current round is 20
      const breakeven = selectedPlayer.breakeven || 80;
      
      if (i === 0) {
        // Current round - all prices are the same (current price)
        data.push({
          round: `R${roundNumber}`,
          roundNumber,
          ceiling: selectedPlayer.price,
          baseline: selectedPlayer.price,
          floor: selectedPlayer.price,
          ceilingScore: null, // No score for current round
          baselineScore: null,
          floorScore: null,
          opponent: selectedPlayer.upcomingOpponents?.[i] || ""
        });
      } else {
        // Future rounds - calculate based on scores
        const sliderIndex = i - 1; // Slider indices are 0, 1, 2 for rounds 1, 2, 3
        
        // Baseline price (using our model's projected scores)
        const baselineScore = selectedPlayer.projectedScores?.[sliderIndex] || 80;
        const baselinePrice = calculatePriceChange(data[i - 1]?.baseline || selectedPlayer.price, baselineScore, breakeven);
        
        // Ceiling price (using user's ceiling scores)
        const ceilingScore = ceilingScores[sliderIndex];
        const ceilingPrice = calculatePriceChange(data[i - 1]?.ceiling || selectedPlayer.price, ceilingScore, breakeven);
        
        // Floor price (using user's floor scores)
        const floorScore = floorScores[sliderIndex];
        const floorPrice = calculatePriceChange(data[i - 1]?.floor || selectedPlayer.price, floorScore, breakeven);
        
        data.push({
          round: `R${roundNumber}`,
          roundNumber,
          ceiling: ceilingPrice,
          baseline: baselinePrice,
          floor: floorPrice,
          ceilingScore,
          baselineScore,
          floorScore,
          opponent: selectedPlayer.upcomingOpponents?.[sliderIndex] || ""
        });
      }
    }
    
    return data;
  }, [selectedPlayer, ceilingScores, floorScores]);

  // Calculate price changes for display table (skip current round)
  const priceChanges = useMemo(() => {
    if (!selectedPlayer || chartData.length === 0) return [];
    
    return chartData.slice(1).map((data, index) => ({
      round: data.round,
      ceilingChange: data.ceiling - selectedPlayer.price,
      baselineChange: data.baseline - selectedPlayer.price,
      floorChange: data.floor - selectedPlayer.price,
      ceilingScore: data.ceilingScore,
      baselineScore: data.baselineScore,
      floorScore: data.floorScore,
      opponent: data.opponent
    }));
  }, [selectedPlayer, chartData]);

  // Clear all filters
  const clearFilters = () => {
    setSearchQuery("");
    setTeamFilter("ALL");
    setPositionFilter("ALL");
    setPriceRange([0, 2000000]);
  };

  // Custom tooltip for the chart
  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length && payload[0].payload) {
      const data = payload[0].payload;
      const guernseyUrl = getTeamGuernsey(data.opponent);
      const teamColors = getTeamColors(data.opponent);
      
      return (
        <div className="bg-gray-800 border border-gray-600 rounded-lg p-3 shadow-lg">
          <p className="text-white font-medium">{label}</p>
          {payload.map((entry: any) => (
            <p key={entry.dataKey} style={{ color: entry.color }}>
              {entry.dataKey === 'ceiling' ? 'Ceiling' : 
               entry.dataKey === 'baseline' ? 'Baseline' : 'Floor'}: {formatCurrency(entry.value)}
            </p>
          ))}
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

  return (
    <div className={`space-y-4 ${className}`}>
      {/* Search and Filters */}
      <Card className="bg-gray-800 border-gray-700 mx-4 rounded-lg">
        <CardHeader className="pb-4">
          <CardTitle className="text-white flex items-center gap-2">
            <CircleDollarSign className="h-5 w-5 text-cyan-400" />
            Cash Gen: Ceiling & Floor Visualizer
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {/* Search with autocomplete */}
          <div className="relative">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
              <Input
                placeholder="Search players by name..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onFocus={() => setInputFocused(true)}
                onBlur={() => setTimeout(() => setInputFocused(false), 200)}
                className="pl-10 bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              />
            </div>
            
            {/* Autocomplete dropdown */}
            {searchSuggestions.length > 0 && inputFocused && (
              <div className="absolute top-full left-0 right-0 mt-1 bg-gray-700 border border-gray-600 rounded-md shadow-lg z-50 max-h-60 overflow-y-auto">
                {searchSuggestions.map((player) => {
                  const guernseyUrl = getTeamGuernsey(player.team);
                  return (
                    <div
                      key={player.id}
                      className="flex items-center justify-between p-3 hover:bg-gray-600 cursor-pointer"
                      onClick={() => {
                        setSelectedPlayer(player);
                        setSearchQuery(player.name);
                        setInputFocused(false);
                      }}
                    >
                      <div className="flex items-center gap-3">
                        {guernseyUrl && (
                          <img 
                            src={guernseyUrl} 
                            alt={player.team}
                            className="w-6 h-6 object-contain"
                          />
                        )}
                        <div>
                          <div className="text-white font-medium">{player.name}</div>
                          <div className="text-gray-400 text-sm">{player.position} - {player.team}</div>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-cyan-400 font-medium">{formatCurrency(player.price)}</div>
                        <div className="text-orange-400 text-sm">BE: {player.breakeven}</div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Filters */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="text-gray-400 text-sm mb-2 block">Team</label>
              <select
                value={teamFilter}
                onChange={(e) => setTeamFilter(e.target.value)}
                className="w-full bg-gray-700 border-gray-600 text-white rounded-md p-2"
              >
                <option value="ALL">All Teams</option>
                {uniqueTeams.map(team => (
                  <option key={team} value={team}>{team}</option>
                ))}
              </select>
            </div>
            
            <div>
              <label className="text-gray-400 text-sm mb-2 block">Position</label>
              <select
                value={positionFilter}
                onChange={(e) => setPositionFilter(e.target.value)}
                className="w-full bg-gray-700 border-gray-600 text-white rounded-md p-2"
              >
                <option value="ALL">All Positions</option>
                {uniquePositions.map(position => (
                  <option key={position} value={position}>{position}</option>
                ))}
              </select>
            </div>
            
            <div>
              <label className="text-gray-400 text-sm mb-2 block">
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
          </div>

          {/* Clear filters button */}
          <Button
            onClick={clearFilters}
            variant="outline"
            size="sm"
            className="border-gray-600 text-gray-400 hover:bg-gray-700"
          >
            <X className="h-4 w-4 mr-2" />
            Clear Filters
          </Button>
        </CardContent>
      </Card>

      {/* Filtered Players Display */}
      {filteredPlayers.length > 0 && !selectedPlayer && (
        <Card className="bg-gray-800 border-gray-700 mx-4 rounded-lg">
          <CardContent className="p-4">
            <div className="flex flex-wrap gap-2">
              {filteredPlayers.slice(0, 20).map((player, index) => {
                const guernseyUrl = getTeamGuernsey(player.team);
                return (
                  <Badge
                    key={player.id || `player-${index}`}
                    variant="secondary"
                    className="bg-gray-700 text-white hover:bg-gray-600 cursor-pointer p-2 flex items-center gap-2"
                    onClick={() => setSelectedPlayer(player)}
                  >
                    {guernseyUrl && (
                      <img 
                        src={guernseyUrl} 
                        alt={player.team}
                        className="w-4 h-4 object-contain"
                      />
                    )}
                    <span>{player.name}</span>
                    <span className="text-cyan-400">{formatCurrency(player.price)}</span>
                  </Badge>
                );
              })}
            </div>
            {filteredPlayers.length > 20 && (
              <p className="text-gray-400 text-sm mt-2">
                Showing 20 of {filteredPlayers.length} players. Use search to narrow results.
              </p>
            )}
          </CardContent>
        </Card>
      )}

      {/* Selected Player Analysis */}
      {selectedPlayer && (
        <Card className="bg-gray-800 border-gray-700 mx-4 rounded-lg">
          <CardHeader className="pb-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <img 
                  src={getTeamGuernsey(selectedPlayer.team)} 
                  alt={selectedPlayer.team}
                  className="w-8 h-8 object-contain"
                />
                <div>
                  <CardTitle className="text-white">{selectedPlayer.name}</CardTitle>
                  <p className="text-gray-400">{selectedPlayer.position} - {selectedPlayer.team}</p>
                </div>
              </div>
              <Button
                onClick={() => setSelectedPlayer(null)}
                variant="ghost"
                size="sm"
                className="text-gray-400 hover:text-white"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>
            <div className="flex gap-4 mt-2">
              <div className="text-center">
                <div className="text-cyan-400 font-bold text-lg">{formatCurrency(selectedPlayer.price)}</div>
                <div className="text-gray-400 text-sm">Current Price</div>
              </div>
              <div className="text-center">
                <div className="text-orange-400 font-bold text-lg">{selectedPlayer.breakeven}</div>
                <div className="text-gray-400 text-sm">Breakeven</div>
              </div>
              <div className="text-center">
                <div className="text-green-400 font-bold text-lg">{selectedPlayer.avg}</div>
                <div className="text-gray-400 text-sm">Season Avg</div>
              </div>
            </div>
          </CardHeader>
          
          <CardContent className="space-y-4">
            {/* Compact layout with chart and sliders side by side */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
              {/* Price Projection Chart */}
              <div className="h-80">
                <h3 className="text-white font-medium mb-2">Price Projections (4 Rounds)</h3>
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                    <XAxis 
                      dataKey="round" 
                      tick={{ fill: '#9CA3AF', fontSize: 11 }}
                    />
                    <YAxis 
                      tick={{ fill: '#9CA3AF', fontSize: 11 }}
                      tickFormatter={(value) => formatCurrency(value, 1)}
                    />
                    <RechartsTooltip content={<CustomTooltip />} />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey="ceiling"
                      stroke="#3b82f6"
                      strokeWidth={2}
                      dot={{ fill: '#3b82f6', strokeWidth: 2, r: 3 }}
                      name="Ceiling"
                    />
                    <Line
                      type="monotone"
                      dataKey="baseline"
                      stroke="#10b981"
                      strokeWidth={2}
                      dot={{ fill: '#10b981', strokeWidth: 2, r: 3 }}
                      name="Baseline"
                    />
                    <Line
                      type="monotone"
                      dataKey="floor"
                      stroke="#ef4444"
                      strokeWidth={2}
                      dot={{ fill: '#ef4444', strokeWidth: 2, r: 3 }}
                      name="Floor"
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>

              {/* Score Input Sliders */}
              <div className="space-y-3">
                <h3 className="text-white font-medium">Score Projections (Next 3 Rounds)</h3>
                {[0, 1, 2].map((roundIndex) => {
                  const roundNumber = 21 + roundIndex; // Start from R21 since R20 is current
                  const opponent = selectedPlayer.upcomingOpponents?.[roundIndex] || "";
                  const guernseyUrl = getTeamGuernsey(opponent);
                  
                  return (
                    <div key={roundIndex} className="bg-gray-700 rounded-lg p-3">
                      <div className="flex items-center gap-2 mb-2">
                        <h4 className="text-white text-sm font-medium">R{roundNumber}</h4>
                        {opponent && (
                          <div className="flex items-center gap-1">
                            {guernseyUrl && (
                              <img 
                                src={guernseyUrl} 
                                alt={opponent}
                                className="w-4 h-4 object-contain"
                              />
                            )}
                            <span className="text-gray-300 text-xs">vs {opponent}</span>
                          </div>
                        )}
                      </div>
                      
                      <div className="space-y-2">
                        <div>
                          <label className="text-blue-400 text-xs mb-1 block">
                            Ceiling: {ceilingScores[roundIndex]}
                          </label>
                          <Slider
                            value={[ceilingScores[roundIndex]]}
                            onValueChange={(value) => {
                              const newCeilingScores = [...ceilingScores];
                              newCeilingScores[roundIndex] = value[0];
                              setCeilingScores(newCeilingScores);
                            }}
                            max={160}
                            min={50}
                            step={5}
                            className="w-full"
                          />
                        </div>
                        
                        <div>
                          <label className="text-red-400 text-xs mb-1 block">
                            Floor: {floorScores[roundIndex]}
                          </label>
                          <Slider
                            value={[floorScores[roundIndex]]}
                            onValueChange={(value) => {
                              const newFloorScores = [...floorScores];
                              newFloorScores[roundIndex] = value[0];
                              setFloorScores(newFloorScores);
                            }}
                            max={130}
                            min={30}
                            step={5}
                            className="w-full"
                          />
                        </div>
                        
                        <div className="text-center">
                          <span className="text-green-400 text-xs">
                            Baseline: {selectedPlayer.projectedScores?.[roundIndex] || 80}
                          </span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Compact Price Changes Summary */}
            <div>
              <h3 className="text-white font-medium mb-2">Price Change Summary</h3>
              <div className="grid grid-cols-3 gap-2">
                {priceChanges.map((change, index) => {
                  const opponent = change.opponent;
                  const guernseyUrl = getTeamGuernsey(opponent);
                  
                  return (
                    <div key={change.round} className="bg-gray-700 rounded-lg p-2">
                      <div className="text-gray-400 text-xs mb-1 text-center">{change.round}</div>
                      {opponent && (
                        <div className="flex items-center justify-center mb-2">
                          {guernseyUrl && (
                            <div className="flex flex-col items-center">
                              <img 
                                src={guernseyUrl} 
                                alt={opponent}
                                className="w-4 h-4 object-contain mb-1"
                              />
                              <span className="text-xs text-gray-300">vs {opponent}</span>
                            </div>
                          )}
                        </div>
                      )}
                      
                      <div className="space-y-1">
                        <div className="text-center">
                          <div className="text-blue-400 text-xs">Ceiling</div>
                          <div className={`font-bold text-sm ${
                            change.ceilingChange > 0 ? 'text-green-400' : 
                            change.ceilingChange < 0 ? 'text-red-400' : 'text-gray-400'
                          }`}>
                            {change.ceilingChange > 0 ? '+' : ''}{formatCurrency(change.ceilingChange, 1)}
                          </div>
                        </div>
                        
                        <div className="text-center">
                          <div className="text-green-400 text-xs">Baseline</div>
                          <div className={`font-bold text-sm ${
                            change.baselineChange > 0 ? 'text-green-400' : 
                            change.baselineChange < 0 ? 'text-red-400' : 'text-gray-400'
                          }`}>
                            {change.baselineChange > 0 ? '+' : ''}{formatCurrency(change.baselineChange, 1)}
                          </div>
                        </div>
                        
                        <div className="text-center">
                          <div className="text-red-400 text-xs">Floor</div>
                          <div className={`font-bold text-sm ${
                            change.floorChange > 0 ? 'text-green-400' : 
                            change.floorChange < 0 ? 'text-red-400' : 'text-gray-400'
                          }`}>
                            {change.floorChange > 0 ? '+' : ''}{formatCurrency(change.floorChange, 1)}
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </CardContent>
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
              Choose a player above to set ceiling and floor scores for price projections.
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
};