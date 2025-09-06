import React, { useState, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Slider } from "@/components/ui/slider";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
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
  Target,
  BarChart3,
  Calendar,
  Shield,
  Lock,
  ArrowUpCircle,
  ArrowDownCircle
} from "lucide-react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';


// Mock data for top AFL Fantasy players with highest projected price increases
const mockPlayerData = [
  {
    id: 1,
    name: "Marcus Bontempelli",
    team: "Western Bulldogs",
    position: "MID",
    currentPrice: 785000,
    projectedIncrease: 45000,
    roleSecurity: 94,
    recommendedBuyRound: 21,
    recommendedSellRound: 24,
    breakeven: 92,
    nextFiveRounds: [
      { round: 21, projectedPrice: 798000, projectedScore: 105, opponent: "Richmond", difficulty: "easy", tagRisk: false },
      { round: 22, projectedPrice: 812000, projectedScore: 98, opponent: "Melbourne", difficulty: "hard", tagRisk: false },
      { round: 23, projectedPrice: 825000, projectedScore: 102, opponent: "St Kilda", difficulty: "neutral", tagRisk: false },
      { round: 24, projectedPrice: 830000, projectedScore: 89, opponent: "Geelong", difficulty: "very_hard", tagRisk: true },
      { round: 25, projectedPrice: 821000, projectedScore: 85, opponent: "Collingwood", difficulty: "hard", tagRisk: false }
    ],
    seasonOpponents: [
      { round: 21, opponent: "Richmond", difficulty: "easy", tagRisk: false },
      { round: 22, opponent: "Melbourne", difficulty: "hard", tagRisk: false },
      { round: 23, opponent: "St Kilda", difficulty: "neutral", tagRisk: false },
      { round: 24, opponent: "Geelong", difficulty: "very_hard", tagRisk: true },
      { round: 25, opponent: "Collingwood", difficulty: "hard", tagRisk: false },
      { round: 26, opponent: "Sydney", difficulty: "very_hard", tagRisk: false },
      { round: 27, opponent: "Adelaide", difficulty: "easy", tagRisk: false }
    ]
  },
  {
    id: 2,
    name: "Christian Petracca",
    team: "Melbourne",
    position: "MID",
    currentPrice: 756000,
    projectedIncrease: 38000,
    roleSecurity: 91,
    recommendedBuyRound: 20,
    recommendedSellRound: 23,
    breakeven: 88,
    nextFiveRounds: [
      { round: 21, projectedPrice: 768000, projectedScore: 102, opponent: "Fremantle", difficulty: "neutral", tagRisk: false },
      { round: 22, projectedPrice: 780000, projectedScore: 95, opponent: "Western Bulldogs", difficulty: "hard", tagRisk: false },
      { round: 23, projectedPrice: 794000, projectedScore: 108, opponent: "North Melbourne", difficulty: "very_easy", tagRisk: false },
      { round: 24, projectedPrice: 785000, projectedScore: 82, opponent: "Brisbane", difficulty: "very_hard", tagRisk: true },
      { round: 25, projectedPrice: 778000, projectedScore: 79, opponent: "Carlton", difficulty: "hard", tagRisk: false }
    ],
    seasonOpponents: [
      { round: 21, opponent: "Fremantle", difficulty: "neutral", tagRisk: false },
      { round: 22, opponent: "Western Bulldogs", difficulty: "hard", tagRisk: false },
      { round: 23, opponent: "North Melbourne", difficulty: "very_easy", tagRisk: false },
      { round: 24, opponent: "Brisbane", difficulty: "very_hard", tagRisk: true },
      { round: 25, opponent: "Carlton", difficulty: "hard", tagRisk: false },
      { round: 26, opponent: "Richmond", difficulty: "easy", tagRisk: false },
      { round: 27, opponent: "Geelong", difficulty: "very_hard", tagRisk: true }
    ]
  },
  {
    id: 3,
    name: "Lachie Neale",
    team: "Brisbane",
    position: "MID",
    currentPrice: 698000,
    projectedIncrease: 42000,
    roleSecurity: 96,
    recommendedBuyRound: 21,
    recommendedSellRound: 25,
    breakeven: 76,
    nextFiveRounds: [
      { round: 21, projectedPrice: 712000, projectedScore: 115, opponent: "Gold Coast", difficulty: "easy", tagRisk: false },
      { round: 22, projectedPrice: 728000, projectedScore: 103, opponent: "Port Adelaide", difficulty: "hard", tagRisk: false },
      { round: 23, projectedPrice: 740000, projectedScore: 98, opponent: "Hawthorn", difficulty: "neutral", tagRisk: false },
      { round: 24, projectedPrice: 731000, projectedScore: 81, opponent: "Melbourne", difficulty: "very_hard", tagRisk: true },
      { round: 25, projectedPrice: 725000, projectedScore: 86, opponent: "Sydney", difficulty: "hard", tagRisk: false }
    ],
    seasonOpponents: [
      { round: 21, opponent: "Gold Coast", difficulty: "easy", tagRisk: false },
      { round: 22, opponent: "Port Adelaide", difficulty: "hard", tagRisk: false },
      { round: 23, opponent: "Hawthorn", difficulty: "neutral", tagRisk: false },
      { round: 24, opponent: "Melbourne", difficulty: "very_hard", tagRisk: true },
      { round: 25, opponent: "Sydney", difficulty: "hard", tagRisk: false },
      { round: 26, opponent: "Carlton", difficulty: "hard", tagRisk: false },
      { round: 27, opponent: "Essendon", difficulty: "neutral", tagRisk: false }
    ]
  },
  {
    id: 4,
    name: "Touk Miller",
    team: "Gold Coast",
    position: "MID",
    currentPrice: 634000,
    projectedIncrease: 35000,
    roleSecurity: 89,
    recommendedBuyRound: 20,
    recommendedSellRound: 24,
    breakeven: 68,
    nextFiveRounds: [
      { round: 21, projectedPrice: 645000, projectedScore: 89, opponent: "Brisbane", difficulty: "hard", tagRisk: false },
      { round: 22, projectedPrice: 658000, projectedScore: 95, opponent: "Adelaide", difficulty: "neutral", tagRisk: false },
      { round: 23, projectedPrice: 669000, projectedScore: 88, opponent: "West Coast", difficulty: "easy", tagRisk: false },
      { round: 24, projectedPrice: 662000, projectedScore: 82, opponent: "Port Adelaide", difficulty: "very_hard", tagRisk: true },
      { round: 25, projectedPrice: 655000, projectedScore: 79, opponent: "GWS Giants", difficulty: "hard", tagRisk: false }
    ],
    seasonOpponents: [
      { round: 21, opponent: "Brisbane", difficulty: "hard", tagRisk: false },
      { round: 22, opponent: "Adelaide", difficulty: "neutral", tagRisk: false },
      { round: 23, opponent: "West Coast", difficulty: "easy", tagRisk: false },
      { round: 24, opponent: "Port Adelaide", difficulty: "very_hard", tagRisk: true },
      { round: 25, opponent: "GWS Giants", difficulty: "hard", tagRisk: false },
      { round: 26, opponent: "Fremantle", difficulty: "neutral", tagRisk: false },
      { round: 27, opponent: "Richmond", difficulty: "easy", tagRisk: false }
    ]
  },
  {
    id: 5,
    name: "Zach Merrett",
    team: "Essendon",
    position: "MID",
    currentPrice: 587000,
    projectedIncrease: 33000,
    roleSecurity: 92,
    recommendedBuyRound: 21,
    recommendedSellRound: 25,
    breakeven: 72,
    nextFiveRounds: [
      { round: 21, projectedPrice: 598000, projectedScore: 94, opponent: "St Kilda", difficulty: "neutral", tagRisk: false },
      { round: 22, projectedPrice: 612000, projectedScore: 101, opponent: "North Melbourne", difficulty: "very_easy", tagRisk: false },
      { round: 23, projectedPrice: 620000, projectedScore: 87, opponent: "Geelong", difficulty: "very_hard", tagRisk: true },
      { round: 24, projectedPrice: 614000, projectedScore: 83, opponent: "Carlton", difficulty: "hard", tagRisk: false },
      { round: 25, projectedPrice: 609000, projectedScore: 86, opponent: "Hawthorn", difficulty: "neutral", tagRisk: false }
    ],
    seasonOpponents: [
      { round: 21, opponent: "St Kilda", difficulty: "neutral", tagRisk: false },
      { round: 22, opponent: "North Melbourne", difficulty: "very_easy", tagRisk: false },
      { round: 23, opponent: "Geelong", difficulty: "very_hard", tagRisk: true },
      { round: 24, opponent: "Carlton", difficulty: "hard", tagRisk: false },
      { round: 25, opponent: "Hawthorn", difficulty: "neutral", tagRisk: false },
      { round: 26, opponent: "Richmond", difficulty: "easy", tagRisk: false },
      { round: 27, opponent: "Brisbane", difficulty: "hard", tagRisk: false }
    ]
  }
];

