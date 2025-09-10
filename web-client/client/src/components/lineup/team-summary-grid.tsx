import { formatCurrency } from "@/lib/utils";
import { Card, CardContent } from "@/components/ui/card";
import { TrendingUp, Trophy, Activity, Coins, Tag } from "lucide-react";

type TeamSummaryGridProps = {
  liveScore: number;
  projectedScore: number;
  teamValue: number;
  remainingSalary: number;
  tradesLeft: number;
  overallRank: number;
}

export default function TeamSummaryGrid({
  liveScore,
  projectedScore,
  teamValue,
  remainingSalary,
  tradesLeft,
  overallRank
}: TeamSummaryGridProps) {
  return (
    <div className="grid grid-cols-3 grid-rows-2 gap-3 mb-6">
      {/* Projected Score Widget */}
      <Card className="bg-gray-900 border-2 border-blue-500 shadow-sm h-[90px]">
        <CardContent className="p-2 h-full flex flex-col items-center justify-center">
          <div className="text-gray-300 text-xs font-medium">Projected Score</div>
          <div className="flex items-center gap-1 text-blue-400 mt-1">
            <Activity className="h-4 w-4" />
            <span className="text-2xl font-bold text-white">{projectedScore}</span>
          </div>
        </CardContent>
      </Card>

      {/* Live Score Widget */}
      <Card className="bg-gray-900 border-2 border-green-500 shadow-sm h-[90px]">
        <CardContent className="p-2 h-full flex flex-col items-center justify-center">
          <div className="text-gray-300 text-xs font-medium">Live Score</div>
          <div className="flex items-center gap-1 text-green-400 mt-1">
            <Activity className="h-4 w-4" />
            <span className="text-2xl font-bold text-white">{liveScore}</span>
          </div>
        </CardContent>
      </Card>

      {/* Team Value Widget */}
      <Card className="bg-gray-900 border-2 border-purple-500 shadow-sm h-[90px]">
        <CardContent className="p-2 h-full flex flex-col items-center justify-center">
          <div className="text-gray-300 text-xs font-medium">Team Value</div>
          <div className="flex items-center gap-1 text-purple-400 mt-1">
            <Coins className="h-4 w-4" />
            <span className="text-xl font-bold text-white">{formatCurrency(teamValue)}</span>
          </div>
        </CardContent>
      </Card>

      {/* Remaining Salary Widget */}
      <Card className="bg-gray-900 border-2 border-green-500 shadow-sm h-[90px]">
        <CardContent className="p-2 h-full flex flex-col items-center justify-center">
          <div className="text-gray-300 text-xs font-medium text-center">Remaining Salary</div>
          <div className="flex items-center gap-1 text-green-400 mt-1">
            <Tag className="h-4 w-4 flex-shrink-0" />
            <span className="text-lg font-bold text-white text-center break-words">{formatCurrency(remainingSalary)}</span>
          </div>
        </CardContent>
      </Card>

      {/* Trades Left Widget */}
      <Card className="bg-gray-900 border-2 border-orange-500 shadow-sm h-[90px]">
        <CardContent className="p-2 h-full flex flex-col items-center justify-center">
          <div className="text-gray-300 text-xs font-medium">Trades Left</div>
          <div className="flex items-center gap-1 text-orange-400 mt-1">
            <TrendingUp className="h-4 w-4" />
            <span className="text-2xl font-bold text-white">{tradesLeft}</span>
          </div>
        </CardContent>
      </Card>

      {/* Overall Rank Widget */}
      <Card className="bg-gray-900 border-2 border-blue-500 shadow-sm h-[90px]">
        <CardContent className="p-2 h-full flex flex-col items-center justify-center">
          <div className="text-gray-300 text-xs font-medium">Overall Rank</div>
          <div className="flex items-center gap-1 text-blue-400 mt-1">
            <Trophy className="h-4 w-4" />
            <span className="text-xl font-bold text-white">{overallRank.toLocaleString()}</span>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}