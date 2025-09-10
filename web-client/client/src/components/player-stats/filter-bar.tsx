import { useState } from "react";
import { 
  Card, CardContent, CardFooter
} from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Search,
  Filter,
  X
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { playerPositions } from "@/lib/utils";
import { StatusFilter } from "./player-types";

type FilterBarProps = {
  searchQuery: string;
  onSearch: (query: string) => void;
  positionFilter: string;
  onPositionFilter: (position: string) => void;
  statusFilter: StatusFilter;
  onStatusFilter: (status: StatusFilter) => void;
  teamFilter: string;
  onTeamFilter: (team: string) => void;
  activeFilters: number;
};

export default function FilterBar({
  searchQuery,
  onSearch,
  positionFilter,
  onPositionFilter,
  statusFilter,
  onStatusFilter,
  teamFilter,
  onTeamFilter,
  activeFilters,
}: FilterBarProps) {
  const [localSearch, setLocalSearch] = useState(searchQuery);
  const teams = [
    { id: "all", name: "All Teams" },
    { id: "ADE", name: "Adelaide" },
    { id: "BRL", name: "Brisbane" },
    { id: "CAR", name: "Carlton" },
    { id: "COL", name: "Collingwood" },
    { id: "ESS", name: "Essendon" },
    { id: "FRE", name: "Fremantle" },
    { id: "GEE", name: "Geelong" },
    { id: "GCS", name: "Gold Coast" },
    { id: "GWS", name: "GWS Giants" },
    { id: "HAW", name: "Hawthorn" },
    { id: "MEL", name: "Melbourne" },
    { id: "NTH", name: "North Melbourne" },
    { id: "PTA", name: "Port Adelaide" },
    { id: "RIC", name: "Richmond" },
    { id: "STK", name: "St Kilda" },
    { id: "SYD", name: "Sydney" },
    { id: "WCE", name: "West Coast" },
    { id: "WBD", name: "Western Bulldogs" }
  ];

  // Handle search input change
  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setLocalSearch(e.target.value);
  };

  // Handle search submission
  const handleSearchSubmit = () => {
    onSearch(localSearch);
  };

  // Handle search input keydown (for Enter key)
  const handleSearchKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter') {
      handleSearchSubmit();
    }
  };

  // Clear all filters
  const clearFilters = () => {
    onSearch("");
    setLocalSearch("");
    onPositionFilter("all");
    onStatusFilter("all");
    onTeamFilter("all");
  };

  // Render team icon/logo (simple colored circle with abbreviation for now)
  const renderTeamIcon = (teamId: string) => {
    if (teamId === "all") return null;
    
    return (
      <div className="h-5 w-5 rounded-full bg-primary flex items-center justify-center text-white text-[10px] font-bold mr-2">
        {teamId.substring(0, 2)}
      </div>
    );
  };

  return (
    <Card className="mb-4">
      <CardContent className="p-4">
        <div className="grid gap-4 sm:grid-cols-1 md:grid-cols-4">
          {/* Search Box */}
          <div className="relative">
            <Input
              type="text"
              placeholder="Search players..."
              value={localSearch}
              onChange={handleSearchChange}
              onKeyDown={handleSearchKeyDown}
              className="pl-9"
            />
            <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
            <button
              onClick={handleSearchSubmit}
              className="absolute right-2 top-2 hover:text-primary"
              type="button"
              aria-label="Search"
            >
              {localSearch && (
                <X 
                  className="h-4 w-4 text-muted-foreground hover:text-destructive" 
                  onClick={(e) => {
                    e.stopPropagation();
                    setLocalSearch("");
                    onSearch("");
                  }} 
                />
              )}
            </button>
          </div>

          {/* Position Filter */}
          <div>
            <Select
              value={positionFilter}
              onValueChange={onPositionFilter}
            >
              <SelectTrigger className="w-full">
                <span className="flex items-center">
                  <Filter className="mr-2 h-4 w-4" />
                  {positionFilter === "all" ? "All Positions" : 
                   positionFilter === "top100" ? "Top 100 Players" : 
                   positionFilter}
                </span>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Positions</SelectItem>
                <SelectItem value="top100">Top 100 Players</SelectItem>
                {playerPositions.map(position => (
                  <SelectItem key={position} value={position}>{position}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Status Filter */}
          <div>
            <Select
              value={statusFilter}
              onValueChange={(value) => onStatusFilter(value as StatusFilter)}
            >
              <SelectTrigger className="w-full">
                <span className="flex items-center">
                  <Filter className="mr-2 h-4 w-4" />
                  {statusFilter === "all" ? "All Players" : 
                   statusFilter === "selected" ? "Selected" :
                   statusFilter === "not-selected" ? "Not Selected" :
                   statusFilter === "injured" ? "Injured" :
                   statusFilter === "suspended" ? "Suspended" :
                   statusFilter === "favorites" ? "Favorites" : statusFilter}
                </span>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Players</SelectItem>
                <SelectItem value="selected">Selected</SelectItem>
                <SelectItem value="not-selected">Not Selected</SelectItem>
                <SelectItem value="injured">Injured</SelectItem>
                <SelectItem value="suspended">Suspended</SelectItem>
                <SelectItem value="favorites">Favorites</SelectItem>
              </SelectContent>
            </Select>
          </div>

          {/* Team Filter */}
          <div>
            <Select
              value={teamFilter}
              onValueChange={onTeamFilter}
            >
              <SelectTrigger className="w-full">
                <span className="flex items-center">
                  {renderTeamIcon(teamFilter)}
                  {teams.find(t => t.id === teamFilter)?.name || "All Teams"}
                </span>
              </SelectTrigger>
              <SelectContent>
                {teams.map(team => (
                  <SelectItem key={team.id} value={team.id}>
                    <span className="flex items-center">
                      {renderTeamIcon(team.id)}
                      {team.name}
                    </span>
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
      </CardContent>
      
      {activeFilters > 0 && (
        <CardFooter className="p-2 pt-0 flex justify-between items-center">
          <div>
            <Badge variant="outline" className="mr-2">
              {activeFilters} active filter{activeFilters !== 1 ? 's' : ''}
            </Badge>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={clearFilters}
            className="text-xs"
          >
            Clear All
          </Button>
        </CardFooter>
      )}
    </Card>
  );
}