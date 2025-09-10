import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Progress } from "@/components/ui/progress";
import { formatCurrency, formatScore } from "@/lib/utils";
import {
  Calculator,
  Search,
  Trash2,
  TrendingUp,
  LineChart,
  DollarSign,
  ChevronDown,
  ChevronUp,
  BarChart2,
  ArrowRight,
  Star
} from "lucide-react";

type Player = {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  averagePoints: number;
  projectedPoints: number;
  valuePerPoint: number;
  roi: number;
  breakEven: number;
  upside: number;
  consistency: number;
  fixtureRating: number;
};

type ROIAnalysis = {
  projectedPointsGain: number;
  valueInvestment: number;
  rawROI: number;
  adjustedROI: number;
  breakEvenRounds: number;
  payoffRating: string;
  confidenceScore: number;
  riskLevel: string;
  recommendation: string;
};

export function TradeReturnAnalyzer() {
  const [playerOut, setPlayerOut] = useState<Player | null>(null);
  const [playerIn, setPlayerIn] = useState<Player | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<Player[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [searchingFor, setSearchingFor] = useState<"in" | "out">("out");
  const [showResults, setShowResults] = useState(false);
  const [roundsToAnalyze, setRoundsToAnalyze] = useState(5);
  const [tradeAnalysis, setTradeAnalysis] = useState<ROIAnalysis | null>(null);

  // Mock data for player search
  const mockPlayers: Player[] = [
    {
      id: 1,
      name: "Marcus Bontempelli",
      position: "MID",
      team: "WB",
      price: 962000,
      averagePoints: 115.3,
      projectedPoints: 118.5,
      valuePerPoint: 8344,
      roi: 0.123,
      breakEven: 105,
      upside: 145,
      consistency: 92,
      fixtureRating: 4.2
    },
    {
      id: 2,
      name: "Nick Daicos",
      position: "MID",
      team: "COLL",
      price: 1020000,
      averagePoints: 128.2,
      projectedPoints: 132.4,
      valuePerPoint: 7957,
      roi: 0.129,
      breakEven: 115,
      upside: 150,
      consistency: 95,
      fixtureRating: 4.5
    },
    {
      id: 3,
      name: "Clayton Oliver",
      position: "MID",
      team: "MELB",
      price: 856000,
      averagePoints: 96.4, 
      projectedPoints: 102.6,
      valuePerPoint: 8881,
      roi: 0.119,
      breakEven: 105,
      upside: 125,
      consistency: 82,
      fixtureRating: 3.8
    },
    {
      id: 4,
      name: "Charlie Curnow",
      position: "FWD",
      team: "CARL",
      price: 825000,
      averagePoints: 92.4,
      projectedPoints: 96.8,
      valuePerPoint: 8934,
      roi: 0.117,
      breakEven: 85,
      upside: 120,
      consistency: 78,
      fixtureRating: 4.0
    },
    {
      id: 5,
      name: "Tim English",
      position: "RUCK",
      team: "WB", 
      price: 978000,
      averagePoints: 115.6,
      projectedPoints: 112.3,
      valuePerPoint: 8459,
      roi: 0.114,
      breakEven: 95,
      upside: 135,
      consistency: 88,
      fixtureRating: 4.2
    },
    {
      id: 6,
      name: "Toby Greene",
      position: "FWD",
      team: "GWS",
      price: 782000,
      averagePoints: 88.2,
      projectedPoints: 91.4,
      valuePerPoint: 8870,
      roi: 0.117,
      breakEven: 98,
      upside: 110,
      consistency: 76,
      fixtureRating: 3.6
    },
    {
      id: 7,
      name: "Errol Gulden",
      position: "MID",
      team: "SYD",
      price: 915000,
      averagePoints: 128.3,
      projectedPoints: 122.7,
      valuePerPoint: 7130,
      roi: 0.134,
      breakEven: 110,
      upside: 140,
      consistency: 90,
      fixtureRating: 4.3
    },
    {
      id: 8,
      name: "Tom Stewart",
      position: "DEF",
      team: "GEEL",
      price: 688000,
      averagePoints: 82.1,
      projectedPoints: 84.6,
      valuePerPoint: 8384,
      roi: 0.123,
      breakEven: 95,
      upside: 105,
      consistency: 86,
      fixtureRating: 3.7
    },
    {
      id: 9,
      name: "Jordan Ridley",
      position: "DEF",
      team: "ESS",
      price: 742000,
      averagePoints: 88.5,
      projectedPoints: 91.3,
      valuePerPoint: 8384,
      roi: 0.123,
      breakEven: 75,
      upside: 110,
      consistency: 84,
      fixtureRating: 3.9
    },
    {
      id: 10,
      name: "Izak Rankine",
      position: "FWD",
      team: "ADEL",
      price: 745000,
      averagePoints: 82.5,
      projectedPoints: 89.3,
      valuePerPoint: 9030,
      roi: 0.119,
      breakEven: 65,
      upside: 115,
      consistency: 72,
      fixtureRating: 4.1
    }
  ];

  // Handle search
  const handleSearch = () => {
    if (searchQuery.length < 2) return;
    
    setIsSearching(true);
    setShowResults(true);
    
    // Simulating API call
    setTimeout(() => {
      const results = mockPlayers.filter(player =>
        player.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        player.position.toLowerCase().includes(searchQuery.toLowerCase()) ||
        player.team.toLowerCase().includes(searchQuery.toLowerCase())
      );
      
      setSearchResults(results);
      setIsSearching(false);
    }, 500);
  };

  // Select player
  const handleSelectPlayer = (player: Player) => {
    if (searchingFor === "out") {
      setPlayerOut(player);
    } else {
      setPlayerIn(player);
    }
    
    setShowResults(false);
    setSearchQuery("");
    
    // If both players are selected, analyze trade
    if ((searchingFor === "out" && playerIn) || (searchingFor === "in" && playerOut)) {
      setTimeout(() => analyzeROI(), 300);
    }
  };

  // Clear player
  const handleClearPlayer = (type: "in" | "out") => {
    if (type === "in") {
      setPlayerIn(null);
    } else {
      setPlayerOut(null);
    }
    
    setTradeAnalysis(null);
  };

  // Analyze ROI
  const analyzeROI = () => {
    if (!playerIn || !playerOut) return;
    
    // Calculate projected points difference over analysis period
    const pointsDifference = playerIn.projectedPoints - playerOut.projectedPoints;
    const totalPointsGain = pointsDifference * roundsToAnalyze;
    
    // Calculate value investment (negative if making money)
    const valueInvestment = playerIn.price - playerOut.price;
    
    // Raw ROI calculation (points gained per dollar invested)
    const rawROI = valueInvestment !== 0 ? totalPointsGain / Math.abs(valueInvestment) * 100 : 0;
    
    // Adjusted ROI factoring in consistency, fixture difficulty and upside potential
    const consistencyFactor = (playerIn.consistency - playerOut.consistency) * 0.005;
    const fixtureFactor = (playerIn.fixtureRating - playerOut.fixtureRating) * 0.01;
    const upsideFactor = ((playerIn.upside - playerIn.projectedPoints) - 
                          (playerOut.upside - playerOut.projectedPoints)) * 0.002;
    
    const adjustedROI = rawROI * (1 + consistencyFactor + fixtureFactor + upsideFactor);
    
    // Break-even round calculation (when point gains offset the price difference)
    const pointsPerRound = pointsDifference;
    const breakEvenRounds = pointsPerRound > 0 ? Math.ceil(Math.abs(valueInvestment) / (pointsPerRound * 1000)) : 999;
    
    // Confidence score based on player consistency and fixture ratings
    const confidenceScore = (
      (playerIn.consistency / 100) * 0.4 +
      (playerIn.fixtureRating / 5) * 0.3 +
      (Math.min(1, 1 / (breakEvenRounds / roundsToAnalyze))) * 0.3
    ) * 100;
    
    // Risk level based on value investment and confidence
    let riskLevel;
    if (confidenceScore > 85) riskLevel = "Very Low";
    else if (confidenceScore > 70) riskLevel = "Low";
    else if (confidenceScore > 55) riskLevel = "Moderate";
    else if (confidenceScore > 40) riskLevel = "High";
    else riskLevel = "Very High";
    
    // Payoff rating based on ROI and break-even rounds
    let payoffRating;
    if (adjustedROI > 0.2 && breakEvenRounds <= roundsToAnalyze / 2) payoffRating = "Excellent";
    else if (adjustedROI > 0.1 && breakEvenRounds <= roundsToAnalyze) payoffRating = "Good";
    else if (adjustedROI > 0 && breakEvenRounds <= roundsToAnalyze * 1.5) payoffRating = "Fair";
    else if (adjustedROI <= 0) payoffRating = "Poor";
    else payoffRating = "Questionable";
    
    // Generate recommendation
    let recommendation;
    if (payoffRating === "Excellent" && riskLevel !== "Very High") 
      recommendation = "Strongly Recommended";
    else if (payoffRating === "Good" && (riskLevel === "Low" || riskLevel === "Very Low"))
      recommendation = "Recommended";
    else if (payoffRating === "Fair" && riskLevel !== "Very High")
      recommendation = "Consider";
    else if (valueInvestment < 0 && pointsDifference > 0)
      recommendation = "Value Trade";
    else
      recommendation = "Not Recommended";
    
    // Set analysis results
    setTradeAnalysis({
      projectedPointsGain: totalPointsGain,
      valueInvestment,
      rawROI,
      adjustedROI,
      breakEvenRounds,
      payoffRating,
      confidenceScore,
      riskLevel,
      recommendation
    });
  };

  // Render recommendation badge
  const renderRecommendationBadge = () => {
    if (!tradeAnalysis) return null;
    
    const { recommendation } = tradeAnalysis;
    let bgColor, textColor;
    
    switch (recommendation) {
      case "Strongly Recommended":
        bgColor = "bg-green-100";
        textColor = "text-green-800";
        break;
      case "Recommended":
        bgColor = "bg-emerald-100";
        textColor = "text-emerald-800";
        break;
      case "Consider":
        bgColor = "bg-blue-100";
        textColor = "text-blue-800";
        break;
      case "Value Trade":
        bgColor = "bg-purple-100";
        textColor = "text-purple-800";
        break;
      default:
        bgColor = "bg-red-100";
        textColor = "text-red-800";
    }
    
    return (
      <div className={`px-3 py-1 rounded-full text-sm font-medium ${bgColor} ${textColor}`}>
        {recommendation}
      </div>
    );
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <Calculator className="h-5 w-5 text-primary" />
        <h3 className="text-lg font-medium">Trade Return Analyzer</h3>
      </div>
      
      <p className="text-sm text-gray-600">
        Analyze the return on investment for a potential trade. This tool calculates when your trade will "break even" 
        and how much value you'll gain over a selected timeframe.
      </p>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-3">
          <div className="bg-white rounded-md border overflow-hidden">
            <div className="bg-gray-50 py-2 px-3 border-b">
              <h4 className="font-medium">Player to Trade Out</h4>
            </div>
            
            <div className="p-3">
              {playerOut ? (
                <div className="bg-gray-50 rounded-md p-3 relative">
                  <Button
                    variant="ghost"
                    size="sm"
                    className="absolute right-2 top-2 h-7 w-7 p-0"
                    onClick={() => handleClearPlayer("out")}
                  >
                    <Trash2 className="h-4 w-4 text-gray-500" />
                  </Button>
                  
                  <div className="flex flex-col gap-2">
                    <div>
                      <div className="font-medium flex items-center">
                        {playerOut.name}
                        <span className="text-xs text-gray-500 ml-1">({playerOut.team})</span>
                      </div>
                      <div className="text-xs text-gray-500">
                        {playerOut.position} | {formatCurrency(playerOut.price)}
                      </div>
                    </div>
                    
                    <div className="grid grid-cols-3 gap-2 text-sm">
                      <div>
                        <div className="text-xs text-gray-500">Avg.</div>
                        <div className="font-medium">{playerOut.averagePoints.toFixed(1)}</div>
                      </div>
                      <div>
                        <div className="text-xs text-gray-500">Proj.</div>
                        <div className="font-medium">{playerOut.projectedPoints.toFixed(1)}</div>
                      </div>
                      <div>
                        <div className="text-xs text-gray-500">BE</div>
                        <div className="font-medium">{playerOut.breakEven}</div>
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center py-6 bg-gray-50 rounded-md">
                  <button
                    className="flex items-center gap-2 text-sm font-medium text-primary hover:text-primary-dark"
                    onClick={() => {
                      setSearchingFor("out");
                      setSearchQuery("");
                      setShowResults(false);
                    }}
                  >
                    <Search className="h-4 w-4" />
                    <span>Select Player to Trade Out</span>
                  </button>
                </div>
              )}
              
              {!playerOut && searchingFor === "out" && (
                <div className="mt-3">
                  <div className="flex gap-2 mb-2">
                    <Input
                      placeholder="Search players..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="flex-1"
                      onKeyDown={(e) => {
                        if (e.key === "Enter") handleSearch();
                      }}
                    />
                    <Button onClick={handleSearch} disabled={isSearching || searchQuery.length < 2}>
                      {isSearching ? (
                        <div className="h-4 w-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                      ) : (
                        <Search className="h-4 w-4" />
                      )}
                    </Button>
                  </div>
                  
                  {showResults && (
                    <div className="border rounded-md overflow-hidden max-h-64 overflow-y-auto">
                      {searchResults.length === 0 ? (
                        <div className="p-3 text-center text-sm text-gray-500">
                          No players found
                        </div>
                      ) : (
                        <div className="divide-y">
                          {searchResults.map(player => (
                            <div
                              key={player.id}
                              className="p-2 hover:bg-gray-50 cursor-pointer flex justify-between items-center"
                              onClick={() => handleSelectPlayer(player)}
                            >
                              <div>
                                <div className="font-medium text-sm">{player.name}</div>
                                <div className="text-xs text-gray-500">
                                  {player.position} | {player.team} | {formatCurrency(player.price)}
                                </div>
                              </div>
                              <div className="text-right text-sm">
                                <div className="font-medium">{player.projectedPoints.toFixed(1)}</div>
                                <div className="text-xs text-gray-500">Proj. pts</div>
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
          
          <div className="bg-white rounded-md border overflow-hidden">
            <div className="bg-gray-50 py-2 px-3 border-b">
              <h4 className="font-medium">Player to Trade In</h4>
            </div>
            
            <div className="p-3">
              {playerIn ? (
                <div className="bg-gray-50 rounded-md p-3 relative">
                  <Button
                    variant="ghost"
                    size="sm"
                    className="absolute right-2 top-2 h-7 w-7 p-0"
                    onClick={() => handleClearPlayer("in")}
                  >
                    <Trash2 className="h-4 w-4 text-gray-500" />
                  </Button>
                  
                  <div className="flex flex-col gap-2">
                    <div>
                      <div className="font-medium flex items-center">
                        {playerIn.name}
                        <span className="text-xs text-gray-500 ml-1">({playerIn.team})</span>
                      </div>
                      <div className="text-xs text-gray-500">
                        {playerIn.position} | {formatCurrency(playerIn.price)}
                      </div>
                    </div>
                    
                    <div className="grid grid-cols-3 gap-2 text-sm">
                      <div>
                        <div className="text-xs text-gray-500">Avg.</div>
                        <div className="font-medium">{playerIn.averagePoints.toFixed(1)}</div>
                      </div>
                      <div>
                        <div className="text-xs text-gray-500">Proj.</div>
                        <div className="font-medium">{playerIn.projectedPoints.toFixed(1)}</div>
                      </div>
                      <div>
                        <div className="text-xs text-gray-500">BE</div>
                        <div className="font-medium">{playerIn.breakEven}</div>
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center py-6 bg-gray-50 rounded-md">
                  <button
                    className="flex items-center gap-2 text-sm font-medium text-primary hover:text-primary-dark"
                    onClick={() => {
                      setSearchingFor("in");
                      setSearchQuery("");
                      setShowResults(false);
                    }}
                  >
                    <Search className="h-4 w-4" />
                    <span>Select Player to Trade In</span>
                  </button>
                </div>
              )}
              
              {!playerIn && searchingFor === "in" && (
                <div className="mt-3">
                  <div className="flex gap-2 mb-2">
                    <Input
                      placeholder="Search players..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="flex-1"
                      onKeyDown={(e) => {
                        if (e.key === "Enter") handleSearch();
                      }}
                    />
                    <Button onClick={handleSearch} disabled={isSearching || searchQuery.length < 2}>
                      {isSearching ? (
                        <div className="h-4 w-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                      ) : (
                        <Search className="h-4 w-4" />
                      )}
                    </Button>
                  </div>
                  
                  {showResults && (
                    <div className="border rounded-md overflow-hidden max-h-64 overflow-y-auto">
                      {searchResults.length === 0 ? (
                        <div className="p-3 text-center text-sm text-gray-500">
                          No players found
                        </div>
                      ) : (
                        <div className="divide-y">
                          {searchResults.map(player => (
                            <div
                              key={player.id}
                              className="p-2 hover:bg-gray-50 cursor-pointer flex justify-between items-center"
                              onClick={() => handleSelectPlayer(player)}
                            >
                              <div>
                                <div className="font-medium text-sm">{player.name}</div>
                                <div className="text-xs text-gray-500">
                                  {player.position} | {player.team} | {formatCurrency(player.price)}
                                </div>
                              </div>
                              <div className="text-right text-sm">
                                <div className="font-medium">{player.projectedPoints.toFixed(1)}</div>
                                <div className="text-xs text-gray-500">Proj. pts</div>
                              </div>
                            </div>
                          ))}
                        </div>
                      )}
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
          
          <div className="bg-white rounded-md border overflow-hidden">
            <div className="bg-gray-50 py-2 px-3 border-b flex justify-between items-center">
              <h4 className="font-medium">Analysis Settings</h4>
            </div>
            
            <div className="p-3">
              <div className="flex flex-col gap-2">
                <div>
                  <label className="text-sm font-medium mb-1 block">Analyze over how many rounds?</label>
                  <div className="flex gap-2">
                    {[3, 5, 8, 12].map(num => (
                      <Button
                        key={num}
                        variant={roundsToAnalyze === num ? "default" : "outline"}
                        size="sm"
                        className="flex-1"
                        onClick={() => {
                          setRoundsToAnalyze(num);
                          if (playerIn && playerOut) analyzeROI();
                        }}
                      >
                        {num}
                      </Button>
                    ))}
                  </div>
                </div>
                
                <div className="mt-2">
                  <Button
                    className="w-full"
                    disabled={!playerIn || !playerOut}
                    onClick={analyzeROI}
                  >
                    <Calculator className="h-4 w-4 mr-2" />
                    Calculate Return
                  </Button>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div className="space-y-3">
          {playerIn && playerOut && tradeAnalysis ? (
            <>
              <div className="bg-white rounded-md border overflow-hidden">
                <div className="bg-gray-50 py-2 px-3 border-b flex justify-between items-center">
                  <h4 className="font-medium">Trade Analysis</h4>
                  <div className="flex items-center gap-2">
                    {renderRecommendationBadge()}
                  </div>
                </div>
                
                <div className="p-3">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="flex-1 bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-sm text-gray-500 mb-1">Analyzing over</div>
                      <div className="font-medium">{roundsToAnalyze} rounds</div>
                    </div>
                    
                    <ArrowRight className="h-4 w-4 text-gray-400" />
                    
                    <div className="flex-1 bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-sm text-gray-500 mb-1">Break-even at</div>
                      <div className={`font-medium ${tradeAnalysis.breakEvenRounds > roundsToAnalyze ? 'text-red-600' : 'text-green-600'}`}>
                        {tradeAnalysis.breakEvenRounds >= 999 ? 'Never' : `Round ${tradeAnalysis.breakEvenRounds}`}
                      </div>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4 mb-4">
                    <div className="bg-gray-50 rounded-md p-2">
                      <div className="text-xs text-gray-500 mb-1">Total Points Gain</div>
                      <div className={`font-medium ${tradeAnalysis.projectedPointsGain > 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {tradeAnalysis.projectedPointsGain > 0 ? '+' : ''}{tradeAnalysis.projectedPointsGain.toFixed(1)}
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-2">
                      <div className="text-xs text-gray-500 mb-1">Value Investment</div>
                      <div className={`font-medium ${tradeAnalysis.valueInvestment <= 0 ? 'text-green-600' : 'text-gray-700'}`}>
                        {formatCurrency(tradeAnalysis.valueInvestment)}
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-2">
                      <div className="text-xs text-gray-500 mb-1">Adjusted ROI</div>
                      <div className={`font-medium ${tradeAnalysis.adjustedROI > 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {(tradeAnalysis.adjustedROI).toFixed(2)}%
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-2">
                      <div className="text-xs text-gray-500 mb-1">Confidence Score</div>
                      <div className="font-medium">
                        {tradeAnalysis.confidenceScore.toFixed(0)}%
                      </div>
                      <div className="mt-1">
                        <Progress value={tradeAnalysis.confidenceScore} className="h-1" />
                      </div>
                    </div>
                  </div>
                  
                  <div className="grid grid-cols-2 gap-4 mb-4">
                    <div className="bg-gray-50 rounded-md p-2">
                      <div className="text-xs text-gray-500 mb-1">Payoff Rating</div>
                      <div className="font-medium">{tradeAnalysis.payoffRating}</div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-2">
                      <div className="text-xs text-gray-500 mb-1">Risk Level</div>
                      <div className={`font-medium 
                        ${tradeAnalysis.riskLevel === "Very Low" ? "text-green-600" : 
                          tradeAnalysis.riskLevel === "Low" ? "text-emerald-600" :
                          tradeAnalysis.riskLevel === "Moderate" ? "text-amber-600" :
                          tradeAnalysis.riskLevel === "High" ? "text-orange-600" :
                          "text-red-600"}`
                      }>
                        {tradeAnalysis.riskLevel}
                      </div>
                    </div>
                  </div>
                  
                  <div className="bg-blue-50 rounded-md p-3 text-blue-700">
                    <div className="text-sm font-medium mb-1 flex items-center gap-1">
                      <Star className="h-4 w-4 text-yellow-500" />
                      AI Recommendation
                    </div>
                    <p className="text-sm">
                      {tradeAnalysis.recommendation === "Strongly Recommended" && 
                        `This trade provides excellent value over the ${roundsToAnalyze}-round analysis period. 
                         The projected points gain of ${tradeAnalysis.projectedPointsGain.toFixed(1)} 
                         makes this a high-impact move for your team.`
                      }
                      
                      {tradeAnalysis.recommendation === "Recommended" && 
                        `This trade offers good value with ${tradeAnalysis.projectedPointsGain.toFixed(1)} 
                         projected points gain over ${roundsToAnalyze} rounds. The risk level is manageable 
                         and the return on investment is solid.`
                      }
                      
                      {tradeAnalysis.recommendation === "Consider" && 
                        `This trade has moderate value with ${tradeAnalysis.projectedPointsGain.toFixed(1)} 
                         projected points gain over ${roundsToAnalyze} rounds. Consider your team's specific 
                         needs before proceeding.`
                      }
                      
                      {tradeAnalysis.recommendation === "Value Trade" && 
                        `While gaining ${tradeAnalysis.projectedPointsGain.toFixed(1)} points, this trade 
                         will also save you ${formatCurrency(Math.abs(tradeAnalysis.valueInvestment))} in 
                         salary cap, making it a good value move.`
                      }
                      
                      {tradeAnalysis.recommendation === "Not Recommended" && 
                        `This trade doesn't provide enough value over the ${roundsToAnalyze}-round period 
                         to justify the investment. Consider alternative trade options or wait for a more 
                         favorable opportunity.`
                      }
                    </p>
                  </div>
                </div>
              </div>
              
              <div className="bg-white rounded-md border overflow-hidden">
                <div className="bg-gray-50 py-2 px-3 border-b">
                  <h4 className="font-medium">Trade Comparison</h4>
                </div>
                
                <div className="p-3">
                  <div className="grid grid-cols-3 gap-2 text-sm">
                    <div className="bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-xs text-gray-500 mb-1">{playerOut?.name}</div>
                      <div className="font-medium">{playerOut?.projectedPoints.toFixed(1)}</div>
                      <div className="text-xs text-gray-500">points/game</div>
                    </div>
                    
                    <div className="flex items-center justify-center">
                      <div className={`text-sm font-medium ${(playerIn?.projectedPoints || 0) > (playerOut?.projectedPoints || 0) ? 'text-green-600' : 'text-red-600'} flex items-center`}>
                        {(playerIn?.projectedPoints || 0) > (playerOut?.projectedPoints || 0) ? (
                          <>
                            <ChevronUp className="h-4 w-4" />
                            +{((playerIn?.projectedPoints || 0) - (playerOut?.projectedPoints || 0)).toFixed(1)}
                          </>
                        ) : (
                          <>
                            <ChevronDown className="h-4 w-4" />
                            {((playerIn?.projectedPoints || 0) - (playerOut?.projectedPoints || 0)).toFixed(1)}
                          </>
                        )}
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-xs text-gray-500 mb-1">{playerIn?.name}</div>
                      <div className="font-medium">{playerIn?.projectedPoints.toFixed(1)}</div>
                      <div className="text-xs text-gray-500">points/game</div>
                    </div>
                  </div>
                  
                  <div className="mt-3 grid grid-cols-3 gap-2 text-sm">
                    <div className="bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-xs text-gray-500 mb-1">Value</div>
                      <div className="font-medium">{formatCurrency(playerOut?.price || 0)}</div>
                    </div>
                    
                    <div className="flex items-center justify-center">
                      <div className={`text-sm font-medium ${(playerIn?.price || 0) > (playerOut?.price || 0) ? 'text-red-600' : 'text-green-600'} flex items-center`}>
                        {(playerIn?.price || 0) > (playerOut?.price || 0) ? (
                          <>
                            <ChevronUp className="h-4 w-4" />
                            +{formatCurrency((playerIn?.price || 0) - (playerOut?.price || 0))}
                          </>
                        ) : (
                          <>
                            <ChevronDown className="h-4 w-4" />
                            {formatCurrency((playerIn?.price || 0) - (playerOut?.price || 0))}
                          </>
                        )}
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-xs text-gray-500 mb-1">Value</div>
                      <div className="font-medium">{formatCurrency(playerIn?.price || 0)}</div>
                    </div>
                  </div>
                  
                  <div className="mt-3 grid grid-cols-3 gap-2 text-sm">
                    <div className="bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-xs text-gray-500 mb-1">$/Point</div>
                      <div className="font-medium">{formatCurrency(playerOut?.valuePerPoint || 0)}</div>
                    </div>
                    
                    <div className="flex items-center justify-center">
                      <div className={`text-sm font-medium ${(playerIn?.valuePerPoint || 0) > (playerOut?.valuePerPoint || 0) ? 'text-red-600' : 'text-green-600'} flex items-center`}>
                        {(playerIn?.valuePerPoint || 0) > (playerOut?.valuePerPoint || 0) ? (
                          <>
                            <ChevronUp className="h-4 w-4" />
                            +{formatCurrency((playerIn?.valuePerPoint || 0) - (playerOut?.valuePerPoint || 0))}
                          </>
                        ) : (
                          <>
                            <ChevronDown className="h-4 w-4" />
                            {formatCurrency((playerIn?.valuePerPoint || 0) - (playerOut?.valuePerPoint || 0))}
                          </>
                        )}
                      </div>
                    </div>
                    
                    <div className="bg-gray-50 rounded-md p-2 text-center">
                      <div className="text-xs text-gray-500 mb-1">$/Point</div>
                      <div className="font-medium">{formatCurrency(playerIn?.valuePerPoint || 0)}</div>
                    </div>
                  </div>
                </div>
              </div>
            </>
          ) : (
            <div className="bg-white rounded-md border h-full flex items-center justify-center p-8">
              <div className="text-center">
                <LineChart className="h-12 w-12 text-gray-300 mx-auto mb-4" />
                <h3 className="text-lg font-medium text-gray-700 mb-2">Calculate Trade Return</h3>
                <p className="text-sm text-gray-500 mb-4">
                  Select players to trade in and out to calculate the points return on your investment
                </p>
                <Button
                  variant="outline"
                  className="text-sm"
                  onClick={() => {
                    if (!playerOut) {
                      setSearchingFor("out");
                      setSearchQuery("");
                      setShowResults(false);
                    } else if (!playerIn) {
                      setSearchingFor("in");
                      setSearchQuery("");
                      setShowResults(false);
                    }
                  }}
                >
                  <Search className="h-4 w-4 mr-2" />
                  {!playerOut ? "Select Player to Trade Out" : "Select Player to Trade In"}
                </Button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}