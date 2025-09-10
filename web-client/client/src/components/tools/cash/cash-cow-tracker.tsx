import React, { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Slider } from "@/components/ui/slider";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { 
  Search, 
  TrendingUp, 
  TrendingDown, 
  Minus,
  ArrowUpCircle,
  ArrowDownCircle,
  Target,
  Star,
  AlertTriangle,
  Shield,
  Activity
} from "lucide-react";

// Mock data for AFL Fantasy rookies
const mockRookieData = [
  {
    id: 1,
    name: "Sam Darcy",
    team: "Western Bulldogs",
    position: "FWD",
    dpp: false,
    price: 234000,
    breakeven: 45,
    projectedScore: 78,
    projectedPriceChange: 28400,
    status: "rising",
    lastThreeScores: [82, 74, 81],
    upcomingFixtures: [
      { opponent: "Richmond", difficulty: "easy" },
      { opponent: "Geelong", difficulty: "hard" },
      { opponent: "St Kilda", difficulty: "medium" }
    ],
    jobSecurity: {
      tog: 85,
      cbaPercent: 12,
      subRisk: "low"
    },
    form: 85
  },
  {
    id: 2,
    name: "Nick Daicos",
    team: "Collingwood",
    position: "MID",
    dpp: false,
    price: 387000,
    breakeven: 72,
    projectedScore: 89,
    projectedPriceChange: 15600,
    status: "rising",
    lastThreeScores: [94, 87, 92],
    upcomingFixtures: [
      { opponent: "Carlton", difficulty: "hard" },
      { opponent: "North Melbourne", difficulty: "easy" },
      { opponent: "Adelaide", difficulty: "medium" }
    ],
    jobSecurity: {
      tog: 92,
      cbaPercent: 45,
      subRisk: "very low"
    },
    form: 92
  },
  {
    id: 3,
    name: "Josh Rachele",
    team: "Adelaide",
    position: "FWD",
    dpp: true,
    price: 298000,
    breakeven: 58,
    projectedScore: 71,
    projectedPriceChange: 8200,
    status: "plateau",
    lastThreeScores: [73, 69, 75],
    upcomingFixtures: [
      { opponent: "Fremantle", difficulty: "medium" },
      { opponent: "Brisbane", difficulty: "hard" },
      { opponent: "Gold Coast", difficulty: "easy" }
    ],
    jobSecurity: {
      tog: 78,
      cbaPercent: 8,
      subRisk: "medium"
    },
    form: 72
  },
  {
    id: 4,
    name: "Jai Newcombe",
    team: "Hawthorn",
    position: "MID",
    dpp: false,
    price: 312000,
    breakeven: 68,
    projectedScore: 63,
    projectedPriceChange: -3400,
    status: "falling",
    lastThreeScores: [61, 58, 67],
    upcomingFixtures: [
      { opponent: "Melbourne", difficulty: "hard" },
      { opponent: "Essendon", difficulty: "medium" },
      { opponent: "West Coast", difficulty: "easy" }
    ],
    jobSecurity: {
      tog: 82,
      cbaPercent: 28,
      subRisk: "low"
    },
    form: 62
  },
  {
    id: 5,
    name: "Finn Callaghan",
    team: "GWS Giants",
    position: "MID",
    dpp: false,
    price: 276000,
    breakeven: 52,
    projectedScore: 69,
    projectedPriceChange: 12800,
    status: "rising",
    lastThreeScores: [71, 66, 72],
    upcomingFixtures: [
      { opponent: "Sydney", difficulty: "hard" },
      { opponent: "Port Adelaide", difficulty: "medium" },
      { opponent: "Western Bulldogs", difficulty: "medium" }
    ],
    jobSecurity: {
      tog: 88,
      cbaPercent: 35,
      subRisk: "low"
    },
    form: 70
  },
  {
    id: 6,
    name: "Will Phillips",
    team: "North Melbourne",
    position: "MID",
    dpp: false,
    price: 245000,
    breakeven: 41,
    projectedScore: 58,
    projectedPriceChange: 11200,
    status: "rising",
    lastThreeScores: [62, 54, 60],
    upcomingFixtures: [
      { opponent: "Collingwood", difficulty: "hard" },
      { opponent: "Richmond", difficulty: "medium" },
      { opponent: "Carlton", difficulty: "hard" }
    ],
    jobSecurity: {
      tog: 75,
      cbaPercent: 22,
      subRisk: "medium"
    },
    form: 58
  },
  {
    id: 7,
    name: "Archie Perkins",
    team: "Essendon",
    position: "FWD",
    dpp: true,
    price: 324000,
    breakeven: 71,
    projectedScore: 68,
    projectedPriceChange: -2100,
    status: "plateau",
    lastThreeScores: [70, 65, 69],
    upcomingFixtures: [
      { opponent: "Brisbane", difficulty: "hard" },
      { opponent: "Hawthorn", difficulty: "medium" },
      { opponent: "Gold Coast", difficulty: "easy" }
    ],
    jobSecurity: {
      tog: 83,
      cbaPercent: 15,
      subRisk: "low"
    },
    form: 68
  },
  {
    id: 8,
    name: "Errol Gulden",
    team: "Sydney",
    position: "MID",
    dpp: true,
    price: 356000,
    breakeven: 79,
    projectedScore: 84,
    projectedPriceChange: 3200,
    status: "plateau",
    lastThreeScores: [86, 82, 85],
    upcomingFixtures: [
      { opponent: "GWS Giants", difficulty: "medium" },
      { opponent: "Melbourne", difficulty: "hard" },
      { opponent: "St Kilda", difficulty: "medium" }
    ],
    jobSecurity: {
      tog: 91,
      cbaPercent: 38,
      subRisk: "very low"
    },
    form: 84
  }
];

