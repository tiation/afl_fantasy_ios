import { useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { 
  BarChart3, TrendingUp, TrendingDown, Search, X, 
  ChevronDown, ChevronUp, Layers, ArrowUpDown, AlertCircle 
} from "lucide-react";
import { formatCurrency } from "@/lib/utils";

interface Player {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  projectedScore: number | null;
  breakEven: number;
  averagePoints: number;
  priceChange?: number;
  projectedPriceChange?: number;
  lastScore?: number | null;
}

interface PriceComparison {
  player1: Player;
  player2: Player;
  currentDifference: number;
  projectedDifference: number;
  deltaChange: number;
  valueFormatted: string;
}

export function PriceDifferenceDelta() {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedPosition, setSelectedPosition] = useState<string>("all");
  const [selectedPlayer1, setSelectedPlayer1] = useState<Player | null>(null);
  const [selectedPlayer2, setSelectedPlayer2] = useState<Player | null>(null);
  const [comparisons, setComparisons] = useState<PriceComparison[]>([]);
  const [sortField, setSortField] = useState<string>("deltaChange");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");
  const [showAlert, setShowAlert] = useState(true);

  // Fetch all available players
  const { data: allPlayers, isLoading } = useQuery<Player[]>({
    queryKey: ["/api/players"],
  });

  // Process players based on filters
  const filteredPlayers = () => {
    if (!allPlayers) return [];
    
    let result = [...allPlayers];
    
    // Apply position filter
    if (selectedPosition !== "all") {
      result = result.filter(p => p.position === selectedPosition);
    }
    
    // Apply search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      result = result.filter(p => 
        p.name.toLowerCase().includes(query) || 
        p.team.toLowerCase().includes(query)
      );
    }
    
    return result;
  };

  // Clear search input
  const clearSearch = () => {
    setSearchQuery("");
  };

  // Handle player selection
  const handlePlayerSelect = (player: Player, slot: 1 | 2) => {
    if (slot === 1) {
      // If selecting same player, deselect
      if (selectedPlayer1 && selectedPlayer1.id === player.id) {
        setSelectedPlayer1(null);
      } else {
        setSelectedPlayer1(player);
      }
    } else {
      if (selectedPlayer2 && selectedPlayer2.id === player.id) {
        setSelectedPlayer2(null);
      } else {
        setSelectedPlayer2(player);
      }
    }
  };

  // Add comparison to the list
  const addComparison = () => {
    if (!selectedPlayer1 || !selectedPlayer2) return;
    
    // Calculate current price difference
    const currentDifference = selectedPlayer1.price - selectedPlayer2.price;
    
    // Calculate projected price change (using break even as a proxy if projectedPriceChange not available)
    const player1ProjChange = selectedPlayer1.projectedPriceChange || 
      ((selectedPlayer1.averagePoints - selectedPlayer1.breakEven) * 5000);
    
    const player2ProjChange = selectedPlayer2.projectedPriceChange || 
      ((selectedPlayer2.averagePoints - selectedPlayer2.breakEven) * 5000);
    
    // Calculate projected difference
    const projectedDifference = (selectedPlayer1.price + player1ProjChange) - 
                                (selectedPlayer2.price + player2ProjChange);
    
    // Calculate delta
    const deltaChange = projectedDifference - currentDifference;
    
    // Format value rating
    let valueFormatted = "Neutral";
    if (deltaChange > 15000) valueFormatted = "Strong Value";
    else if (deltaChange > 5000) valueFormatted = "Good Value";
    else if (deltaChange < -15000) valueFormatted = "Poor Value";
    else if (deltaChange < -5000) valueFormatted = "Caution";
    
    // Create comparison object
    const comparison: PriceComparison = {
      player1: selectedPlayer1,
      player2: selectedPlayer2,
      currentDifference,
      projectedDifference,
      deltaChange,
      valueFormatted
    };
    
    // Add to list
    setComparisons(prev => [...prev, comparison]);
    
    // Clear selections
    setSelectedPlayer1(null);
    setSelectedPlayer2(null);
  };

  // Remove comparison from list
  const removeComparison = (index: number) => {
    setComparisons(prev => prev.filter((_, i) => i !== index));
  };

  // Handle sorting
  const handleSort = (field: string) => {
    if (sortField === field) {
      // Toggle direction if same field
      setSortDirection(prev => prev === "asc" ? "desc" : "asc");
    } else {
      // Set new field and default to desc
      setSortField(field);
      setSortDirection("desc");
    }
  };

  // Sort comparisons
  const sortedComparisons = [...comparisons].sort((a, b) => {
    // Get the values safely
    const getValueSafely = (obj: PriceComparison, field: string): string | number => {
      const value = obj[field as keyof PriceComparison];
      
      // Special handling for player objects
      if ((field === "player1" || field === "player2") && value && typeof value === 'object' && 'name' in value) {
        return value.name as string;
      }
      
      return value as string | number;
    };
    
    const valueA = getValueSafely(a, sortField);
    const valueB = getValueSafely(b, sortField);
    
    // Handle strings and numbers for comparison
    if (typeof valueA === 'string' && typeof valueB === 'string') {
      return sortDirection === "asc" 
        ? valueA.localeCompare(valueB)
        : valueB.localeCompare(valueA);
    }
    
    // Default number comparison
    if (valueA < valueB) return sortDirection === "asc" ? -1 : 1;
    if (valueA > valueB) return sortDirection === "asc" ? 1 : -1;
    return 0;
  });

  // Get sort icon
  const getSortIcon = (field: string) => {
    if (sortField !== field) return <ArrowUpDown className="h-4 w-4 opacity-50" />;
    return sortDirection === "asc" ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />;
  };

  // Get color class based on value
  const getValueColor = (value: number) => {
    if (value > 15000) return "text-green-600";
    if (value > 5000) return "text-green-500";
    if (value < -15000) return "text-red-600";
    if (value < -5000) return "text-red-500";
    return "text-gray-600";
  };

  // Loading state
  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full"></div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Optional: Information alert */}
      {showAlert && (
        <Card className="bg-blue-50 border-blue-200">
          <CardContent className="p-4">
            <div className="flex space-x-2">
              <AlertCircle className="h-5 w-5 text-blue-500 flex-shrink-0 mt-0.5" />
              <div className="flex-1">
                <h4 className="font-medium text-blue-800">About Price Difference Delta</h4>
                <p className="text-sm text-blue-700 mt-1">
                  This tool helps you analyze how price differences between two players are likely to change over time.
                  Track multiple player pairs to identify the most efficient ways to make future trades and maximize value.
                </p>
              </div>
              <button 
                onClick={() => setShowAlert(false)}
                className="text-blue-500 hover:text-blue-700"
              >
                <X className="h-5 w-5" />
              </button>
            </div>
          </CardContent>
        </Card>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Player Selection Panel */}
        <div className="col-span-1 space-y-4">
          <Card>
            <CardContent className="p-4 space-y-4">
              <h3 className="text-lg font-medium">Select Players to Compare</h3>
              
              <div className="space-y-2">
                <Label>Position Filter</Label>
                <Select 
                  value={selectedPosition} 
                  onValueChange={setSelectedPosition}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Filter by position" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">All Positions</SelectItem>
                    <SelectItem value="MID">Midfielders</SelectItem>
                    <SelectItem value="FWD">Forwards</SelectItem>
                    <SelectItem value="DEF">Defenders</SelectItem>
                    <SelectItem value="RUCK">Rucks</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              <div className="relative">
                <Input
                  type="text"
                  placeholder="Search players..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="pl-9"
                />
                <Search className="absolute left-3 top-2.5 h-4 w-4 text-gray-400" />
                {searchQuery && (
                  <button 
                    onClick={clearSearch}
                    className="absolute right-3 top-2.5"
                  >
                    <X className="h-4 w-4 text-gray-400" />
                  </button>
                )}
              </div>
              
              <div className="border rounded-md overflow-hidden max-h-[300px] overflow-y-auto">
                <Table>
                  <TableHeader className="sticky top-0 bg-white z-10">
                    <TableRow>
                      <TableHead className="w-10"></TableHead>
                      <TableHead>Player</TableHead>
                      <TableHead className="text-right">Price</TableHead>
                      <TableHead className="text-right">Avg</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredPlayers().map(player => (
                      <TableRow 
                        key={player.id}
                        className={`cursor-pointer ${
                          (selectedPlayer1?.id === player.id || selectedPlayer2?.id === player.id)
                            ? "bg-blue-50"
                            : ""
                        }`}
                      >
                        <TableCell className="py-1">
                          <div className="flex space-x-1">
                            <Button
                              variant={selectedPlayer1?.id === player.id ? "default" : "outline"}
                              size="sm"
                              className="h-7 w-7 p-0"
                              onClick={() => handlePlayerSelect(player, 1)}
                            >
                              1
                            </Button>
                            <Button
                              variant={selectedPlayer2?.id === player.id ? "default" : "outline"}
                              size="sm"
                              className="h-7 w-7 p-0"
                              onClick={() => handlePlayerSelect(player, 2)}
                            >
                              2
                            </Button>
                          </div>
                        </TableCell>
                        <TableCell className="py-1">
                          <div className="font-medium text-sm">{player.name}</div>
                          <div className="text-xs text-gray-500">{player.position} | {player.team}</div>
                        </TableCell>
                        <TableCell className="text-right py-1">{formatCurrency(player.price)}</TableCell>
                        <TableCell className="text-right py-1">{player.averagePoints?.toFixed(1) || '-'}</TableCell>
                      </TableRow>
                    ))}
                    {filteredPlayers().length === 0 && (
                      <TableRow>
                        <TableCell colSpan={4} className="text-center py-4 text-gray-500">
                          No players found
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </div>
              
              <div className="grid grid-cols-2 gap-4">
                <Card className={`p-3 ${selectedPlayer1 ? 'border-blue-300' : 'border-gray-200'}`}>
                  <h4 className="text-sm font-medium mb-1">Player 1 (Higher Price)</h4>
                  {selectedPlayer1 ? (
                    <div className="space-y-1">
                      <div className="flex items-center">
                        <div className="h-6 w-6 rounded-full bg-gray-200 flex items-center justify-center text-xs font-bold mr-2">
                          {selectedPlayer1.team.substring(0, 2).toUpperCase()}
                        </div>
                        <div className="font-medium">{selectedPlayer1.name}</div>
                      </div>
                      <div className="text-sm text-gray-600">Price: {formatCurrency(selectedPlayer1.price)}</div>
                      <div className="text-sm text-gray-600">BE: {selectedPlayer1.breakEven}</div>
                    </div>
                  ) : (
                    <div className="text-gray-400 text-sm italic">Not selected</div>
                  )}
                </Card>
                
                <Card className={`p-3 ${selectedPlayer2 ? 'border-blue-300' : 'border-gray-200'}`}>
                  <h4 className="text-sm font-medium mb-1">Player 2 (Lower Price)</h4>
                  {selectedPlayer2 ? (
                    <div className="space-y-1">
                      <div className="flex items-center">
                        <div className="h-6 w-6 rounded-full bg-gray-200 flex items-center justify-center text-xs font-bold mr-2">
                          {selectedPlayer2.team.substring(0, 2).toUpperCase()}
                        </div>
                        <div className="font-medium">{selectedPlayer2.name}</div>
                      </div>
                      <div className="text-sm text-gray-600">Price: {formatCurrency(selectedPlayer2.price)}</div>
                      <div className="text-sm text-gray-600">BE: {selectedPlayer2.breakEven}</div>
                    </div>
                  ) : (
                    <div className="text-gray-400 text-sm italic">Not selected</div>
                  )}
                </Card>
              </div>
              
              <Button 
                className="w-full" 
                disabled={!selectedPlayer1 || !selectedPlayer2}
                onClick={addComparison}
              >
                Add Comparison
              </Button>
            </CardContent>
          </Card>
        </div>

        {/* Comparison Results */}
        <div className="col-span-1 lg:col-span-2">
          <Card>
            <CardContent className="p-4">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-medium">Price Difference Analysis</h3>
                <div className="text-sm text-gray-500 flex items-center">
                  <Layers className="h-4 w-4 mr-1" />
                  {comparisons.length} comparisons
                </div>
              </div>
              
              {comparisons.length === 0 ? (
                <div className="text-center py-12 text-gray-500">
                  <BarChart3 className="h-12 w-12 mx-auto text-gray-400 mb-3" />
                  <p>Select players and add comparisons to see price difference analysis</p>
                </div>
              ) : (
                <div className="overflow-x-auto">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead 
                          className="cursor-pointer"
                          onClick={() => handleSort("player1")}
                        >
                          Player 1 {getSortIcon("player1")}
                        </TableHead>
                        <TableHead 
                          className="cursor-pointer"
                          onClick={() => handleSort("player2")}
                        >
                          Player 2 {getSortIcon("player2")}
                        </TableHead>
                        <TableHead 
                          className="text-right cursor-pointer"
                          onClick={() => handleSort("currentDifference")}
                        >
                          Current Diff {getSortIcon("currentDifference")}
                        </TableHead>
                        <TableHead 
                          className="text-right cursor-pointer"
                          onClick={() => handleSort("projectedDifference")}
                        >
                          Proj Diff {getSortIcon("projectedDifference")}
                        </TableHead>
                        <TableHead 
                          className="text-right cursor-pointer"
                          onClick={() => handleSort("deltaChange")}
                        >
                          Delta {getSortIcon("deltaChange")}
                        </TableHead>
                        <TableHead 
                          className="text-right cursor-pointer"
                          onClick={() => handleSort("valueFormatted")}
                        >
                          Rating {getSortIcon("valueFormatted")}
                        </TableHead>
                        <TableHead className="w-10"></TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {sortedComparisons.map((comp, index) => (
                        <TableRow key={`comp-${index}`}>
                          <TableCell>
                            <div className="flex items-center space-x-2">
                              <div className="h-6 w-6 rounded-full bg-gray-200 flex items-center justify-center text-xs font-bold">
                                {comp.player1.team.substring(0, 2).toUpperCase()}
                              </div>
                              <div className="font-medium text-sm">{comp.player1.name}</div>
                            </div>
                            <div className="ml-8 text-xs text-gray-500">{formatCurrency(comp.player1.price)}</div>
                          </TableCell>
                          <TableCell>
                            <div className="flex items-center space-x-2">
                              <div className="h-6 w-6 rounded-full bg-gray-200 flex items-center justify-center text-xs font-bold">
                                {comp.player2.team.substring(0, 2).toUpperCase()}
                              </div>
                              <div className="font-medium text-sm">{comp.player2.name}</div>
                            </div>
                            <div className="ml-8 text-xs text-gray-500">{formatCurrency(comp.player2.price)}</div>
                          </TableCell>
                          <TableCell className="text-right font-medium">
                            {formatCurrency(comp.currentDifference)}
                          </TableCell>
                          <TableCell className="text-right font-medium">
                            {formatCurrency(comp.projectedDifference)}
                          </TableCell>
                          <TableCell className={`text-right font-medium ${getValueColor(comp.deltaChange)}`}>
                            {comp.deltaChange > 0 ? "+" : ""}{formatCurrency(comp.deltaChange)}
                          </TableCell>
                          <TableCell className="text-right">
                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                              comp.valueFormatted === "Strong Value" ? "bg-green-100 text-green-800" :
                              comp.valueFormatted === "Good Value" ? "bg-green-50 text-green-600" :
                              comp.valueFormatted === "Poor Value" ? "bg-red-100 text-red-800" :
                              comp.valueFormatted === "Caution" ? "bg-orange-100 text-orange-800" :
                              "bg-gray-100 text-gray-800"
                            }`}>
                              {comp.valueFormatted}
                            </span>
                          </TableCell>
                          <TableCell>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => removeComparison(index)}
                              className="h-8 w-8 p-0"
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}