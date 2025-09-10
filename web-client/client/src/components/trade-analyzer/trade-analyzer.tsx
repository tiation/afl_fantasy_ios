import { useState } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { apiRequest } from "@/lib/queryClient";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { CircleDollarSign, TrendingUp, AlertTriangle, BarChart4, Trophy, Clock, Coins } from "lucide-react";
import { Separator } from "@/components/ui/separator";
import { Skeleton } from "@/components/ui/skeleton";
import { Progress } from "@/components/ui/progress";

type TradeScoreResponse = {
  status: string;
  trade_score: number;
  scoring_score?: number;
  cash_score?: number;
  overall_score?: number;
  score_breakdown?: {
    projected_score: number;
    value: number;
    breakeven: number;
    risk: number;
    scoring_weight?: number;
    cash_weight?: number;
    timing?: number;
    team_value?: number;
  };
  price_projections?: {
    player_in: number[];
    player_out: number[];
    net_gain: number;
  };
  projected_prices?: {
    player_in: number[];
    player_out: number[];
  };
  projected_scores?: {
    player_in: number[];
    player_out: number[];
  };
  explanations: string[];
  recommendation: string;
  verdict?: string;
  flags?: {
    peaked_rookie: boolean;
    trading_peaked_player: boolean;
    getting_peaked_player: boolean;
    player_in_class: string;
    player_out_class: string;
    upgrade_path?: string;
    season_match?: boolean;
  };
  _fallback?: boolean;
};

