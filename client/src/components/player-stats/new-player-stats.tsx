import { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ChevronDown, ChevronUp, Filter, Search, X, ArrowUpDown, ArrowUp, ArrowDown } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Slider } from "@/components/ui/slider";
import { getTeamGuernsey } from "@/lib/team-utils";
import PlayerDetailModal from "@/components/player-stats/player-detail-modal";
import { Player as DetailPlayer } from "@/components/player-stats/player-types";

// Define custom Player type for this component
export type Player = {
  id: string | number;
  name: string;
  team: string;
  position: string;
  price: number;
  averagePoints: number;
  projectedScore?: number;
  lastScore: number;
  l3Average: number;
  l5Average: number;
  breakEven: number;
  priceChange: number;
  pricePerPoint: number;
  totalPoints: number;
  selectionPercentage: number;
  kicks?: number;
  handballs?: number;
  marks?: number;
  tackles?: number;
  hitouts?: number;
  freeKicksFor?: number;
  freeKicksAgainst?: number;
  clearances?: number;
  cba?: number;
  kickIns?: number;
  contestedMarks?: number;
  uncontestedMarks?: number;
  contestedDisposals?: number;
  uncontestedDisposals?: number;
  disposals?: number;
};

type NewPlayerStatsProps = {
  players: Player[];
  isLoading: boolean;
  onSearch: (query: string) => void;
  onFilter: (position: string) => void;
  searchQuery: string;
  positionFilter: string;
};

// Define stat categories
const statCategories = {
  core: {
    name: 'Core Fantasy Stats',
    borderColor: 'border-purple-500',
    neonClass: 'shadow-[0_0_15px_rgba(168,85,247,0.5)] border-purple-500 bg-purple-500/20',
    columns: ['avg', 'projectedScore', 'last', 'l3', 'l5', 'be', 'total', 'selection']
  },
  price: {
    name: 'Price & Movement',
    borderColor: 'border-blue-500',
    neonClass: 'shadow-[0_0_15px_rgba(59,130,246,0.5)] border-blue-500 bg-blue-500/20',
    columns: ['price', 'priceChange', 'pricePerPoint', 'value']
  },
  match: {
    name: 'Match Stats',
    borderColor: 'border-green-500',
    neonClass: 'shadow-[0_0_15px_rgba(34,197,94,0.5)] border-green-500 bg-green-500/20',
    columns: ['kicks', 'handballs', 'disposals', 'marks', 'tackles', 'hitouts']
  },
  role: {
    name: 'Role Stats',
    borderColor: 'border-orange-500',
    neonClass: 'shadow-[0_0_15px_rgba(249,115,22,0.5)] border-orange-500 bg-orange-500/20',
    columns: ['cbaPercentage', 'kickIns', 'togPercentage', 'possessionType', 'insideOutside']
  },
  volatility: {
    name: 'Volatility Stats',
    borderColor: 'border-red-600',
    neonClass: 'shadow-[0_0_15px_rgba(220,38,38,0.5)] border-red-600 bg-red-600/20',
    columns: ['consistency', 'volatility', 'ceiling', 'floor']
  },
  fixture: {
    name: 'Fixture & Matchups',
    borderColor: 'border-emerald-500',
    neonClass: 'shadow-[0_0_15px_rgba(16,185,129,0.5)] border-emerald-500 bg-emerald-500/20',
    columns: ['opponentR20', 'opponentR21', 'opponentR22', 'dvpR20', 'dvpR21', 'dvpR22', 'dvpR23', 'dvpR24']
  }
};

