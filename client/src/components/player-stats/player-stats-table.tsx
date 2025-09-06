import { useState } from "react";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Card, CardContent } from "@/components/ui/card";
import { Search, ArrowDown, ArrowUp, ArrowUpDown, ChevronDown, ChevronUp } from "lucide-react";
import { PlayerPosition, formatCurrency } from "@/lib/utils";
import { Player } from "./player-table";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

type PlayerStatsTableProps = {
  players: Player[];
  isLoading: boolean;
  onSearch: (query: string) => void;
  onFilter: (position: string) => void;
  searchQuery: string;
  positionFilter: string;
};

// Type for sort direction
type SortDirection = "asc" | "desc" | null;

// Type for sort fields based on the stat category
type FantasySortField = "name" | "team" | "roundsPlayed" | "averagePoints" | "lastScore" | "l3Average" | "l5Average" | "breakEven" | "price" | "priceChange" | "pricePerPoint" | "totalPoints" | "selectionPercentage" | null;
type BasicSortField = "name" | "team" | "kicks" | "handballs" | "disposals" | "marks" | "tackles" | "freeKicksFor" | "freeKicksAgainst" | "clearances" | "hitouts" | "cba" | "kickIns" | "uncontestedMarks" | "contestedMarks" | "uncontestedDisposals" | "contestedDisposals" | null;
type VsSortField = "name" | "team" | "averageVsOpp" | "averageAtVenue" | "averageVs3RoundOpp" | "averageAt3RoundVenue" | "opponentDifficulty" | "opponent3RoundDifficulty" | null;

