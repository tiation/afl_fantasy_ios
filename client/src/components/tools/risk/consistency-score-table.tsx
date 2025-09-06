import { useEffect, useState } from "react";
import { fetchConsistencyScore } from "@/services/riskService";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Calculator, ArrowUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";

type ConsistencyPlayer = {
  player: string;
  team: string;
  consistency_score: number;
  floor_score: number;
};

export default function ConsistencyScoreTable() {
  const [players, setPlayers] = useState<ConsistencyPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const result = await fetchConsistencyScore();
        console.log("Consistency data:", result);
        
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
          setError("Failed to load consistency score data");
        }
      } catch (err) {
        console.error("Error loading consistency score data:", err);
        setError("Failed to load consistency score data");
      } finally {
        setLoading(false);
      }
    }
    
    loadData();
  }, []);

  // If loading or error, show appropriate message
  if (loading) {
    return <div>Loading consistency score data...</div>;
  }
  
  if (error) {
    return <div className="text-red-500">{error}</div>;
  }
  
  // If no players, show empty message
  if (!players || players.length === 0) {
    return <div>No consistency score data available.</div>;
  }

  // Sort players by consistency score
  const sortedPlayers = [...players].sort((a, b) => {
    return sortOrder === 'asc' 
      ? a.consistency_score - b.consistency_score
      : b.consistency_score - a.consistency_score;
  });

  // Function to toggle sort order
  const toggleSortOrder = () => {
    setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
  };

  // Function to get color class based on consistency score
  const getConsistencyColor = (score: number) => {
    if (score >= 8) return "text-green-500 font-medium";
    if (score >= 6) return "text-blue-500 font-medium";
    if (score >= 4) return "text-orange-500 font-medium";
    return "text-red-500 font-medium";
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <Calculator className="h-5 w-5 text-blue-500" />
        <h3 className="text-lg font-medium">Consistency Score Generator</h3>
      </div>
      
      <p className="text-sm text-gray-600">
        This tool generates consistency scores for players, helping you identify 
        reliable performers for your team. Higher scores indicate more consistent performances.
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
                Consistency Score
                <ArrowUpDown className="h-4 w-4" />
              </Button>
            </TableHead>
            <TableHead className="text-right">Floor Score</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {sortedPlayers.map((player, i) => (
            <TableRow key={i}>
              <TableCell className="font-medium">{player.player}</TableCell>
              <TableCell>{player.team}</TableCell>
              <TableCell className={`text-right ${getConsistencyColor(player.consistency_score)}`}>
                {player.consistency_score.toFixed(1)}
              </TableCell>
              <TableCell className="text-right">{player.floor_score}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}