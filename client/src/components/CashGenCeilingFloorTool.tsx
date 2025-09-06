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

export default function CashGenCeilingFloorTool() {
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
    <Card className="p-4 space-y-4 dark:bg-slate-900">
      <h2 className="text-xl font-bold">Cash Gen Ceiling/Floor</h2>
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <Label>Player Name</Label>
          <Input value={player} onChange={(e) => setPlayer(e.target.value)} />
        </div>
        <div>
          <Label>Current Price ($)</Label>
          <Input 
            type="number" 
            value={currentPrice} 
            onChange={(e) => setCurrentPrice(Number(e.target.value))} 
          />
        </div>
        <div>
          <Label>Last 3 Scores (comma separated)</Label>
          <Input 
            value={last3.join(",")} 
            onChange={(e) => setLast3(e.target.value.split(",").map(Number))} 
          />
        </div>
        <div>
          <Label>Ceiling Score: {ceiling}</Label>
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
          <Label>Floor Score: {floor}</Label>
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
      <CardContent>
        <Line data={data} options={options} />
      </CardContent>
    </Card>
  );
}