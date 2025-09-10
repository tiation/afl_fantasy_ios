import { useEffect, useState } from "react";
import { fetchLateOutRisk } from "@/services/riskService";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Clock, ArrowUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

type LateOutRiskPlayer = {
  player: string;
  team: string;
  risk_level: string;
  next_game?: string;
};

export default function LateOutRiskTable() {
  const [players, setPlayers] = useState<LateOutRiskPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const result = await fetchLateOutRisk();
        console.log("Late out risk data:", result);
        
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
          setError("Failed to load late out risk data");
        }
      } catch (err) {
        console.error("Error loading late out risk data:", err);
        setError("Failed to load late out risk data");
      } finally {
        setLoading(false);
      }
    }
    
    loadData();
  }, []);

  // If loading or error, show appropriate message
  if (loading) {
    return <div>Loading late out risk data...</div>;
  }
  
  if (error) {
    return <div className="text-red-500">{error}</div>;
  }
  
  // If no players, show empty message
  if (!players || players.length === 0) {
    return <div>No late out risk data available.</div>;
  }

  // Sort players by risk level
  const getRiskValue = (risk: string) => {
    switch (risk.toLowerCase()) {
      case 'high': return 3;
      case 'medium': return 2;
      case 'low': return 1;
      default: return 0;
    }
  };

  const sortedPlayers = [...players].sort((a, b) => {
    const aValue = getRiskValue(a.risk_level);
    const bValue = getRiskValue(b.risk_level);
    return sortOrder === 'asc' ? aValue - bValue : bValue - aValue;
  });

  // Function to toggle sort order
  const toggleSortOrder = () => {
    setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
  };

  // Function to get badge variant based on risk level
  const getRiskBadgeVariant = (risk: string) => {
    switch (risk.toLowerCase()) {
      case 'high': return "destructive";
      case 'medium': return "warning";
      case 'low': return "outline";
      default: return "secondary";
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <Clock className="h-5 w-5 text-orange-500" />
        <h3 className="text-lg font-medium">Late Out Risk Estimator</h3>
      </div>
      
      <p className="text-sm text-gray-600">
        This tool estimates the risk of players being late withdrawals, helping you
        avoid potential selection issues close to game time.
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
                Risk Level
                <ArrowUpDown className="h-4 w-4" />
              </Button>
            </TableHead>
            <TableHead>Next Game</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {sortedPlayers.map((player, i) => (
            <TableRow key={i}>
              <TableCell className="font-medium">{player.player}</TableCell>
              <TableCell>{player.team}</TableCell>
              <TableCell className="text-right">
                <Badge 
                  variant={getRiskBadgeVariant(player.risk_level)} 
                  className="ml-auto"
                >
                  {player.risk_level}
                </Badge>
              </TableCell>
              <TableCell>{player.next_game || "Unknown"}</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}