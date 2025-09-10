import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { ChevronDown, ChevronUp } from "lucide-react";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";
// Define custom Player type for this component
export type Player = {
  id: string | number;
  name: string;
  team: string;
  position: string;
  price: number;
  averagePoints: number;
  lastScore?: number;
  l3Average?: number;
  l5Average?: number;
  breakEven: number;
  priceChange?: number;
  pricePerPoint?: number;
  totalPoints?: number;
  selectionPercentage?: number;
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

type PlayerStatsRedesignProps = {
  players: Player[];
  isLoading: boolean;
  onSearch: (query: string) => void;
  onFilter: (position: string) => void;
  searchQuery: string;
  positionFilter: string;
};

// Define stat categories
const statCategories = {
  'core': {
    name: 'Core Fantasy Stats',
    borderColor: 'border-purple-500',
    columns: ['avg', 'last', 'l3', 'l5', 'be', 'total', 'selection']
  },
  'price': {
    name: 'Price & Movement',
    borderColor: 'border-blue-500', 
    columns: ['price', 'priceChange', 'pricePerPoint', 'value']
  },
  'match': {
    name: 'Match Stats',
    borderColor: 'border-red-500',
    columns: ['kicks', 'handballs', 'disposals', 'marks', 'tackles', 'hitouts']
  }
};

// Define column headers and explanations
const columnDefinitions = {
  avg: { header: 'Avg', explanation: 'Season Average Points' },
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
  hitouts: { header: 'HO', explanation: 'Hitouts' }
};

export default function PlayerStatsRedesign({
  players,
  isLoading,
  onSearch,
  onFilter,
  searchQuery,
  positionFilter,
}: PlayerStatsRedesignProps) {
  const [statCategory, setStatCategory] = useState<"fantasy" | "basic" | "vs" | "value" | "consistency" | "dvp">("fantasy");
  const [keyExpanded, setKeyExpanded] = useState(true);
  const [selectedPlayer, setSelectedPlayer] = useState<Player | null>(null);
  
  // Function to toggle key visibility
  const toggleKey = () => {
    setKeyExpanded(!keyExpanded);
  };

  // Function to render team logo/icon
  const renderTeamLogo = (team: string) => {
    return (
      <div className="h-6 w-6 rounded-full bg-amber-500 flex items-center justify-center text-white text-xs font-bold shadow-[0_0_6px_rgba(245,158,11,0.5)]">
        {team.substring(0, 2).toUpperCase()}
      </div>
    );
  };

  // Generate sample consistency data
  const generateConsistencyData = (player: Player) => {
    // This would normally come from real data but for now we'll generate it
    // based on the player's average score
    const base = player.averagePoints;
    const variance = base * 0.3; // 30% variance
    
    return [
      { round: "R1", score: Math.max(0, base + (Math.random() - 0.5) * variance) },
      { round: "R2", score: Math.max(0, base + (Math.random() - 0.5) * variance) },
      { round: "R3", score: Math.max(0, base + (Math.random() - 0.5) * variance) },
      { round: "R4", score: Math.max(0, base + (Math.random() - 0.5) * variance) },
      { round: "R5", score: Math.max(0, base + (Math.random() - 0.5) * variance) },
    ];
  };

  // Generate sample DVP (Difficulty vs Position) data
  const generateDVPData = (player: Player) => {
    // This would normally come from real data but for now we'll generate it
    const position = player.position;
    const difficultyLevels = [
      { round: "R8", difficulty: Math.random() * 100 },
      { round: "R9", difficulty: Math.random() * 100 },
      { round: "R10", difficulty: Math.random() * 100 },
      { round: "R11", difficulty: Math.random() * 100 },
      { round: "R12", difficulty: Math.random() * 100 },
    ];
    
    return difficultyLevels;
  };

  // Format the value based on the stat type
  const formatValue = (value: number | string | undefined, type: string): string => {
    if (value === undefined) return '-';
    
    if (typeof value === 'number') {
      switch (type) {
        case 'price':
          return `$${(value / 1000).toFixed(0)}k`;
        case 'percentage':
          return `${value.toFixed(1)}%`;
        case 'decimal':
          return value.toFixed(1);
        default:
          return value.toString();
      }
    }
    
    return value.toString();
  };

  // Function to determine cell color based on value (for DVP display)
  const getCellColor = (value: number | undefined, type: string): string => {
    if (value === undefined) return '';
    
    // Only apply color to specific stats like breakeven, price change
    if (type === 'be') {
      if (value < 0) return 'bg-green-500 text-white';
      if (value > 80) return 'bg-red-500 text-white';
      if (value > 40) return 'bg-orange-500 text-white';
      return 'bg-green-300 text-white';
    }
    
    if (type === 'priceChange') {
      if (value > 20000) return 'bg-green-500 text-white';
      if (value > 0) return 'bg-green-300 text-white';
      if (value < -20000) return 'bg-red-500 text-white';
      if (value < 0) return 'bg-red-300 text-white';
      return '';
    }
    
    return '';
  };

  // Custom tooltip for charts
  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      return (
        <div className="bg-gray-800 text-white p-2 rounded-md shadow-lg text-xs border border-gray-700">
          <p className="font-bold text-amber-300">{label}</p>
          <p>{`Score: ${payload[0].value.toFixed(1)}`}</p>
        </div>
      );
    }
    return null;
  };

  // DVP Custom Tooltip
  const DVPTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      const value = payload[0].value;
      let difficultyText = "Medium";
      let color = "text-yellow-400";
      
      if (value < 33) {
        difficultyText = "Easy";
        color = "text-green-400";
      } else if (value > 66) {
        difficultyText = "Hard";
        color = "text-red-400";
      }
      
      return (
        <div className="bg-gray-800 text-white p-2 rounded-md shadow-lg text-xs border border-gray-700">
          <p className="font-bold text-amber-300">{label}</p>
          <p className={color}>{`Difficulty: ${difficultyText}`}</p>
        </div>
      );
    }
    return null;
  };

  // Get gradient SVG definition for charts
  const getGradientDef = (id: string, startColor: string, endColor: string) => {
    return (
      <defs>
        <linearGradient id={id} x1="0" y1="0" x2="1" y2="0">
          <stop offset="0%" stopColor={startColor} />
          <stop offset="100%" stopColor={endColor} />
        </linearGradient>
      </defs>
    );
  };

  // Get player trend graph card
  const getPlayerTrendCard = (player: Player, title: string, chartId: string, data: any[], startColor: string, endColor: string) => {
    return (
      <Card className="mb-4 bg-gray-800 text-white overflow-hidden border-gray-700">
        <div className="p-3 border-b border-gray-700 flex items-center space-x-2">
          {renderTeamLogo(player.team)}
          <h3 className="text-lg font-bold text-amber-300">{title}</h3>
        </div>
        <CardContent className="p-4">
          <div className="h-36">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart
                data={data}
                margin={{ top: 5, right: 20, left: 0, bottom: 5 }}
              >
                {getGradientDef(chartId, startColor, endColor)}
                <XAxis 
                  dataKey="round" 
                  tick={{ fill: '#d1d5db', fontSize: 12 }}
                  axisLine={{ stroke: '#4b5563' }} 
                />
                <YAxis 
                  hide 
                />
                <Tooltip content={<CustomTooltip />} />
                <Line 
                  type="monotone" 
                  dataKey="score" 
                  stroke={`url(#${chartId})`} 
                  strokeWidth={2} 
                  dot={{ fill: "#1f2937", stroke: startColor, strokeWidth: 2, r: 4 }}
                  activeDot={{ r: 6, fill: endColor }}
                />
                {/* Add enhanced shadow effect */}
                <defs>
                  <filter id={`shadow-${chartId}`} height="200%">
                    <feDropShadow dx="0" dy="4" stdDeviation="6" floodColor={startColor} floodOpacity="0.6" />
                  </filter>
                </defs>
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    );
  };

  // Get DVP graph card
  const getDVPCard = (player: Player) => {
    const data = generateDVPData(player);
    const chartId = `dvp-${player.id}-${Math.random().toString(36)}`;
    
    return (
      <Card className="mb-4 bg-gray-800 text-white overflow-hidden border-gray-700">
        <div className="p-3 border-b border-gray-700 flex items-center space-x-2">
          {renderTeamLogo(player.team)}
          <h3 className="text-lg font-bold text-amber-300">Team vs {player.position} Difficulty</h3>
        </div>
        <CardContent className="p-4">
          <div className="h-36">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart
                data={data}
                margin={{ top: 5, right: 20, left: 0, bottom: 5 }}
              >
                {getGradientDef(chartId, "#ef4444", "#10b981")}
                <XAxis 
                  dataKey="round" 
                  tick={{ fill: '#d1d5db', fontSize: 12 }}
                  axisLine={{ stroke: '#4b5563' }} 
                />
                <YAxis hide />
                <Tooltip content={<DVPTooltip />} />
                <Line 
                  type="monotone" 
                  dataKey="difficulty" 
                  stroke={`url(#${chartId})`} 
                  strokeWidth={2} 
                  dot={{ fill: "#1f2937", stroke: "#10b981", strokeWidth: 2, r: 4 }}
                  activeDot={{ r: 6, fill: "#10b981" }}
                />
                <defs>
                  <filter id={`shadow-${chartId}`} height="200%">
                    <feDropShadow dx="0" dy="4" stdDeviation="6" floodColor="#10b981" floodOpacity="0.6" />
                  </filter>
                </defs>
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    );
  };

  // Bar chart for player role & distribution
  const getPlayerRoleCard = (player: Player) => {
    // Sample data for role distribution
    const roleData = [
      { category: "Midfield", value: player.position === "MID" ? 80 : Math.random() * 40 },
      { category: "Defense", value: player.position === "DEF" ? 80 : Math.random() * 40 },
      { category: "Forward", value: player.position === "FWD" ? 80 : Math.random() * 40 },
    ];
    
    return (
      <Card className="mb-4 bg-gray-800 text-white overflow-hidden border-gray-700">
        <div className="p-3 border-b border-gray-700 flex items-center space-x-2">
          {renderTeamLogo(player.team)}
          <h3 className="text-lg font-bold text-amber-300">Role Distribution</h3>
        </div>
        <CardContent className="p-4">
          <div className="space-y-2">
            {roleData.map(item => (
              <div key={item.category} className="space-y-1">
                <div className="flex justify-between text-sm">
                  <span>{item.category}</span>
                  <span>{item.value.toFixed(0)}%</span>
                </div>
                <div className="w-full bg-gray-700 rounded-full h-2.5">
                  <div 
                    className="h-2.5 rounded-full shadow-lg" 
                    style={{ 
                      width: `${item.value}%`,
                      backgroundColor: 
                        item.category === "Midfield" ? "#10b981" : 
                        item.category === "Defense" ? "#3b82f6" :
                        "#f59e0b",
                      boxShadow: item.category === "Midfield" 
                        ? "0 0 8px 1px rgba(16, 185, 129, 0.6)" 
                        : item.category === "Defense"
                          ? "0 0 8px 1px rgba(59, 130, 246, 0.6)"
                          : "0 0 8px 1px rgba(245, 158, 11, 0.6)"
                    }}
                  />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  };

  return (
    <div className="w-full">
      {/* Search and filter controls */}
      <div className="flex flex-col md:flex-row gap-2 mb-4">
        <div className="relative flex-grow mb-2 md:mb-0">
          <Search className="absolute left-2 top-2.5 h-4 w-4 text-amber-300" />
          <Input
            placeholder="Search player..."
            value={searchQuery}
            onChange={(e) => onSearch(e.target.value)}
            className="pl-8 bg-gray-800 border-gray-700 text-white placeholder:text-gray-400 focus-visible:ring-amber-500"
          />
        </div>
        <Select value={positionFilter} onValueChange={onFilter}>
          <SelectTrigger className="w-full md:w-[180px] bg-gray-800 border-gray-700 text-white">
            <SelectValue placeholder="Position filter" />
          </SelectTrigger>
          <SelectContent className="bg-gray-800 text-white border-gray-700">
            <SelectItem value="all" className="focus:bg-gray-700 focus:text-white">All Positions</SelectItem>
            <SelectItem value="DEF" className="focus:bg-gray-700 focus:text-white">Defenders</SelectItem>
            <SelectItem value="MID" className="focus:bg-gray-700 focus:text-white">Midfielders</SelectItem>
            <SelectItem value="RUC" className="focus:bg-gray-700 focus:text-white">Rucks</SelectItem>
            <SelectItem value="FWD" className="focus:bg-gray-700 focus:text-white">Forwards</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Stats key/legend - collapsible */}
      <Card className="mb-4 bg-gray-800 text-white border-gray-700">
        <div className="p-3 flex justify-between items-center cursor-pointer" onClick={toggleKey}>
          <h3 className="font-semibold text-amber-300">Stats Key</h3>
          <div className="text-amber-300">{keyExpanded ? <ChevronUp size={16} /> : <ChevronDown size={16} />}</div>
        </div>
        
        {keyExpanded && (
          <CardContent className="pt-2 pb-4 px-4">
            <div className="space-y-2 text-sm">
              {statCategory === "fantasy" && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-1">
                  <div>Avg = Average</div>
                  <div>Last = Last Round</div>
                  <div>L3 = Last 3 Avg</div>
                  <div>L5 = Last 5 Avg</div>
                  <div>BE = Break Even</div>
                  <div>Δ = Price Change</div>
                  <div>$/P = $ Per Point</div>
                  <div>Tot = Total Points</div>
                  <div>% = Selection %</div>
                </div>
              )}
              {statCategory === "basic" && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-1">
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
              {statCategory === "value" && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-1">
                  <div>PP$ = Points per $1,000</div>
                  <div>Value = Value Rating</div>
                  <div>Proj = Projected Points</div>
                  <div>Proj$ = Projected Value</div>
                </div>
              )}
              {statCategory === "consistency" && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-1">
                  <div>Dev = Standard Deviation</div>
                  <div>CV = Coefficient of Variation</div>
                  <div>Cons = Consistency Rating</div>
                  <div>Ceil = Ceiling Score</div>
                  <div>Floor = Floor Score</div>
                </div>
              )}
              {statCategory === "dvp" && (
                <div className="grid grid-cols-2 md:grid-cols-4 gap-x-6 gap-y-1">
                  <div>DVP = Defense vs Position</div>
                  <div>Diff = Difficulty Rating</div>
                  <div>Pos = Position DVP Rank</div>
                  <div>Team = Team DVP Rank</div>
                </div>
              )}
            </div>
          </CardContent>
        )}
      </Card>
      
      {/* Stat category tabs */}
      <Tabs 
        value={statCategory} 
        onValueChange={(value) => setStatCategory(value as any)}
        className="w-full mb-4"
      >
        <TabsList className="flex flex-wrap h-auto py-1 px-1 gap-1 bg-gray-800 border-gray-700">
          <TabsTrigger 
            value="fantasy" 
            className="text-xs md:text-sm py-1 px-2 h-auto data-[state=active]:bg-amber-500 data-[state=active]:text-white"
          >
            Fantasy
          </TabsTrigger>
          <TabsTrigger 
            value="basic" 
            className="text-xs md:text-sm py-1 px-2 h-auto data-[state=active]:bg-amber-500 data-[state=active]:text-white"
          >
            Basic
          </TabsTrigger>
          <TabsTrigger 
            value="vs" 
            className="text-xs md:text-sm py-1 px-2 h-auto data-[state=active]:bg-amber-500 data-[state=active]:text-white"
          >
            VS
          </TabsTrigger>
          <TabsTrigger 
            value="value" 
            className="text-xs md:text-sm py-1 px-2 h-auto data-[state=active]:bg-amber-500 data-[state=active]:text-white"
          >
            Value
          </TabsTrigger>
          <TabsTrigger 
            value="consistency" 
            className="text-xs md:text-sm py-1 px-2 h-auto data-[state=active]:bg-amber-500 data-[state=active]:text-white"
          >
            Consistency
          </TabsTrigger>
          <TabsTrigger 
            value="dvp" 
            className="text-xs md:text-sm py-1 px-2 h-auto data-[state=active]:bg-amber-500 data-[state=active]:text-white"
          >
            DVP
          </TabsTrigger>
        </TabsList>
      </Tabs>

      {/* Player stats table */}
      <Card className="mb-6 overflow-hidden bg-gray-900 border-gray-700">
        <ScrollArea className="h-[500px]">
          <Table>
            <TableHeader className="sticky top-0 z-10">
              {statCategory === "fantasy" && (
                <TableRow className="border-b-gray-700">
                  <TableHead className="sticky left-0 z-20 bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-48 min-w-[12rem]">
                    Player / Team
                  </TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Role</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Avg</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Last</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">L3</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">L5</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">BE</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-16 min-w-[4rem]">Price</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">Δ</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">$/P</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">Tot</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">%</TableHead>
                </TableRow>
              )}
              {statCategory === "basic" && (
                <TableRow className="border-b-gray-700">
                  <TableHead className="sticky left-0 z-20 bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-48 min-w-[12rem]">
                    Player / Team
                  </TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">K</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">HB</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">D</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">M</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">T</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">FF</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">FA</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">C</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">HO</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">CBA</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">KI</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">UM</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-10 min-w-[2.5rem]">CM</TableHead>
                </TableRow>
              )}
              {statCategory === "vs" && (
                <TableRow className="border-b-gray-700">
                  <TableHead className="sticky left-0 z-20 bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-48 min-w-[12rem]">
                    Player / Team
                  </TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">vOpp</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Venue</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">3ROpp</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">3RVen</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Diff</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">3RDiff</TableHead>
                </TableRow>
              )}
              {statCategory === "value" && (
                <TableRow className="border-b-gray-700">
                  <TableHead className="sticky left-0 z-20 bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-48 min-w-[12rem]">
                    Player / Team
                  </TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">PP$</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Value</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Proj</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Proj$</TableHead>
                </TableRow>
              )}
              {statCategory === "consistency" && (
                <TableRow className="border-b-gray-700">
                  <TableHead className="sticky left-0 z-20 bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-48 min-w-[12rem]">
                    Player / Team
                  </TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Dev</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">CV</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Cons</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Ceil</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Floor</TableHead>
                </TableRow>
              )}
              {statCategory === "dvp" && (
                <TableRow className="border-b-gray-700">
                  <TableHead className="sticky left-0 z-20 bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-48 min-w-[12rem]">
                    Player / Team
                  </TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">DVP</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Diff</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Pos</TableHead>
                  <TableHead className="bg-gradient-to-r from-purple-600 to-blue-600 text-white whitespace-nowrap w-14 min-w-[3.5rem]">Team</TableHead>
                </TableRow>
              )}
            </TableHeader>
            <TableBody>
              {players.map((player) => (
                <TableRow 
                  key={`player-${player.id}-${Math.random().toString(36)}`} 
                  className="hover:bg-gray-800 cursor-pointer border-t-gray-700"
                  onClick={() => setSelectedPlayer(player)}
                >
                  <TableCell className="sticky left-0 z-10 bg-gray-900 text-white font-medium text-sm py-2 max-w-[140px]">
                    <div className="flex items-center space-x-2">
                      <div className="shrink-0">
                        {renderTeamLogo(player.team)}
                      </div>
                      <div className="flex flex-col">
                        <div className="text-sm font-medium line-clamp-1 text-white">{player.name.split(' ')[0]}</div>
                        <div className="text-sm font-medium line-clamp-1 text-gray-400">{player.name.split(' ').slice(1).join(' ')}</div>
                      </div>
                    </div>
                  </TableCell>
                  
                  {statCategory === "fantasy" && (
                    <>
                      <TableCell className="text-center text-sm py-2 text-white">{player.position}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.averagePoints.toFixed(1)}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.lastScore || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.l3Average?.toFixed(1) || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.l5Average?.toFixed(1) || '-'}</TableCell>
                      <TableCell className={`text-center text-sm py-2 ${getCellColor(player.breakEven, 'be')}`}>
                        {player.breakEven}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{formatValue(player.price, 'price')}</TableCell>
                      <TableCell className={`text-center text-sm py-2 ${getCellColor(player.priceChange, 'priceChange')}`}>
                        {player.priceChange !== undefined ? formatValue(player.priceChange, 'price') : '-'}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {player.pricePerPoint?.toFixed(1) || '-'}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.totalPoints || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {player.selectionPercentage?.toFixed(1) || '-'}
                      </TableCell>
                    </>
                  )}
                  
                  {statCategory === "basic" && (
                    <>
                      <TableCell className="text-center text-sm py-2 text-white">{player.kicks || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.handballs || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{(player.kicks || 0) + (player.handballs || 0)}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.marks || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.tackles || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.freeKicksFor || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.freeKicksAgainst || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.clearances || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.hitouts || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.cba || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.kickIns || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.uncontestedMarks || '-'}</TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">{player.contestedMarks || '-'}</TableCell>
                    </>
                  )}
                  
                  {statCategory === "vs" && (
                    <>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {(player.averagePoints * (0.9 + Math.random() * 0.2)).toFixed(1)}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {(player.averagePoints * (0.9 + Math.random() * 0.2)).toFixed(1)}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {(player.averagePoints * (0.9 + Math.random() * 0.2)).toFixed(1)}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {(player.averagePoints * (0.9 + Math.random() * 0.2)).toFixed(1)}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.floor(Math.random() * 5) + 1}/5
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.floor(Math.random() * 5) + 1}/5
                      </TableCell>
                    </>
                  )}
                  
                  {statCategory === "value" && (
                    <>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {((player.averagePoints * 1000) / player.price).toFixed(2)}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.floor(((player.averagePoints * 1000) / player.price) * 10)}/10
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.round(player.averagePoints * (0.9 + Math.random() * 0.3))}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {formatValue(player.price * (0.9 + Math.random() * 0.3), 'price')}
                      </TableCell>
                    </>
                  )}
                  
                  {statCategory === "consistency" && (
                    <>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {(player.averagePoints * 0.2).toFixed(1)}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {(0.2 * 100).toFixed(1)}%
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.floor(Math.random() * 3) + 3}/5
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.round(player.averagePoints * 1.3)}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.round(player.averagePoints * 0.7)}
                      </TableCell>
                    </>
                  )}
                  
                  {statCategory === "dvp" && (
                    <>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {player.position}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.floor(Math.random() * 5) + 1}/5
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.floor(Math.random() * 18) + 1}
                      </TableCell>
                      <TableCell className="text-center text-sm py-2 text-white">
                        {Math.floor(Math.random() * 18) + 1}
                      </TableCell>
                    </>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </ScrollArea>
      </Card>

      {/* Player detail section with charts */}
      {selectedPlayer && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {getPlayerTrendCard(
            selectedPlayer, 
            "Recent Performance", 
            `trend-${selectedPlayer.id}-${Math.random().toString(36)}`, 
            generateConsistencyData(selectedPlayer),
            "#ef4444",
            "#10b981"
          )}
          
          {getDVPCard(selectedPlayer)}
          
          {getPlayerRoleCard(selectedPlayer)}
        </div>
      )}
    </div>
  );
}