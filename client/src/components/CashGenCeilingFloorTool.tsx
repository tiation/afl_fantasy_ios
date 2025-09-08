import { useState } from "react";
import { useAFLData } from "../hooks/useAFLData";
import { LoadingSpinner } from "./LoadingSpinner";
import { ErrorFallback } from "./ErrorBoundary";
import { ErrorBoundary } from "react-error-boundary";
import { Card } from "../components/ui/card";
import { Slider } from "../components/ui/slider";
import { Input } from "../components/ui/input";
import { Label } from "../components/ui/label";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';
import { PiggyBank, TrendingUp, TrendingDown } from "lucide-react";

interface CashGenCeilingFloorToolProps {}

interface PriceProjection {
  round: string;
  ceiling: number;
  floor: number;
  projected: number;
}

interface PlayerData {
  id: number;
  name: string;
  team: string;
  position: string;
  price: number;
  projection: PriceProjection[];
  breakeven: number;
  last3Scores: number[];
  averageScore: number;
}

export default function CashGenCeilingFloorTool({}: CashGenCeilingFloorToolProps) {
  const [selectedPlayer, setSelectedPlayer] = useState<string>("");
  const [ceiling, setCeiling] = useState<number>(95);
  const [floor, setFloor] = useState<number>(40);

  // Fetch player data
  const { data: players, isLoading, error } = useAFLData('/players');

  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorFallback error={error as Error} resetErrorBoundary={() => window.location.reload()} />;

  const player = players?.find((p: PlayerData) => p.name === selectedPlayer);

  // Calculate projections
  const calculateProjections = (player: PlayerData | undefined): PriceProjection[] => {
    if (!player) return [];

    const magicNumber = 9750;
    const rounds = ['Next Round', 'In 2 Rounds', 'In 3 Rounds'];
    
    let currentPrice = player.price;
    let currentCeiling = currentPrice;
    let currentFloor = currentPrice;
    let currentProjected = currentPrice;
    
    return rounds.map((round, index) => {
      const projectedScore = player.averageScore;
      const projectedChange = (projectedScore - player.breakeven) * (magicNumber / 100);
      const ceilingChange = (ceiling - player.breakeven) * (magicNumber / 100);
      const floorChange = (floor - player.breakeven) * (magicNumber / 100);
      
      currentCeiling += ceilingChange;
      currentFloor += floorChange;
      currentProjected += projectedChange;
      
      return {
        round,
        ceiling: Math.round(currentCeiling),
        floor: Math.round(currentFloor),
        projected: Math.round(currentProjected)
      };
    });
  };

  const projections = calculateProjections(player);
  const chartData = projections.map(proj => ({
    name: proj.round,
    Ceiling: proj.ceiling,
    Floor: proj.floor,
    Projected: proj.projected
  }));

  return (
    <Card className="p-6 space-y-6 dark:bg-gray-800/50">
      <div className="space-y-2">
        <div className="flex items-center space-x-2 mb-4">
          <PiggyBank className="h-6 w-6 text-green-500" />
          <h2 className="text-2xl font-bold">Cash Generation Calculator</h2>
        </div>
        <p className="text-gray-600 dark:text-gray-400">
          Calculate potential price ranges and cash generation based on score projections.
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="space-y-4">
          <div>
            <Label className="block mb-2">Player Name</Label>
            <Input 
              list="players"
              value={selectedPlayer}
              onChange={(e) => setSelectedPlayer(e.target.value)}
              placeholder="Search for a player..."
              className="w-full"
            />
            <datalist id="players">
              {players?.map((player: PlayerData) => (
                <option key={player.id} value={player.name} />
              ))}
            </datalist>
          </div>

          {player && (
            <div className="grid grid-cols-2 gap-4">
              <div className="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <Label className="block mb-2">Current Price</Label>
                <div className="text-xl font-bold">
                  ${(player.price / 1000).toFixed(1)}k
                </div>
              </div>
              <div className="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <Label className="block mb-2">Breakeven</Label>
                <div className="text-xl font-bold">
                  {player.breakeven}
                </div>
              </div>
            </div>
          )}

          <div>
            <Label className="flex items-center space-x-2 mb-2">
              <TrendingUp className="h-4 w-4 text-green-500" />
              <span>Ceiling Score ({ceiling})</span>
            </Label>
            <Slider
              value={[ceiling]}
              onValueChange={(val) => setCeiling(val[0])}
              min={0}
              max={150}
              step={1}
              className="mb-6"
            />
          </div>

          <div>
            <Label className="flex items-center space-x-2 mb-2">
              <TrendingDown className="h-4 w-4 text-red-500" />
              <span>Floor Score ({floor})</span>
            </Label>
            <Slider
              value={[floor]}
              onValueChange={(val) => setFloor(val[0])}
              min={0}
              max={150}
              step={1}
              className="mb-6"
            />
          </div>

          {player && (
            <div className="p-4 bg-gray-50 dark:bg-gray-900 rounded-lg space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-600 dark:text-gray-400">Last 3 Scores:</span>
                <span className="font-medium">
                  {player.last3Scores.join(', ')}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600 dark:text-gray-400">Average Score:</span>
                <span className="font-medium">
                  {player.averageScore.toFixed(1)}
                </span>
              </div>
            </div>
          )}
        </div>

        <div className="space-y-4">
          <div className="h-[400px] w-full">
            <ResponsiveContainer>
              <LineChart data={chartData} margin={{ top: 20, right: 30, left: 20, bottom: 20 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis
                  tickFormatter={(value) => `$${(value / 1000).toFixed(0)}k`}
                  domain={['dataMin - 50000', 'dataMax + 50000']}
                />
                <Tooltip
                  formatter={(value: number) => [`$${(value / 1000).toFixed(1)}k`, 'Price']}
                />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="Ceiling"
                  stroke="#22c55e"
                  strokeWidth={2}
                  dot
                />
                <Line
                  type="monotone"
                  dataKey="Floor"
                  stroke="#ef4444"
                  strokeWidth={2}
                  dot
                />
                <Line
                  type="monotone"
                  dataKey="Projected"
                  stroke="#3b82f6"
                  strokeWidth={2}
                  dot
                  strokeDasharray="5 5"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {player && projections.length > 0 && (
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="p-4 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
                <Label className="block text-green-700 dark:text-green-400 mb-1">Ceiling</Label>
                <div className="text-xl font-bold text-green-600 dark:text-green-400">
                  ${((projections[projections.length - 1].ceiling - player.price) / 1000).toFixed(1)}k
                </div>
                <span className="text-sm text-green-600/80 dark:text-green-400/80">Potential Gain</span>
              </div>

              <div className="p-4 bg-red-50 dark:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-800">
                <Label className="block text-red-700 dark:text-red-400 mb-1">Floor</Label>
                <div className="text-xl font-bold text-red-600 dark:text-red-400">
                  ${((projections[projections.length - 1].floor - player.price) / 1000).toFixed(1)}k
                </div>
                <span className="text-sm text-red-600/80 dark:text-red-400/80">Potential Loss</span>
              </div>

              <div className="p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
                <Label className="block text-blue-700 dark:text-blue-400 mb-1">Projected</Label>
                <div className="text-xl font-bold text-blue-600 dark:text-blue-400">
                  ${((projections[projections.length - 1].projected - player.price) / 1000).toFixed(1)}k
                </div>
                <span className="text-sm text-blue-600/80 dark:text-blue-400/80">Expected Change</span>
              </div>
            </div>
          )}
        </div>
      </div>
    </Card>
  );
}
