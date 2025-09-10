import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Slider } from "@/components/ui/slider";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Line } from "react-chartjs-2";
import {
  Chart as ChartJS,
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Tooltip,
  Legend,
  Filler
} from "chart.js";

ChartJS.register(
  LineElement,
  CategoryScale,
  LinearScale,
  PointElement,
  Tooltip,
  Legend,
  Filler
);

export function CashGenCeilingFloor() {
  const [player, setPlayer] = useState("");
  const [currentPrice, setCurrentPrice] = useState(300000);
  const [last3, setLast3] = useState([65, 72, 58]);
  const [ceiling, setCeiling] = useState(95);
  const [floor, setFloor] = useState(40);
  const magicNumber = 9750;

  const simulatePrices = (scoreSet: number[]) => {
    const prices: number[] = [];
    const scores = [...last3];
    for (let i = 0; i < 3; i++) {
      scores.shift();
      scores.push(scoreSet[i]);
      const newPrice = Math.round((scores.reduce((a, b) => a + b) / 3) * magicNumber);
      prices.push(newPrice);
    }
    return prices;
  };

  const floorPrices = simulatePrices([floor, floor, floor]);
  const ceilingPrices = simulatePrices([ceiling, ceiling, ceiling]);
  const basePrices = simulatePrices([70, 70, 70]);

  const data = {
    labels: ["Next Round", "In 2 Rounds", "In 3 Rounds"],
    datasets: [
      {
        label: "Ceiling Price",
        data: ceilingPrices,
        borderColor: "rgba(0, 180, 70, 1)",
        backgroundColor: "rgba(0, 180, 70, 0.3)",
        fill: true,
      },
      {
        label: "Floor Price",
        data: floorPrices,
        borderColor: "rgba(220, 50, 50, 1)",
        backgroundColor: "rgba(220, 50, 50, 0.3)",
        fill: true,
      },
      {
        label: "Projected Price (Avg 70)",
        data: basePrices,
        borderColor: "rgba(60, 120, 220, 1)",
        backgroundColor: "rgba(60, 120, 220, 0.3)",
        borderDash: [5, 5],
        fill: true,
      },
    ],
  };

  const options = {
    responsive: true,
    plugins: {
      legend: {
        position: 'top' as const,
      },
      tooltip: {
        callbacks: {
          label: function(context: any) {
            return `${context.dataset.label}: $${context.parsed.y.toLocaleString()}`;
          }
        }
      }
    },
    scales: {
      y: {
        ticks: {
          callback: function(value: any) {
            return '$' + value.toLocaleString();
          }
        }
      }
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-2">
        <p className="text-sm text-gray-400">
          📈 Visualize potential ceiling and floor price changes for players based on different scoring scenarios. 
          🧮 Use our magic number algorithm (9750) to predict how a player's price might change over the next 3 rounds.
        </p>
      </div>
      
      <Card className="p-4 space-y-4 bg-gray-800 border-gray-700">
        <h2 className="text-xl font-bold text-white">💰 Cash Gen Ceiling/Floor</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <Label className="text-gray-300">👤 Player Name</Label>
            <Input 
              value={player} 
              onChange={(e) => setPlayer(e.target.value)} 
              className="bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              placeholder="Enter player name..."
            />
          </div>
          <div>
            <Label className="text-gray-300">💵 Current Price ($)</Label>
            <Input 
              type="number" 
              value={currentPrice} 
              onChange={(e) => setCurrentPrice(Number(e.target.value))} 
              className="bg-gray-700 border-gray-600 text-white"
            />
          </div>
          <div>
            <Label className="text-gray-300">📊 Last 3 Scores (comma separated)</Label>
            <Input 
              value={last3.join(",")} 
              onChange={(e) => setLast3(e.target.value.split(",").map(Number))} 
              className="bg-gray-700 border-gray-600 text-white placeholder-gray-400"
              placeholder="e.g., 65,72,58"
            />
          </div>
          <div>
            <Label className="text-gray-300">📈 Ceiling Score: <span className="text-green-400 font-bold">{ceiling}</span></Label>
            <Slider 
              defaultValue={[ceiling]} 
              max={150} 
              min={0} 
              step={1} 
              onValueChange={(val) => setCeiling(val[0])} 
              className="my-2"
            />
          </div>
          <div>
            <Label className="text-gray-300">📉 Floor Score: <span className="text-red-400 font-bold">{floor}</span></Label>
            <Slider 
              defaultValue={[floor]} 
              max={150} 
              min={0} 
              step={1} 
              onValueChange={(val) => setFloor(val[0])} 
              className="my-2"
            />
          </div>
        </div>
        <CardContent className="p-0 pt-4 bg-gray-900 rounded-lg">
          <Line data={data} options={options} />
        </CardContent>
      </Card>
    </div>
  );
}