export function TradeAnalyzer() {
  const [playerIn, setPlayerIn] = useState({
    price: 850000,
    breakeven: 90,
    proj_scores: [95.5, 88.2, 105.1, 92.3, 98.7],
    is_red_dot: false
  });

  const [playerOut, setPlayerOut] = useState({
    price: 720000,
    breakeven: 75,
    proj_scores: [70.2, 82.5, 78.4, 85.1, 76.3],
    is_red_dot: true
  });

  const [roundNumber, setRoundNumber] = useState(8);
  const [teamValue, setTeamValue] = useState(15200000);
  const [leagueAvgValue, setLeagueAvgValue] = useState(14800000);

  const [isLoading, setIsLoading] = useState(false);
  const [tradeResult, setTradeResult] = useState<TradeScoreResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  const analyzeTradeScore = async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const payload = {
        player_in: playerIn,
        player_out: playerOut,
        round_number: roundNumber,
        team_value: teamValue,
        league_avg_value: leagueAvgValue
      };
      
      const response = await apiRequest("POST", "/api/trade_score", payload);
      const data = await response.json();
      
      if (data.status === "ok") {
        setTradeResult(data);
      } else {
        setError(data.message || "Failed to analyze trade");
      }
    } catch (err) {
      console.error("Trade analysis error:", err);
      setError("An error occurred while analyzing the trade");
    } finally {
      setIsLoading(false);
    }
  };

  const handlePlayerInChange = (field: string, value: any) => {
    if (field === "price" || field === "breakeven") {
      value = Number(value);
    } else if (field === "proj_scores") {
      // Split by comma and convert to numbers
      value = value.split(",").map((v: string) => parseFloat(v.trim())).filter((v: number) => !isNaN(v));
    }
    
    setPlayerIn({
      ...playerIn,
      [field]: value
    });
  };

  const handlePlayerOutChange = (field: string, value: any) => {
    if (field === "price" || field === "breakeven") {
      value = Number(value);
    } else if (field === "proj_scores") {
      // Split by comma and convert to numbers
      value = value.split(",").map((v: string) => parseFloat(v.trim())).filter((v: number) => !isNaN(v));
    }
    
    setPlayerOut({
      ...playerOut,
      [field]: value
    });
  };

  // Helper to get color based on score
  const getScoreColor = (score: number) => {
    if (score >= 80) return "text-green-600";
    if (score >= 60) return "text-emerald-500";
    if (score >= 40) return "text-amber-500";
    return "text-red-500";
  };

  // Helper to get recommendation icon
  const getRecommendationIcon = (recommendation: string) => {
    if (recommendation.includes("Highly recommend")) return <Trophy className="h-5 w-5 text-green-600" />;
    if (recommendation.includes("Good trade")) return <TrendingUp className="h-5 w-5 text-emerald-500" />;
    if (recommendation.includes("Neutral")) return <BarChart4 className="h-5 w-5 text-amber-500" />;
    return <AlertTriangle className="h-5 w-5 text-red-500" />;
  };

  return (
    <div className="grid gap-6 md:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>Trade Analyzer</CardTitle>
          <CardDescription>Evaluate potential trades for your AFL Fantasy team</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="space-y-4">
              <div>
                <h3 className="text-lg font-medium">Player Coming In</h3>
                <Separator className="my-2" />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="playerInPrice">Price ($)</Label>
                <Input
                  id="playerInPrice"
                  type="number"
                  value={playerIn.price}
                  onChange={(e) => handlePlayerInChange("price", e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="playerInBreakeven">Breakeven</Label>
                <Input
                  id="playerInBreakeven"
                  type="number"
                  value={playerIn.breakeven}
                  onChange={(e) => handlePlayerInChange("breakeven", e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="playerInProjScores">Projected Scores (comma separated)</Label>
                <Input
                  id="playerInProjScores"
                  placeholder="e.g. 95.5, 88.2, 105.1, 92.3, 98.7"
                  value={playerIn.proj_scores.join(", ")}
                  onChange={(e) => handlePlayerInChange("proj_scores", e.target.value)}
                />
              </div>
              
              <div className="flex items-center space-x-2">
                <Switch
                  id="playerInRedDot"
                  checked={playerIn.is_red_dot}
                  onCheckedChange={(checked) => handlePlayerInChange("is_red_dot", checked)}
                />
                <Label htmlFor="playerInRedDot">
                  Has Injury/Suspension Risk
                </Label>
              </div>
            </div>
            
            <div className="space-y-4">
              <div>
                <h3 className="text-lg font-medium">Player Going Out</h3>
                <Separator className="my-2" />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="playerOutPrice">Price ($)</Label>
                <Input
                  id="playerOutPrice"
                  type="number"
                  value={playerOut.price}
                  onChange={(e) => handlePlayerOutChange("price", e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="playerOutBreakeven">Breakeven</Label>
                <Input
                  id="playerOutBreakeven"
                  type="number"
                  value={playerOut.breakeven}
                  onChange={(e) => handlePlayerOutChange("breakeven", e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="playerOutProjScores">Projected Scores (comma separated)</Label>
                <Input
                  id="playerOutProjScores"
                  placeholder="e.g. 70.2, 82.5, 78.4, 85.1, 76.3"
                  value={playerOut.proj_scores.join(", ")}
                  onChange={(e) => handlePlayerOutChange("proj_scores", e.target.value)}
                />
              </div>
              
              <div className="flex items-center space-x-2">
                <Switch
                  id="playerOutRedDot"
                  checked={playerOut.is_red_dot}
                  onCheckedChange={(checked) => handlePlayerOutChange("is_red_dot", checked)}
                />
                <Label htmlFor="playerOutRedDot">
                  Has Injury/Suspension Risk
                </Label>
              </div>
            </div>
          </div>
          
          <Separator />
          
          <div className="grid gap-4 md:grid-cols-3">
            <div className="space-y-2">
              <Label htmlFor="roundNumber">Current Round</Label>
              <Input
                id="roundNumber"
                type="number"
                min="1"
                max="23"
                value={roundNumber}
                onChange={(e) => setRoundNumber(Number(e.target.value))}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="teamValue">Your Team Value ($)</Label>
              <Input
                id="teamValue"
                type="number"
                value={teamValue}
                onChange={(e) => setTeamValue(Number(e.target.value))}
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="leagueAvgValue">League Avg Value ($)</Label>
              <Input
                id="leagueAvgValue"
                type="number"
                value={leagueAvgValue}
                onChange={(e) => setLeagueAvgValue(Number(e.target.value))}
              />
            </div>
          </div>
          
          <Button
            className="w-full"
            onClick={analyzeTradeScore}
            disabled={isLoading}
          >
            {isLoading ? "Analyzing..." : "Analyze Trade"}
          </Button>
          
          {error && (
            <Alert variant="destructive">
              <AlertTitle>Error</AlertTitle>
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>
          <CardTitle>Trade Analysis Results</CardTitle>
          <CardDescription>
            {tradeResult ? 
              "Your trade evaluation is ready" : 
              "Fill out the trade details and click 'Analyze Trade'"
            }
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {isLoading ? (
            <div className="space-y-4">
              <Skeleton className="h-5 w-28" />
              <Skeleton className="h-12 w-full" />
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-4 w-2/3" />
              <Separator />
              <Skeleton className="h-16 w-full" />
            </div>
          ) : tradeResult ? (
            <div className="space-y-4">
              <div className="flex justify-between items-center">
                <h3 className="text-base font-medium">Trade Score</h3>
                <span className={`text-2xl font-bold ${getScoreColor(tradeResult.trade_score)}`}>
                  {tradeResult.trade_score}/100
                </span>
              </div>
              
              <Progress value={tradeResult.trade_score} className="h-3" />
              
              <div className="flex items-center gap-2">
                {getRecommendationIcon(tradeResult.recommendation)}
                <span className="font-semibold">{tradeResult.recommendation}</span>
              </div>
              
              {tradeResult.verdict && (
                <div className={`mt-2 px-3 py-2 rounded-md ${
                  tradeResult.verdict === "Perfect Timing" ? "bg-green-100 text-green-800" :
                  tradeResult.verdict === "Solid Structure Trade" ? "bg-blue-100 text-blue-800" :
                  tradeResult.verdict === "Risky Move" ? "bg-amber-100 text-amber-800" :
                  "bg-red-100 text-red-800"
                }`}>
                  <span className="font-semibold">Verdict: {tradeResult.verdict}</span>
                </div>
              )}
              
              {tradeResult.scoring_score !== undefined && tradeResult.cash_score !== undefined && (
                <div className="flex gap-4 mt-2">
                  <div className="flex-1 p-2 rounded bg-slate-50">
                    <div className="text-xs text-gray-500">Scoring Impact</div>
                    <div className={`text-sm font-semibold ${tradeResult.scoring_score > 0 ? "text-green-600" : "text-red-600"}`}>
                      {tradeResult.scoring_score > 0 ? "+" : ""}{tradeResult.scoring_score.toFixed(1)} points
                    </div>
                  </div>
                  <div className="flex-1 p-2 rounded bg-slate-50">
                    <div className="text-xs text-gray-500">Cash Impact</div>
                    <div className={`text-sm font-semibold ${tradeResult.cash_score > 0 ? "text-green-600" : "text-red-600"}`}>
                      {tradeResult.cash_score > 0 ? "+" : ""}${(tradeResult.cash_score/1000).toFixed(1)}k
                    </div>
                  </div>
                </div>
              )}
              
              <Separator />
              
              {tradeResult.flags && (
                <div className="mb-4">
                  <h3 className="text-base font-medium mb-2">Player Types:</h3>
                  <div className="flex flex-wrap gap-2">
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      tradeResult.flags.player_in_class === "rookie" ? "bg-blue-100 text-blue-800" :
                      tradeResult.flags.player_in_class === "midpricer" ? "bg-green-100 text-green-800" :
                      tradeResult.flags.player_in_class === "underpriced_premium" ? "bg-purple-100 text-purple-800" :
                      "bg-amber-100 text-amber-800"
                    }`}>
                      In: {tradeResult.flags.player_in_class.replace('_', ' ')}
                    </span>
                    
                    <span className={`px-2 py-1 rounded-full text-xs ${
                      tradeResult.flags.player_out_class === "rookie" ? "bg-blue-100 text-blue-800" :
                      tradeResult.flags.player_out_class === "midpricer" ? "bg-green-100 text-green-800" :
                      tradeResult.flags.player_out_class === "underpriced_premium" ? "bg-purple-100 text-purple-800" :
                      "bg-amber-100 text-amber-800"
                    }`}>
                      Out: {tradeResult.flags.player_out_class.replace('_', ' ')}
                    </span>
                  </div>
                  
                  <div className="flex flex-wrap gap-2 mt-2">
                    {tradeResult.flags.peaked_rookie && (
                      <span className="px-2 py-1 rounded-full text-xs bg-red-100 text-red-800">
                        Peaked Rookie Warning
                      </span>
                    )}
                    
                    {tradeResult.flags.getting_peaked_player && (
                      <span className="px-2 py-1 rounded-full text-xs bg-orange-100 text-orange-800">
                        Player In May Have Peaked
                      </span>
                    )}
                    
                    {tradeResult.flags.trading_peaked_player && (
                      <span className="px-2 py-1 rounded-full text-xs bg-emerald-100 text-emerald-800">
                        Trading Peaked Player
                      </span>
                    )}
                    
                    {tradeResult.flags.upgrade_path && (
                      <span className={`px-2 py-1 rounded-full text-xs ${
                        tradeResult.flags.upgrade_path === "upgrade" ? "bg-blue-100 text-blue-800" :
                        tradeResult.flags.upgrade_path === "downgrade" ? "bg-amber-100 text-amber-800" :
                        "bg-gray-100 text-gray-800"
                      }`}>
                        {tradeResult.flags.upgrade_path.charAt(0).toUpperCase() + tradeResult.flags.upgrade_path.slice(1)} Path
                      </span>
                    )}
                    
                    {tradeResult.flags.season_match !== undefined && (
                      <span className={`px-2 py-1 rounded-full text-xs ${
                        tradeResult.flags.season_match ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800"
                      }`}>
                        {tradeResult.flags.season_match ? "Good Season Timing" : "Poor Season Timing"}
                      </span>
                    )}
                  </div>
                </div>
              )}
              
              <div>
                <h3 className="text-base font-medium mb-2">Analysis:</h3>
                <ul className="space-y-2">
                  {tradeResult.explanations.map((explanation, index) => (
                    <li key={index} className="flex items-start gap-2 text-sm">
                      <span className="text-gray-500">•</span>
                      <span>{explanation}</span>
                    </li>
                  ))}
                </ul>
              </div>
              
              {tradeResult.score_breakdown && (
                <>
                  <Separator />
                  <div>
                    <h3 className="text-base font-medium mb-2">Score Breakdown:</h3>
                    <div className="grid grid-cols-2 gap-2">
                      <div className="flex items-center gap-2">
                        <TrendingUp className="h-4 w-4 text-blue-500" />
                        <span className="text-sm">Projected Score: {tradeResult.score_breakdown.projected_score}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <CircleDollarSign className="h-4 w-4 text-green-500" />
                        <span className="text-sm">Value: {tradeResult.score_breakdown.value}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <BarChart4 className="h-4 w-4 text-purple-500" />
                        <span className="text-sm">Breakeven: {tradeResult.score_breakdown.breakeven}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <AlertTriangle className="h-4 w-4 text-red-500" />
                        <span className="text-sm">Risk: {tradeResult.score_breakdown.risk}</span>
                      </div>
                      
                      {tradeResult.score_breakdown.scoring_weight !== undefined && (
                        <div className="flex items-center gap-2">
                          <TrendingUp className="h-4 w-4 text-amber-500" />
                          <span className="text-sm">Scoring Weight: {tradeResult.score_breakdown.scoring_weight}%</span>
                        </div>
                      )}
                      
                      {tradeResult.score_breakdown.cash_weight !== undefined && (
                        <div className="flex items-center gap-2">
                          <Coins className="h-4 w-4 text-emerald-500" />
                          <span className="text-sm">Cash Weight: {tradeResult.score_breakdown.cash_weight}%</span>
                        </div>
                      )}
                      
                      {tradeResult.score_breakdown.timing !== undefined && (
                        <div className="flex items-center gap-2">
                          <Clock className="h-4 w-4 text-amber-500" />
                          <span className="text-sm">Timing: {tradeResult.score_breakdown.timing}</span>
                        </div>
                      )}
                      
                      {tradeResult.score_breakdown.team_value !== undefined && (
                        <div className="flex items-center gap-2">
                          <Trophy className="h-4 w-4 text-indigo-500" />
                          <span className="text-sm">Team Value: {tradeResult.score_breakdown.team_value}</span>
                        </div>
                      )}
                    </div>
                  </div>
                </>
              )}
              
              {tradeResult.price_projections && (
                <>
                  <Separator />
                  <div>
                    <h3 className="text-base font-medium mb-2">Price Projections:</h3>
                    <div className="space-y-4">
                      <div>
                        <h4 className="text-sm font-medium mb-1">Weekly Price Changes:</h4>
                        <div className="grid grid-cols-2 gap-4">
                          <div>
                            <h5 className="text-xs font-medium text-gray-500 mb-1">Player Coming In:</h5>
                            <div className="flex flex-wrap gap-2">
                              {tradeResult.price_projections.player_in.map((change, index) => (
                                <span key={`in-${index}`} className={`px-2 py-1 rounded-md text-xs ${
                                  change > 0 ? "bg-green-100 text-green-800" : 
                                  change < 0 ? "bg-red-100 text-red-800" : 
                                  "bg-gray-100 text-gray-800"
                                }`}>
                                  Round {index + 1}: {change > 0 ? '+' : ''}{(change/1000).toFixed(1)}k
                                </span>
                              ))}
                            </div>
                          </div>
                          
                          <div>
                            <h5 className="text-xs font-medium text-gray-500 mb-1">Player Going Out:</h5>
                            <div className="flex flex-wrap gap-2">
                              {tradeResult.price_projections.player_out.map((change, index) => (
                                <span key={`out-${index}`} className={`px-2 py-1 rounded-md text-xs ${
                                  change > 0 ? "bg-green-100 text-green-800" : 
                                  change < 0 ? "bg-red-100 text-red-800" : 
                                  "bg-gray-100 text-gray-800"
                                }`}>
                                  Round {index + 1}: {change > 0 ? '+' : ''}{(change/1000).toFixed(1)}k
                                </span>
                              ))}
                            </div>
                          </div>
                        </div>
                      </div>
                      
                      {tradeResult.projected_prices && (
                        <div>
                          <h4 className="text-sm font-medium mb-1">Projected Future Prices:</h4>
                          <div className="grid grid-cols-2 gap-4">
                            <div>
                              <h5 className="text-xs font-medium text-gray-500 mb-1">Player Coming In:</h5>
                              <div className="flex flex-wrap gap-2">
                                {tradeResult.projected_prices.player_in.map((price, index) => (
                                  <span key={`price-in-${index}`} className="px-2 py-1 rounded-md text-xs bg-blue-50 text-blue-800">
                                    Round {index + 1}: ${(price/1000).toFixed(1)}k
                                  </span>
                                ))}
                              </div>
                            </div>
                            
                            <div>
                              <h5 className="text-xs font-medium text-gray-500 mb-1">Player Going Out:</h5>
                              <div className="flex flex-wrap gap-2">
                                {tradeResult.projected_prices.player_out.map((price, index) => (
                                  <span key={`price-out-${index}`} className="px-2 py-1 rounded-md text-xs bg-blue-50 text-blue-800">
                                    Round {index + 1}: ${(price/1000).toFixed(1)}k
                                  </span>
                                ))}
                              </div>
                            </div>
                          </div>
                        </div>
                      )}
                      
                      <div className="flex items-center gap-2 bg-slate-50 p-2 rounded">
                        <span className="text-sm font-medium">Net Gain:</span>
                        <span className={`text-sm font-bold ${
                          tradeResult.price_projections.net_gain > 0 ? "text-green-600" : 
                          tradeResult.price_projections.net_gain < 0 ? "text-red-600" : 
                          "text-gray-600"
                        }`}>
                          {tradeResult.price_projections.net_gain > 0 ? '+' : ''}
                          ${(tradeResult.price_projections.net_gain/1000).toFixed(1)}k over 5 rounds
                        </span>
                      </div>
                    </div>
                  </div>
                </>
              )}
              
              {tradeResult._fallback && (
                <Alert>
                  <AlertTriangle className="h-4 w-4" />
                  <AlertTitle>Using simplified calculator</AlertTitle>
                  <AlertDescription>The advanced AI-powered calculator is currently unavailable. A simplified calculator has been used instead.</AlertDescription>
                </Alert>
              )}
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center h-64 text-center text-gray-500">
              <BarChart4 className="h-16 w-16 mb-4 opacity-30" />
              <p>Enter trade details on the left to analyze its potential value</p>
              <p className="text-sm mt-2">We'll help you decide if this trade is worthwhile</p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}