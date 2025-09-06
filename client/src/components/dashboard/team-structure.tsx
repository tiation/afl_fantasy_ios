import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { TrendingUp, ArrowUp, ArrowDown } from "lucide-react";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useState } from "react";

type PositionCategoryProps = {
  label: string;
  count: number;
  total: number;
  percentage: number;
  color: string;
  value?: string;
};

const PositionCategory = ({ label, count, total, percentage, color, value }: PositionCategoryProps) => (
  <div className="mb-3">
    <div className="flex justify-between text-sm mb-1">
      <span className={color}>{label}</span>
      <div className="flex items-center gap-2">
        {value && <span className="text-gray-400">{value}</span>}
        <span className="text-white">{count}/{total}</span>
      </div>
    </div>
    <div className="progress-container h-2 bg-gray-700 rounded-full overflow-hidden">
      <div 
        className="progress-bar bg-gradient-to-r from-blue-500 to-red-500 h-full rounded-full"
        style={{ width: `${percentage}%` }}
      ></div>
    </div>
  </div>
);

type PositionGroupProps = {
  title: string;
  playerCount: number;
  categories: {
    premium: { count: number, label: string, value?: string };
    midPricer: { count: number, label: string, value?: string };
    rookie: { count: number, label: string, value?: string };
  };
  positionValue?: string;
};

const PositionGroup = ({ title, playerCount, categories, positionValue }: PositionGroupProps) => {
  const premiumPercentage = (categories.premium.count / playerCount) * 100;
  const midPricerPercentage = (categories.midPricer.count / playerCount) * 100;
  const rookiePercentage = (categories.rookie.count / playerCount) * 100;

  return (
    <div className="mb-6">
      <div className="flex justify-between mb-2">
        <h3 className="font-medium text-white">{title}</h3>
        <div className="flex items-center gap-2">
          {positionValue && (
            <span className="text-sm text-gray-400">{positionValue}</span>
          )}
          <span className="text-sm text-gray-400">{playerCount} players</span>
        </div>
      </div>
      
      <PositionCategory 
        label={categories.premium.label}
        count={categories.premium.count}
        total={playerCount}
        percentage={premiumPercentage}
        color="text-red-600 font-semibold"
        value={categories.premium.value}
      />
      
      <PositionCategory 
        label={categories.midPricer.label}
        count={categories.midPricer.count}
        total={playerCount}
        percentage={midPricerPercentage}
        color="text-yellow-500"
        value={categories.midPricer.value}
      />
      
      <PositionCategory 
        label={categories.rookie.label}
        count={categories.rookie.count}
        total={playerCount}
        percentage={rookiePercentage}
        color="text-blue-500"
        value={categories.rookie.value}
      />
    </div>
  );
};

// New Performance Component for recent team performance
type TeamPerformanceProps = {
  rounds: {
    round: number;
    score: number;
    rankChange: number;
    rank?: number; // Overall rank (optional)
  }[];
};

