import { useState } from "react";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card } from "@/components/ui/card";
import { Search, ArrowDownAZ, ArrowUpAZ, ArrowDown, ArrowUp, ArrowUpDown } from "lucide-react";
import { PlayerPosition, formatCurrency } from "@/lib/utils";

export type Player = {
  id: number;
  name: string;
  position: PlayerPosition;
  price: number;
  breakEven: number;
  category: string;
  team: string;
  averagePoints: number;
  lastScore?: number;
  projectedScore?: number;
  
  // Fantasy stats
  roundsPlayed?: number;
  l3Average?: number;
  l5Average?: number;
  priceChange?: number;
  pricePerPoint?: number;
  totalPoints?: number;
  selectionPercentage?: number;
  
  // Basic stats
  kicks?: number;
  handballs?: number;
  disposals?: number;
  marks?: number;
  tackles?: number;
  freeKicksFor?: number;
  freeKicksAgainst?: number;
  clearances?: number;
  hitouts?: number;
  cba?: number;
  kickIns?: number;
  uncontestedMarks?: number;
  contestedMarks?: number;
  uncontestedDisposals?: number;
  contestedDisposals?: number;
  
  // VS stats
  averageVsOpp?: number;
  averageAtVenue?: number;
  averageVs3RoundOpp?: number;
  averageAt3RoundVenue?: number;
  opponentDifficulty?: number;
  opponent3RoundDifficulty?: number;
};

type PlayerTableProps = {
  players: Player[];
  isLoading: boolean;
  onSearch: (query: string) => void;
  onFilter: (position: string) => void;
  searchQuery: string;
  positionFilter: string;
};

// Type for sort direction
type SortDirection = "asc" | "desc" | null;

// Type for sort field
type SortField = "name" | "team" | "position" | "price" | "breakEven" | "averagePoints" | null;