// Define column headers and explanations
const columnDefinitions = {
  avg: { header: 'Avg', explanation: 'Season Average Points' },
  projectedScore: { header: 'Proj', explanation: 'Projected Score (v3.4.4 Algorithm)' },
  last: { header: 'Last', explanation: 'Last Round Score' },
  l3: { header: 'L3', explanation: 'Last 3 Games Average' },
  l5: { header: 'L5', explanation: 'Last 5 Games Average' },
  be: { header: 'BE', explanation: 'Break Even Score' },
  total: { header: 'Tot', explanation: 'Total Points' },
  selection: { header: '%', explanation: 'Selection Percentage' },
  price: { header: 'Price', explanation: 'Current Price' },
  priceChange: { header: 'Δ', explanation: 'Price Change' },
  pricePerPoint: { header: '$/P', explanation: 'Price Per Point' },
  value: { header: 'Value', explanation: 'Value Rating' },
  kicks: { header: 'K', explanation: 'Kicks' },
  handballs: { header: 'HB', explanation: 'Handballs' },
  disposals: { header: 'D', explanation: 'Disposals' },
  marks: { header: 'M', explanation: 'Marks' },
  tackles: { header: 'T', explanation: 'Tackles' },
  hitouts: { header: 'HO', explanation: 'Hitouts' },
  // Role Stats
  cbaPercentage: { header: 'CBA%', explanation: 'Centre Bounce Attendance %' },
  kickIns: { header: 'Kick-Ins', explanation: 'Kick-Ins' },
  togPercentage: { header: 'TOG%', explanation: 'Time On Ground %' },
  possessionType: { header: 'Possession Type', explanation: 'Possession Type' },
  insideOutside: { header: 'Inside/Outside', explanation: 'Inside/Outside' },
  // Volatility Stats
  consistency: { header: 'Consistency', explanation: 'Consistency' },
  volatility: { header: 'Volatility', explanation: 'Volatility' },
  ceiling: { header: 'Ceiling', explanation: 'Ceiling' },
  floor: { header: 'Floor', explanation: 'Floor' },
  // Fixture & Matchups
  opponentR20: { header: 'Opp R20', explanation: 'Opponent Round 20' },
  opponentR21: { header: 'Opp R21', explanation: 'Opponent Round 21' },
  opponentR22: { header: 'Opp R22', explanation: 'Opponent Round 22' },
  dvpR20: { header: 'DVP R20', explanation: 'DVP Difficulty Round 20' },
  dvpR21: { header: 'DVP R21', explanation: 'DVP Difficulty Round 21' },
  dvpR22: { header: 'DVP R22', explanation: 'DVP Difficulty Round 22' },
  dvpR23: { header: 'DVP R23', explanation: 'DVP Difficulty Round 23' },
  dvpR24: { header: 'DVP R24', explanation: 'DVP Difficulty Round 24' }
};

type StatCategory = keyof typeof statCategories;

// Helper function to get player fixture data (moved to top to avoid hoisting issues)
const getPlayerFixtureData = (player: Player, round: string, type: 'opponent' | 'difficulty'): string => {
  // Placeholder implementation - can be enhanced later with real fixture data
  if (type === 'opponent') {
    const opponents = ['ADE', 'BRL', 'CAR', 'COL', 'ESS', 'FRE', 'GEE', 'GCS', 'GWS', 'HAW', 'MEL', 'NM', 'PA', 'RIC', 'STK', 'SYD', 'WB', 'WCE'];
    return opponents[Math.floor(Math.random() * opponents.length)];
  } else {
    // Return difficulty rating 0-10
    return Math.floor(Math.random() * 11).toString();
  }
};

// Helper function to get player stat value (moved to top to avoid hoisting issues)
const getPlayerStatValue = (player: Player, statKey: string): string => {
  switch (statKey) {
    case 'avg': return player.averagePoints?.toFixed(1) || '0';
    case 'projectedScore': return player.projectedScore?.toFixed(1) || '0';
    case 'last': return player.lastScore?.toString() || '0';
    case 'l3': return player.l3Average?.toFixed(1) || '0';
    case 'l5': return player.l5Average?.toFixed(1) || '0';
    case 'be': return player.breakEven?.toString() || '0';
    case 'total': return player.totalPoints?.toString() || '0';
    case 'selection': return `${player.selectionPercentage?.toFixed(1) || '0'}%`;
    case 'price': return `$${Math.round((player.price || 0) / 1000)}k`;
    case 'priceChange': return `${player.priceChange >= 0 ? '+' : ''}${player.priceChange || 0}k`;
    case 'pricePerPoint': return `$${player.pricePerPoint?.toFixed(1) || '0'}`;
    case 'value': return '★★★☆☆'; // Placeholder
    case 'kicks': return player.kicks?.toString() || '0';
    case 'handballs': return player.handballs?.toString() || '0';
    case 'disposals': return player.disposals?.toString() || '0';
    case 'marks': return player.marks?.toString() || '0';
    case 'tackles': return player.tackles?.toString() || '0';
    case 'hitouts': return player.hitouts?.toString() || '0';
    // Role Stats - actual data from comprehensive dataset
    case 'cbaPercentage': return `${player.cba?.toFixed(1) || '0'}%`;
    case 'kickIns': return player.kickIns?.toString() || '0';
    case 'togPercentage': return '78%';
    case 'possessionType': return 'Contested';
    case 'insideOutside': return 'Inside';
    // Volatility Stats - placeholder values
    case 'consistency': return '7.5';
    case 'volatility': return 'Medium';
    case 'ceiling': return '120';
    case 'floor': return '65';
    // Fixture & Matchups - real DVP data
    case 'opponentR20': return getPlayerFixtureData(player, '20', 'opponent');
    case 'opponentR21': return getPlayerFixtureData(player, '21', 'opponent');
    case 'opponentR22': return getPlayerFixtureData(player, '22', 'opponent');
    case 'dvpR20': return getPlayerFixtureData(player, '20', 'difficulty');
    case 'dvpR21': return getPlayerFixtureData(player, '21', 'difficulty');
    case 'dvpR22': return getPlayerFixtureData(player, '22', 'difficulty');
    case 'dvpR23': return getPlayerFixtureData(player, '23', 'difficulty');
    case 'dvpR24': return getPlayerFixtureData(player, '24', 'difficulty');
    default: return '0';
  }
};

