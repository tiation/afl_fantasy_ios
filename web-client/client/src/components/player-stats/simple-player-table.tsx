import { useState } from "react";
import { 
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow 
} from "@/components/ui/table";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { 
  Search, TrendingUp, TrendingDown, Minus,
  Star, StarOff, ArrowUp, ArrowDown
} from "lucide-react";
import { formatCurrency } from "@/lib/utils";

interface SimplePlayer {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  averagePoints: number;
  lastScore: number;
  projectedScore: number;
  breakEven: number;
  l3Average: number;
  priceChange: number;
  selectionPercentage: number;
  roundsPlayed: number;
  isInjured?: boolean;
  isSuspended?: boolean;
  isFavorite?: boolean;
}

interface SimplePlayerTableProps {
  players: SimplePlayer[];
  isLoading?: boolean;
}

export default function SimplePlayerTable({ players, isLoading }: SimplePlayerTableProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [positionFilter, setPositionFilter] = useState("ALL");
  const [teamFilter, setTeamFilter] = useState("ALL");
  const [sortField, setSortField] = useState<keyof SimplePlayer>("averagePoints");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");
  const [favorites, setFavorites] = useState<Set<number>>(new Set());

  // Filter and sort players
  const filteredAndSortedPlayers = players
    .filter(player => {
      const matchesSearch = player.name.toLowerCase().includes(searchQuery.toLowerCase());
      const matchesPosition = positionFilter === "ALL" || player.position === positionFilter;
      const matchesTeam = teamFilter === "ALL" || player.team === teamFilter;
      return matchesSearch && matchesPosition && matchesTeam;
    })
    .sort((a, b) => {
      const aValue = a[sortField];
      const bValue = b[sortField];
      
      if (typeof aValue === 'number' && typeof bValue === 'number') {
        return sortDirection === "asc" ? aValue - bValue : bValue - aValue;
      }
      
      if (typeof aValue === 'string' && typeof bValue === 'string') {
        return sortDirection === "asc" 
          ? aValue.localeCompare(bValue)
          : bValue.localeCompare(aValue);
      }
      
      return 0;
    });

  const handleSort = (field: keyof SimplePlayer) => {
    if (sortField === field) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortField(field);
      setSortDirection("desc");
    }
  };

  const toggleFavorite = (playerId: number) => {
    const newFavorites = new Set(favorites);
    if (newFavorites.has(playerId)) {
      newFavorites.delete(playerId);
    } else {
      newFavorites.add(playerId);
    }
    setFavorites(newFavorites);
  };

  const getPositionColor = (position: string) => {
    switch (position) {
      case "MID": return "bg-blue-500";
      case "FWD": return "bg-red-500";
      case "DEF": return "bg-green-500";
      case "RUC": return "bg-purple-500";
      default: return "bg-gray-500";
    }
  };

  const getPriceChangeIcon = (change: number | undefined | null) => {
    const priceChange = change || 0;
    if (priceChange > 0) return <TrendingUp className="h-4 w-4 text-green-500" />;
    if (priceChange < 0) return <TrendingDown className="h-4 w-4 text-red-500" />;
    return <Minus className="h-4 w-4 text-gray-400" />;
  };

  const SortHeader = ({ field, children }: { field: keyof SimplePlayer; children: React.ReactNode }) => (
    <TableHead 
      className="cursor-pointer select-none hover:bg-gray-700"
      onClick={() => handleSort(field)}
    >
      <div className="flex items-center space-x-1">
        <span>{children}</span>
        {sortField === field && (
          sortDirection === "asc" ? <ArrowUp className="h-4 w-4" /> : <ArrowDown className="h-4 w-4" />
        )}
      </div>
    </TableHead>
  );

  if (isLoading) {
    return (
      <Card className="bg-gray-800 border-gray-700">
        <CardContent className="p-6">
          <div className="animate-pulse space-y-4">
            {Array.from({ length: 10 }).map((_, i) => (
              <div key={i} className="h-12 bg-gray-700 rounded" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="space-y-4">
      {/* Filters */}
      <Card className="bg-gray-800 border-gray-700">
        <CardHeader>
          <CardTitle className="text-white">Player Statistics</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
              <Input
                placeholder="Search players..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10 bg-gray-700 border-gray-600 text-white"
              />
            </div>
            
            <select
              value={positionFilter}
              onChange={(e) => setPositionFilter(e.target.value)}
              className="px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
            >
              <option value="ALL">All Positions</option>
              <option value="MID">Midfielders</option>
              <option value="FWD">Forwards</option>
              <option value="DEF">Defenders</option>
              <option value="RUC">Rucks</option>
            </select>
            
            <select
              value={teamFilter}
              onChange={(e) => setTeamFilter(e.target.value)}
              className="px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
            >
              <option value="ALL">All Teams</option>
              {Array.from(new Set(players.map(p => p.team))).sort().map(team => (
                <option key={team} value={team}>{team}</option>
              ))}
            </select>
            
            <div className="flex items-center space-x-2">
              <span className="text-sm text-gray-400">
                {filteredAndSortedPlayers.length} players
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Table */}
      <Card className="bg-gray-800 border-gray-700">
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="border-gray-700">
                  <TableHead className="w-12"></TableHead>
                  <SortHeader field="name">Player</SortHeader>
                  <SortHeader field="position">Pos</SortHeader>
                  <SortHeader field="team">Team</SortHeader>
                  <SortHeader field="price">Price</SortHeader>
                  <SortHeader field="averagePoints">Avg</SortHeader>
                  <SortHeader field="lastScore">Last</SortHeader>
                  <SortHeader field="projectedScore">Proj</SortHeader>
                  <SortHeader field="breakEven">BE</SortHeader>
                  <SortHeader field="l3Average">L3</SortHeader>
                  <SortHeader field="priceChange">Price Δ</SortHeader>
                  <SortHeader field="selectionPercentage">Own %</SortHeader>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredAndSortedPlayers.map((player) => (
                  <TableRow 
                    key={player.id} 
                    className="border-gray-700 hover:bg-gray-700/50 cursor-pointer"
                  >
                    <TableCell>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => toggleFavorite(player.id)}
                        className="h-8 w-8 p-0"
                      >
                        {favorites.has(player.id) ? (
                          <Star className="h-4 w-4 text-yellow-500 fill-current" />
                        ) : (
                          <StarOff className="h-4 w-4 text-gray-400" />
                        )}
                      </Button>
                    </TableCell>
                    
                    <TableCell className="font-medium text-white">
                      <div className="flex items-center space-x-2">
                        <span>{player.name}</span>
                        {player.isInjured && (
                          <Badge variant="destructive" className="text-xs">INJ</Badge>
                        )}
                        {player.isSuspended && (
                          <Badge variant="secondary" className="text-xs">SUSP</Badge>
                        )}
                      </div>
                    </TableCell>
                    
                    <TableCell>
                      <Badge className={`${getPositionColor(player.position)} text-white`}>
                        {player.position}
                      </Badge>
                    </TableCell>
                    
                    <TableCell className="text-gray-300">{player.team}</TableCell>
                    
                    <TableCell className="text-gray-300">
                      {formatCurrency(player.price)}
                    </TableCell>
                    
                    <TableCell className="text-white font-medium">
                      {player.averagePoints ? player.averagePoints.toFixed(1) : '0.0'}
                    </TableCell>
                    
                    <TableCell className="text-gray-300">
                      {player.lastScore}
                    </TableCell>
                    
                    <TableCell className="text-blue-400 font-medium">
                      {player.projectedScore}
                    </TableCell>
                    
                    <TableCell className="text-gray-300">
                      {player.breakEven}
                    </TableCell>
                    
                    <TableCell className="text-gray-300">
                      {player.l3Average?.toFixed(1) || '-'}
                    </TableCell>
                    
                    <TableCell>
                      <div className="flex items-center space-x-1">
                        {getPriceChangeIcon(player.priceChange)}
                        <span className={
                          (player.priceChange || 0) > 0 ? "text-green-500" :
                          (player.priceChange || 0) < 0 ? "text-red-500" : "text-gray-400"
                        }>
                          {formatCurrency(Math.abs(player.priceChange || 0))}
                        </span>
                      </div>
                    </TableCell>
                    
                    <TableCell className="text-gray-300">
                      {player.selectionPercentage ? player.selectionPercentage.toFixed(1) : '0.0'}%
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}