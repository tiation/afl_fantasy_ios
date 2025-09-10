import { 
  Table, TableBody, TableCell, TableHead, TableHeader, TableRow 
} from "@/components/ui/table";
import { Card } from "@/components/ui/card";
import {
  ArrowUp, ArrowDown, ArrowUpDown, Star, StarOff
} from "lucide-react";
import { formatCurrency } from "@/lib/utils";
import {
  Player, StatsCategory, 
  BasicSortField, FantasySortField, ValueSortField,
  ConsistencySortField, OppositionSortField, VenueSortField,
  SortDirection
} from "./player-types";
import { useState } from "react";
import PlayerDetailModal from "./player-detail-modal";

type PlayerStatsTableProps = {
  players: Player[];
  isLoading: boolean;
  category: StatsCategory;
  onToggleFavorite?: (playerId: number) => void;
};

export default function EnhancedStatsTable({
  players,
  isLoading,
  category,
  onToggleFavorite
}: PlayerStatsTableProps) {
  // Modal state
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  
  // Sort states for each category
  const [basicSortField, setBasicSortField] = useState<BasicSortField>(null);
  const [basicSortDirection, setBasicSortDirection] = useState<SortDirection>(null);
  
  const [fantasySortField, setFantasySortField] = useState<FantasySortField>(null);
  const [fantasySortDirection, setFantasySortDirection] = useState<SortDirection>(null);
  
  const [valueSortField, setValueSortField] = useState<ValueSortField>(null);
  const [valueSortDirection, setValueSortDirection] = useState<SortDirection>(null);
  
  const [consistencySortField, setConsistencySortField] = useState<ConsistencySortField>(null);
  const [consistencySortDirection, setConsistencySortDirection] = useState<SortDirection>(null);
  
  const [oppositionSortField, setOppositionSortField] = useState<OppositionSortField>(null);
  const [oppositionSortDirection, setOppositionSortDirection] = useState<SortDirection>(null);
  
  const [venueSortField, setVenueSortField] = useState<VenueSortField>(null);
  const [venueSortDirection, setVenueSortDirection] = useState<SortDirection>(null);
  
  // Get current sort field and direction based on active tab
  const getCurrentSortField = () => {
    switch (category) {
      case 'basic': return basicSortField;
      case 'fantasy': return fantasySortField;
      case 'value': return valueSortField;
      case 'consistency': return consistencySortField;
      case 'opposition': return oppositionSortField;
      case 'venue': return venueSortField;
      default: return null;
    }
  };
  
  const getCurrentSortDirection = () => {
    switch (category) {
      case 'basic': return basicSortDirection;
      case 'fantasy': return fantasySortDirection;
      case 'value': return valueSortDirection;
      case 'consistency': return consistencySortDirection;
      case 'opposition': return oppositionSortDirection;
      case 'venue': return venueSortDirection;
      default: return null;
    }
  };
  
  // Generic handle sort function
  const handleSort = (field: string) => {
    switch (category) {
      case 'basic': {
        const basicField = field as BasicSortField;
        if (basicSortField === basicField) {
          if (basicSortDirection === "asc") {
            setBasicSortDirection("desc");
          } else {
            setBasicSortField(null);
            setBasicSortDirection(null);
          }
        } else {
          setBasicSortField(basicField);
          setBasicSortDirection("asc");
        }
        break;
      }
        
      case 'fantasy': {
        const fantasyField = field as FantasySortField;
        if (fantasySortField === fantasyField) {
          if (fantasySortDirection === "asc") {
            setFantasySortDirection("desc");
          } else {
            setFantasySortField(null);
            setFantasySortDirection(null);
          }
        } else {
          setFantasySortField(fantasyField);
          setFantasySortDirection("asc");
        }
        break;
      }
        
      case 'value': {
        const valueField = field as ValueSortField;
        if (valueSortField === valueField) {
          if (valueSortDirection === "asc") {
            setValueSortDirection("desc");
          } else {
            setValueSortField(null);
            setValueSortDirection(null);
          }
        } else {
          setValueSortField(valueField);
          setValueSortDirection("asc");
        }
        break;
      }
        
      case 'consistency': {
        const consistencyField = field as ConsistencySortField;
        if (consistencySortField === consistencyField) {
          if (consistencySortDirection === "asc") {
            setConsistencySortDirection("desc");
          } else {
            setConsistencySortField(null);
            setConsistencySortDirection(null);
          }
        } else {
          setConsistencySortField(consistencyField);
          setConsistencySortDirection("asc");
        }
        break;
      }
        
      case 'opposition': {
        const oppositionField = field as OppositionSortField;
        if (oppositionSortField === oppositionField) {
          if (oppositionSortDirection === "asc") {
            setOppositionSortDirection("desc");
          } else {
            setOppositionSortField(null);
            setOppositionSortDirection(null);
          }
        } else {
          setOppositionSortField(oppositionField);
          setOppositionSortDirection("asc");
        }
        break;
      }
        
      case 'venue': {
        const venueField = field as VenueSortField;
        if (venueSortField === venueField) {
          if (venueSortDirection === "asc") {
            setVenueSortDirection("desc");
          } else {
            setVenueSortField(null);
            setVenueSortDirection(null);
          }
        } else {
          setVenueSortField(venueField);
          setVenueSortDirection("asc");
        }
        break;
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

  // Function to render team logo/icon
  const renderTeamLogo = (team: string | undefined) => {
    // Handle undefined, null, or empty team names safely
    const teamAbbrev = team && typeof team === 'string' ? team.substring(0, 2).toUpperCase() : 'NA';
    
    return (
      <div className="h-6 w-6 rounded-full bg-primary flex items-center justify-center text-white text-xs font-bold">
        {teamAbbrev}
      </div>
    );
  };

  // Function to toggle player favorite status
  const handleToggleFavorite = (playerId: number) => {
    if (onToggleFavorite) {
      onToggleFavorite(playerId);
    }
  };

  // Open the player detail modal
  const openPlayerDetailModal = (player: Player) => {
    setSelectedPlayer(player);
    setIsDetailModalOpen(true);
  };
  
  // Player name and team cell (common across all views)
  const renderPlayerCell = (player: Player) => (
    <>
      <TableCell className="sticky left-0 z-10 bg-white font-medium text-sm py-2">
        <div className="flex items-center">
          <button 
            onClick={() => handleToggleFavorite(player.id)}
            className="mr-2 text-gray-400 hover:text-yellow-500 focus:outline-none"
          >
            {player.isFavorite ? (
              <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
            ) : (
              <StarOff className="h-4 w-4" />
            )}
          </button>
          <div className="flex flex-col">
            <div className="text-sm font-medium flex items-center">
              <button 
                onClick={() => openPlayerDetailModal(player)}
                className="hover:text-primary hover:underline text-left focus:outline-none"
              >
                {player.name}
              </button>
              {player.isInjured && (
                <span className="ml-1 px-1 text-xs bg-red-100 text-red-800 rounded">INJ</span>
              )}
              {player.isSuspended && (
                <span className="ml-1 px-1 text-xs bg-red-100 text-red-800 rounded">SUS</span>
              )}
            </div>
            <div className="text-xs text-gray-500">{player.position}</div>
          </div>
        </div>
      </TableCell>
      <TableCell className="sticky left-32 z-10 bg-white py-2">
        {renderTeamLogo(player.team)}
      </TableCell>
    </>
  );

  // Different table headers based on category
  const renderTableHeaders = () => {
    switch (category) {
      case 'basic':
        return (
          <TableRow>
            <TableHead 
              className={`sticky left-0 z-10 bg-white whitespace-nowrap w-32 min-w-[8rem] ${getSortableHeaderClass("name")}`}
              onClick={() => handleSort("name")}
            >
              Player {getSortIcon("name")}
            </TableHead>
            <TableHead 
              className={`sticky left-32 z-10 bg-white w-12 min-w-[3rem] ${getSortableHeaderClass("team")}`}
              onClick={() => handleSort("team")}
            >
              Team {getSortIcon("team")}
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
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("clearances")}`}
              onClick={() => handleSort("clearances")}
            >
              C {getSortIcon("clearances")}
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
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("hitouts")}`}
              onClick={() => handleSort("hitouts")}
            >
              HO {getSortIcon("hitouts")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("cba")}`}
              onClick={() => handleSort("cba")}
            >
              CBA% {getSortIcon("cba")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("kickIns")}`}
              onClick={() => handleSort("kickIns")}
            >
              KI {getSortIcon("kickIns")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("contestedMarks")}`}
              onClick={() => handleSort("contestedMarks")}
            >
              CM {getSortIcon("contestedMarks")}
            </TableHead>
          </TableRow>
        );
        
      case 'fantasy':
        return (
          <TableRow>
            <TableHead 
              className={`sticky left-0 z-10 bg-white whitespace-nowrap w-32 min-w-[8rem] ${getSortableHeaderClass("name")}`}
              onClick={() => handleSort("name")}
            >
              Player {getSortIcon("name")}
            </TableHead>
            <TableHead 
              className={`sticky left-32 z-10 bg-white w-12 min-w-[3rem] ${getSortableHeaderClass("team")}`}
              onClick={() => handleSort("team")}
            >
              Team {getSortIcon("team")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-16 min-w-[4rem] ${getSortableHeaderClass("price")}`}
              onClick={() => handleSort("price")}
            >
              Price {getSortIcon("price")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("lastScore")}`}
              onClick={() => handleSort("lastScore")}
            >
              Last Rd {getSortIcon("lastScore")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("totalPoints")}`}
              onClick={() => handleSort("totalPoints")}
            >
              Total {getSortIcon("totalPoints")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averagePoints")}`}
              onClick={() => handleSort("averagePoints")}
            >
              Avg {getSortIcon("averagePoints")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("l3Average")}`}
              onClick={() => handleSort("l3Average")}
            >
              L3 Avg {getSortIcon("l3Average")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("l5Average")}`}
              onClick={() => handleSort("l5Average")}
            >
              L5 Avg {getSortIcon("l5Average")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("breakEven")}`}
              onClick={() => handleSort("breakEven")}
            >
              BE {getSortIcon("breakEven")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("pricePerPoint")}`}
              onClick={() => handleSort("pricePerPoint")}
            >
              $/Point {getSortIcon("pricePerPoint")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("selectionPercentage")}`}
              onClick={() => handleSort("selectionPercentage")}
            >
              Own % {getSortIcon("selectionPercentage")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("roundsPlayed")}`}
              onClick={() => handleSort("roundsPlayed")}
            >
              GP {getSortIcon("roundsPlayed")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-12 min-w-[3rem] ${getSortableHeaderClass("priceChange")}`}
              onClick={() => handleSort("priceChange")}
            >
              $ Ch {getSortIcon("priceChange")}
            </TableHead>
          </TableRow>
        );
        
      case 'value':
        return (
          <TableRow>
            <TableHead 
              className={`sticky left-0 z-10 bg-white whitespace-nowrap w-32 min-w-[8rem] ${getSortableHeaderClass("name")}`}
              onClick={() => handleSort("name")}
            >
              Player {getSortIcon("name")}
            </TableHead>
            <TableHead 
              className={`sticky left-32 z-10 bg-white w-12 min-w-[3rem] ${getSortableHeaderClass("team")}`}
              onClick={() => handleSort("team")}
            >
              Team {getSortIcon("team")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-16 min-w-[4rem] ${getSortableHeaderClass("price")}`}
              onClick={() => handleSort("price")}
            >
              Value {getSortIcon("price")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("breakEven")}`}
              onClick={() => handleSort("breakEven")}
            >
              BE {getSortIcon("breakEven")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("projectedScore")}`}
              onClick={() => handleSort("projectedScore")}
            >
              Proj Score {getSortIcon("projectedScore")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("projectedPriceChange")}`}
              onClick={() => handleSort("projectedPriceChange")}
            >
              Proj $ Change {getSortIcon("projectedPriceChange")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-10 min-w-[2.5rem] ${getSortableHeaderClass("breakEvenPercentage")}`}
              onClick={() => handleSort("breakEvenPercentage")}
            >
              BE% {getSortIcon("breakEvenPercentage")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("projectedOwnershipChange")}`}
              onClick={() => handleSort("projectedOwnershipChange")}
            >
              Proj Own % {getSortIcon("projectedOwnershipChange")}
            </TableHead>
          </TableRow>
        );
        
      case 'consistency':
        return (
          <TableRow>
            <TableHead 
              className={`sticky left-0 z-10 bg-white whitespace-nowrap w-32 min-w-[8rem] ${getSortableHeaderClass("name")}`}
              onClick={() => handleSort("name")}
            >
              Player {getSortIcon("name")}
            </TableHead>
            <TableHead 
              className={`sticky left-32 z-10 bg-white w-12 min-w-[3rem] ${getSortableHeaderClass("team")}`}
              onClick={() => handleSort("team")}
            >
              Team {getSortIcon("team")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("roundsPlayed")}`}
              onClick={() => handleSort("roundsPlayed")}
            >
              GP {getSortIcon("roundsPlayed")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averagePoints")}`}
              onClick={() => handleSort("averagePoints")}
            >
              Avg {getSortIcon("averagePoints")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("standardDeviation")}`}
              onClick={() => handleSort("standardDeviation")}
            >
              Std Dev {getSortIcon("standardDeviation")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("highScore")}`}
              onClick={() => handleSort("highScore")}
            >
              High {getSortIcon("highScore")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("lowScore")}`}
              onClick={() => handleSort("lowScore")}
            >
              Low {getSortIcon("lowScore")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-16 min-w-[4rem] ${getSortableHeaderClass("belowAveragePercentage")}`}
              onClick={() => handleSort("belowAveragePercentage")}
            >
              % Below Avg {getSortIcon("belowAveragePercentage")}
            </TableHead>
          </TableRow>
        );
        
      case 'opposition':
        return (
          <TableRow>
            <TableHead 
              className={`sticky left-0 z-10 bg-white whitespace-nowrap w-32 min-w-[8rem] ${getSortableHeaderClass("name")}`}
              onClick={() => handleSort("name")}
            >
              Player {getSortIcon("name")}
            </TableHead>
            <TableHead 
              className={`sticky left-32 z-10 bg-white w-12 min-w-[3rem] ${getSortableHeaderClass("team")}`}
              onClick={() => handleSort("team")}
            >
              Team {getSortIcon("team")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("nextOpponent")}`}
              onClick={() => handleSort("nextOpponent")}
            >
              Next Opp {getSortIcon("nextOpponent")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averageVsOpp")}`}
              onClick={() => handleSort("averageVsOpp")}
            >
              Avg vs Opp {getSortIcon("averageVsOpp")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("opponent3RoundDifficulty")}`}
              onClick={() => handleSort("opponent3RoundDifficulty")}
            >
              3R Diff {getSortIcon("opponent3RoundDifficulty")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("scoreImpact")}`}
              onClick={() => handleSort("scoreImpact")}
            >
              Score Impact {getSortIcon("scoreImpact")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("projectedAverage")}`}
              onClick={() => handleSort("projectedAverage")}
            >
              Proj Avg {getSortIcon("projectedAverage")}
            </TableHead>
          </TableRow>
        );
        
      case 'venue':
        return (
          <TableRow>
            <TableHead 
              className={`sticky left-0 z-10 bg-white whitespace-nowrap w-32 min-w-[8rem] ${getSortableHeaderClass("name")}`}
              onClick={() => handleSort("name")}
            >
              Player {getSortIcon("name")}
            </TableHead>
            <TableHead 
              className={`sticky left-32 z-10 bg-white w-12 min-w-[3rem] ${getSortableHeaderClass("team")}`}
              onClick={() => handleSort("team")}
            >
              Team {getSortIcon("team")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("nextVenue")}`}
              onClick={() => handleSort("nextVenue")}
            >
              Next Venue {getSortIcon("nextVenue")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averageAtVenue")}`}
              onClick={() => handleSort("averageAtVenue")}
            >
              Avg at Venue {getSortIcon("averageAtVenue")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("averageAt3RoundVenue")}`}
              onClick={() => handleSort("averageAt3RoundVenue")}
            >
              3R Venue Avg {getSortIcon("averageAt3RoundVenue")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("opponent3RoundDifficulty")}`}
              onClick={() => handleSort("opponent3RoundDifficulty")}
            >
              3R Diff Rating {getSortIcon("opponent3RoundDifficulty")}
            </TableHead>
            <TableHead 
              className={`bg-white whitespace-nowrap w-14 min-w-[3.5rem] ${getSortableHeaderClass("venueScoreVariance")}`}
              onClick={() => handleSort("venueScoreVariance")}
            >
              Venue Variance {getSortIcon("venueScoreVariance")}
            </TableHead>
          </TableRow>
        );
        
      default:
        return null;
    }
  };

  // Different row renderers based on category
  const renderTableRow = (player: Player) => {
    switch (category) {
      case 'basic':
        return (
          <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
            {renderPlayerCell(player)}
            <TableCell className="text-center text-sm py-2">{player.kicks || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.handballs || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.disposals || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.marks || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.tackles || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.clearances || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.freeKicksFor || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.freeKicksAgainst || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.hitouts || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.cba ? `${player.cba}%` : '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.kickIns || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.contestedMarks || '-'}</TableCell>
          </TableRow>
        );
        
      case 'fantasy':
        return (
          <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
            {renderPlayerCell(player)}
            <TableCell className="text-center text-sm py-2">{formatCurrency(player.price)}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.lastScore || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.totalPoints || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.averagePoints ? player.averagePoints.toFixed(1) : '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.l3Average ? player.l3Average.toFixed(1) : '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.l5Average ? player.l5Average.toFixed(1) : '-'}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${player.breakEven && player.breakEven < 0 ? 'text-red-600' : ''}`}>
              {player.breakEven || '-'}
            </TableCell>
            <TableCell className="text-center text-sm py-2">{player.pricePerPoint ? player.pricePerPoint.toFixed(2) : '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.selectionPercentage ? player.selectionPercentage.toFixed(1) + '%' : '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.roundsPlayed || '-'}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.priceChange && player.priceChange > 0 
                ? 'text-green-600' 
                : player.priceChange && player.priceChange < 0 
                  ? 'text-red-600' 
                  : ''
            }`}>
              {player.priceChange 
                ? `${player.priceChange > 0 ? '+' : ''}${formatCurrency(player.priceChange)}` 
                : '-'
              }
            </TableCell>
          </TableRow>
        );
        
      case 'value':
        return (
          <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
            {renderPlayerCell(player)}
            <TableCell className="text-center text-sm py-2">{formatCurrency(player.price)}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${player.breakEven < 0 ? 'text-red-600' : ''}`}>
              {player.breakEven}
            </TableCell>
            <TableCell className="text-center text-sm py-2">{player.projectedScore || '-'}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.projectedPriceChange && player.projectedPriceChange > 0
                ? 'text-green-600'
                : player.projectedPriceChange && player.projectedPriceChange < 0
                ? 'text-red-600'
                : ''
            }`}>
              {player.projectedPriceChange
                ? `${player.projectedPriceChange > 0 ? '+' : ''}${formatCurrency(player.projectedPriceChange)}`
                : '-'}
            </TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.breakEvenPercentage && player.breakEvenPercentage > 0.8
                ? 'text-red-600'
                : player.breakEvenPercentage && player.breakEvenPercentage < 0.4
                ? 'text-green-600'
                : ''
            }`}>
              {player.breakEvenPercentage ? `${(player.breakEvenPercentage * 100).toFixed(0)}%` : '-'}
            </TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.projectedOwnershipChange && player.projectedOwnershipChange > 0
                ? 'text-green-600'
                : player.projectedOwnershipChange && player.projectedOwnershipChange < 0
                ? 'text-red-600'
                : ''
            }`}>
              {player.projectedOwnershipChange 
                ? `${player.projectedOwnershipChange > 0 ? '+' : ''}${player.projectedOwnershipChange.toFixed(1)}%` 
                : '-'}
            </TableCell>
          </TableRow>
        );
        
      case 'consistency':
        return (
          <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
            {renderPlayerCell(player)}
            <TableCell className="text-center text-sm py-2">{player.roundsPlayed || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.averagePoints ? player.averagePoints.toFixed(1) : '-'}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.standardDeviation && player.standardDeviation > player.averagePoints * 0.4
                ? 'text-red-600'
                : player.standardDeviation && player.standardDeviation < player.averagePoints * 0.2
                ? 'text-green-600'
                : ''
            }`}>
              {player.standardDeviation?.toFixed(1) || '-'}
            </TableCell>
            <TableCell className="text-center text-sm py-2">{player.highScore || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.lowScore || '-'}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.belowAveragePercentage && player.belowAveragePercentage > 0.5
                ? 'text-red-600'
                : player.belowAveragePercentage && player.belowAveragePercentage < 0.25
                ? 'text-green-600'
                : ''
            }`}>
              {player.belowAveragePercentage ? `${(player.belowAveragePercentage * 100).toFixed(0)}%` : '-'}
            </TableCell>
          </TableRow>
        );
        
      case 'opposition':
        return (
          <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
            {renderPlayerCell(player)}
            <TableCell className="text-center text-sm py-2">
              {player.nextOpponent ? (
                <div className="flex justify-center">
                  <div className="h-5 w-5 rounded-full bg-blue-500 flex items-center justify-center text-white text-[10px] font-bold">
                    {player.nextOpponent.substring(0, 2).toUpperCase()}
                  </div>
                </div>
              ) : '-'}
            </TableCell>
            <TableCell className="text-center text-sm py-2">{player.averageVsOpp?.toFixed(1) || '-'}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.opponent3RoundDifficulty && player.opponent3RoundDifficulty > 7
                ? 'text-red-600'
                : player.opponent3RoundDifficulty && player.opponent3RoundDifficulty < 4
                ? 'text-green-600'
                : ''
            }`}>
              {player.opponent3RoundDifficulty?.toFixed(1) || '-'}/10
            </TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.scoreImpact && player.scoreImpact < 0
                ? 'text-red-600'
                : player.scoreImpact && player.scoreImpact > 0
                ? 'text-green-600'
                : ''
            }`}>
              {player.scoreImpact ? `${player.scoreImpact > 0 ? '+' : ''}${player.scoreImpact.toFixed(1)}` : '-'}
            </TableCell>
            <TableCell className="text-center text-sm py-2">{player.projectedAverage?.toFixed(1) || '-'}</TableCell>
          </TableRow>
        );
        
      case 'venue':
        return (
          <TableRow key={player.id} className="hover:bg-neutral-lightest cursor-pointer">
            {renderPlayerCell(player)}
            <TableCell className="text-center text-sm py-2">{player.nextVenue || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.averageAtVenue?.toFixed(1) || '-'}</TableCell>
            <TableCell className="text-center text-sm py-2">{player.averageAt3RoundVenue?.toFixed(1) || '-'}</TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.opponent3RoundDifficulty && player.opponent3RoundDifficulty > 7
                ? 'text-red-600'
                : player.opponent3RoundDifficulty && player.opponent3RoundDifficulty < 4
                ? 'text-green-600'
                : ''
            }`}>
              {player.opponent3RoundDifficulty?.toFixed(1) || '-'}/10
            </TableCell>
            <TableCell className={`text-center text-sm py-2 ${
              player.venueScoreVariance && player.venueScoreVariance > 20
                ? 'text-red-600'
                : player.venueScoreVariance && player.venueScoreVariance < 10
                ? 'text-green-600'
                : ''
            }`}>
              {player.venueScoreVariance?.toFixed(1) || '-'}
            </TableCell>
          </TableRow>
        );
        
      default:
        return null;
    }
  };

  // Sort players based on current sort state
  const sortedPlayers = [...players].sort((a, b) => {
    const currentField = getCurrentSortField();
    const currentDirection = getCurrentSortDirection();
    
    if (!currentField || !currentDirection) return 0;
    
    // Type narrowing with string key
    const field = currentField as string;
    
    // Handle string fields specially
    if (field === 'name' || field === 'team' || field === 'nextOpponent' || field === 'nextVenue') {
      const valueA = (a[field as keyof Player] as string) || '';
      const valueB = (b[field as keyof Player] as string) || '';
      const result = valueA.localeCompare(valueB);
      return currentDirection === 'asc' ? result : -result;
    } 
    
    // Handle numeric fields
    const valueA = typeof a[field as keyof Player] === 'number' ? a[field as keyof Player] as number : 0;
    const valueB = typeof b[field as keyof Player] === 'number' ? b[field as keyof Player] as number : 0;
    return currentDirection === 'asc' ? valueA - valueB : valueB - valueA;
  });

  return (
    <>
      <Card className="bg-white shadow-sm">
        <div className="overflow-x-auto relative" style={{ WebkitOverflowScrolling: 'touch' }}>
          {/* Add overlay gradient to hide scrolling content behind sticky columns */}
          <div className="absolute top-0 left-[160px] bottom-0 w-6 z-20 pointer-events-none" 
              style={{ background: 'linear-gradient(to right, rgba(255,255,255,1) 0%, rgba(255,255,255,0) 100%)' }}>
          </div>
          <Table className="relative w-full min-w-max">
            <TableHeader className="bg-white">
              {renderTableHeaders()}
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={12} className="h-24 text-center">
                    Loading players...
                  </TableCell>
                </TableRow>
              ) : sortedPlayers.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={12} className="h-24 text-center">
                    No players found. Try adjusting your search.
                  </TableCell>
                </TableRow>
              ) : (
                sortedPlayers.map(player => renderTableRow(player))
              )}
            </TableBody>
          </Table>
        </div>
      </Card>
      
      {/* Player detail modal */}
      <PlayerDetailModal 
        player={selectedPlayer}
        open={isDetailModalOpen}
        onOpenChange={setIsDetailModalOpen}
      />
    </>
  );
}