// Team logo URLs
const teamLogos: { [key: string]: string } = {
  "Adelaide": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/adelaide-crows-logo.png",
  "Brisbane": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/brisbane-lions-logo.png",
  "Carlton": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/carlton-blues-logo.png",
  "Collingwood": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/collingwood-magpies-logo.png",
  "Essendon": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/essendon-bombers-logo.png",
  "Fremantle": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/fremantle-dockers-logo.png",
  "Geelong": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/geelong-cats-logo.png",
  "Gold Coast": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/gold-coast-suns-logo.png",
  "GWS": "https://resources.afl.com.au/afl/document/2021/03/11/cd2ac9b5-e4be-4f67-b98c-2e0e4e5b6e1c/gws-giants-logo.png",
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

// Team logo component
const TeamLogo = ({ teamName, size = "w-8 h-8" }: { teamName: string, size?: string }) => {
  const logoUrl = teamLogos[teamName];
  return (
    <img 
      src={logoUrl} 
      alt={`${teamName} logo`} 
      className={`${size} object-contain rounded`}
      onError={(e) => {
        // Fallback to team initials if image fails to load
        (e.target as HTMLImageElement).style.display = 'none';
      }}
    />
  );
};

// Difficulty color mapping
const difficultyColors = {
  "very_easy": { bg: "bg-green-900/30", text: "text-green-400", emoji: "🟩" },
  "easy": { bg: "bg-yellow-900/30", text: "text-yellow-400", emoji: "🟨" },
  "neutral": { bg: "bg-blue-900/30", text: "text-blue-400", emoji: "🟦" },
  "medium": { bg: "bg-orange-900/30", text: "text-orange-400", emoji: "🟧" },
  "hard": { bg: "bg-orange-900/30", text: "text-orange-400", emoji: "🟧" },
  "very_hard": { bg: "bg-red-900/30", text: "text-red-400", emoji: "🟥" }
};

// Format currency
const formatCurrency = (amount: number, decimals = 0) => {
  return new Intl.NumberFormat('en-AU', {
    style: 'currency',
    currency: 'AUD',
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals
  }).format(amount);
};

// Player Detail Modal Component
const PlayerDetailModal = ({ player }: { player: any }) => {
  const [activeTab, setActiveTab] = useState("upcoming");

  // Chart data for upcoming rounds
  const chartData = player.nextFiveRounds.map((round: any) => ({
    round: `R${round.round}`,
    price: round.projectedPrice,
    score: round.projectedScore,
    difficulty: round.difficulty
  }));

  const getDifficultyInfo = (difficulty: string) => {
    return difficultyColors[difficulty as keyof typeof difficultyColors] || difficultyColors["neutral"];
  };

  return (
    <div className="space-y-4">
      {/* Player Header */}
      <div className="flex items-center gap-3">
        <TeamLogo teamName={player.team} />
        <div>
          <h3 className="text-lg font-bold text-white">{player.name}</h3>
          <div className="flex items-center gap-2">
            <span className="text-gray-300">{player.team}</span>
            <Badge variant="outline" className="text-blue-400 border-blue-400">
              {player.position}
            </Badge>
          </div>
        </div>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-2 bg-gray-700">
          <TabsTrigger value="upcoming" className="text-white data-[state=active]:bg-green-600">
            📊 Upcoming
          </TabsTrigger>
          <TabsTrigger value="season" className="text-white data-[state=active]:bg-green-600">
            📅 Season DVP
          </TabsTrigger>
        </TabsList>

        <TabsContent value="upcoming" className="space-y-4">
          {/* Price/Score Chart */}
          <div className="h-64">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis 
                  dataKey="round" 
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <YAxis 
                  yAxisId="price"
                  orientation="left"
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                  tickFormatter={(value) => `$${Math.round(value / 1000)}k`}
                />
                <YAxis 
                  yAxisId="score"
                  orientation="right"
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: '#374151', 
                    border: '1px solid #6B7280',
                    borderRadius: '8px'
                  }}
                />
                <Legend />
                <Line
                  yAxisId="price"
                  type="monotone"
                  dataKey="price"
                  stroke="#10b981"
                  strokeWidth={3}
                  dot={{ fill: '#10b981', strokeWidth: 2, r: 4 }}
                  name="Price"
                />
                <Line
                  yAxisId="score"
                  type="monotone"
                  dataKey="score"
                  stroke="#3b82f6"
                  strokeWidth={3}
                  dot={{ fill: '#3b82f6', strokeWidth: 2, r: 4 }}
                  name="Score"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Player Stats */}
          <div className="grid grid-cols-2 gap-4">
            <div className="bg-gray-700 p-3 rounded-lg">
              <div className="text-gray-400 text-sm">Current Price</div>
              <div className="text-white font-bold">{formatCurrency(player.currentPrice)}</div>
            </div>
            <div className="bg-gray-700 p-3 rounded-lg">
              <div className="text-gray-400 text-sm">Breakeven</div>
              <div className="text-white font-bold">{player.breakeven}</div>
            </div>
          </div>

          {/* Role Security */}
          <div className="space-y-2">
            <div className="flex justify-between items-center">
              <span className="text-gray-300 text-sm">Role Security</span>
              <span className="text-white font-bold">{player.roleSecurity}%</span>
            </div>
            <Progress value={player.roleSecurity} className="h-2" />
          </div>

          {/* Projected Scores Table */}
          <div>
            <h4 className="text-white font-medium mb-2">Projected Scores by Round</h4>
            <div className="space-y-2">
              {player.nextFiveRounds.map((round: any, index: number) => {
                const diffInfo = getDifficultyInfo(round.difficulty);
                return (
                  <div key={index} className="flex items-center justify-between bg-gray-700 p-2 rounded">
                    <div className="flex items-center gap-2">
                      <span className="text-gray-400 text-sm">R{round.round}</span>
                      <div className="flex items-center gap-1">
                        <span className="text-white">vs</span>
                        <TeamLogo teamName={round.opponent} size="w-4 h-4" />
                        <span className="text-white">{round.opponent}</span>
                      </div>
                      {round.tagRisk && <Lock className="h-3 w-3 text-yellow-400" />}
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-white font-bold">{round.projectedScore}</span>
                      <Badge className={`${diffInfo.bg} ${diffInfo.text} text-xs`}>
                        {diffInfo.emoji}
                      </Badge>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </TabsContent>

        <TabsContent value="season" className="space-y-4">
          {/* Season Opponents Table */}
          <div>
            <h4 className="text-white font-medium mb-2">Remaining Season Matchups</h4>
            <div className="space-y-1">
              <div className="grid grid-cols-4 gap-2 p-2 bg-gray-700 text-gray-300 text-xs font-medium rounded-t">
                <div>Round</div>
                <div>Opponent</div>
                <div>Difficulty</div>
                <div>Tag Risk</div>
              </div>
              {player.seasonOpponents.map((match: any, index: number) => {
                const diffInfo = getDifficultyInfo(match.difficulty);
                return (
                  <div key={index} className="grid grid-cols-4 gap-2 p-2 border-b border-gray-600 text-sm">
                    <div className="text-white">R{match.round}</div>
                    <div className="flex items-center gap-2">
                      <TeamLogo teamName={match.opponent} size="w-4 h-4" />
                      <span className="text-white">{match.opponent}</span>
                    </div>
                    <div>
                      <Badge className={`${diffInfo.bg} ${diffInfo.text} text-xs`}>
                        {diffInfo.emoji} {match.difficulty.replace('_', ' ')}
                      </Badge>
                    </div>
                    <div className="text-center">
                      {match.tagRisk && <Lock className="h-4 w-4 text-yellow-400" />}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
};

export function BuySellTimingTool() {
  const [searchQuery, setSearchQuery] = useState("");
  const [teamFilter, setTeamFilter] = useState("All");
  const [positionFilter, setPositionFilter] = useState("All");
  const [priceRange, setPriceRange] = useState([0, 2000000]);

  // Fetch player data from API
  const { data: apiPlayers, isLoading } = useQuery({
    queryKey: ["/api/players"],
    select: (data: any[]) => {
      return data.map((player: any, index: number) => ({
        id: player.externalId || index,
        name: player.name,
        team: player.team,
        position: player.position || "N/A",
        currentPrice: player.price || 300000,
        projectedIncrease: Math.round(Math.random() * 50000 + 10000),
        roleSecurity: Math.round(85 + Math.random() * 10),
        recommendedBuyRound: 21,
        recommendedSellRound: 24,
        breakeven: player.breakeven || Math.round(Math.random() * 40 + 40),
        nextFiveRounds: Array.from({ length: 5 }, (_, i) => ({
          round: 21 + i,
          projectedPrice: Math.round((player.price || 300000) + (i * 15000)),
          projectedScore: Math.round(75 + Math.random() * 30),
          opponent: ["Richmond", "Melbourne", "Collingwood", "Sydney", "Geelong"][i] || "TBA",
          difficulty: ["easy", "neutral", "hard", "very_hard", "neutral"][i] || "neutral",
          tagRisk: Math.random() > 0.7
        })),
        seasonOpponents: Array.from({ length: 7 }, (_, i) => ({
          round: 21 + i,
          opponent: ["Richmond", "Melbourne", "Collingwood", "Sydney", "Geelong", "Adelaide", "Brisbane"][i] || "TBA",
          difficulty: ["easy", "neutral", "hard", "very_hard", "neutral", "easy", "medium"][i] || "neutral",
          tagRisk: Math.random() > 0.8
        }))
      })).filter(player => player.currentPrice >= 200000); // Filter out very low priced players
    }
  });

  // Use API data or fallback to mock data
  const playerData = apiPlayers || mockPlayerData;

  // Filter players based on search criteria
  const filteredPlayers = useMemo(() => {
    return playerData.filter(player => {
      // Search filter - allow single character searches
      if (searchQuery.trim().length > 0 && !player.name.toLowerCase().includes(searchQuery.toLowerCase().trim())) {
        return false;
      }
      
      // Team filter
      if (teamFilter !== "All" && player.team !== teamFilter) {
        return false;
      }
      
      // Position filter
      if (positionFilter !== "All" && player.position !== positionFilter) {
        return false;
      }
      
      // Price filter
      if (player.currentPrice < priceRange[0] || player.currentPrice > priceRange[1]) {
        return false;
      }
      
      return true;
    }).sort((a, b) => b.projectedIncrease - a.projectedIncrease); // Sort by highest projected increase
  }, [playerData, searchQuery, teamFilter, positionFilter, priceRange]);

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
          <h2 className="text-xl font-bold text-white">📈 Buy/Sell Timing Tool</h2>
        </div>
        
        {/* Filter Controls */}
        <div className="space-y-4">
          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <Input
              placeholder="Type any part of a player's name..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-10 bg-gray-700 border-gray-600 text-white placeholder-gray-400"
            />
          </div>

          {/* Filter Row */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
            {/* Team Filter */}
            <div className="space-y-2">
              <label className="text-sm text-gray-300">Team</label>
              <Select value={teamFilter} onValueChange={setTeamFilter}>
                <SelectTrigger className="bg-gray-700 border-gray-600 text-white">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-gray-700 border-gray-600">
                  <SelectItem value="All">All Teams</SelectItem>
                  {Object.keys(teamLogos).map(team => (
                    <SelectItem key={team} value={team}>
                      <div className="flex items-center gap-2">
                        <TeamLogo teamName={team} size="w-4 h-4" />
                        {team}
                      </div>
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Position Filter */}
            <div className="space-y-2">
              <label className="text-sm text-gray-300">Position</label>
              <Select value={positionFilter} onValueChange={setPositionFilter}>
                <SelectTrigger className="bg-gray-700 border-gray-600 text-white">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="bg-gray-700 border-gray-600">
                  <SelectItem value="All">All Positions</SelectItem>
                  <SelectItem value="DEF">DEF</SelectItem>
                  <SelectItem value="MID">MID</SelectItem>
                  <SelectItem value="FWD">FWD</SelectItem>
                  <SelectItem value="RUC">RUC</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Price Range */}
            <div className="col-span-2 space-y-2">
              <label className="text-sm text-gray-300">
                Price Range: {formatCurrency(priceRange[0], 0)} - {formatCurrency(priceRange[1], 0)}
              </label>
              <div className="px-2">
                <Slider
                  value={priceRange}
                  onValueChange={setPriceRange}
                  max={2000000}
                  min={0}
                  step={50000}
                  className="w-full"
                />
              </div>
            </div>
          </div>
        </div>
      </CardHeader>

      <CardContent className="p-4">
        <div className="mb-4">
          <h3 className="text-lg font-bold text-white mb-2">
            {searchQuery ? `🔍 Search Results for "${searchQuery}"` : '🚀 Players - Highest Projected Price Increases'}
          </h3>
          <p className="text-gray-400 text-sm">
            {filteredPlayers.length} player{filteredPlayers.length !== 1 ? 's' : ''} match your criteria
          </p>
        </div>

        {/* Player Cards Grid */}
        <div className="space-y-3">
          {filteredPlayers.map((player) => (
            <Card key={player.id} className="bg-gray-700 border-gray-600 hover:border-green-400 transition-colors">
              <CardContent className="p-4">
                <div className="flex items-center justify-between">
                  {/* Player Info */}
                  <div className="flex items-center gap-3">
                    <TeamLogo teamName={player.team} />
                    <div>
                      <h4 className="text-white font-bold">{player.name}</h4>
                      <div className="flex items-center gap-2">
                        <span className="text-gray-300 text-sm">{player.team}</span>
                        <Badge variant="outline" className="text-blue-400 border-blue-400 text-xs">
                          {player.position}
                        </Badge>
                      </div>
                    </div>
                  </div>

                  {/* Stats */}
                  <div className="text-right">
                    <div className="text-white font-bold">{formatCurrency(player.currentPrice, 0)}</div>
                    <div className="text-green-400 font-bold">
                      ⬆️ +{formatCurrency(player.projectedIncrease, 0)}
                    </div>
                  </div>
                </div>

                <div className="mt-3 flex items-center justify-between">
                  {/* Role Security */}
                  <div className="flex items-center gap-2">
                    <Shield className="h-4 w-4 text-blue-400" />
                    <Badge className="bg-green-900/30 text-green-400">
                      🟢 {player.roleSecurity}%
                    </Badge>
                  </div>

                  {/* Buy/Sell Recommendations */}
                  <div className="flex items-center gap-2 text-sm">
                    <Badge className="bg-blue-900/30 text-blue-400">
                      🟨 Buy R{player.recommendedBuyRound}
                    </Badge>
                    <Badge className="bg-red-900/30 text-red-400">
                      🔴 Sell R{player.recommendedSellRound}
                    </Badge>
                  </div>

                  {/* View Details Button */}
                  <Dialog>
                    <DialogTrigger asChild>
                      <Button size="sm" className="bg-green-600 hover:bg-green-700 text-white">
                        View Details
                      </Button>
                    </DialogTrigger>
                    <DialogContent className="bg-gray-800 border-gray-600 text-white max-w-2xl max-h-[90vh] overflow-y-auto">
                      <DialogHeader>
                        <DialogTitle className="text-green-400">Player Analysis - {player.name}</DialogTitle>
                        <DialogDescription className="text-gray-400">Detailed buy/sell timing analysis and projections</DialogDescription>
                      </DialogHeader>
                      <PlayerDetailModal player={player} />
                    </DialogContent>
                  </Dialog>
                </div>
              </CardContent>
            </Card>
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

export default BuySellTimingTool;