const TeamPerformance = ({ rounds }: TeamPerformanceProps) => {
  const maxScore = Math.max(...rounds.map(r => r.score)); // Find the highest score to scale bars

  // Get color for the score bar
  const getScoreBarColor = (score: number) => {
    const percentage = score / maxScore;
    if (percentage > 0.9) return "bg-gradient-to-r from-emerald-500 to-emerald-600";
    if (percentage > 0.8) return "bg-gradient-to-r from-green-500 to-green-600";
    if (percentage > 0.7) return "bg-gradient-to-r from-lime-500 to-lime-600";
    if (percentage > 0.6) return "bg-gradient-to-r from-yellow-500 to-yellow-600";
    if (percentage > 0.5) return "bg-gradient-to-r from-amber-500 to-amber-600";
    return "bg-gradient-to-r from-orange-500 to-orange-600";
  };

  return (
    <div className="mb-4">
      <div className="space-y-3">
        {rounds.map((round) => (
          <div key={round.round} className="flex flex-col space-y-1">
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">Round {round.round}</span>
              
              <div className="flex items-center gap-4">
                {/* Overall Rank (if available) */}
                {round.rank && (
                  <div className="flex items-center text-indigo-600">
                    <span className="text-sm font-medium">
                      Rank: {round.rank.toLocaleString()}
                    </span>
                  </div>
                )}
                
                {/* Rank Change */}
                <div className="flex items-center">
                  <span className="text-sm mr-1">
                    {round.rankChange > 0 ? "+" : ""}{round.rankChange}
                  </span>
                  {round.rankChange > 0 ? (
                    <ArrowUp className="h-4 w-4 text-status-positive" />
                  ) : round.rankChange < 0 ? (
                    <ArrowDown className="h-4 w-4 text-status-negative" />
                  ) : null}
                </div>
              </div>
            </div>
            
            {/* Score Bar */}
            <div className="flex items-center w-full">
              <div className="w-full h-6 bg-neutral-light/20 rounded relative">
                <div 
                  className={`${getScoreBarColor(round.score)} h-full rounded`} 
                  style={{ width: `${(round.score / (maxScore * 1.1)) * 100}%` }}
                ></div>
                <span className="absolute right-2 top-1/2 transform -translate-y-1/2 text-xs font-semibold">
                  {round.score}
                </span>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

type TeamStructureProps = {
  midfield: {
    premium: { count: number, label: string };
    midPricer: { count: number, label: string };
    rookie: { count: number, label: string };
  };
  forward: {
    premium: { count: number, label: string };
    midPricer: { count: number, label: string };
    rookie: { count: number, label: string };
  };
  defense: {
    premium: { count: number, label: string };
    midPricer: { count: number, label: string };
    rookie: { count: number, label: string };
  };
  ruck: {
    premium: { count: number, label: string };
    midPricer: { count: number, label: string };
    rookie: { count: number, label: string };
  };
  teamValue: string;
};

export default function TeamStructure({
  midfield,
  forward,
  defense,
  ruck,
  teamValue
}: TeamStructureProps) {
  const [valueView, setValueView] = useState<"overall" | "breakdown" | "team-value">("overall");
  
  // Sample data for position values - in a real app, this would be calculated or provided
  const midfieldValue = "$3,200,000";
  const forwardValue = "$1,850,000";
  const defenseValue = "$1,700,000";
  const ruckValue = "$950,000";
  
  // Sample data for recent performance with overall ranks
  const recentPerformance = [
    { round: 6, score: 2243, rankChange: 1250, rank: 3842 },
    { round: 5, score: 2102, rankChange: -345, rank: 5092 },
    { round: 4, score: 2281, rankChange: 867, rank: 4747 },
    { round: 3, score: 1998, rankChange: -127, rank: 5614 },
    { round: 2, score: 2125, rankChange: 523, rank: 5487 }
  ];

  return (
    <Card className="bg-gray-800 border-2 border-yellow-500">
      <CardContent className="p-4">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-medium text-white">Team Value</h2>
          <Select 
            value={valueView} 
            onValueChange={(value) => setValueView(value as "overall" | "breakdown" | "team-value")}
          >
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Value Display" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="overall">Overall Value</SelectItem>
              <SelectItem value="breakdown">Value Breakdown</SelectItem>
              <SelectItem value="team-value">Team Value</SelectItem>
            </SelectContent>
          </Select>
        </div>
        
        <PositionGroup 
          title="Midfield"
          playerCount={10}
          categories={{
            premium: {
              ...midfield.premium,
              value: valueView === "team-value" ? "$1,800,000" : undefined 
            },
            midPricer: {
              ...midfield.midPricer,
              value: valueView === "team-value" ? "$1,050,000" : undefined
            },
            rookie: {
              ...midfield.rookie,
              value: valueView === "team-value" ? "$350,000" : undefined
            }
          }}
          positionValue={valueView === "breakdown" ? midfieldValue : undefined}
        />
        
        <PositionGroup 
          title="Forward"
          playerCount={6}
          categories={{
            premium: {
              ...forward.premium,
              value: valueView === "team-value" ? "$1,200,000" : undefined
            },
            midPricer: {
              ...forward.midPricer,
              value: valueView === "team-value" ? "$450,000" : undefined
            },
            rookie: {
              ...forward.rookie,
              value: valueView === "team-value" ? "$200,000" : undefined
            }
          }}
          positionValue={valueView === "breakdown" ? forwardValue : undefined}
        />
        
        <PositionGroup 
          title="Defense"
          playerCount={6}
          categories={{
            premium: {
              ...defense.premium,
              value: valueView === "team-value" ? "$1,000,000" : undefined
            },
            midPricer: {
              ...defense.midPricer,
              value: valueView === "team-value" ? "$500,000" : undefined
            },
            rookie: {
              ...defense.rookie,
              value: valueView === "team-value" ? "$200,000" : undefined
            }
          }}
          positionValue={valueView === "breakdown" ? defenseValue : undefined}
        />
        
        <PositionGroup 
          title="Ruck"
          playerCount={2}
          categories={{
            premium: {
              ...ruck.premium,
              value: valueView === "team-value" ? "$750,000" : undefined
            },
            midPricer: {
              ...ruck.midPricer,
              value: valueView === "team-value" ? "$200,000" : undefined
            },
            rookie: {
              ...ruck.rookie,
              value: undefined
            }
          }}
          positionValue={valueView === "breakdown" ? ruckValue : undefined}
        />
        
        <div className="mt-6 pt-4 border-t border-gray-600 flex items-center justify-between">
          <span className="font-medium text-white">Team Value</span>
          <div className="flex items-center">
            <span className="font-semibold text-lg text-white">{teamValue}</span>
            <TrendingUp className="h-5 w-5 ml-1 text-green-400" />
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
