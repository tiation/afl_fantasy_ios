import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer,
  TooltipProps 
} from "recharts";
import { 
  NameType, 
  ValueType 
} from "recharts/types/component/DefaultTooltipContent";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

export type RoundData = {
  round: number;
  actualScore: number;
  projectedScore: number;
  rank?: number;
  teamValue?: number;
};

type PerformanceChartProps = {
  data: RoundData[];
};

const CustomTooltip = ({ active, payload, label }: TooltipProps<ValueType, NameType>) => {
  if (active && payload && payload.length) {
    return (
      <div className="bg-gray-800 border border-gray-600 shadow-lg rounded p-2 text-sm">
        <div className="font-medium mb-1 text-white">R{label}</div>
        {payload[0] && payload[0].value && (
          <div className="flex items-center text-red-400">
            <div className="w-2 h-2 rounded-full bg-red-400 mr-2"></div>
            <span>Score: {payload[0].value}</span>
          </div>
        )}
        {payload[1] && payload[1].value && (
          <div className="flex items-center text-green-400">
            <div className="w-2 h-2 rounded-full bg-green-400 mr-2"></div>
            <span>Projected: {payload[1].value}</span>
          </div>
        )}
      </div>
    );
  }

  return null;
};

const RankTooltip = ({ active, payload, label }: TooltipProps<ValueType, NameType>) => {
  if (active && payload && payload.length && payload[0] && payload[0].value) {
    return (
      <div className="bg-gray-800 border border-gray-600 shadow-lg rounded p-2 text-sm">
        <div className="font-medium mb-1 text-white">R{label}</div>
        <div className="flex items-center text-red-400">
          <div className="w-2 h-2 rounded-full bg-red-400 mr-2"></div>
          <span>Overall Rank: {payload[0].value}</span>
        </div>
      </div>
    );
  }

  return null;
};

const ValueTooltip = ({ active, payload, label }: TooltipProps<ValueType, NameType>) => {
  if (active && payload && payload.length && payload[0] && payload[0].value) {
    return (
      <div className="bg-gray-800 border border-gray-600 shadow-lg rounded p-2 text-sm">
        <div className="font-medium mb-1 text-white">R{label}</div>
        <div className="flex items-center text-red-400">
          <div className="w-2 h-2 rounded-full bg-red-400 mr-2"></div>
          <span>Team Value: ${(payload[0].value as number / 1000).toFixed(1)}k</span>
        </div>
      </div>
    );
  }

  return null;
};

