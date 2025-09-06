import { useEffect, useState } from "react";
import { fetchScoringRange } from "@/services/riskService";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { BarChart3, ArrowUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";

type ScoringRangePlayer = {
  player: string;
  team: string;
  average: number;
  min_score: number;
  max_score: number;
  projected_range: string;
};

export default function ScoringRangeTable() {
  const [players, setPlayers] = useState<ScoringRangePlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const result = await fetchScoringRange();
        console.log("Scoring range data:", result);
        
        if (result.status === "ok") {
          // Handle nested data structure from the server
          if (result.players && result.players.players) {
            setPlayers(result.players.players);
          } else if (result.players) {
            setPlayers(result.players);
          } else {
            setError("Invalid data format received");
          }
        } else {
          setError("Failed to load scoring range data");
        }
      } catch (err) {
        console.error("Error loading scoring range data:", err);
        setError("Failed to load scoring range data");
      } finally {
        setLoading(false);
      }
    }
    
    loadData();
  }, []);

  // If loading or error, show appropriate message
  if (loading) {
    return <div>Loading scoring range data...</div>;
  }
  
  if (error) {
    return <div className="text-red-500">{error}</div>;
  }
  
  // If no players, show empty message
  if (!players || players.length === 0) {
    return <div>No scoring range data available.</div>;
  }

  // Sort players by average
  const sortedPlayers = [...players].sort((a, b) => {
    return sortOrder === 'asc' ? a.average - b.average : b.average - a.average;
  });

  // Function to toggle sort order
  const toggleSortOrder = () => {
    setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
  };

  // Function to calculate range width for visualization
  const getRangeWidth = (min: number, max: number) => {
    const range = max - min;
    // Return percentage width based on range (capped at 100%)
    return Math.min(range / 2, 100);
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <BarChart3 className="h-5 w-5 text-green-500" />
        <h3 className="text-lg font-medium">Scoring Range Predictor</h3>
      </div>
      
      <p className="text-sm text-gray-600">
        This tool predicts the likely scoring range for players based on their
        historical performances, helping you understand potential upside and downside.
      </p>
      
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>Player</TableHead>
            <TableHead>Team</TableHead>
            <TableHead className="text-right">
              <Button 
                variant="ghost" 
                className="p-0 h-auto font-semibold flex items-center gap-1"
                onClick={toggleSortOrder}
              >
                Average
                <ArrowUpDown className="h-4 w-4" />
              </Button>
            </TableHead>
            <TableHead className="text-right">Min</TableHead>
            <TableHead className="text-right">Max</TableHead>
            <TableHead>Range</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {sortedPlayers.map((player, i) => (
            <TableRow key={i}>
              <TableCell className="font-medium">{player.player}</TableCell>
              <TableCell>{player.team}</TableCell>
              <TableCell className="text-right">{player.average}</TableCell>
              <TableCell className="text-right">{player.min_score}</TableCell>
              <TableCell className="text-right">{player.max_score}</TableCell>
              <TableCell>
                <div className="flex items-center">
                  <div className="w-full bg-gray-200 h-2 rounded-full">
                    <div 
                      className="h-2 bg-blue-500 rounded-full" 
                      style={{ 
                        width: `${getRangeWidth(player.min_score, player.max_score)}%` 
                      }}
                    />
                  </div>
                  <span className="ml-2 text-xs text-gray-500">{player.projected_range}</span>
                </div>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}