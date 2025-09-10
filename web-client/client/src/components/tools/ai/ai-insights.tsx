import { useEffect, useState } from "react";
import {
  fetchAITrade,
  fetchAICaptain,
  fetchTeamStructure,
  fetchOwnershipRisk,
  fetchFormVsPrice
} from "@/services/aiService";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import {
  CircleDollarSign,
  Trophy,
  Users,
  AlertTriangle,
  TrendingUp,
  RefreshCw,
  ArrowUpDown,
  CheckCircle2
} from "lucide-react";

export default function AIInsights() {
  const [trade, setTrade] = useState<any>(null);
  const [captains, setCaptains] = useState<any[]>([]);
  const [structure, setStructure] = useState<any>(null);
  const [risks, setRisks] = useState<any[]>([]);
  const [valueScan, setValueScan] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadAllData() {
    try {
      setLoading(true);
      setError(null);
      
      // Load all data in parallel
      const [tradeData, captainData, structureData, riskData, valueData] = await Promise.all([
        fetchAITrade().catch(() => null),
        fetchAICaptain().catch(() => []),
        fetchTeamStructure().catch(() => null),
        fetchOwnershipRisk().catch(() => []),
        fetchFormVsPrice().catch(() => [])
      ]);
      
      setTrade(tradeData);
      setCaptains(captainData);
      setStructure(structureData);
      setRisks(riskData);
      setValueScan(valueData);
    } catch (err) {
      console.error("Error loading AI insights:", err);
      setError("Failed to load some AI insight data");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadAllData();
  }, []);

  // Format price for display
  const formatPrice = (price: number) => {
    if (!price) return "$0";
    return `$${(price / 1000).toFixed(0)}K`;
  };

  // Calculate percentage for structure visualization
  const getPercentage = (value: number) => {
    if (!structure) return 0;
    const total = structure.rookies + structure.mid_pricers + structure.premiums;
    if (total === 0) return 0;
    return Math.round((value / total) * 100);
  };

  if (loading) {
    return <div>Loading AI insights...</div>;
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-bold">AI Fantasy Insights Dashboard</h2>
        <Button 
          size="sm" 
          variant="outline" 
          onClick={loadAllData}
          className="flex items-center gap-1"
        >
          <RefreshCw className="h-4 w-4" />
          Refresh All
        </Button>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* AI Trade Suggestion */}
        <Card>
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <ArrowUpDown className="h-5 w-5 text-blue-500" />
              <CardTitle className="text-lg">AI Trade Suggestion</CardTitle>
            </div>
            <CardDescription>Optimal trade based on current form and price</CardDescription>
          </CardHeader>
          <CardContent>
            {trade ? (
              <div className="grid grid-cols-2 gap-4">
                <div className="border rounded-md p-3 bg-gray-50">
                  <Badge variant="destructive" className="mb-2">Trade Out</Badge>
                  <div className="font-semibold text-lg">{trade.downgrade_out?.name}</div>
                  <div className="text-sm text-gray-500">
                    {trade.downgrade_out?.team} · {trade.downgrade_out?.position}
                  </div>
                  <div className="mt-2 font-medium">
                    {formatPrice(trade.downgrade_out?.price)}
                  </div>
                </div>
                
                <div className="border rounded-md p-3 bg-gray-50">
                  <Badge className="bg-green-600 mb-2">Trade In</Badge>
                  <div className="font-semibold text-lg">{trade.upgrade_in?.name}</div>
                  <div className="text-sm text-gray-500">
                    {trade.upgrade_in?.team} · {trade.upgrade_in?.position}
                  </div>
                  <div className="mt-2 font-medium">
                    {formatPrice(trade.upgrade_in?.price)}
                  </div>
                </div>
              </div>
            ) : (
              <div className="text-center py-4 text-gray-500">No trade suggestion available</div>
            )}
          </CardContent>
        </Card>
        
        {/* AI Captain Picks */}
        <Card>
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <Trophy className="h-5 w-5 text-yellow-500" />
              <CardTitle className="text-lg">AI Captain Picks</CardTitle>
            </div>
            <CardDescription>Top 3 captain recommendations for this round</CardDescription>
          </CardHeader>
          <CardContent>
            {captains && captains.length > 0 ? (
              <div className="space-y-3">
                {captains.slice(0, 3).map((captain, index) => (
                  <div 
                    key={index} 
                    className={`flex items-center justify-between p-3 rounded-md ${index === 0 ? 'bg-yellow-50 border border-yellow-200' : 'bg-gray-50 border'}`}
                  >
                    <div className="flex items-center gap-3">
                      {index === 0 && <Trophy className="h-4 w-4 text-yellow-500" />}
                      <div>
                        <div className="font-medium">{captain.name}</div>
                        <div className="text-sm text-gray-500">{captain.team}</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm">L3 Avg: <span className="font-semibold">{captain.l3_avg?.toFixed(1) || 'N/A'}</span></div>
                      <div className="text-sm">BE: <span className="font-semibold">{captain.breakeven || 'N/A'}</span></div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-4 text-gray-500">No captain recommendations available</div>
            )}
          </CardContent>
        </Card>
        
        {/* Team Structure Summary */}
        <Card>
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <Users className="h-5 w-5 text-indigo-500" />
              <CardTitle className="text-lg">Team Structure</CardTitle>
            </div>
            <CardDescription>Your team's price distribution analysis</CardDescription>
          </CardHeader>
          <CardContent>
            {structure ? (
              <div className="space-y-4">
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Rookies</span>
                    <span className="text-sm">{structure.rookies} players ({getPercentage(structure.rookies)}%)</span>
                  </div>
                  <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-green-400 transition-all duration-500 ease-in-out" 
                      style={{ width: `${getPercentage(structure.rookies)}%` }}
                    ></div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Mid-pricers</span>
                    <span className="text-sm">{structure.mid_pricers} players ({getPercentage(structure.mid_pricers)}%)</span>
                  </div>
                  <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-blue-400 transition-all duration-500 ease-in-out" 
                      style={{ width: `${getPercentage(structure.mid_pricers)}%` }}
                    ></div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Premiums</span>
                    <span className="text-sm">{structure.premiums} players ({getPercentage(structure.premiums)}%)</span>
                  </div>
                  <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-purple-400 transition-all duration-500 ease-in-out" 
                      style={{ width: `${getPercentage(structure.premiums)}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            ) : (
              <div className="text-center py-4 text-gray-500">No structure data available</div>
            )}
          </CardContent>
        </Card>
        
        {/* Ownership Risk Alerts */}
        <Card>
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-red-500" />
              <CardTitle className="text-lg">Ownership Risk Alerts</CardTitle>
            </div>
            <CardDescription>High-priced players not meeting expectations</CardDescription>
          </CardHeader>
          <CardContent>
            {risks && risks.length > 0 ? (
              <div className="space-y-2">
                {risks.slice(0, 4).map((risk, index) => (
                  <div 
                    key={index} 
                    className="flex justify-between items-center p-2 rounded-md bg-red-50 border border-red-100"
                  >
                    <div>
                      <div className="font-medium">{risk.player}</div>
                      <div className="text-sm text-gray-500">{formatPrice(risk.price)}</div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm">Avg: <span className="font-semibold">{risk.avg?.toFixed(1) || 'N/A'}</span></div>
                      <div className="text-sm">BE: <span className="font-semibold text-red-600">{risk.breakeven || 'N/A'}</span></div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-4 text-gray-500">No risk alerts available</div>
            )}
          </CardContent>
        </Card>
        
        {/* Form vs Price Insights */}
        <Card className="md:col-span-2">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2">
              <TrendingUp className="h-5 w-5 text-green-500" />
              <CardTitle className="text-lg">Form vs Price Insights</CardTitle>
            </div>
            <CardDescription>Players that may be over or under valued based on current form</CardDescription>
          </CardHeader>
          <CardContent>
            {valueScan && valueScan.length > 0 ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
                {valueScan.slice(0, 6).map((player, index) => (
                  <div 
                    key={index} 
                    className={`p-3 rounded-md border ${
                      player.valuation === 'undervalued' ? 'bg-green-50 border-green-200' :
                      player.valuation === 'overvalued' ? 'bg-red-50 border-red-200' :
                      'bg-gray-50'
                    }`}
                  >
                    <div className="flex justify-between items-start">
                      <div className="font-medium truncate pr-2">{player.player}</div>
                      <Badge 
                        className={`${
                          player.valuation === 'undervalued' ? 'bg-green-600' :
                          player.valuation === 'overvalued' ? 'bg-red-600' :
                          'bg-gray-500'
                        }`}
                      >
                        {player.valuation}
                      </Badge>
                    </div>
                    <div className="mt-2 grid grid-cols-3 gap-1 text-sm">
                      <div>
                        <div className="text-gray-500">Price</div>
                        <div>{formatPrice(player.price)}</div>
                      </div>
                      <div>
                        <div className="text-gray-500">Avg</div>
                        <div>{player.l3_avg?.toFixed(1) || 'N/A'}</div>
                      </div>
                      <div>
                        <div className="text-gray-500">BE</div>
                        <div>{player.breakeven || 'N/A'}</div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-4 text-gray-500">No valuation insights available</div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}