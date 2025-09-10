import { useState, useMemo } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import { BarChart3, Table as TableIcon, Home, Plane, Calendar, MapPin, Users } from "lucide-react";

// Types for game data
interface GameData {
  round: number;
  opponent: string;
  venue: string;
  homeAway: 'home' | 'away';
  score: number;
  season: string;
  date: string;
}

// Score thresholds
const SCORE_THRESHOLDS = [70, 80, 90, 100, 110, 120];

// AFL Teams
const AFL_TEAMS = [
  'Adelaide', 'Brisbane', 'Carlton', 'Collingwood', 'Essendon', 'Fremantle',
  'Geelong', 'Gold Coast', 'GWS', 'Hawthorn', 'Melbourne', 'North Melbourne',
  'Port Adelaide', 'Richmond', 'St Kilda', 'Sydney', 'West Coast', 'Western Bulldogs'
];

// AFL Venues
const AFL_VENUES = [
  'MCG', 'Marvel Stadium', 'Adelaide Oval', 'Gabba', 'Optus Stadium', 'SCG',
  'ANZ Stadium', 'GMHBA Stadium', 'Metricon Stadium', 'York Park', 'TIO Stadium'
];

interface ScoreBreakdownModuleProps {
  playerName: string;
  gameData: GameData[];
}

