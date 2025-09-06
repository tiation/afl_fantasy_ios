import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { SliderProps } from "@radix-ui/react-slider";
import { Slider } from "@/components/ui/slider";
import { Progress } from "@/components/ui/progress";
import { formatCurrency } from "@/lib/utils";
import {
  AlertTriangle,
  ShieldAlert,
  TrendingUp,
  Scale,
  HelpCircle,
  BarChart,
  Flame,
  Zap,
  XCircle,
  CheckCircle2,
  LineChart,
  Info
} from "lucide-react";

export function TradeBurnRiskAnalyzer() {
  const [tradesUsed, setTradesUsed] = useState<number[]>([2]);
  const [tradesPerRound, setTradesPerRound] = useState<number[]>([2]);
  const [totalTrades, setTotalTrades] = useState(30);
  const [roundsRemaining, setRoundsRemaining] = useState(12);
  const [injuredPlayers, setInjuredPlayers] = useState<number[]>([1]);
  const [suspendedPlayers, setSuspendedPlayers] = useState<number[]>([0]);

  // Calculate burn rate metrics
  const calculateBurnMetrics = () => {
    // Calculate current trade pace
    const currentPace = tradesPerRound[0] * roundsRemaining;
    
    // Calculate burn rate (% of remaining trades that will be used at current pace)
    const burnRate = Math.min(100, (currentPace / totalTrades) * 100);
    
    // Calculate rounds until out of trades
    const roundsUntilExhausted = Math.floor(totalTrades / tradesPerRound[0]);
    
    // Trade deficit/surplus calculation
    const tradeSurplusDeficit = totalTrades - currentPace;
    
    // Sustainability status
    const isRateSustainable = tradeSurplusDeficit >= 0;
    
    // Calculate risk level based on various factors
    const paceRiskFactor = Math.min(100, (tradesPerRound[0] / (totalTrades / roundsRemaining)) * 50);
    const injuryRiskFactor = (injuredPlayers[0] + suspendedPlayers[0]) * 10;
    const reserveFactor = Math.max(0, 50 - (totalTrades / 30) * 50); // Lower trades = higher risk
    
    // Overall risk calculation (0-100)
    const riskScore = Math.min(100, paceRiskFactor + injuryRiskFactor + reserveFactor);
    
    // Determine risk category
    let riskCategory;
    if (riskScore < 20) riskCategory = "Very Low";
    else if (riskScore < 40) riskCategory = "Low";
    else if (riskScore < 60) riskCategory = "Moderate";
    else if (riskScore < 80) riskCategory = "High";
    else riskCategory = "Critical";
    
    // Generate recommendations
    const recommendations = [];
    
    if (tradesPerRound[0] > totalTrades / roundsRemaining) {
      recommendations.push("Reduce your weekly trading pace to avoid running out of trades before season end.");
    }
    
    if (tradeSurplusDeficit < 0) {
      const adjustedRate = Math.floor(totalTrades / roundsRemaining);
      recommendations.push(`Consider limiting trades to ${adjustedRate} per round to ensure season-long coverage.`);
    }
    
    if (injuredPlayers[0] > 0 || suspendedPlayers[0] > 0) {
      const reserveRecommendation = Math.max(2, (injuredPlayers[0] + suspendedPlayers[0]) * 2);
      recommendations.push(`Reserve at least ${reserveRecommendation} trades to address injured/suspended players.`);
    }
    
    if (recommendations.length === 0) {
      recommendations.push("Your current trade strategy is sustainable. Continue monitoring team needs.");
    }
    
    return {
      burnRate,
      roundsUntilExhausted,
      tradeSurplusDeficit,
      isRateSustainable,
      riskScore,
      riskCategory,
      recommendations,
      sustainableRate: Math.floor(totalTrades / roundsRemaining)
    };
  };

  const burnMetrics = calculateBurnMetrics();

  return (
    <div className="space-y-5">
      <div className="flex items-center gap-2">
        <Flame className="h-5 w-5 text-red-600" />
        <h3 className="text-lg font-medium">Trade Burn Risk Analyzer</h3>
      </div>

      <p className="text-sm text-gray-600">
        Analyze your trade usage pattern to evaluate sustainability through the season. 
        Avoid trade burnout by balancing current needs with long-term strategy.
      </p>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-4 bg-white rounded-md p-4 border">
          <h3 className="font-medium text-sm flex items-center">
            <Scale className="h-4 w-4 mr-2 text-blue-600" />
            Burn Rate Factors
          </h3>
          
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label htmlFor="totalTrades" className="text-sm font-medium mb-1 block">
                  Trades Remaining
                </label>
                <Input
                  id="totalTrades"
                  type="number"
                  value={totalTrades}
                  onChange={(e) => setTotalTrades(parseInt(e.target.value) || 0)}
                  min={0}
                  max={30}
                  className="h-9"
                />
              </div>
              <div>
                <label htmlFor="roundsRemaining" className="text-sm font-medium mb-1 block">
                  Rounds Remaining
                </label>
                <Input
                  id="roundsRemaining"
                  type="number"
                  value={roundsRemaining}
                  onChange={(e) => setRoundsRemaining(parseInt(e.target.value) || 0)}
                  min={1}
                  max={24}
                  className="h-9"
                />
              </div>
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Average Trades Per Round</span>
                <span className="font-medium">{tradesPerRound[0]} trades</span>
              </div>
              <Slider
                value={tradesPerRound}
                onValueChange={(newValue) => setTradesPerRound(newValue)}
                min={0}
                max={4}
                step={1}
              />
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Trades Used This Round</span>
                <span className="font-medium">{tradesUsed[0]} trades</span>
              </div>
              <Slider
                value={tradesUsed}
                onValueChange={(newValue) => setTradesUsed(newValue)}
                min={0}
                max={4}
                step={1}
              />
            </div>
            
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Injured Players</span>
                  <span className="font-medium">{injuredPlayers[0]}</span>
                </div>
                <Slider
                  value={injuredPlayers}
                  onValueChange={(newValue) => setInjuredPlayers(newValue)}
                  min={0}
                  max={5}
                  step={1}
                />
              </div>
              
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span>Suspended Players</span>
                  <span className="font-medium">{suspendedPlayers[0]}</span>
                </div>
                <Slider
                  value={suspendedPlayers}
                  onValueChange={(newValue) => setSuspendedPlayers(newValue)}
                  min={0}
                  max={3}
                  step={1}
                />
              </div>
            </div>
          </div>
        </div>
        
        <div className="space-y-4">
          <div className="bg-white rounded-md p-4 border">
            <h3 className="font-medium text-sm flex items-center mb-3">
              <Flame className="h-4 w-4 mr-2 text-red-600" />
              Burn Rate Assessment
            </h3>
            
            <div className="space-y-4">
              <div>
                <div className="flex justify-between mb-1 text-sm">
                  <span>Trade Burnout Risk</span>
                  <span className={
                    burnMetrics.riskScore < 20 ? "text-green-600" :
                    burnMetrics.riskScore < 40 ? "text-emerald-600" :
                    burnMetrics.riskScore < 60 ? "text-amber-500" :
                    burnMetrics.riskScore < 80 ? "text-orange-600" :
                    "text-red-600"
                  }>
                    {burnMetrics.riskCategory}
                  </span>
                </div>
                <Progress
                  value={burnMetrics.riskScore}
                  className="h-2.5"
                  style={{
                    '--progress-color': burnMetrics.riskScore < 20 ? '#16a34a' :
                      burnMetrics.riskScore < 40 ? '#059669' :
                      burnMetrics.riskScore < 60 ? '#f59e0b' :
                      burnMetrics.riskScore < 80 ? '#ea580c' :
                      '#dc2626'
                  } as React.CSSProperties}
                />
              </div>
              
              <div className="grid grid-cols-2 gap-3 text-sm">
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-gray-500 text-xs mb-1">Trade Burn Rate</div>
                  <div className={`font-medium ${burnMetrics.burnRate > 100 ? 'text-red-600' : 'text-gray-700'}`}>
                    {burnMetrics.burnRate.toFixed(0)}%
                  </div>
                </div>
                
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-gray-500 text-xs mb-1">Sustainability</div>
                  <div className={`font-medium flex items-center ${burnMetrics.isRateSustainable ? 'text-green-600' : 'text-red-600'}`}>
                    {burnMetrics.isRateSustainable ? (
                      <>
                        <CheckCircle2 className="h-3.5 w-3.5 mr-1" />
                        Sustainable
                      </>
                    ) : (
                      <>
                        <XCircle className="h-3.5 w-3.5 mr-1" />
                        Unsustainable
                      </>
                    )}
                  </div>
                </div>
                
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-gray-500 text-xs mb-1">Rounds Until Exhausted</div>
                  <div className={`font-medium ${
                    burnMetrics.roundsUntilExhausted < roundsRemaining / 2 ? 'text-red-600' : 
                    burnMetrics.roundsUntilExhausted < roundsRemaining ? 'text-amber-600' : 
                    'text-green-600'
                  }`}>
                    {burnMetrics.roundsUntilExhausted}
                  </div>
                </div>
                
                <div className="bg-gray-50 p-2 rounded-md">
                  <div className="text-gray-500 text-xs mb-1">Trade Surplus/Deficit</div>
                  <div className={`font-medium ${burnMetrics.tradeSurplusDeficit >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {burnMetrics.tradeSurplusDeficit >= 0 ? '+' : ''}{burnMetrics.tradeSurplusDeficit}
                  </div>
                </div>
              </div>
              
              <div className="border-t pt-3">
                <div className="flex items-center gap-2 mb-2">
                  <Info className="h-4 w-4 text-blue-600" />
                  <span className="font-medium text-sm">Sustainable Rate</span>
                </div>
                
                <div className="flex items-center gap-2 bg-blue-50 p-2 rounded-md">
                  <Zap className="h-5 w-5 text-blue-500" />
                  <div className="text-sm">
                    <span className="font-medium">{burnMetrics.sustainableRate}</span> trades per round is your maximum sustainable rate
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-md p-4 border">
            <h3 className="font-medium text-sm flex items-center mb-3">
              <HelpCircle className="h-4 w-4 mr-2 text-purple-600" />
              Recommendations
            </h3>
            
            <ul className="space-y-2">
              {burnMetrics.recommendations.map((rec, index) => (
                <li key={index} className="text-sm flex items-start gap-2">
                  <TrendingUp className="h-4 w-4 text-blue-600 mt-0.5" />
                  <span>{rec}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
      
      <div className="bg-gray-50 rounded-md p-4">
        <h3 className="font-medium text-sm flex items-center mb-3">
          <BarChart className="h-4 w-4 mr-2 text-blue-600" />
          Trade Burn Analysis
        </h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
          <div className="bg-white rounded-md p-3 border">
            <div className="flex gap-2 items-center mb-1">
              <LineChart className="h-4 w-4 text-green-600" />
              <span className="font-medium">Trade Usage Projection</span>
            </div>
            <p className="text-gray-700">
              At your current rate of {tradesPerRound[0]} trades per round, you'll use {tradesPerRound[0] * roundsRemaining} of your {totalTrades} remaining trades by season end.
            </p>
          </div>
          
          <div className="bg-white rounded-md p-3 border">
            <div className="flex gap-2 items-center mb-1">
              <AlertTriangle className="h-4 w-4 text-amber-500" />
              <span className="font-medium">Injury & Suspension Impact</span>
            </div>
            <p className="text-gray-700">
              With {injuredPlayers[0]} injured and {suspendedPlayers[0]} suspended players, you should reserve {(injuredPlayers[0] + suspendedPlayers[0]) * 2} trades minimum for unexpected replacements.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}