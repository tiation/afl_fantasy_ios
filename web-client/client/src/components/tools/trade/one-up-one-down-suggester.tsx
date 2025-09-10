import { useState } from "react";
import { Button } from "@/components/ui/button";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { 
  ArrowDown, ArrowUp, ArrowUpDown, CircleDollarSign, 
  TrendingUp, AlertCircle 
} from "lucide-react";
import { Separator } from "@/components/ui/separator";
import { Slider } from "@/components/ui/slider";

export function OneUpOneDownSuggester() {
  const [isLoading, setIsLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [maxRookiePrice, setMaxRookiePrice] = useState(300000);
  const { toast } = useToast();
  
  // In a real implementation, we would:
  // 1. Load the user's current team from API or state
  // 2. Allow configuring the max rookie price (Done)
  // 3. Send request to API
  // 4. Display results in a visually appealing way
  
  const findCombinations = async () => {
    setIsLoading(true);
    
    try {
      // Placeholder data for demo purposes
      const demoData = {
        currentTeam: [
          {
            id: 1,
            name: "Marcus Bontempelli",
            position: "MID",
            team: "Western Bulldogs",
            price: 1100000,
            breakeven: 114,
            average: 120.5,
            projectedScore: 125
          },
          {
            id: 2,
            name: "Andrew Brayshaw",
            position: "MID",
            team: "Fremantle",
            price: 950000,
            breakeven: 105,
            average: 107.2,
            projectedScore: 110
          },
          {
            id: 3,
            name: "Matt Rowell",
            position: "MID",
            team: "Gold Coast",
            price: 680000,
            breakeven: 85,
            average: 92.1,
            projectedScore: 95
          },
          {
            id: 4,
            name: "Tim English",
            position: "RUCK",
            team: "Western Bulldogs",
            price: 880000,
            breakeven: 93,
            average: 101.4,
            projectedScore: 105
          },
          {
            id: 5,
            name: "Jordan Dawson",
            position: "DEF",
            team: "Adelaide",
            price: 790000,
            breakeven: 89,
            average: 96.3,
            projectedScore: 100
          },
          {
            id: 6,
            name: "Brayden Maynard",
            position: "DEF",
            team: "Collingwood",
            price: 620000,
            breakeven: 75,
            average: 85.2,
            projectedScore: 88
          },
          {
            id: 7,
            name: "Errol Gulden",
            position: "MID",
            team: "Sydney",
            price: 860000,
            breakeven: 95,
            average: 99.5,
            projectedScore: 102
          },
          {
            id: 8, 
            name: "Charlie Curnow",
            position: "FWD",
            team: "Carlton",
            price: 700000,
            breakeven: 72,
            average: 84.5,
            projectedScore: 88
          },
          {
            id: 9,
            name: "Xavier Duursma",
            position: "MID",
            team: "Essendon",
            price: 280000,
            breakeven: 65,
            average: 72.1,
            projectedScore: 75
          },
          {
            id: 10,
            name: "Sam Darcy",
            position: "DEF/FWD",
            team: "Western Bulldogs",
            price: 320000,
            breakeven: 55,
            average: 68.3,
            projectedScore: 72
          }
        ],
        maxRookiePrice
      };
      
      const response = await apiRequest("POST", "/api/fantasy/tools/one_up_one_down_suggester", demoData);
      const data = await response.json();
      
      if (data.status === "error") {
        toast({
          title: "Error",
          description: data.message || "Failed to find trade combinations",
          variant: "destructive"
        });
      } else {
        setResult(data);
      }
    } catch (error) {
      console.error("Error finding trade combinations:", error);
      toast({
        title: "Error",
        description: "Failed to find trade combinations",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };
  
  return (
    <div className="space-y-4">
      <div className="text-sm text-gray-600 mb-4">
        The One Up One Down Suggester finds optimal trade combinations that involve downgrading one player to a rookie and using the cash to upgrade another player.
      </div>
      
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base">Tool Settings</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            <div>
              <label className="text-sm font-medium">Maximum Rookie Price</label>
              <div className="flex items-center gap-4 mt-2">
                <Slider 
                  value={[maxRookiePrice]} 
                  min={150000} 
                  max={450000} 
                  step={10000} 
                  onValueChange={(values) => setMaxRookiePrice(values[0])}
                  className="flex-1"
                />
                <span className="text-sm font-medium w-24">${(maxRookiePrice/1000).toFixed(0)}k</span>
              </div>
            </div>
            
            <Button 
              onClick={findCombinations} 
              disabled={isLoading}
              className="w-full"
            >
              <ArrowUpDown className="h-4 w-4 mr-2" />
              {isLoading ? "Finding Combinations..." : "Find Trade Combinations"}
            </Button>
          </div>
        </CardContent>
      </Card>
      
      {result && result.combinations && result.combinations.length > 0 ? (
        <div className="mt-6 space-y-4">
          <h3 className="font-medium">Top Trade Combinations (Score Based on Overall Value)</h3>
          {result.combinations.map((combo: any, index: number) => (
            <Card key={index} className="overflow-hidden">
              <div className="bg-muted p-3 flex justify-between items-center">
                <div className="font-medium">Combination {index + 1}</div>
                <div className="text-sm">
                  <span className="font-medium">Score: </span>
                  <span className="text-primary">{Math.round((combo.overallScore || 0) * 10)}/10</span>
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 divide-y md:divide-y-0 md:divide-x">
                <div className="p-4">
                  <div className="flex items-center text-sm font-medium text-red-500 mb-2">
                    <ArrowDown className="h-4 w-4 mr-1" />
                    Downgrade
                  </div>
                  
                  {combo.downgrade && (
                    <>
                      <div className="flex flex-col md:flex-row gap-2 md:gap-6 items-start md:items-center">
                        <div className="flex-1">
                          <div className="font-medium">{combo.downgrade.from?.name || "Unknown Player"}</div>
                          <div className="text-sm text-gray-600">
                            {combo.downgrade.from?.team || "Team"} | {combo.downgrade.from?.position || "POS"} | 
                            ${((combo.downgrade.from?.price || 0)/1000).toFixed(0)}k
                          </div>
                        </div>
                        <ArrowRight />
                        <div className="flex-1">
                          <div className="font-medium">{combo.downgrade.to?.name || "Unknown Player"}</div>
                          <div className="text-sm text-gray-600">
                            {combo.downgrade.to?.team || "Team"} | {combo.downgrade.to?.position || "POS"} | 
                            ${((combo.downgrade.to?.price || 0)/1000).toFixed(0)}k
                          </div>
                        </div>
                      </div>
                      
                      <div className="mt-3 pt-3 border-t flex justify-between text-sm">
                        <div>
                          <span className="text-gray-600">Score Impact: </span>
                          <span className={(combo.downgrade.scoreImpact || 0) >= 0 ? "text-green-600" : "text-red-600"}>
                            {(combo.downgrade.scoreImpact || 0) > 0 ? "+" : ""}
                            {(combo.downgrade.scoreImpact || 0).toFixed(1)}
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-600">Cash Generated: </span>
                          <span className="text-green-600">
                            +${((combo.downgrade.cashFreed || 0)/1000).toFixed(0)}k
                          </span>
                        </div>
                      </div>
                    </>
                  )}
                </div>
                
                <div className="p-4">
                  <div className="flex items-center text-sm font-medium text-green-600 mb-2">
                    <ArrowUp className="h-4 w-4 mr-1" />
                    Upgrade
                  </div>
                  
                  {combo.upgrade && (
                    <>
                      <div className="flex flex-col md:flex-row gap-2 md:gap-6 items-start md:items-center">
                        <div className="flex-1">
                          <div className="font-medium">{combo.upgrade.from?.name || "Unknown Player"}</div>
                          <div className="text-sm text-gray-600">
                            {combo.upgrade.from?.team || "Team"} | {combo.upgrade.from?.position || "POS"} | 
                            ${((combo.upgrade.from?.price || 0)/1000).toFixed(0)}k
                          </div>
                        </div>
                        <ArrowRight />
                        <div className="flex-1">
                          <div className="font-medium">{combo.upgrade.to?.name || "Unknown Player"}</div>
                          <div className="text-sm text-gray-600">
                            {combo.upgrade.to?.team || "Team"} | {combo.upgrade.to?.position || "POS"} | 
                            ${((combo.upgrade.to?.price || 0)/1000).toFixed(0)}k
                          </div>
                        </div>
                      </div>
                      
                      <div className="mt-3 pt-3 border-t flex justify-between text-sm">
                        <div>
                          <span className="text-gray-600">Score Impact: </span>
                          <span className={(combo.upgrade.scoreImpact || 0) >= 0 ? "text-green-600" : "text-red-600"}>
                            {(combo.upgrade.scoreImpact || 0) > 0 ? "+" : ""}
                            {(combo.upgrade.scoreImpact || 0).toFixed(1)}
                          </span>
                        </div>
                        <div>
                          <span className="text-gray-600">Cash Required: </span>
                          <span className="text-red-600">
                            -${((combo.upgrade.cashNeeded || 0)/1000).toFixed(0)}k
                          </span>
                        </div>
                      </div>
                    </>
                  )}
                </div>
              </div>
              
              <div className="p-3 bg-muted border-t flex flex-wrap justify-between gap-2">
                <div className="text-sm">
                  <span className="text-gray-600">Net Score Impact: </span>
                  <span className={(combo.netScore || 0) >= 0 ? "text-green-600 font-medium" : "text-red-600 font-medium"}>
                    {(combo.netScore || 0) > 0 ? "+" : ""}
                    {(combo.netScore || 0).toFixed(1)} points
                  </span>
                </div>
                <div className="text-sm">
                  <span className="text-gray-600">Net Cash: </span>
                  <span className={(combo.netCash || 0) >= 0 ? "text-green-600 font-medium" : "text-red-600 font-medium"}>
                    {(combo.netCash || 0) > 0 ? "+" : ""}
                    ${((combo.netCash || 0)/1000).toFixed(0)}k
                  </span>
                </div>
              </div>
            </Card>
          ))}
        </div>
      ) : result && result.status === "error" ? (
        <Card className="border-red-200 mt-6">
          <CardContent className="pt-6">
            <div className="flex items-center text-red-600 mb-2">
              <AlertCircle className="h-5 w-5 mr-2" />
              <h3 className="font-medium">Error Finding Combinations</h3>
            </div>
            <p className="text-sm">{result.message}</p>
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}

function ArrowRight() {
  return (
    <div className="flex items-center justify-center">
      <ArrowUpDown className="h-6 w-6 text-gray-400 rotate-90" />
    </div>
  );
}