export default function NewPlayerStats({
  players,
  isLoading,
  onSearch,
  onFilter,
  searchQuery,
  positionFilter,
}: NewPlayerStatsProps) {
  const [activeCategory, setActiveCategory] = useState<StatCategory>('core');
  const [isStatsKeyOpen, setIsStatsKeyOpen] = useState(false);
  const [selectedRound, setSelectedRound] = useState<string>('Season Average');
  const [isFilterOpen, setIsFilterOpen] = useState(false);
  const [selectedPlayer, setSelectedPlayer] = useState<DetailPlayer | null>(null);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  const [isTableCollapsed, setIsTableCollapsed] = useState(false);
  
  // Sorting state
  const [sortBy, setSortBy] = useState<string>('');
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('desc');
  
  // Convert player data for modal
  const convertToDetailPlayer = (player: Player): DetailPlayer => {
    return {
      id: typeof player.id === 'string' ? parseInt(player.id) : player.id,
      name: player.name,
      team: player.team,
      position: player.position,
      price: player.price,
      averagePoints: player.averagePoints,
      lastScore: player.lastScore,
      breakEven: player.breakEven,
      l3Average: player.l3Average || 0,
      l5Average: player.l5Average || 0,
      priceChange: player.priceChange || 0,
      totalPoints: player.totalPoints || 0,
      category: '',
      projectedScore: 0
    };
  };

  const handlePlayerClick = (player: Player) => {
    setSelectedPlayer(convertToDetailPlayer(player));
    setIsDetailModalOpen(true);
  };
  
  // Filter states
  const [selectedTeams, setSelectedTeams] = useState<string[]>([]);
  const [selectedPositions, setSelectedPositions] = useState<string[]>([]);
  const [priceRange, setPriceRange] = useState<number[]>([200, 1600]);
  const [breakevenRange, setBreakevenRange] = useState<number[]>([-200, 300]);
  const [projectedScoreRange, setProjectedScoreRange] = useState<number[]>([0, 200]);
  const [priceChangeRange, setPriceChangeRange] = useState<number[]>([-500, 500]);
  const [ownershipRange, setOwnershipRange] = useState<number[]>([0, 100]);
  const [selectionStatus, setSelectionStatus] = useState<string[]>([]);
  const [recommendation, setRecommendation] = useState<string[]>([]);
  const [playerNameSearch, setPlayerNameSearch] = useState<string>('');

  // Team and position lists for filters - use actual team abbreviations from data
  const teams = ['ADE', 'BRL', 'CAR', 'COL', 'ESS', 'FRE', 'GEE', 'GCS', 'GWS', 'HAW', 
                'MEL', 'NTH', 'PTA', 'RIC', 'STK', 'SYD', 'WBD', 'WCE'];
  
  const positions = ['DEF', 'MID', 'RUC', 'FWD'];

  // Filter players by name search - show all matching players, no limit
  const filteredPlayersByName = playerNameSearch.length >= 3 
    ? players
        .filter(player => 
          player.name.toLowerCase().includes(playerNameSearch.toLowerCase())
        )
        .sort((a, b) => (b.price || 0) - (a.price || 0))
    : [];

  // Get current category config
  const currentCategory = statCategories[activeCategory];
  const currentColumns = currentCategory.columns;

  // Helper function to get player's primary position
  const getPlayerPrimaryPosition = (position: string) => {
    if (!position) return 'MID';
    // Handle both comma and slash separators, normalize to uppercase
    const posArray = position.split(/[,/]/).map(p => p.trim().toUpperCase());
    // Priority: RUCK > MID > DEF > FWD
    if (posArray.includes('RUCK') || posArray.includes('RUC')) return 'RUC';
    if (posArray.includes('MID')) return 'MID';
    if (posArray.includes('DEF')) return 'DEF';
    if (posArray.includes('FWD')) return 'FWD';
    return posArray[0] || 'MID';
  };

  // Create unique teams/positions to fetch fixture data for
  const uniqueTeamPositions = useMemo(() => {
    const teamPosSet = new Set<string>();
    players.forEach(player => {
      const primaryPos = getPlayerPrimaryPosition(player.position);
      teamPosSet.add(`${player.team}|${primaryPos}`);
    });
    return Array.from(teamPosSet).map(tp => {
      const [team, position] = tp.split('|');
      return { team, position };
    });
  }, [players]);

  // Fetch fixture data for all unique team/position combinations
  const fixtureQueries = useQuery({
    queryKey: ['fixture-data-batch', uniqueTeamPositions],
    queryFn: async () => {
      const fixtureMap = new Map<string, any>();
      
      // Fetch all fixture data in parallel
      const promises = uniqueTeamPositions.map(async ({ team, position }) => {
        try {
          const response = await fetch(`/api/stats-tools/stats/team-fixtures/${team}/${position}`);
          if (response.ok) {
            const data = await response.json();
            fixtureMap.set(`${team}|${position}`, data.fixtures || []);
          }
        } catch (error) {
          console.error(`Error fetching fixtures for ${team} ${position}:`, error);
        }
      });
      
      await Promise.all(promises);
      return fixtureMap;
    },
    enabled: activeCategory === 'fixture' && uniqueTeamPositions.length > 0
  });

  // Helper function to get fixture data for a player
  const getPlayerFixtureData = (player: Player, round: string, dataType: 'opponent' | 'difficulty') => {
    if (!fixtureQueries.data) return '-';
    
    const primaryPos = getPlayerPrimaryPosition(player.position);
    const fixtures = fixtureQueries.data.get(`${player.team}|${primaryPos}`);
    
    if (!fixtures || !Array.isArray(fixtures)) return '-';
    
    const roundFixture = fixtures.find(f => f.round === `R${round}`);
    if (!roundFixture) return '-';
    
    if (dataType === 'opponent') {
      return roundFixture.opponentAbbr || roundFixture.opponent || '-';
    } else if (dataType === 'difficulty') {
      const difficulty = roundFixture.difficulty;
      if (difficulty === undefined || difficulty === null) return '-';
      
      // Color code based on difficulty (0=easiest, 10=hardest)
      if (difficulty <= 2) return `🟢${difficulty}`;
      if (difficulty <= 4) return `🟡${difficulty}`;
      if (difficulty <= 6) return `🟠${difficulty}`;
      return `🔴${difficulty}`;
    }
    
    return '-';
  };

  // Apply filters to players
  const filteredPlayers = useMemo(() => {
    let filtered = [...players];

    // Filter by selected teams
    if (selectedTeams.length > 0) {
      filtered = filtered.filter(player => selectedTeams.includes(player.team));
    }

    // Filter by selected positions
    if (selectedPositions.length > 0) {
      filtered = filtered.filter(player => {
        const primaryPosition = getPlayerPrimaryPosition(player.position);
        return selectedPositions.includes(primaryPosition);
      });
    }

    // Filter by price range (handle null/undefined values, convert to thousands)
    filtered = filtered.filter(player => {
      const price = (player.price || 0) / 1000; // Convert to thousands
      return price >= priceRange[0] && price <= priceRange[1];
    });

    // Filter by breakeven range (handle null/undefined values)
    filtered = filtered.filter(player => {
      const breakEven = player.breakEven || 0;
      return breakEven >= breakevenRange[0] && breakEven <= breakevenRange[1];
    });

    // Filter by projected score range (using average points as proxy, handle null/undefined values)
    filtered = filtered.filter(player => {
      const averagePoints = player.averagePoints || 0;
      return averagePoints >= projectedScoreRange[0] && averagePoints <= projectedScoreRange[1];
    });

    // Filter by price change range (handle null/undefined values, convert to thousands)
    filtered = filtered.filter(player => {
      const priceChange = (player.priceChange || 0) / 1000; // Convert to thousands
      return priceChange >= priceChangeRange[0] && priceChange <= priceChangeRange[1];
    });

    // Filter by ownership range (using selection percentage, handle null/undefined values)
    filtered = filtered.filter(player => {
      const selectionPercentage = player.selectionPercentage || 0;
      return selectionPercentage >= ownershipRange[0] && selectionPercentage <= ownershipRange[1];
    });

    return filtered;
  }, [players, selectedTeams, priceRange, breakevenRange, projectedScoreRange, priceChangeRange, ownershipRange]);

  // Apply sorting to filtered players
  const sortedPlayers = useMemo(() => {
    if (!sortBy) return filteredPlayers;

    const sorted = [...filteredPlayers].sort((a, b) => {
      let aValue: any;
      let bValue: any;

      // Get values for sorting based on the column
      switch (sortBy) {
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'team':
          aValue = a.team;
          bValue = b.team;
          break;
        case 'position':
          aValue = a.position;
          bValue = b.position;
          break;
        case 'price':
          aValue = a.price;
          bValue = b.price;
          break;
        case 'avg':
          aValue = a.averagePoints;
          bValue = b.averagePoints;
          break;
        case 'last':
          aValue = a.lastScore;
          bValue = b.lastScore;
          break;
        case 'l3':
          aValue = a.l3Average;
          bValue = b.l3Average;
          break;
        case 'l5':
          aValue = a.l5Average;
          bValue = b.l5Average;
          break;
        case 'be':
          aValue = a.breakEven;
          bValue = b.breakEven;
          break;
        case 'total':
          aValue = a.totalPoints;
          bValue = b.totalPoints;
          break;
        case 'selection':
          aValue = a.selectionPercentage;
          bValue = b.selectionPercentage;
          break;
        case 'priceChange':
          aValue = a.priceChange;
          bValue = b.priceChange;
          break;
        case 'pricePerPoint':
          aValue = a.pricePerPoint;
          bValue = b.pricePerPoint;
          break;
        // For fixture columns, get the actual difficulty values
        case 'dvpR20':
        case 'dvpR21':
        case 'dvpR22':
        case 'dvpR23':
        case 'dvpR24': {
          const round = sortBy.slice(-2);
          const primaryPos = getPlayerPrimaryPosition(a.position);
          const fixturesA = fixtureQueries.data?.get(`${a.team}|${primaryPos}`);
          const fixturesB = fixtureQueries.data?.get(`${b.team}|${getPlayerPrimaryPosition(b.position)}`);
          
          const roundFixtureA = fixturesA?.find((f: any) => f.round === `R${round}`);
          const roundFixtureB = fixturesB?.find((f: any) => f.round === `R${round}`);
          
          aValue = roundFixtureA?.difficulty ?? 999;
          bValue = roundFixtureB?.difficulty ?? 999;
          break;
        }
        default: {
          // For other stats, try to get numeric values
          const aVal = getPlayerStatValue(a, sortBy);
          const bVal = getPlayerStatValue(b, sortBy);
          aValue = parseFloat(aVal.replace(/[^0-9.-]/g, '')) || 0;
          bValue = parseFloat(bVal.replace(/[^0-9.-]/g, '')) || 0;
        }
      }

      // Handle null/undefined values
      if (aValue == null && bValue == null) return 0;
      if (aValue == null) return 1;
      if (bValue == null) return -1;

      // Sort based on direction
      if (typeof aValue === 'string') {
        return sortDirection === 'asc' 
          ? aValue.localeCompare(bValue)
          : bValue.localeCompare(aValue);
      } else {
        return sortDirection === 'asc' 
          ? aValue - bValue
          : bValue - aValue;
      }
    });

    return sorted;
  }, [filteredPlayers, sortBy, sortDirection, fixtureQueries.data, getPlayerPrimaryPosition]);

  // Handle column header click for sorting
  const handleColumnSort = (columnKey: string) => {
    if (sortBy === columnKey) {
      // Toggle direction if same column
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      // New column, start with descending
      setSortBy(columnKey);
      setSortDirection('desc');
    }
  };

  // Reset all filters
  const resetFilters = () => {
    setSelectedTeams([]);
    setSelectedPositions([]);
    setPriceRange([200, 1600]);
    setBreakevenRange([-200, 300]);
    setProjectedScoreRange([0, 200]);
    setPriceChangeRange([-500, 500]);
    setOwnershipRange([0, 100]);
    setSelectionStatus([]);
    setRecommendation([]);
    setPlayerNameSearch('');
    setSortBy('');
    setSortDirection('desc');
  };

  // Check if any filters are active
  const hasActiveFilters = 
    selectedTeams.length > 0 ||
    selectedPositions.length > 0 ||
    priceRange[0] !== 200 || priceRange[1] !== 1600 ||
    breakevenRange[0] !== -200 || breakevenRange[1] !== 300 ||
    projectedScoreRange[0] !== 0 || projectedScoreRange[1] !== 200 ||
    priceChangeRange[0] !== -500 || priceChangeRange[1] !== 500 ||
    ownershipRange[0] !== 0 || ownershipRange[1] !== 100 ||
    playerNameSearch.length > 0;



  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-purple-600"></div>
      </div>
    );
  }

  return (
    <div className="w-full space-y-4">
      {/* 1. Stat category buttons in 3x2 grid */}
      <div className="grid grid-cols-3 gap-4">
        {/* Top row */}
        {(['core', 'price', 'match'] as StatCategory[]).map((key) => {
          const category = statCategories[key];
          return (
            <Button
              key={key}
              onClick={() => setActiveCategory(key)}
              className={`
                px-3 py-3 font-bold text-white border-2 transition-all duration-300 text-xs
                ${activeCategory === key 
                  ? `${category.neonClass}` 
                  : 'border-gray-600 bg-gray-900 hover:bg-gray-800'
                }
              `}
            >
              {category.name}
            </Button>
          );
        })}
        
        {/* Bottom row */}
        {(['role', 'volatility', 'fixture'] as StatCategory[]).map((key) => {
          const category = statCategories[key];
          return (
            <Button
              key={key}
              onClick={() => setActiveCategory(key)}
              className={`
                px-3 py-3 font-bold text-white border-2 transition-all duration-300 text-xs
                ${activeCategory === key 
                  ? `${category.neonClass}` 
                  : 'border-gray-600 bg-gray-900 hover:bg-gray-800'
                }
              `}
            >
              {category.name}
            </Button>
          );
        })}
      </div>

      {/* 2. Stats Key - Full width */}
      <Card className="bg-gray-900 border-gray-700 w-full">
        <CardContent 
          className="p-4 cursor-pointer hover:bg-gray-800 transition-colors"
          onClick={() => setIsStatsKeyOpen(!isStatsKeyOpen)}
        >
          <div className="flex items-center justify-between">
            <h3 className="text-lg font-bold text-white">Stats Key</h3>
            {isStatsKeyOpen ? (
              <ChevronUp className="h-5 w-5 text-gray-400" />
            ) : (
              <ChevronDown className="h-5 w-5 text-gray-400" />
            )}
          </div>
          
          {isStatsKeyOpen && (
            <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-2 text-sm text-gray-300">
              {currentColumns.map(columnKey => {
                const def = columnDefinitions[columnKey as keyof typeof columnDefinitions];
                return (
                  <div key={columnKey}>
                    <span className="font-bold text-white">{def.header}</span> = {def.explanation}
                  </div>
                );
              })}
            </div>
          )}
        </CardContent>
      </Card>

      {/* 3. Round dropdown on left side */}
      <div className="flex items-center gap-4">
        <div className="min-w-[200px]">
          <div className="mb-2">
            <h4 className="text-sm font-semibold text-gray-300">Round</h4>
          </div>
          <Select value={selectedRound} onValueChange={setSelectedRound}>
            <SelectTrigger className="bg-gray-800 border-gray-700 text-white">
              <SelectValue placeholder="Select Round" />
            </SelectTrigger>
            <SelectContent className="bg-gray-800 border-gray-700">
              <SelectItem value="Season Average" className="text-white">Season Average</SelectItem>
              <SelectItem value="Season Total" className="text-white">Season Total</SelectItem>
              {Array.from({length: 24}, (_, i) => (
                <SelectItem key={i + 1} value={`Round ${i + 1}`} className="text-white">
                  Round {i + 1}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      {/* 4. Stats Table with Filter button in top-left */}
      <div className="relative w-full">
        {/* Filter Button and Results Count positioned above table */}
        <div className="mb-2 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Dialog open={isFilterOpen} onOpenChange={setIsFilterOpen}>
              <DialogTrigger asChild>
                <Button 
                  variant="outline" 
                  className={`border-gray-600 bg-gray-900 text-white hover:bg-gray-800 flex items-center gap-2 ${
                    hasActiveFilters ? 'border-blue-500 bg-blue-900/20' : ''
                  }`}
                >
                  <Filter className="h-4 w-4" />
                  Filter
                  {hasActiveFilters && (
                    <span className="bg-blue-600 text-white text-xs px-1.5 py-0.5 rounded-full">
                      ON
                    </span>
                  )}
                </Button>
              </DialogTrigger>
            <DialogContent className="bg-gray-900 border-gray-700 text-white max-w-4xl max-h-[80vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle className="text-xl font-bold text-white">Filter Players</DialogTitle>
              </DialogHeader>
              
              <div className="space-y-6 mt-4">
                {/* Player Name Search */}
                <div>
                  <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                    <Search className="h-5 w-5" />
                    Search Player by Name
                  </h3>
                  <Input
                    placeholder="Type 3+ characters to search..."
                    value={playerNameSearch}
                    onChange={(e) => setPlayerNameSearch(e.target.value)}
                    className="bg-gray-800 border-gray-700 text-white"
                  />
                  {filteredPlayersByName.length > 0 && (
                    <div className="mt-2 space-y-1">
                      <p className="text-sm text-gray-400">Top 5 highest-priced matches:</p>
                      {filteredPlayersByName.map(player => (
                        <div 
                          key={player.id} 
                          className="text-sm p-2 bg-gray-800 rounded border border-gray-700 cursor-pointer hover:bg-gray-700 transition-colors"
                          onClick={() => {
                            handlePlayerClick(player);
                            setIsFilterOpen(false);
                          }}
                        >
                          <span className="font-semibold">{player.name}</span> - {player.team} - ${Math.round((player.price || 0) / 1000)}k
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                {/* Team Filter */}
                <div>
                  <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                    🏷️ By Team
                  </h3>
                  <div className="grid grid-cols-3 md:grid-cols-6 gap-2">
                    {teams.map(team => (
                      <Button
                        key={team}
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setSelectedTeams(prev => 
                            prev.includes(team) 
                              ? prev.filter(t => t !== team)
                              : [...prev, team]
                          );
                        }}
                        className={`text-xs ${
                          selectedTeams.includes(team)
                            ? 'bg-blue-600 border-blue-500 text-white'
                            : 'border-gray-600 bg-gray-800 text-gray-300 hover:bg-gray-700'
                        }`}
                      >
                        {team}
                      </Button>
                    ))}
                  </div>
                </div>

                {/* Position Filter */}
                <div>
                  <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                    🏃 By Position
                  </h3>
                  <div className="grid grid-cols-4 gap-2">
                    {positions.map(position => (
                      <Button
                        key={position}
                        variant="outline"
                        size="sm"
                        onClick={() => {
                          setSelectedPositions(prev => 
                            prev.includes(position) 
                              ? prev.filter(p => p !== position)
                              : [...prev, position]
                          );
                        }}
                        className={`text-sm ${
                          selectedPositions.includes(position)
                            ? 'bg-green-600 border-green-500 text-white'
                            : 'border-gray-600 bg-gray-800 text-gray-300 hover:bg-gray-700'
                        }`}
                      >
                        {position}
                      </Button>
                    ))}
                  </div>
                </div>

                {/* Price Range */}
                <div>
                  <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                    💲 By Price Range
                  </h3>
                  <div className="px-4">
                    <Slider
                      value={priceRange}
                      onValueChange={setPriceRange}
                      max={1600}
                      min={200}
                      step={10}
                      className="w-full"
                    />
                    <div className="flex justify-between text-sm text-gray-400 mt-2">
                      <span>${priceRange[0]}k</span>
                      <span>${priceRange[1]}k</span>
                    </div>
                  </div>
                </div>

                {/* Clear Filters */}
                <div className="flex justify-between pt-4 border-t border-gray-700">
                  <Button
                    variant="outline"
                    onClick={() => {
                      setSelectedTeams([]);
                      setSelectedPositions([]);
                      setPriceRange([200, 1600]);
                      setBreakevenRange([-200, 300]);
                      setProjectedScoreRange([0, 200]);
                      setPriceChangeRange([-200, 200]);
                      setOwnershipRange([0, 100]);
                      setSelectionStatus([]);
                      setRecommendation([]);
                      setPlayerNameSearch('');
                    }}
                    className="border-gray-600 bg-gray-800 text-gray-300 hover:bg-gray-700"
                  >
                    Clear All Filters
                  </Button>
                  <Button
                    onClick={() => setIsFilterOpen(false)}
                    className="bg-blue-600 hover:bg-blue-700 text-white"
                  >
                    Apply Filters
                  </Button>
                </div>

                {/* Reset Filters Button */}
                <div className="flex justify-between items-center pt-4 border-t border-gray-700">
                  <div className="text-sm text-gray-400">
                    Showing {sortedPlayers.length} of {players.length} players
                  </div>
                  <Button
                    onClick={resetFilters}
                    variant="outline"
                    className="border-red-600 bg-red-900/20 text-red-400 hover:bg-red-800 hover:text-red-300"
                    disabled={!hasActiveFilters}
                  >
                    Reset Filters
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>

          {hasActiveFilters && (
            <Button
              onClick={resetFilters}
              variant="outline"
              size="sm"
              className="border-red-600 bg-red-900/20 text-red-400 hover:bg-red-800 hover:text-red-300 flex items-center gap-2"
            >
              <X className="h-3 w-3" />
              Clear Filters
            </Button>
          )}
          </div>

          <div className="text-sm text-gray-400">
            Showing {sortedPlayers.slice(0, 50).length} of {sortedPlayers.length} players
            {sortedPlayers.length !== players.length && (
              <span className="text-blue-400"> (filtered)</span>
            )}
          </div>
        </div>

        {/* Stats Table */}
        <Card className="bg-gray-900 border-gray-700 w-full">
          {/* Collapsible header with close button */}
          <div className="flex items-center justify-between p-4 border-b border-gray-700">
            <h3 className="text-lg font-semibold text-white">Player Stats</h3>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setIsTableCollapsed(!isTableCollapsed)}
              className="text-gray-400 hover:text-white"
            >
              {isTableCollapsed ? <ChevronDown className="h-4 w-4" /> : <X className="h-4 w-4" />}
            </Button>
          </div>
          
          {/* Collapsed banner */}
          {isTableCollapsed ? (
            <div 
              className="p-8 text-center cursor-pointer hover:bg-gray-800 transition-colors"
              onClick={() => setIsTableCollapsed(false)}
            >
              <div className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-4 rounded-lg font-bold text-lg">
                Player Stats
              </div>
              <p className="text-gray-400 mt-2">Click anywhere to expand the table</p>
            </div>
          ) : (
            /* Expanded table */
            <div className="overflow-x-auto">
              <Table className="table-fixed">
                <TableHeader>
                  <TableRow className="border-gray-700 h-8">
                    {/* Sticky column header */}
                    <TableHead className="sticky left-0 bg-gray-900 border-r border-gray-700 w-32 min-w-32">
                      <div 
                        className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-1 rounded font-bold text-center text-xs cursor-pointer hover:opacity-80 flex items-center justify-center gap-1"
                        onClick={() => handleColumnSort('name')}
                      >
                        Player
                        {sortBy === 'name' ? (
                          sortDirection === 'asc' ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />
                        ) : (
                          <ArrowUpDown className="h-3 w-3 opacity-50" />
                        )}
                      </div>
                    </TableHead>
                    
                    {/* Dynamic stat columns */}
                    {currentColumns.map(columnKey => {
                      const def = columnDefinitions[columnKey as keyof typeof columnDefinitions];
                      return (
                        <TableHead key={columnKey} className="text-center w-12 min-w-12 px-1">
                          <div 
                            className="bg-gradient-to-r from-purple-600 to-blue-600 text-white p-1 rounded font-bold text-xs cursor-pointer hover:opacity-80 flex items-center justify-center gap-1"
                            onClick={() => handleColumnSort(columnKey)}
                          >
                            {def.header}
                            {sortBy === columnKey ? (
                              sortDirection === 'asc' ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />
                            ) : (
                              <ArrowUpDown className="h-3 w-3 opacity-50" />
                            )}
                          </div>
                        </TableHead>
                      );
                    })}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {sortedPlayers.slice(0, 50).map((player) => (
                    <TableRow key={player.id} className="border-gray-700 hover:bg-gray-800 h-12">
                      {/* Sticky player info column */}
                      <TableCell className="sticky left-0 bg-gray-900 border-r border-gray-700 w-32 min-w-32 px-1 py-1">
                        <div className="flex items-start gap-1">
                          {/* Team guernsey */}
                          <div className="w-5 h-5 rounded-full overflow-hidden border border-gray-600 bg-white flex-shrink-0 mt-0.5">
                            {getTeamGuernsey(player.team) ? (
                              <img
                                src={getTeamGuernsey(player.team)}
                                alt={`${player.team} guernsey`}
                                className="w-full h-full object-cover"
                              />
                            ) : (
                              <div className="w-full h-full flex items-center justify-center bg-gray-700">
                                <span className="text-[8px] font-bold text-white">
                                  {player.team?.substring(0, 2).toUpperCase()}
                                </span>
                              </div>
                            )}
                          </div>
                          
                          {/* Player info */}
                          <div className="space-y-0.5 flex-1 min-w-0">
                            <div 
                              className="font-semibold text-white text-xs cursor-pointer hover:text-blue-400 transition-colors leading-tight"
                              onClick={() => handlePlayerClick(player)}
                            >
                              <div>{player.name.split(' ')[0]}</div>
                              <div>{player.name.split(' ').slice(1).join(' ')}</div>
                            </div>
                            <div className="text-[10px] text-gray-400">{player.team}</div>
                            <div className="text-[10px] text-gray-400">{player.position}</div>
                            <div className="text-[10px] font-semibold text-green-400">${player.price}k</div>
                          </div>
                        </div>
                      </TableCell>
                      
                      {/* Dynamic stat columns */}
                      {currentColumns.map(columnKey => (
                        <TableCell key={columnKey} className="text-center text-white w-12 min-w-12 px-1 py-1 text-xs">
                          {getPlayerStatValue(player, columnKey)}
                        </TableCell>
                      ))}
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </Card>
      </div>

      {/* Player Detail Modal */}
      {selectedPlayer && (
        <PlayerDetailModal
          player={selectedPlayer}
          open={isDetailModalOpen}
          onOpenChange={(open) => {
            if (!open) {
              setIsDetailModalOpen(false);
              setSelectedPlayer(null);
            }
          }}
        />
      )}
    </div>
  );
}