// Team guernsey mapping
const teamGuernsey: { [key: string]: string } = {
  "Adelaide": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/adelaide-crows-logo.png",
  "Brisbane": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/brisbane-lions-logo.png",
  "Carlton": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/carlton-blues-logo.png",
  "Collingwood": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/collingwood-magpies-logo.png",
  "Essendon": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/essendon-bombers-logo.png",
  "Fremantle": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/fremantle-dockers-logo.png",
  "Geelong": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/geelong-cats-logo.png",
  "Gold Coast": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/gold-coast-suns-logo.png",
  "GWS Giants": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/gws-giants-logo.png",
  "Hawthorn": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/hawthorn-hawks-logo.png",
  "Melbourne": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/melbourne-demons-logo.png",
  "North Melbourne": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/north-melbourne-kangaroos-logo.png",
  "Port Adelaide": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/port-adelaide-power-logo.png",
  "Richmond": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/richmond-tigers-logo.png",
  "St Kilda": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/st-kilda-saints-logo.png",
  "Sydney": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/sydney-swans-logo.png",
  "West Coast": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/west-coast-eagles-logo.png",
  "Western Bulldogs": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/western-bulldogs-logo.png"
};

const getTeamGuernsey = (team: string) => {
  return teamGuernsey[team] || "";
};

// Format currency for display
const formatCurrency = (amount: number, decimals = 0) => {
  return new Intl.NumberFormat('en-AU', {
    style: 'currency',
    currency: 'AUD',
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals
  }).format(amount);
};

// Get status emoji
const getStatusEmoji = (status: string) => {
  switch (status) {
    case "rising":
      return "📈";
    case "falling":
      return "📉";
    default:
      return "⚖️";
  }
};



// Get fixture difficulty color
const getFixtureDifficultyColor = (difficulty: string) => {
  switch (difficulty) {
    case "easy":
      return "text-green-400 bg-green-900/30";
    case "medium":
      return "text-yellow-400 bg-yellow-900/30";
    case "hard":
      return "text-red-400 bg-red-900/30";
    default:
      return "text-gray-400 bg-gray-700";
  }
};