export default function PlayerStatsTable({
  players,
  isLoading,
  onSearch,
  onFilter,
  searchQuery,
  positionFilter,
}: PlayerStatsTableProps) {
  const [statCategory, setStatCategory] = useState<"fantasy" | "basic" | "vs">("fantasy");
  const [keyExpanded, setKeyExpanded] = useState(true);
  
  // Sort states for each stat category
  const [fantasySortField, setFantasySortField] = useState<FantasySortField>(null);
  const [fantasySortDirection, setFantasySortDirection] = useState<SortDirection>(null);
  
  const [basicSortField, setBasicSortField] = useState<BasicSortField>(null);
  const [basicSortDirection, setBasicSortDirection] = useState<SortDirection>(null);
  
  const [vsSortField, setVsSortField] = useState<VsSortField>(null);
  const [vsSortDirection, setVsSortDirection] = useState<SortDirection>(null);
  
  // Function to toggle key visibility
  const toggleKey = () => {
    setKeyExpanded(!keyExpanded);
  };
  
  // Get current sort field and direction based on active tab
  const getCurrentSortField = () => {
    if (statCategory === "fantasy") return fantasySortField;
    if (statCategory === "basic") return basicSortField;
    return vsSortField;
  };
  
  const getCurrentSortDirection = () => {
    if (statCategory === "fantasy") return fantasySortDirection;
    if (statCategory === "basic") return basicSortDirection;
    return vsSortDirection;
  };
  
  // Generic handle sort function
  const handleSort = (field: string) => {
    if (statCategory === "fantasy") {
      const typedField = field as FantasySortField;
      if (fantasySortField === typedField) {
        if (fantasySortDirection === "asc") {
          setFantasySortDirection("desc");
        } else {
          setFantasySortField(null);
          setFantasySortDirection(null);
        }
      } else {
        setFantasySortField(typedField);
        setFantasySortDirection("asc");
      }
    } else if (statCategory === "basic") {
      const typedField = field as BasicSortField;
      if (basicSortField === typedField) {
        if (basicSortDirection === "asc") {
          setBasicSortDirection("desc");
        } else {
          setBasicSortField(null);
          setBasicSortDirection(null);
        }
      } else {
        setBasicSortField(typedField);
        setBasicSortDirection("asc");
      }
    } else {
      const typedField = field as VsSortField;
      if (vsSortField === typedField) {
        if (vsSortDirection === "asc") {
          setVsSortDirection("desc");
        } else {
          setVsSortField(null);
          setVsSortDirection(null);
        }
      } else {
        setVsSortField(typedField);
        setVsSortDirection("asc");
      }
    }
  };
  
  // Get sort icon component based on current sort state
  const getSortIcon = (field: string) => {
    const currentField = getCurrentSortField();
    const currentDirection = getCurrentSortDirection();
    
    if (currentField !== field) {
      return <ArrowUpDown className="ml-1 h-3 w-3 inline opacity-40" />;
    }
    return currentDirection === "asc" 
      ? <ArrowUp className="ml-1 h-3 w-3 inline text-primary" /> 
      : <ArrowDown className="ml-1 h-3 w-3 inline text-primary" />;
  };
  
  // Add the sort class for styling
  const getSortableHeaderClass = (field: string) => {
    return `cursor-pointer hover:bg-neutral-light/50 ${getCurrentSortField() === field ? "bg-neutral-light/30" : ""}`;
  };

  const renderFantasyStatsHeaders = () => (
    <TableRow>
      <TableHead 
        className={`sticky left-0 z-10 bg-white whitespace-nowrap w-48 min-w-[12rem] ${getSortableHeaderClass("name")}`}
        onClick={() => handleSort("name")}
      >
        Player / Team {getSortIcon("name")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("roundsPlayed")}`}
        onClick={() => handleSort("roundsPlayed")}
      >
        Rd {getSortIcon("roundsPlayed")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averagePoints")}`}
        onClick={() => handleSort("averagePoints")}
      >
        Avg {getSortIcon("averagePoints")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("lastScore")}`}
        onClick={() => handleSort("lastScore")}
      >
        Last {getSortIcon("lastScore")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("l3Average")}`}
        onClick={() => handleSort("l3Average")}
      >
        L3 {getSortIcon("l3Average")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("l5Average")}`}
        onClick={() => handleSort("l5Average")}
      >
        L5 {getSortIcon("l5Average")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("breakEven")}`}
        onClick={() => handleSort("breakEven")}
      >
        BE {getSortIcon("breakEven")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-16 min-w-[4rem] ${getSortableHeaderClass("price")}`}
        onClick={() => handleSort("price")}
      >
        Price {getSortIcon("price")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("priceChange")}`}
        onClick={() => handleSort("priceChange")}
      >
        Δ {getSortIcon("priceChange")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("pricePerPoint")}`}
        onClick={() => handleSort("pricePerPoint")}
      >
        $/P {getSortIcon("pricePerPoint")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("totalPoints")}`}
        onClick={() => handleSort("totalPoints")}
      >
        Tot {getSortIcon("totalPoints")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("selectionPercentage")}`}
        onClick={() => handleSort("selectionPercentage")}
      >
        % {getSortIcon("selectionPercentage")}
      </TableHead>
    </TableRow>
  );

  const renderBasicStatsHeaders = () => (
    <TableRow>
      <TableHead 
        className={`sticky left-0 z-10 bg-white whitespace-nowrap w-48 min-w-[12rem] ${getSortableHeaderClass("name")}`}
        onClick={() => handleSort("name")}
      >
        Player / Team {getSortIcon("name")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("kicks")}`}
        onClick={() => handleSort("kicks")}
      >
        K {getSortIcon("kicks")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("handballs")}`}
        onClick={() => handleSort("handballs")}
      >
        HB {getSortIcon("handballs")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("disposals")}`}
        onClick={() => handleSort("disposals")}
      >
        D {getSortIcon("disposals")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("marks")}`}
        onClick={() => handleSort("marks")}
      >
        M {getSortIcon("marks")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("tackles")}`}
        onClick={() => handleSort("tackles")}
      >
        T {getSortIcon("tackles")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("freeKicksFor")}`}
        onClick={() => handleSort("freeKicksFor")}
      >
        FF {getSortIcon("freeKicksFor")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("freeKicksAgainst")}`}
        onClick={() => handleSort("freeKicksAgainst")}
      >
        FA {getSortIcon("freeKicksAgainst")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("clearances")}`}
        onClick={() => handleSort("clearances")}
      >
        C {getSortIcon("clearances")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("hitouts")}`}
        onClick={() => handleSort("hitouts")}
      >
        HO {getSortIcon("hitouts")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("cba")}`}
        onClick={() => handleSort("cba")}
      >
        CBA {getSortIcon("cba")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("kickIns")}`}
        onClick={() => handleSort("kickIns")}
      >
        KI {getSortIcon("kickIns")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("uncontestedMarks")}`}
        onClick={() => handleSort("uncontestedMarks")}
      >
        UM {getSortIcon("uncontestedMarks")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("contestedMarks")}`}
        onClick={() => handleSort("contestedMarks")}
      >
        CM {getSortIcon("contestedMarks")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("uncontestedDisposals")}`}
        onClick={() => handleSort("uncontestedDisposals")}
      >
        UD {getSortIcon("uncontestedDisposals")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("contestedDisposals")}`}
        onClick={() => handleSort("contestedDisposals")}
      >
        CD {getSortIcon("contestedDisposals")}
      </TableHead>
    </TableRow>
  );

  const renderVsStatsHeaders = () => (
    <TableRow>
      <TableHead 
        className={`sticky left-0 z-10 bg-white whitespace-nowrap w-48 min-w-[12rem] ${getSortableHeaderClass("name")}`}
        onClick={() => handleSort("name")}
      >
        Player / Team {getSortIcon("name")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averageVsOpp")}`}
        onClick={() => handleSort("averageVsOpp")}
      >
        vOpp {getSortIcon("averageVsOpp")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averageAtVenue")}`}
        onClick={() => handleSort("averageAtVenue")}
      >
        Venue {getSortIcon("averageAtVenue")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averageVs3RoundOpp")}`}
        onClick={() => handleSort("averageVs3RoundOpp")}
      >
        3ROpp {getSortIcon("averageVs3RoundOpp")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averageAt3RoundVenue")}`}
        onClick={() => handleSort("averageAt3RoundVenue")}
      >
        3RVen {getSortIcon("averageAt3RoundVenue")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("opponentDifficulty")}`}
        onClick={() => handleSort("opponentDifficulty")}
      >
        Diff {getSortIcon("opponentDifficulty")}
      </TableHead>
      <TableHead 
        className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("opponent3RoundDifficulty")}`}
        onClick={() => handleSort("opponent3RoundDifficulty")}
      >
        3RDiff {getSortIcon("opponent3RoundDifficulty")}
      </TableHead>
    </TableRow>
  );

  // Function to render team logo/icon
  const renderTeamLogo = (team: string) => {
    // We could add actual SVG logos for teams but for now using styled text
    return (
      <div className="h-6 w-6 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold">
        {team.substring(0, 2).toUpperCase()}
      </div>
    );
  };

  const renderFantasyStats = (player: Player) => (
    <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
      <TableCell className="sticky left-0 z-10 bg-white font-medium text-sm py-2 max-w-[140px]">
        <div className="flex items-center space-x-2">
          <div className="shrink-0">
            {renderTeamLogo(player.team)}
          </div>
          <div className="flex flex-col">
            <div className="text-sm font-medium line-clamp-1">{player.name.split(' ')[0]}</div>
            <div className="text-sm font-medium line-clamp-1">{player.name.split(' ').slice(1).join(' ')}</div>
          </div>
        </div>
      </TableCell>
      <TableCell className="text-center text-sm py-2">{player.roundsPlayed || 0}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.averagePoints.toFixed(1)}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.lastScore || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.l3Average?.toFixed(1) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.l5Average?.toFixed(1) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.breakEven}</TableCell>
      <TableCell className="text-center text-sm py-2">{formatCurrency(player.price)}</TableCell>
      <TableCell className={`text-center text-sm py-2 ${
        player.priceChange !== undefined 
          ? (player.priceChange > 0 
            ? 'text-green-600' 
            : player.priceChange < 0 
              ? 'text-red-600' 
              : '')
          : ''
      }`}>
        {player.priceChange !== undefined
          ? (player.priceChange > 0 ? '+' : '') + formatCurrency(player.priceChange) 
          : '-'}
      </TableCell>
      <TableCell className="text-center text-sm py-2">{player.pricePerPoint?.toFixed(2) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.totalPoints}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.selectionPercentage}%</TableCell>
    </TableRow>
  );

  const renderBasicStats = (player: Player) => (
    <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
      <TableCell className="sticky left-0 z-10 bg-white font-medium text-sm py-2 max-w-[140px]">
        <div className="flex items-center space-x-2">
          <div className="shrink-0">
            {renderTeamLogo(player.team)}
          </div>
          <div className="flex flex-col">
            <div className="text-sm font-medium line-clamp-1">{player.name.split(' ')[0]}</div>
            <div className="text-sm font-medium line-clamp-1">{player.name.split(' ').slice(1).join(' ')}</div>
          </div>
        </div>
      </TableCell>
      <TableCell className="text-center text-sm py-2">{player.kicks}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.handballs}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.disposals}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.marks}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.tackles}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.freeKicksFor}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.freeKicksAgainst}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.clearances}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.hitouts}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.cba}%</TableCell>
      <TableCell className="text-center text-sm py-2">{player.kickIns}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.uncontestedMarks}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.contestedMarks}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.uncontestedDisposals}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.contestedDisposals}</TableCell>
    </TableRow>
  );

  const renderVsStats = (player: Player) => (
    <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
      <TableCell className="sticky left-0 z-10 bg-white font-medium text-sm py-2 max-w-[140px]">
        <div className="flex items-center space-x-2">
          <div className="shrink-0">
            {renderTeamLogo(player.team)}
          </div>
          <div className="flex flex-col">
            <div className="text-sm font-medium line-clamp-1">{player.name.split(' ')[0]}</div>
            <div className="text-sm font-medium line-clamp-1">{player.name.split(' ').slice(1).join(' ')}</div>
          </div>
        </div>
      </TableCell>
      <TableCell className="text-center text-sm py-2">{player.averageVsOpp?.toFixed(1) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.averageAtVenue?.toFixed(1) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.averageVs3RoundOpp?.toFixed(1) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.averageAt3RoundVenue?.toFixed(1) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.opponentDifficulty?.toFixed(1) || '-'}</TableCell>
      <TableCell className="text-center text-sm py-2">{player.opponent3RoundDifficulty?.toFixed(1) || '-'}</TableCell>
    </TableRow>
  );

  return (
    <>
      <div className="mb-4">
        {/* Full-width stats key with collapsible functionality */}
        <div 
          className="w-full bg-gray-100 p-3 rounded text-xs mb-4 cursor-pointer"
          onClick={toggleKey}
        >
          <div className="font-medium mb-2 text-sm flex justify-between items-center">
            <span>Stats Key</span>
            {keyExpanded ? 
              <ChevronUp className="h-4 w-4 opacity-70" /> : 
              <ChevronDown className="h-4 w-4 opacity-70" />
            }
          </div>
          
          {keyExpanded && (
            <>
              {statCategory === "fantasy" && (
                <div className="grid grid-cols-3 md:grid-cols-6 gap-x-6 gap-y-1">
                  <div>Rd = Rounds</div>
                  <div>Avg = Average</div>
                  <div>L3 = Last 3</div>
                  <div>L5 = Last 5</div>
                  <div>BE = Break Even</div>
                  <div>Δ = Price Change</div>
                  <div>$/P = Price per Point</div>
                  <div>Tot = Total Points</div>
                  <div>% = Selected %</div>
                </div>
              )}
              {statCategory === "basic" && (
                <div className="grid grid-cols-3 md:grid-cols-5 gap-x-6 gap-y-1">
                  <div>K = Kicks</div>
                  <div>HB = Handballs</div>
                  <div>D = Disposals</div>
                  <div>M = Marks</div>
                  <div>T = Tackles</div>
                  <div>FF = Free Kicks For</div>
                  <div>FA = Free Against</div>
                  <div>C = Clearances</div>
                  <div>HO = Hitouts</div>
                  <div>CBA = Center Bounce %</div>
                  <div>KI = Kick Ins</div>
                  <div>UM = Uncontested Marks</div>
                  <div>CM = Contested Marks</div>
                  <div>UD = Uncontested Disp.</div>
                  <div>CD = Contested Disp.</div>
                </div>
              )}
              {statCategory === "vs" && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-1">
                  <div>vOpp = vs Opponent</div>
                  <div>Venue = at Venue</div>
                  <div>3ROpp = Next 3 Oppo</div>
                  <div>3RVen = Next 3 Venues</div>
                  <div>Diff = Difficulty</div>
                  <div>3RDiff = 3R Difficulty</div>
                </div>
              )}
            </>
          )}
        </div>
        
        {/* Stat category tabs below the key */}
        <div className="mb-4">
          <Tabs 
            value={statCategory} 
            onValueChange={(value) => setStatCategory(value as "fantasy" | "basic" | "vs")}
            className="w-full"
          >
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="fantasy">Fantasy</TabsTrigger>
              <TabsTrigger value="basic">Basic</TabsTrigger>
              <TabsTrigger value="vs">VS</TabsTrigger>
            </TabsList>
          </Tabs>
        </div>
        
        {/* Search and position filters below the tabs */}
        <div className="flex flex-wrap gap-3 mb-4 items-center">
          <div className="relative">
            <Input
              type="text"
              placeholder="Search..."
              className="w-[180px] sm:w-[220px] pl-8 pr-2 py-1 h-9 text-sm"
              value={searchQuery}
              onChange={(e) => onSearch(e.target.value)}
            />
            <div className="absolute left-2 top-2 text-neutral">
              <Search className="h-4 w-4" />
            </div>
          </div>
          
          <Select value={positionFilter} onValueChange={onFilter}>
            <SelectTrigger className="w-[120px] h-9 text-sm">
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
      
      <Card className="bg-white shadow-sm">
        <div className="overflow-x-auto relative" style={{ WebkitOverflowScrolling: 'touch' }}>
          {/* Add overlay gradient to hide scrolling content behind sticky columns */}
          <div className="absolute top-0 left-[160px] bottom-0 w-6 z-20 pointer-events-none" 
               style={{ background: 'linear-gradient(to right, rgba(255,255,255,1) 0%, rgba(255,255,255,0) 100%)' }}>
          </div>
          <Table className="relative w-full min-w-max">
            <TableHeader className="bg-white">
              {statCategory === "fantasy" && renderFantasyStatsHeaders()}
              {statCategory === "basic" && renderBasicStatsHeaders()}
              {statCategory === "vs" && renderVsStatsHeaders()}
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={12} className="h-24 text-center">
                    Loading players...
                  </TableCell>
                </TableRow>
              ) : players.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={12} className="h-24 text-center">
                    No players found. Try adjusting your search.
                  </TableCell>
                </TableRow>
              ) : (
                // Sort players based on current sort state
                [...players]
                  .sort((a, b) => {
                    const currentField = getCurrentSortField();
                    const currentDirection = getCurrentSortDirection();
                    
                    if (!currentField || !currentDirection) return 0;
                    
                    // Type narrowing with string key
                    const field = currentField as string;
                    
                    // Compare values with proper type checks
                    if (field === 'name' || field === 'team' || field === 'position') {
                      // Handle string fields
                      const valueA = a[field as keyof Player] as string || '';
                      const valueB = b[field as keyof Player] as string || '';
                      const result = valueA.localeCompare(valueB);
                      return currentDirection === 'asc' ? result : -result;
                    } else {
                      // Handle numeric fields
                      const valueA = typeof a[field as keyof Player] === 'number' ? a[field as keyof Player] as number : 0;
                      const valueB = typeof b[field as keyof Player] === 'number' ? b[field as keyof Player] as number : 0;
                      return currentDirection === 'asc' ? valueA - valueB : valueB - valueA;
                    }
                  })
                  .map((player) => (
                    statCategory === "fantasy" ? renderFantasyStats(player) :
                    statCategory === "basic" ? renderBasicStats(player) :
                    renderVsStats(player)
                  ))
              )}
            </TableBody>
          </Table>
        </div>
      </Card>
    </>
  );
}