export default function ScoreBreakdownModule({ playerName, gameData }: ScoreBreakdownModuleProps) {
  // View states
  const [viewMode, setViewMode] = useState<'chart' | 'table'>('chart');
  const [chartType, setChartType] = useState<'games' | 'thresholds'>('games');
  const [percentageMode, setPercentageMode] = useState(false);
  
  // Filter states
  const [selectedOpponent, setSelectedOpponent] = useState<string>('all');
  const [selectedVenue, setSelectedVenue] = useState<string>('all');
  const [selectedHomeAway, setSelectedHomeAway] = useState<string>('all');
  const [selectedRange, setSelectedRange] = useState<string>('season2025');
  const [selectedMinScore, setSelectedMinScore] = useState<number | null>(null);

  // Filter game data based on selections
  const filteredGames = useMemo(() => {
    let filtered = [...gameData];

    // Filter by opponent
    if (selectedOpponent !== 'all') {
      filtered = filtered.filter(game => game.opponent === selectedOpponent);
    }

    // Filter by venue
    if (selectedVenue !== 'all') {
      filtered = filtered.filter(game => game.venue === selectedVenue);
    }

    // Filter by home/away
    if (selectedHomeAway !== 'all') {
      filtered = filtered.filter(game => game.homeAway === selectedHomeAway);
    }

    // Filter by minimum score
    if (selectedMinScore !== null) {
      filtered = filtered.filter(game => game.score >= selectedMinScore);
    }

    // Filter by range
    switch (selectedRange) {
      case 'L5':
        filtered = filtered.slice(-5);
        break;
      case 'L10':
        filtered = filtered.slice(-10);
        break;
      case 'season2025':
        filtered = filtered.filter(game => game.season === '2025');
        break;
      case 'season2024':
        filtered = filtered.filter(game => game.season === '2024');
        break;
      case 'season2023':
        filtered = filtered.filter(game => game.season === '2023');
        break;
    }

    return filtered;
  }, [gameData, selectedOpponent, selectedVenue, selectedHomeAway, selectedRange, selectedMinScore]);

  // Calculate threshold statistics for table view
  const thresholdStats = useMemo(() => {
    const totalGames = filteredGames.length;
    
    return SCORE_THRESHOLDS.map(threshold => {
      const timesAchieved = filteredGames.filter(game => game.score >= threshold).length;
      const percentage = totalGames > 0 ? (timesAchieved / totalGames) * 100 : 0;
      const avgWhenAchieved = filteredGames
        .filter(game => game.score >= threshold)
        .reduce((sum, game, _, arr) => sum + game.score / arr.length, 0);

      return {
        threshold,
        count: timesAchieved,
        percentage: percentage.toFixed(1),
        average: avgWhenAchieved.toFixed(1),
        displayValue: percentageMode ? `${percentage.toFixed(1)}%` : timesAchieved
      };
    });
  }, [filteredGames, percentageMode]);

  // Chart data for individual game scores
  const gameChartData = useMemo(() => {
    return filteredGames.map((game, index) => {
      // Determine color based on score
      let barColor = '#6B7280'; // Gray for low scores
      if (game.score >= 120) barColor = '#10B981'; // Green for excellent
      else if (game.score >= 100) barColor = '#34D399'; // Light green for great
      else if (game.score >= 80) barColor = '#60A5FA'; // Blue for good
      else if (game.score >= 60) barColor = '#A78BFA'; // Purple for okay
      
      return {
        game: `${game.season === '2025' ? '' : game.season.slice(-2) + '-'}R${game.round}`,
        score: game.score,
        opponent: game.opponent,
        venue: game.venue,
        season: game.season,
        homeAway: game.homeAway,
        fill: barColor,
        label: `${game.score}`
      };
    });
  }, [filteredGames]);

  // Chart data for threshold analysis
  const thresholdChartData = useMemo(() => {
    return thresholdStats.map(stat => ({
      threshold: `${stat.threshold}+`,
      value: percentageMode ? parseFloat(stat.percentage) : stat.count,
      label: percentageMode ? `${stat.percentage}%` : `${stat.count}`
    }));
  }, [thresholdStats, percentageMode]);

  // Reset all filters
  const resetFilters = () => {
    setSelectedOpponent('all');
    setSelectedVenue('all');
    setSelectedHomeAway('all');
    setSelectedRange('season2025');
    setSelectedMinScore(null);
  };

  return (
    <div className="space-y-4">
      {/* Header with toggle buttons */}
      <div className="flex items-center justify-between">
        <h3 className="text-lg font-semibold text-white">Score Breakdown Analysis</h3>
        <div className="flex gap-2">
          <Button
            size="sm"
            variant={viewMode === 'chart' ? 'default' : 'outline'}
            onClick={() => setViewMode('chart')}
            className="flex items-center gap-1"
          >
            <BarChart3 className="h-4 w-4" />
            Chart
          </Button>
          <Button
            size="sm"
            variant={viewMode === 'table' ? 'default' : 'outline'}
            onClick={() => setViewMode('table')}
            className="flex items-center gap-1"
          >
            <TableIcon className="h-4 w-4" />
            Table
          </Button>
          {viewMode === 'chart' && (
            <>
              <Button
                size="sm"
                variant={chartType === 'games' ? 'default' : 'outline'}
                onClick={() => setChartType('games')}
                className="text-xs"
              >
                Games
              </Button>
              <Button
                size="sm"
                variant={chartType === 'thresholds' ? 'default' : 'outline'}
                onClick={() => setChartType('thresholds')}
                className="text-xs"
              >
                Thresholds
              </Button>
            </>
          )}
          {(viewMode === 'table' || chartType === 'thresholds') && (
            <Button
              size="sm"
              variant={percentageMode ? 'default' : 'outline'}
              onClick={() => setPercentageMode(!percentageMode)}
            >
              % Mode
            </Button>
          )}
        </div>
      </div>

      {/* Minimum Score Filter Buttons */}
      <Card className="bg-gray-800 border-gray-700">
        <CardContent className="p-4">
          <div className="space-y-3">
            <div>
              <label className="text-xs text-gray-400 mb-2 block">Show Only Games Scoring</label>
              <div className="flex flex-wrap gap-2">
                <Button
                  size="sm"
                  onClick={() => setSelectedMinScore(null)}
                  className={`text-xs text-black font-medium ${
                    selectedMinScore === null 
                      ? 'bg-green-500 hover:bg-green-600 border-green-500' 
                      : 'bg-gray-300 hover:bg-gray-400 border-gray-300'
                  }`}
                >
                  All Scores
                </Button>
                {[80, 90, 100, 110, 120].map(threshold => (
                  <Button
                    key={threshold}
                    size="sm"
                    onClick={() => setSelectedMinScore(threshold)}
                    className={`text-xs text-black font-medium ${
                      selectedMinScore === threshold 
                        ? 'bg-green-500 hover:bg-green-600 border-green-500' 
                        : 'bg-gray-300 hover:bg-gray-400 border-gray-300'
                    }`}
                  >
                    {threshold}+
                  </Button>
                ))}
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Main Filter Controls */}
      <Card className="bg-gray-800 border-gray-700">
        <CardContent className="p-4">
          <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
            {/* Range Filter */}
            <div className="space-y-2">
              <label className="text-xs text-gray-400 flex items-center gap-1">
                <Calendar className="h-3 w-3" />
                Range
              </label>
              <Select value={selectedRange} onValueChange={setSelectedRange}>
                <SelectTrigger className="bg-gray-300 border-gray-300 text-black">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-white border-gray-300">
                  <SelectItem value="L5" className="text-black">Last 5 Games</SelectItem>
                  <SelectItem value="L10" className="text-black">Last 10 Games</SelectItem>
                  <SelectItem value="season2025" className="text-black">2025 Season</SelectItem>
                  <SelectItem value="season2024" className="text-black">2024 Season</SelectItem>
                  <SelectItem value="season2023" className="text-black">2023 Season</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Opponent Filter */}
            <div className="space-y-2">
              <label className="text-xs text-gray-400 flex items-center gap-1">
                <Users className="h-3 w-3" />
                Vs Opponent
              </label>
              <Select value={selectedOpponent} onValueChange={setSelectedOpponent}>
                <SelectTrigger className="bg-gray-300 border-gray-300 text-black">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-white border-gray-300">
                  <SelectItem value="all" className="text-black">All Teams</SelectItem>
                  {AFL_TEAMS.map(team => (
                    <SelectItem key={team} value={team} className="text-black">{team}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Venue Filter */}
            <div className="space-y-2">
              <label className="text-xs text-gray-400 flex items-center gap-1">
                <MapPin className="h-3 w-3" />
                Venue
              </label>
              <Select value={selectedVenue} onValueChange={setSelectedVenue}>
                <SelectTrigger className="bg-gray-300 border-gray-300 text-black">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-white border-gray-300">
                  <SelectItem value="all" className="text-black">All Venues</SelectItem>
                  {AFL_VENUES.map(venue => (
                    <SelectItem key={venue} value={venue} className="text-black">{venue}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Home/Away Filter */}
            <div className="space-y-2">
              <label className="text-xs text-gray-400 flex items-center gap-1">
                <Home className="h-3 w-3" />
                Location
              </label>
              <Select value={selectedHomeAway} onValueChange={setSelectedHomeAway}>
                <SelectTrigger className="bg-gray-300 border-gray-300 text-black">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-white border-gray-300">
                  <SelectItem value="all" className="text-black">Home & Away</SelectItem>
                  <SelectItem value="home" className="text-black">Home Only</SelectItem>
                  <SelectItem value="away" className="text-black">Away Only</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Reset Button */}
            <div className="space-y-2">
              <label className="text-xs text-gray-400 opacity-0">Reset</label>
              <Button
                size="sm"
                onClick={resetFilters}
                className="w-full bg-gray-300 hover:bg-gray-400 border-gray-300 text-black font-medium"
              >
                Reset All
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Results Summary */}
      <div className="text-sm text-gray-400">
        Showing {filteredGames.length} games
        {selectedMinScore !== null && ` scoring ${selectedMinScore}+`}
        {selectedOpponent !== 'all' && ` vs ${selectedOpponent}`}
        {selectedVenue !== 'all' && ` at ${selectedVenue}`}
        {selectedHomeAway !== 'all' && ` (${selectedHomeAway})`}
      </div>

      {/* Chart or Table View */}
      {viewMode === 'chart' ? (
        <Card className="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle className="text-white text-center">
              {chartType === 'games' ? 'Individual Game Scores' : 'Fantasy Score Threshold Analysis'}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-96">
              <ResponsiveContainer width="100%" height="100%">
                {chartType === 'games' ? (
                  <BarChart 
                    data={gameChartData} 
                    margin={{ top: 20, right: 10, left: 20, bottom: 60 }}
                    barCategoryGap="2%"
                    maxBarSize={12}
                  >
                    <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                    <XAxis 
                      dataKey="game" 
                      axisLine={false}
                      tick={{ fill: '#9CA3AF', fontSize: 8 }}
                      interval={0}
                      angle={-45}
                      textAnchor="end"
                      height={80}
                    />
                    <YAxis 
                      axisLine={false}
                      tick={{ fill: '#9CA3AF', fontSize: 12 }}
                      domain={[0, 150]}
                    />
                    <Tooltip 
                      contentStyle={{ 
                        backgroundColor: '#1F2937', 
                        border: '1px solid #374151',
                        borderRadius: '6px',
                        color: '#F9FAFB'
                      }}
                      formatter={(value, name, props) => [
                        `${value} points`,
                        `Round ${props.payload.game}`
                      ]}
                      labelFormatter={(label, payload) => {
                        if (payload && payload[0]) {
                          const data = payload[0].payload;
                          return `${data.season} ${label} vs ${data.opponent} (${data.homeAway})`;
                        }
                        return label;
                      }}
                    />
                    <Bar 
                      dataKey="score" 
                      radius={[2, 2, 0, 0]}
                    >
                      {gameChartData.map((entry, index) => (
                        <Cell key={`cell-${index}`} fill={entry.fill} />
                      ))}
                    </Bar>
                  </BarChart>
                ) : (
                  <BarChart data={thresholdChartData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                    <XAxis 
                      dataKey="threshold" 
                      axisLine={false}
                      tick={{ fill: '#9CA3AF', fontSize: 12 }}
                    />
                    <YAxis 
                      axisLine={false}
                      tick={{ fill: '#9CA3AF', fontSize: 12 }}
                      domain={percentageMode ? [0, 100] : [0, 'dataMax']}
                    />
                    <Tooltip 
                      contentStyle={{ 
                        backgroundColor: '#1F2937', 
                        border: '1px solid #374151',
                        borderRadius: '6px',
                        color: '#F9FAFB'
                      }}
                    />
                    <Bar 
                      dataKey="value" 
                      fill="#3B82F6"
                      radius={[4, 4, 0, 0]}
                    />
                  </BarChart>
                )}
              </ResponsiveContainer>
            </div>
            
            {/* Legend for individual games */}
            {chartType === 'games' && (
              <div className="mt-4 flex flex-wrap justify-center gap-4 text-xs">
                <div className="flex items-center gap-1">
                  <div className="w-3 h-3 bg-green-500 rounded"></div>
                  <span className="text-gray-300">120+ Excellent</span>
                </div>
                <div className="flex items-center gap-1">
                  <div className="w-3 h-3 bg-green-400 rounded"></div>
                  <span className="text-gray-300">100+ Great</span>
                </div>
                <div className="flex items-center gap-1">
                  <div className="w-3 h-3 bg-blue-400 rounded"></div>
                  <span className="text-gray-300">80+ Good</span>
                </div>
                <div className="flex items-center gap-1">
                  <div className="w-3 h-3 bg-purple-400 rounded"></div>
                  <span className="text-gray-300">60+ Okay</span>
                </div>
                <div className="flex items-center gap-1">
                  <div className="w-3 h-3 bg-gray-500 rounded"></div>
                  <span className="text-gray-300">&lt;60 Poor</span>
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      ) : (
        <Card className="bg-gray-800 border-gray-700">
          <CardHeader>
            <CardTitle className="text-white">Score Threshold Statistics</CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow className="border-gray-700">
                  <TableHead className="text-gray-300">Threshold</TableHead>
                  <TableHead className="text-gray-300">Times Achieved</TableHead>
                  <TableHead className="text-gray-300">Percentage</TableHead>
                  <TableHead className="text-gray-300">Avg When Hit</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {thresholdStats.map((stat) => (
                  <TableRow key={stat.threshold} className="border-gray-700">
                    <TableCell className="text-white font-medium">
                      {stat.threshold}+
                    </TableCell>
                    <TableCell className="text-white">
                      {stat.count}
                    </TableCell>
                    <TableCell className="text-white">
                      {stat.percentage}%
                    </TableCell>
                    <TableCell className="text-white">
                      {stat.average}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}
    </div>
  );
}