// Player Detail Panel Component
const PlayerDetailPanel = ({ player, onClose }: { player: any; onClose: () => void }) => {
  return (
    <div className="space-y-4">
      {/* Player Header */}
      <div className="flex items-center gap-3">
        <img 
          src={getTeamGuernsey(player.team)} 
          alt={player.team}
          className="w-8 h-8 object-contain"
        />
        <div>
          <h3 className="text-lg font-bold text-white">{player.name}</h3>
          <div className="flex items-center gap-2">
            <span className="text-gray-300">{player.team}</span>
            <Badge variant="outline" className="text-blue-400 border-blue-400">
              {player.position}{player.dpp ? "/DPP" : ""}
            </Badge>
          </div>
        </div>
      </div>

      {/* Price Info */}
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-gray-700 p-3 rounded-lg">
          <div className="text-gray-400 text-sm">Current Price</div>
          <div className="text-white font-bold">{formatCurrency(player.price)}</div>
        </div>
        <div className="bg-gray-700 p-3 rounded-lg">
          <div className="text-gray-400 text-sm">Breakeven</div>
          <div className="text-white font-bold">{player.breakeven}</div>
        </div>
      </div>

      {/* Last 3 Scores */}
      <div>
        <h4 className="text-white font-medium mb-2">Last 3 Round Scores</h4>
        <div className="flex gap-2">
          {player.lastThreeScores.map((score: number, index: number) => (
            <div key={index} className="bg-gray-700 p-2 rounded text-center flex-1">
              <div className="text-gray-400 text-xs">R{20 - 2 + index}</div>
              <div className="text-white font-bold">{score}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Upcoming Fixtures */}
      <div>
        <h4 className="text-white font-medium mb-2">Upcoming 3 Fixture Difficulty</h4>
        <div className="space-y-2">
          {player.upcomingFixtures.map((fixture: any, index: number) => (
            <div key={index} className="flex items-center justify-between bg-gray-700 p-2 rounded">
              <div className="flex items-center gap-2">
                <div className="text-gray-400 text-sm">R{21 + index}</div>
                <div className="text-white">vs {fixture.opponent}</div>
              </div>
              <Badge className={getFixtureDifficultyColor(fixture.difficulty)}>
                {fixture.difficulty}
              </Badge>
            </div>
          ))}
        </div>
      </div>

      {/* Job Security */}
      <div>
        <h4 className="text-white font-medium mb-2">Job Security</h4>
        <div className="space-y-2">
          <div className="flex justify-between items-center">
            <span className="text-gray-400">TOG%</span>
            <span className="text-white font-bold">{player.jobSecurity.tog}%</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-gray-400">CBA%</span>
            <span className="text-white font-bold">{player.jobSecurity.cbaPercent}%</span>
          </div>
          <div className="flex justify-between items-center">
            <span className="text-gray-400">Sub Risk</span>
            <Badge 
              variant="outline" 
              className={
                player.jobSecurity.subRisk === "very low" ? "text-green-400 border-green-400" :
                player.jobSecurity.subRisk === "low" ? "text-blue-400 border-blue-400" :
                player.jobSecurity.subRisk === "medium" ? "text-yellow-400 border-yellow-400" :
                "text-red-400 border-red-400"
              }
            >
              {player.jobSecurity.subRisk}
            </Badge>
          </div>
        </div>
      </div>

      {/* Price Projection */}
      <div className="bg-gray-700 p-3 rounded-lg">
        <h4 className="text-white font-medium mb-2">Price Projection</h4>
        <div className="flex items-center justify-between">
          <div>
            <div className="text-gray-400 text-sm">Projected Score</div>
            <div className="text-white font-bold">{player.projectedScore}</div>
          </div>
          <div className="text-right">
            <div className="text-gray-400 text-sm">Price Change</div>
            <div className={`font-bold ${
              player.projectedPriceChange > 0 ? 'text-green-400' : 
              player.projectedPriceChange < 0 ? 'text-red-400' : 'text-gray-400'
            }`}>
              {player.projectedPriceChange > 0 ? '+' : ''}{formatCurrency(player.projectedPriceChange)}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export function CashCowTracker() {
  const [searchQuery, setSearchQuery] = useState("");
  const [maxPrice, setMaxPrice] = useState([400000]);
  const [positionFilter, setPositionFilter] = useState("All");
  const [sortBy, setSortBy] = useState("price_change");
  const [selectedPlayer, setSelectedPlayer] = useState<any>(null);

  // Fetch player data from API
  const { data: apiPlayers, isLoading } = useQuery({
    queryKey: ["/api/players"],
    select: (data: any[]) => {
      // Filter for rookie-priced players (under $400k) and transform data
      return data.filter(player => {
        const price = player.price || 300000;
        return price <= 400000 && price >= 180000; // Rookie price range
      }).map((player: any, index: number) => ({
        id: player.externalId || index,
        name: player.name,
        team: player.team,
        position: player.position || "ROO",
        dpp: Math.random() > 0.7, // Random dual position premium
        price: player.price || 300000,
        breakeven: player.breakeven || Math.round(Math.random() * 60 + 20),
        projectedScore: Math.round(60 + Math.random() * 40),
        projectedPriceChange: Math.round((Math.random() - 0.3) * 40000), // Mostly positive for rookies
        status: Math.random() > 0.6 ? "rising" : Math.random() > 0.3 ? "stable" : "falling",
        lastThreeScores: Array.from({ length: 3 }, () => Math.round(40 + Math.random() * 50)),
        upcomingFixtures: [
          { opponent: "Richmond", difficulty: "easy" },
          { opponent: "Geelong", difficulty: "hard" },
          { opponent: "St Kilda", difficulty: "medium" }
        ],
        jobSecurity: {
          tog: Math.round(70 + Math.random() * 30),
          cbaPercent: Math.round(Math.random() * 20),
          subRisk: Math.random() > 0.7 ? "high" : Math.random() > 0.4 ? "medium" : "low"
        },
        form: Math.round(60 + Math.random() * 35)
      }));
    }
  });

  // Use API data or fallback to mock data
  const rookieData = apiPlayers || mockRookieData;

  // Filter and sort players
  const filteredPlayers = useMemo(() => {
    const filtered = rookieData.filter(player => {
      // Search filter - allow single character searches
      if (searchQuery.trim().length > 0 && !player.name.toLowerCase().includes(searchQuery.toLowerCase().trim())) {
        return false;
      }
      
      // Price filter
      if (player.price > maxPrice[0]) {
        return false;
      }
      
      // Position filter
      if (positionFilter !== "All") {
        if (positionFilter === "DPP") {
          if (!player.dpp) return false;
        } else {
          if (player.position !== positionFilter) return false;
        }
      }
      
      return true;
    });

    // Sort players
    filtered.sort((a, b) => {
      switch (sortBy) {
        case "price_change":
          return b.projectedPriceChange - a.projectedPriceChange;
        case "breakeven":
          return a.breakeven - b.breakeven;
        case "form":
          return b.form - a.form;
        case "job_security":
          return b.jobSecurity.tog - a.jobSecurity.tog;
        default:
          return 0;
      }
    });

    return filtered;
  }, [rookieData, searchQuery, maxPrice, positionFilter, sortBy]);

  if (isLoading) {
    return (
      <Card className="bg-gray-800 border-green-500 border-2">
        <CardContent className="p-8 text-center">
          <div className="flex items-center justify-center gap-2">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-400"></div>
            <span className="text-white">Loading player data...</span>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className="bg-gray-800 border-green-500 border-2">
      <CardHeader className="border-b border-green-500/30">
        <div className="flex items-center gap-2 mb-4">
          <Target className="h-6 w-6 text-green-400" />
          <h2 className="text-xl font-bold text-white">🐄 Cash Cow Tracker</h2>
        </div>
        
        {/* Filter Controls */}
        <div className="space-y-4">
          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <Input
              placeholder="Search player names (2+ letters)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 bg-gray-700 border-gray-600 text-white placeholder-gray-400"
            />
          </div>

          {/* Filter Row */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-2 text-xs">
            {/* Price Slider */}
            <div className="col-span-2 md:col-span-1 space-y-1">
              <label className="text-xs text-gray-300">Max Price: {formatCurrency(maxPrice[0], 0)}</label>
              <Slider
                value={maxPrice}
                onValueChange={setMaxPrice}
                max={400000}
                min={200000}
                step={10000}
                className="w-full"
              />
            </div>

            {/* Position Filter */}
            <div className="space-y-1">
              <label className="text-xs text-gray-300">Position</label>
              <Select value={positionFilter} onValueChange={setPositionFilter}>
                <SelectTrigger className="bg-gray-700 border-gray-600 text-white h-8 text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-gray-700 border-gray-600">
                  <SelectItem value="All">All</SelectItem>
                  <SelectItem value="DEF">DEF</SelectItem>
                  <SelectItem value="MID">MID</SelectItem>
                  <SelectItem value="FWD">FWD</SelectItem>
                  <SelectItem value="RUC">RUC</SelectItem>
                  <SelectItem value="DPP">DPP</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Sort By */}
            <div className="space-y-1">
              <label className="text-xs text-gray-300">Sort</label>
              <Select value={sortBy} onValueChange={setSortBy}>
                <SelectTrigger className="bg-gray-700 border-gray-600 text-white h-8 text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-gray-700 border-gray-600">
                  <SelectItem value="price_change">Price Change</SelectItem>
                  <SelectItem value="breakeven">Break Even</SelectItem>
                  <SelectItem value="form">Form</SelectItem>
                  <SelectItem value="job_security">Job Security</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Results Count - Hidden on mobile, shown on larger screens */}
            <div className="hidden md:flex items-end">
              <div className="text-xs text-gray-400">
                {filteredPlayers.length} players
              </div>
            </div>
          </div>

          {/* Mobile Results Count */}
          <div className="md:hidden text-center">
            <div className="text-xs text-gray-400">
              Showing {filteredPlayers.length} players
            </div>
          </div>
        </div>
      </CardHeader>

      <CardContent className="p-0">
        {/* Table Header */}
        <div className="grid grid-cols-8 gap-1 p-2 bg-gray-700 text-gray-300 text-xs font-medium border-b border-gray-600">
          <div className="col-span-2">Player</div>
          <div>Pos</div>
          <div>Price</div>
          <div>BE</div>
          <div>Score</div>
          <div>Change</div>
          <div>📊</div>
        </div>

        {/* Table Rows */}
        <div className="max-h-96 overflow-y-auto">
          {filteredPlayers.map((player) => (
            <Dialog key={player.id}>
              <DialogTrigger asChild>
                <div 
                  className="grid grid-cols-8 gap-1 p-2 border-b border-gray-700 hover:bg-gray-700 cursor-pointer transition-colors"
                  onClick={() => setSelectedPlayer(player)}
                >
                  {/* Player Info */}
                  <div className="col-span-2 flex items-center gap-1">
                    <img 
                      src={getTeamGuernsey(player.team)} 
                      alt={player.team}
                      className="w-4 h-4 object-contain"
                    />
                    <div className="min-w-0 flex-1">
                      <div className="text-white font-medium text-xs truncate">{player.name}</div>
                      <div className="text-gray-400 text-xs truncate">{player.team}</div>
                    </div>
                  </div>

                  {/* Position */}
                  <div className="flex items-center justify-center">
                    <span className="text-blue-400 text-xs font-medium">
                      {player.position}{player.dpp ? "/D" : ""}
                    </span>
                  </div>

                  {/* Price */}
                  <div className="flex items-center text-white text-xs">
                    ${Math.round(player.price / 1000)}k
                  </div>

                  {/* Break Even */}
                  <div className="flex items-center text-white text-xs">
                    {player.breakeven}
                  </div>

                  {/* Projected Score */}
                  <div className="flex items-center text-white text-xs">
                    {player.projectedScore}
                  </div>

                  {/* Price Change */}
                  <div className={`flex items-center text-xs font-medium ${
                    player.projectedPriceChange > 20000 ? 'text-green-400' :
                    player.projectedPriceChange > 5000 ? 'text-blue-400' :
                    player.projectedPriceChange > -5000 ? 'text-gray-400' :
                    'text-red-400'
                  }`}>
                    {player.projectedPriceChange > 0 ? '+' : ''}{Math.round(player.projectedPriceChange / 1000)}k
                  </div>

                  {/* Status */}
                  <div className="flex items-center justify-center text-sm">
                    {getStatusEmoji(player.status)}
                  </div>
                </div>
              </DialogTrigger>

              <DialogContent className="bg-gray-800 border-gray-600 text-white max-w-md">
                <DialogHeader>
                  <DialogTitle className="text-green-400">Player Details</DialogTitle>
                  <DialogDescription className="text-gray-400">Detailed player statistics and performance metrics</DialogDescription>
                </DialogHeader>
                <PlayerDetailPanel player={player} onClose={() => setSelectedPlayer(null)} />
              </DialogContent>
            </Dialog>
          ))}
        </div>

        {/* Empty State */}
        {filteredPlayers.length === 0 && (
          <div className="p-8 text-center text-gray-400">
            <Target className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>No players match your current filters.</p>
            <p className="text-sm mt-2">Try adjusting your search criteria.</p>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

export default CashCowTracker;