export default function PlayerTable({
  players,
  isLoading,
  onSearch,
  onFilter,
  searchQuery,
  positionFilter,
}: PlayerTableProps) {
  // State for sorting
  const [sortField, setSortField] = useState<SortField>(null);
  const [sortDirection, setSortDirection] = useState<SortDirection>(null);

  // Handle sort column click
  const handleSort = (field: SortField) => {
    if (sortField === field) {
      // Toggle direction or reset if already sorted in desc
      if (sortDirection === "asc") {
        setSortDirection("desc");
      } else if (sortDirection === "desc") {
        setSortField(null);
        setSortDirection(null);
      }
    } else {
      // New field selected, start with ascending sort
      setSortField(field);
      setSortDirection("asc");
    }
  };

  // Get sort icon component based on current sort state
  const getSortIcon = (field: SortField) => {
    if (sortField !== field) {
      return <ArrowUpDown className="ml-1 h-3 w-3 inline opacity-40" />;
    }
    return sortDirection === "asc" 
      ? <ArrowUp className="ml-1 h-3 w-3 inline text-primary" /> 
      : <ArrowDown className="ml-1 h-3 w-3 inline text-primary" />;
  };

  // Add the sort class for styling
  const getSortableHeaderClass = (field: SortField) => {
    return `cursor-pointer hover:bg-neutral-light/50 ${sortField === field ? "bg-neutral-light/30" : ""}`;
  };

  // Sort players based on current sort state
  const sortedPlayers = [...players];
  if (sortField && sortDirection) {
    sortedPlayers.sort((a, b) => {
      let valueA = a[sortField] as string | number;
      let valueB = b[sortField] as string | number;
      
      // String comparison for string fields
      if (typeof valueA === "string" && typeof valueB === "string") {
        valueA = valueA.toLowerCase();
        valueB = valueB.toLowerCase();
        return sortDirection === "asc" 
          ? valueA.localeCompare(valueB) 
          : valueB.localeCompare(valueA);
      }
      
      // Number comparison for number fields
      if (valueA === undefined) valueA = 0;
      if (valueB === undefined) valueB = 0;
      
      return sortDirection === "asc" 
        ? (valueA as number) - (valueB as number)
        : (valueB as number) - (valueA as number);
    });
  }

  return (
    <>
      <div className="mb-4">
        <div className="flex justify-between items-center mb-4">
          <h1 className="text-xl font-semibold">Player Stats</h1>
          
          <div className="flex gap-2">
            <div className="relative">
              <Input
                type="text"
                placeholder="Search..."
                className="w-[120px] sm:w-[160px] pl-8 pr-2 py-1 h-9 text-sm"
                value={searchQuery}
                onChange={(e) => onSearch(e.target.value)}
              />
              <div className="absolute left-2 top-2 text-neutral">
                <Search className="h-4 w-4" />
              </div>
            </div>
            
            <Select value={positionFilter} onValueChange={onFilter}>
              <SelectTrigger className="w-[90px] h-9 text-sm">
                <SelectValue placeholder="Position" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All</SelectItem>
                <SelectItem value="MID">MID</SelectItem>
                <SelectItem value="FWD">FWD</SelectItem>
                <SelectItem value="DEF">DEF</SelectItem>
                <SelectItem value="RUCK">RUCK</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </div>
      
      <Card className="bg-white shadow-sm">
        <div className="overflow-x-auto relative" style={{ WebkitOverflowScrolling: 'touch' }}>
          {/* Add overlay gradient to hide scrolling content behind sticky columns */}
          <div className="absolute top-0 left-24 bottom-0 w-6 z-20 pointer-events-none" 
               style={{ background: 'linear-gradient(to right, rgba(255,255,255,1) 0%, rgba(255,255,255,0) 100%)' }}>
          </div>
          <table className="min-w-full divide-y divide-neutral-light">
            <thead className="bg-neutral-lightest">
              <tr>
                <th 
                  scope="col" 
                  className={`sticky left-0 z-10 bg-neutral-lightest px-3 py-2 text-left text-xs font-medium text-neutral-dark uppercase tracking-wider w-[140px] ${getSortableHeaderClass("name")}`}
                  onClick={() => handleSort("name")}
                >
                  Player {getSortIcon("name")}
                </th>
                <th 
                  scope="col" 
                  className={`sticky left-24 z-10 bg-neutral-lightest px-3 py-2 text-center text-xs font-medium text-neutral-dark uppercase tracking-wider w-[40px] ${getSortableHeaderClass("team")}`}
                  onClick={() => handleSort("team")}
                >
                  Team {getSortIcon("team")}
                </th>
                <th 
                  scope="col" 
                  className={`px-3 py-2 text-center text-xs font-medium text-neutral-dark uppercase tracking-wider w-[60px] ${getSortableHeaderClass("position")}`}
                  onClick={() => handleSort("position")}
                >
                  Pos {getSortIcon("position")}
                </th>
                <th 
                  scope="col" 
                  className={`px-3 py-2 text-center text-xs font-medium text-neutral-dark uppercase tracking-wider w-[80px] ${getSortableHeaderClass("price")}`}
                  onClick={() => handleSort("price")}
                >
                  Price {getSortIcon("price")}
                </th>
                <th 
                  scope="col" 
                  className={`px-3 py-2 text-center text-xs font-medium text-neutral-dark uppercase tracking-wider w-[60px] ${getSortableHeaderClass("breakEven")}`}
                  onClick={() => handleSort("breakEven")}
                >
                  BE {getSortIcon("breakEven")}
                </th>
                <th 
                  scope="col" 
                  className={`px-3 py-2 text-center text-xs font-medium text-neutral-dark uppercase tracking-wider w-[60px] ${getSortableHeaderClass("averagePoints")}`}
                  onClick={() => handleSort("averagePoints")}
                >
                  AVG {getSortIcon("averagePoints")}
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-neutral-light">
              {isLoading ? (
                <tr>
                  <td colSpan={6} className="px-6 py-4 text-center">
                    Loading players...
                  </td>
                </tr>
              ) : sortedPlayers.length === 0 ? (
                <tr>
                  <td colSpan={6} className="px-6 py-4 text-center">
                    No players found. Try adjusting your search.
                  </td>
                </tr>
              ) : (
                sortedPlayers.map((player) => {
                  // Function to create team logo badge
                  const renderTeamLogo = () => (
                    <div className="h-6 w-6 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold">
                      {player.team.substring(0, 2).toUpperCase()}
                    </div>
                  );
                  
                  // Row hover class with sort highlighting
                  const getRowHoverClass = () => {
                    return `hover:bg-neutral-lightest cursor-pointer ${sortField && sortDirection
                      ? "hover:bg-neutral-light/10" 
                      : ""}`;
                  };
                  
                  return (
                    <tr 
                      key={player.id} 
                      className={getRowHoverClass()}
                    >
                      <td className="sticky left-0 z-10 bg-white px-3 py-2 whitespace-nowrap max-w-[140px] truncate">
                        <div className="text-sm font-medium truncate">{player.name}</div>
                      </td>
                      <td className="sticky left-24 z-10 bg-white px-3 py-2 whitespace-nowrap text-center">
                        <div className="flex justify-center">
                          {renderTeamLogo()}
                        </div>
                      </td>
                      <td className="px-3 py-2 whitespace-nowrap text-center">
                        <div className="text-sm">{player.position}</div>
                      </td>
                      <td className="px-3 py-2 whitespace-nowrap text-center">
                        <div className="text-sm">{formatCurrency(player.price)}</div>
                      </td>
                      <td className="px-3 py-2 whitespace-nowrap text-center">
                        <div className="text-sm">{player.breakEven}</div>
                      </td>
                      <td className="px-3 py-2 whitespace-nowrap text-center">
                        <div className="text-sm">{player.averagePoints || 0}</div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </>
  );
}
