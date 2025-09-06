import { Card, CardContent } from "@/components/ui/card";
import { cn } from "@/lib/utils";
import { ArrowUp, ArrowDown } from "lucide-react";
import { LineChart, Line, XAxis, YAxis, ResponsiveContainer, Tooltip } from "recharts";

export type RoundPerformanceData = {
  round: number;
  score: number;
  projectedScore?: number;
  rank: number;
  rankChange: number;
};

type TeamPerformanceProps = {
  data: RoundPerformanceData[];
};

export default function TeamPerformance({ data }: TeamPerformanceProps) {
  // Sort data by round in ascending order for the chart
  const chartData = [...data].sort((a, b) => a.round - b.round);
  
  // Sort data by round in descending order (most recent first) for display
  const sortedData = [...data].sort((a, b) => b.round - a.round);
  
  // Find the highest score to scale the bars
  const maxScore = Math.max(...data.map(r => r.score)) * 1.1;
  
  // Debug: Check if projected scores exist
  console.log('Team Performance Data:', chartData);
  
  return (
    <Card className="bg-gray-800 border-2 border-teal-500 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-teal-500/5 to-transparent pointer-events-none"></div>
      <CardContent className="p-4 relative">
        <h2 className="text-lg font-medium mb-4 text-white">Team Performance</h2>
        
        {/* Team Score Chart with Projected Score */}
        <div className="h-[250px] mb-6 relative">
          <div className="absolute inset-0 bg-gradient-to-t from-teal-500/10 to-transparent rounded-lg"></div>
          <ResponsiveContainer width="100%" height="100%">
            <LineChart
              data={chartData}
              margin={{
                top: 10,
                right: 15,
                left: 40,
                bottom: 25,
              }}
            >
              <defs>
                <linearGradient id="tealGlow" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#14b8a6" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#14b8a6" stopOpacity={0.05}/>
                </linearGradient>
                <linearGradient id="cyanGlow" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#06b6d4" stopOpacity={0.3}/>
                  <stop offset="95%" stopColor="#06b6d4" stopOpacity={0.05}/>
                </linearGradient>
                <filter id="tealGlowFilter">
                  <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
                  <feMerge> 
                    <feMergeNode in="coloredBlur"/>
                    <feMergeNode in="SourceGraphic"/>
                  </feMerge>
                </filter>
                <filter id="cyanGlowFilter">
                  <feGaussianBlur stdDeviation="2" result="coloredBlur"/>
                  <feMerge> 
                    <feMergeNode in="coloredBlur"/>
                    <feMergeNode in="SourceGraphic"/>
                  </feMerge>
                </filter>
              </defs>
              <XAxis 
                dataKey="round"
                axisLine={false}
                tickLine={false}
                tick={{ fill: '#9CA3AF', fontSize: 12 }}
                interval={0}
                tickFormatter={(value) => `R${value}`}
              />
              <YAxis 
                axisLine={false}
                tickLine={false}
                tick={{ fill: '#9CA3AF', fontSize: 12 }}
                domain={[0, 3000]}
                ticks={[0, 750, 1500, 2250, 3000]}
                tickFormatter={(value) => `${value}`}
              />
              <Tooltip
                content={({ active, payload, label }) => {
                  if (active && payload && payload.length) {
                    return (
                      <div className="bg-gray-800 border border-gray-600 shadow-lg rounded p-2 text-sm">
                        <div className="font-medium mb-1 text-white">Round {label}</div>
                        {payload.map((entry, index) => (
                          <div key={index} className="flex items-center" style={{ color: entry.color }}>
                            <div className="w-2 h-2 rounded-full mr-2" style={{ backgroundColor: entry.color }}></div>
                            <span>{entry.name}: {entry.value}</span>
                          </div>
                        ))}
                      </div>
                    );
                  }
                  return null;
                }}
              />
              <Line
                type="monotone"
                dataKey="score"
                stroke="#14b8a6"
                strokeWidth={2.5}
                dot={{ fill: '#14b8a6', strokeWidth: 1, r: 3, filter: 'url(#tealGlowFilter)' }}
                activeDot={{ r: 5, fill: '#14b8a6', stroke: '#ffffff', strokeWidth: 1, filter: 'url(#tealGlowFilter)' }}
                filter="url(#tealGlowFilter)"
                name="Team Score"
              />
              <Line
                type="monotone"
                dataKey="projectedScore"
                stroke="#06b6d4"
                strokeWidth={2.5}
                strokeDasharray="5 5"
                dot={{ fill: '#06b6d4', strokeWidth: 1, r: 3 }}
                activeDot={{ r: 5, fill: '#06b6d4', stroke: '#ffffff', strokeWidth: 1 }}
                name="Projected Score"
                connectNulls={false}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
        
        <div className="space-y-4">
          {sortedData.slice(0, 3).map((round) => (
            <div key={round.round} className="flex justify-between items-center py-2">
              <div className="flex items-center space-x-4">
                <span className="font-medium text-white text-base">R{round.round}</span>
                <span className="text-teal-400 font-bold text-lg">{round.score}</span>
              </div>
              <div className="flex items-center space-x-3">
                <span className="text-gray-400 text-base">
                  #{round.rank.toLocaleString()}
                </span>
                <div className={cn(
                  "flex items-center text-sm font-medium",
                  round.rankChange > 0 ? "text-green-400" : "text-red-400"
                )}>
                  <span>{round.rankChange > 0 ? "+" : ""}{round.rankChange.toLocaleString()}</span>
                  {round.rankChange > 0 ? (
                    <ArrowUp className="h-3 w-3 ml-1" />
                  ) : round.rankChange < 0 ? (
                    <ArrowDown className="h-3 w-3 ml-1" />
                  ) : null}
                </div>
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  );
}