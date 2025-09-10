import { useState } from "react";
import { Button } from "@/components/ui/button";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { 
  ArrowRight, Calculator, CircleDollarSign, 
  TrendingUp, TrendingDown, CheckCircle2, XCircle 
} from "lucide-react";

export function TradeScoreCalculator() {
  const [isLoading, setIsLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const { toast } = useToast();
  
  // In a real implementation, we would:
  // 1. Allow searching and selecting players
  // 2. Take player inputs (player_in, player_out)
  // 3. Send request to API
  // 4. Display results in a visually appealing way
  
  const calculateTradeScore = async () => {
    setIsLoading(true);
    
    try {
      // Placeholder data for demo purposes
      const demoData = {
        player_in: {
          name: "Marcus Bontempelli", 
          price: 1100000,
          breakeven: 114, 
          projectedScore: 125,
          projectedScores: [125, 122, 118, 130, 120]
        },
        player_out: {
          name: "Jack Steele",
          price: 930000, 
          breakeven: 120,
          projectedScore: 105,
          projectedScores: [105, 110, 102, 108, 104]
        },
        round_number: 7,
        team_value: 15800000,
        league_avg_value: 15200000
      };
      
      const response = await apiRequest("POST", "/api/fantasy/tools/trade_score_calculator", demoData);
      const data = await response.json();
      
      if (data.status === "error") {
        toast({
          title: "Error",
          description: data.message || "Failed to calculate trade score",
          variant: "destructive"
        });
      } else {
        setResult(data);
      }
    } catch (error) {
      console.error("Error in trade score calculation:", error);
      toast({
        title: "Error",
        description: "Failed to calculate trade score",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <div className="space-y-4">
      <div className="text-sm text-gray-600 mb-4">
        The Trade Score Calculator helps you evaluate potential trades by analyzing scoring impact, price changes, and team value considerations.
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base flex items-center">
              <ArrowRight className="h-4 w-4 mr-2 text-green-500" />
              Player In
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="font-medium">Marcus Bontempelli</div>
            <div className="text-sm text-gray-600 mt-1">
              Western Bulldogs | MID | $1,100,000
            </div>
            <div className="grid grid-cols-2 gap-2 text-sm mt-2">
              <div>
                <span className="text-gray-500">BE:</span> 114
              </div>
              <div>
                <span className="text-gray-500">Avg:</span> 120.5
              </div>
              <div>
                <span className="text-gray-500">Status:</span> Fit
              </div>
              <div>
                <span className="text-gray-500">Proj:</span> 125
              </div>
            </div>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base flex items-center">
              <ArrowRight className="h-4 w-4 mr-2 text-red-500 rotate-180" />
              Player Out
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="font-medium">Jack Steele</div>
            <div className="text-sm text-gray-600 mt-1">
              St Kilda | MID | $930,000
            </div>
            <div className="grid grid-cols-2 gap-2 text-sm mt-2">
              <div>
                <span className="text-gray-500">BE:</span> 120
              </div>
              <div>
                <span className="text-gray-500">Avg:</span> 105.5
              </div>
              <div>
                <span className="text-gray-500">Status:</span> Fit
              </div>
              <div>
                <span className="text-gray-500">Proj:</span> 105
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
      
      <Button 
        onClick={calculateTradeScore} 
        disabled={isLoading}
        className="w-full mt-4"
      >
        <Calculator className="h-4 w-4 mr-2" />
        {isLoading ? "Calculating..." : "Calculate Trade Score"}
      </Button>
      
      {result && (
        <div className="mt-6 space-y-4">
          <Card className={`border-2 ${getTradeScoreColorClass(result.trade_score)}`}>
            <CardHeader className="pb-2">
              <CardTitle className="text-base flex items-center">
                <span className="text-2xl font-bold mr-2">{result.trade_score}</span> 
                Trade Score • {result.verdict}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm">{result.recommendation}</p>
              
              <div className="grid grid-cols-2 gap-4 mt-4">
                <div>
                  <div className="text-sm font-medium">Scoring Impact</div>
                  <div className="flex items-center mt-1">
                    <div 
                      className="h-2 rounded-full bg-primary" 
                      style={{ width: `${result.score_breakdown?.scoring_score || 0}%` }}
                    />
                    <span className="ml-2 text-sm">{result.score_breakdown?.scoring_score || 0}/100</span>
                  </div>
                </div>
                <div>
                  <div className="text-sm font-medium">Cash Impact</div>
                  <div className="flex items-center mt-1">
                    <div 
                      className="h-2 rounded-full bg-primary" 
                      style={{ width: `${result.score_breakdown?.cash_score || 0}%` }}
                    />
                    <span className="ml-2 text-sm">{result.score_breakdown?.cash_score || 0}/100</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
          
          <div className="text-sm font-medium mt-4">Explanations</div>
          <ul className="space-y-1 text-sm">
            {result.explanations?.map((explanation: string, index: number) => (
              <li key={index} className="flex items-start">
                <CheckCircle2 className="h-4 w-4 mr-2 text-green-500 mt-0.5 flex-shrink-0" />
                <span>{explanation}</span>
              </li>
            ))}
          </ul>
          
          <div className="text-sm font-medium mt-4">Price Trends (Next 5 Rounds)</div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <Card>
              <CardHeader className="py-2 px-4">
                <CardTitle className="text-sm font-medium">Marcus Bontempelli</CardTitle>
              </CardHeader>
              <CardContent className="p-4">
                <div className="space-y-2">
                  {result.price_trend?.player_in.map((change: any, index: number) => (
                    <div key={index} className="flex justify-between text-sm">
                      <span>Round {change.week}</span>
                      <span className="font-medium">${(change.price / 1000).toFixed(0)}k</span>
                      <span className={change.change > 0 ? "text-green-500" : change.change < 0 ? "text-red-500" : ""}>
                        {change.change > 0 ? "+" : ""}{(change.change / 1000).toFixed(1)}k
                      </span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="py-2 px-4">
                <CardTitle className="text-sm font-medium">Jack Steele</CardTitle>
              </CardHeader>
              <CardContent className="p-4">
                <div className="space-y-2">
                  {result.price_trend?.player_out.map((change: any, index: number) => (
                    <div key={index} className="flex justify-between text-sm">
                      <span>Round {change.week}</span>
                      <span className="font-medium">${(change.price / 1000).toFixed(0)}k</span>
                      <span className={change.change > 0 ? "text-green-500" : change.change < 0 ? "text-red-500" : ""}>
                        {change.change > 0 ? "+" : ""}{(change.change / 1000).toFixed(1)}k
                      </span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      )}
    </div>
  );
}

function getTradeScoreColorClass(score: number): string {
  if (score >= 90) return "border-green-500";
  if (score >= 75) return "border-green-400";
  if (score >= 60) return "border-green-300";
  if (score >= 40) return "border-amber-300";
  if (score >= 20) return "border-orange-400";
  return "border-red-500";
}