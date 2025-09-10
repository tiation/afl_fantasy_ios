import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Input } from "@/components/ui/input";
import { SliderProps } from "@radix-ui/react-slider";
import { Slider } from "@/components/ui/slider";
import { formatCurrency } from "@/lib/utils";
import {
  AlertTriangle,
  ShieldAlert,
  TrendingUp,
  Scale,
  HelpCircle,
  BarChart,
  CreditCard,
  Check,
  X
} from "lucide-react";

// Simplified trade risk analyzer with AI-driven insights

export function TradeRiskAnalyzer() {
  const [tradesUsed, setTradesUsed] = useState<number[]>([2]);
  const [injuryRisk, setInjuryRisk] = useState<number[]>([2]);
  const [benchCoverage, setBenchCoverage] = useState<number[]>([5]);
  const [totalTrades, setTotalTrades] = useState(30);
  const [roundsRemaining, setRoundsRemaining] = useState(12);
  
  // Calculate risk metrics
  const calculateRiskMetrics = () => {
    // Trade burn rate (% of total trades used per round)
    const burnRate = (tradesUsed[0] / totalTrades) * 100;
    
    // Trade utilization (% of total trades already used)
    const usedTrades = 30 - totalTrades;
    const utilizationRate = (usedTrades / 30) * 100;
    
    // Trade flexibility score (how many trades available per round)
    const tradesPerRound = totalTrades / roundsRemaining;
    const flexibilityScore = Math.min(100, tradesPerRound * 33);
    
    // Risk score calculation
    // Scale: 0-20 = Very Low, 21-40 = Low, 41-60 = Medium, 61-80 = High, 81-100 = Very High
    
    // Higher injury risk increases overall risk
    const injuryRiskFactor = (injuryRisk[0] / 5) * 35;
    
    // Higher burn rate increases risk
    const burnRiskFactor = burnRate * 1.5;
    
    // Lower bench coverage increases risk
    const benchRiskFactor = ((10 - benchCoverage[0]) / 10) * 30;
    
    // Lower trades available increases risk
    const tradeAvailabilityRiskFactor = (1 - (totalTrades / 30)) * 20;
    
    // Calculate overall risk score
    let riskScore = injuryRiskFactor + burnRiskFactor + benchRiskFactor + tradeAvailabilityRiskFactor;
    riskScore = Math.min(100, Math.max(0, riskScore));
    
    // Get risk category
    let riskCategory;
    if (riskScore <= 20) {
      riskCategory = "Very Low";
    } else if (riskScore <= 40) {
      riskCategory = "Low";
    } else if (riskScore <= 60) {
      riskCategory = "Medium";
    } else if (riskScore <= 80) {
      riskCategory = "High";
    } else {
      riskCategory = "Very High";
    }
    
    // Generate recommendations
    const recommendations = [];
    
    if (burnRate > 20) {
      recommendations.push("Reduce your trade frequency to preserve trades for critical situations.");
    }
    
    if (injuryRisk[0] >= 4) {
      recommendations.push("Consider holding trades in reserve to cover potential injuries to key players.");
    }
    
    if (benchCoverage[0] < 3) {
      recommendations.push("Improve your bench coverage to reduce dependency on trades for emergencies.");
    }
    
    if (totalTrades < 10) {
      recommendations.push("Conserve your remaining trades carefully as you have limited flexibility remaining.");
    }
    
    if (recommendations.length === 0) {
      recommendations.push("Your current trade strategy appears sustainable - continue to make calculated moves.");
    }
    
    return {
      burnRate,
      utilizationRate,
      flexibilityScore,
      riskScore,
      riskCategory,
      recommendations
    };
  };
  
  const riskMetrics = calculateRiskMetrics();
  
  // Calculate trade sustainability
  const calculateSustainability = () => {
    const currentBurnRate = tradesUsed[0];
    const sustainableWeeks = Math.floor(totalTrades / currentBurnRate);
    
    let assessmentText;
    let isPositive = true;
    
    if (sustainableWeeks >= roundsRemaining) {
      assessmentText = `You can sustain your current trade rate (${tradesUsed[0]} per week) for the remainder of the season.`;
    } else {
      isPositive = false;
      const shortfallWeeks = roundsRemaining - sustainableWeeks;
      assessmentText = `At your current trade rate (${tradesUsed[0]} per week), you'll run out of trades with ${shortfallWeeks} rounds remaining.`;
    }
    
    return {
      sustainableWeeks,
      roundsRemaining,
      assessmentText,
      isPositive,
      maximumSustainableTrades: Math.floor(totalTrades / roundsRemaining)
    };
  };
  
  const sustainability = calculateSustainability();
  
  // Calculate injury reserve
  const calculateInjuryReserve = () => {
    // Based on injury risk, calculate recommended trades to keep in reserve
    const recommendedReserve = Math.ceil(injuryRisk[0] * 2);
    const criticalReserve = Math.min(totalTrades, benchCoverage[0] < 5 ? 6 : 4);
    
    return {
      recommendedReserve,
      criticalReserve,
      hasAdequateReserve: totalTrades >= recommendedReserve
    };
  };
  
  const injuryReserve = calculateInjuryReserve();

  return (
    <div className="space-y-5">
      <div className="text-sm text-gray-600 mb-2">
        The Trade Risk Analyzer helps you evaluate your trade strategy's sustainability and identifies potential risks in your approach.
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
        <div className="space-y-4 bg-white rounded-md p-4 border">
          <h3 className="font-medium text-sm flex items-center">
            <Scale className="h-4 w-4 mr-2 text-blue-600" />
            Trade Strategy Inputs
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
                <span>Weekly Trades Used</span>
                <span className="font-medium">{`${tradesUsed[0]} trades`}</span>
              </div>
              <Slider
                value={tradesUsed}
                onValueChange={(newValue) => setTradesUsed(newValue)}
                min={0}
                max={4}
                step={1}
              />
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Injury Risk Level</span>
                <span className="font-medium">
                  {injuryRisk[0] === 1 ? "Very Low" :
                  injuryRisk[0] === 2 ? "Low" :
                  injuryRisk[0] === 3 ? "Medium" :
                  injuryRisk[0] === 4 ? "High" :
                  "Very High"}
                </span>
              </div>
              <Slider
                value={injuryRisk}
                onValueChange={(newValue) => setInjuryRisk(newValue)}
                min={1}
                max={5}
                step={1}
              />
            </div>
            
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span>Bench Coverage Strength</span>
                <span className="font-medium">
                  {benchCoverage[0] <= 2 ? "Very Poor" :
                  benchCoverage[0] <= 4 ? "Poor" :
                  benchCoverage[0] <= 6 ? "Average" :
                  benchCoverage[0] <= 8 ? "Good" :
                  "Excellent"}
                </span>
              </div>
              <Slider
                value={benchCoverage}
                onValueChange={(newValue) => setBenchCoverage(newValue)}
                min={1}
                max={10}
                step={1}
              />
            </div>
          </div>
        </div>
        
        <div className="bg-white rounded-md p-4 border">
          <h3 className="font-medium text-sm flex items-center mb-4">
            <AlertTriangle className="h-4 w-4 mr-2 text-amber-500" />
            Risk Assessment
          </h3>
          
          <div className="space-y-6">
            <div>
              <div className="flex justify-between mb-1 text-sm">
                <span>Overall Trade Risk</span>
                <span className={
                  riskMetrics.riskScore <= 20 ? "text-green-600" :
                  riskMetrics.riskScore <= 40 ? "text-emerald-600" :
                  riskMetrics.riskScore <= 60 ? "text-amber-500" :
                  riskMetrics.riskScore <= 80 ? "text-orange-600" :
                  "text-red-600"
                }>
                  {riskMetrics.riskCategory}
                </span>
              </div>
              <Progress
                value={riskMetrics.riskScore}
                className="h-2.5"
                // Custom color styling applied directly 
                style={{
                  '--progress-color': riskMetrics.riskScore <= 20 ? '#16a34a' :
                    riskMetrics.riskScore <= 40 ? '#059669' :
                    riskMetrics.riskScore <= 60 ? '#f59e0b' :
                    riskMetrics.riskScore <= 80 ? '#ea580c' :
                    '#dc2626'
                } as React.CSSProperties}
              />
            </div>
            
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <div className="text-gray-500 mb-1">Trade Burn Rate</div>
                <div className="font-medium">{riskMetrics.burnRate.toFixed(1)}% per week</div>
              </div>
              <div>
                <div className="text-gray-500 mb-1">Trades Used</div>
                <div className="font-medium">{riskMetrics.utilizationRate.toFixed(0)}% of total</div>
              </div>
              <div>
                <div className="text-gray-500 mb-1">Trade Flexibility</div>
                <div className="font-medium">{riskMetrics.flexibilityScore.toFixed(0)}%</div>
              </div>
              <div>
                <div className="text-gray-500 mb-1">Max Sustainable</div>
                <div className="font-medium">{sustainability.maximumSustainableTrades} trades/week</div>
              </div>
            </div>
            
            <div className="border-t pt-4">
              <div className="flex gap-2 items-center mb-2">
                <ShieldAlert className="h-4 w-4 text-blue-600" />
                <span className="font-medium">Trade Sustainability Assessment</span>
              </div>
              
              <div className={`text-sm ${sustainability.isPositive ? 'text-green-600' : 'text-amber-600'}`}>
                {sustainability.assessmentText}
              </div>
              
              <div className="mt-2 flex items-center gap-2 text-sm">
                <span className="text-gray-600">Recommended Injury Reserve:</span>
                <span className="font-medium">{injuryReserve.recommendedReserve} trades</span>
                {injuryReserve.hasAdequateReserve ? (
                  <Check className="h-4 w-4 text-green-600" />
                ) : (
                  <X className="h-4 w-4 text-red-600" />
                )}
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
          {riskMetrics.recommendations.map((rec, index) => (
            <li key={index} className="text-sm flex items-start gap-2">
              <TrendingUp className="h-4 w-4 text-blue-600 mt-0.5" />
              <span>{rec}</span>
            </li>
          ))}
        </ul>
      </div>
      
      <div className="bg-gray-50 rounded-md p-4">
        <h3 className="font-medium text-sm flex items-center mb-3">
          <BarChart className="h-4 w-4 mr-2 text-blue-600" />
          Trade Strategy Insights
        </h3>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
          <div className="bg-white rounded-md p-3 border">
            <div className="flex gap-2 items-center mb-1">
              <CreditCard className="h-4 w-4 text-green-600" />
              <span className="font-medium">Value Maximization</span>
            </div>
            <p className="text-gray-700">
              Reserve at least {Math.ceil(totalTrades * 0.3)} trades (30%) for capitalizing on injuries to premium players where significant value can be gained.
            </p>
          </div>
          
          <div className="bg-white rounded-md p-3 border">
            <div className="flex gap-2 items-center mb-1">
              <AlertTriangle className="h-4 w-4 text-amber-500" />
              <span className="font-medium">Risk Mitigation</span>
            </div>
            <p className="text-gray-700">
              With {roundsRemaining} rounds remaining and {totalTrades} trades left, aim to use no more than {Math.max(1, Math.floor(totalTrades / roundsRemaining))} trades per week to maintain flexibility.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}