export default function PerformanceChart({ data }: PerformanceChartProps) {
  const [chartType, setChartType] = useState<"score" | "rank" | "value">("score");

  return (
    <Card className="bg-gray-800 border-2 border-red-500 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-red-500/5 to-transparent pointer-events-none"></div>
      <CardContent className="p-4 relative">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-lg font-medium text-white">Season Performance</h2>
          <Select 
            value={chartType} 
            onValueChange={(value) => setChartType(value as "score" | "rank" | "value")}
          >
            <SelectTrigger className="w-[180px] bg-gray-700 border-gray-600 text-white">
              <SelectValue placeholder="Select chart type" />
            </SelectTrigger>
            <SelectContent className="bg-gray-700 border-gray-600">
              <SelectItem value="score" className="text-white hover:bg-gray-600 focus:bg-gray-600">Team Score</SelectItem>
              <SelectItem value="rank" className="text-white hover:bg-gray-600 focus:bg-gray-600">Overall Rank</SelectItem>
              <SelectItem value="value" className="text-white hover:bg-gray-600 focus:bg-gray-600">Team Value</SelectItem>
            </SelectContent>
          </Select>
        </div>
        
        <div className="h-[200px] mt-4 relative">
          <div className="absolute inset-0 bg-gradient-to-t from-red-500/10 to-transparent rounded-lg"></div>
          <ResponsiveContainer width="100%" height="100%">
            {chartType === "score" ? (
              <LineChart
                data={data}
                margin={{
                  top: 10,
                  right: 10,
                  left: 10,
                  bottom: 10,
                }}
              >
                <defs>
                  <linearGradient id="redGlow" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#ef4444" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#ef4444" stopOpacity={0.05}/>
                  </linearGradient>
                  <filter id="glow">
                    <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                    <feMerge> 
                      <feMergeNode in="coloredBlur"/>
                      <feMergeNode in="SourceGraphic"/>
                    </feMerge>
                  </filter>
                </defs>
                <CartesianGrid strokeDasharray="2 2" stroke="#374151" opacity={0.3} />
                <XAxis 
                  dataKey="round" 
                  tickFormatter={(round) => `R${round}`}
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <YAxis 
                  domain={[(dataMin: number) => Math.max(dataMin * 0.85, 0), (dataMax: number) => dataMax * 1.05]}
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <Tooltip content={<CustomTooltip />} />
                <Line
                  type="monotone"
                  dataKey="actualScore"
                  name="Actual Score"
                  stroke="#ef4444"
                  strokeWidth={3}
                  fill="url(#redGlow)"
                  dot={{ fill: '#ef4444', strokeWidth: 2, r: 4, filter: 'url(#glow)' }}
                  activeDot={{ r: 6, fill: '#ef4444', stroke: '#ffffff', strokeWidth: 2, filter: 'url(#glow)' }}
                  filter="url(#glow)"
                />
                <Line
                  type="monotone"
                  dataKey="projectedScore"
                  name="Projected Score"
                  stroke="#22c55e"
                  strokeWidth={3}
                  dot={{ fill: '#22c55e', strokeWidth: 2, r: 4, filter: 'url(#glow)' }}
                  activeDot={{ r: 6, fill: '#22c55e', stroke: '#ffffff', strokeWidth: 2, filter: 'url(#glow)' }}
                  filter="url(#glow)"
                />
              </LineChart>
            ) : chartType === "rank" ? (
              <LineChart
                data={data}
                margin={{
                  top: 10,
                  right: 10,
                  left: 10,
                  bottom: 10,
                }}
              >
                <defs>
                  <filter id="glow">
                    <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                    <feMerge> 
                      <feMergeNode in="coloredBlur"/>
                      <feMergeNode in="SourceGraphic"/>
                    </feMerge>
                  </filter>
                </defs>
                <CartesianGrid strokeDasharray="2 2" stroke="#374151" opacity={0.3} />
                <XAxis 
                  dataKey="round" 
                  tickFormatter={(round) => `R${round}`}
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <YAxis 
                  reversed
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <Tooltip content={<RankTooltip />} />
                <Line
                  type="monotone"
                  dataKey="rank"
                  name="Overall Rank"
                  stroke="#ef4444"
                  strokeWidth={3}
                  dot={{ fill: '#ef4444', strokeWidth: 2, r: 4, filter: 'url(#glow)' }}
                  activeDot={{ r: 6, fill: '#ef4444', stroke: '#ffffff', strokeWidth: 2, filter: 'url(#glow)' }}
                  filter="url(#glow)"
                />
              </LineChart>
            ) : (
              <LineChart
                data={data}
                margin={{
                  top: 10,
                  right: 10,
                  left: 10,
                  bottom: 10,
                }}
              >
                <defs>
                  <filter id="glow">
                    <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
                    <feMerge> 
                      <feMergeNode in="coloredBlur"/>
                      <feMergeNode in="SourceGraphic"/>
                    </feMerge>
                  </filter>
                </defs>
                <CartesianGrid strokeDasharray="2 2" stroke="#374151" opacity={0.3} />
                <XAxis 
                  dataKey="round" 
                  tickFormatter={(round) => `R${round}`}
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <YAxis 
                  tickFormatter={(value) => `$${(value/1000).toFixed(0)}k`}
                  axisLine={false}
                  tickLine={false}
                  tick={{ fill: '#9CA3AF', fontSize: 12 }}
                />
                <Tooltip content={<ValueTooltip />} />
                <Line
                  type="monotone"
                  dataKey="teamValue"
                  name="Team Value"
                  stroke="#ef4444"
                  strokeWidth={3}
                  dot={{ fill: '#ef4444', strokeWidth: 2, r: 4, filter: 'url(#glow)' }}
                  activeDot={{ r: 6, fill: '#ef4444', stroke: '#ffffff', strokeWidth: 2, filter: 'url(#glow)' }}
                  filter="url(#glow)"
                />
              </LineChart>
            )}
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
}
