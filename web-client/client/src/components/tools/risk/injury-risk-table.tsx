import { useEffect, useState } from "react";
import { fetchInjuryRisk } from "@/services/riskService";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { AlertTriangle, ArrowUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";

type InjuryRiskPlayer = {
  player: string;
  team: string;
  risk_level: string;
  injury_history?: string;
};

export default function InjuryRiskTable() {
  const [players, setPlayers] = useState<InjuryRiskPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const result = await fetchInjuryRisk();
        console.log("Injury risk data:", result);
        
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
          setError("Failed to load injury risk data");
        }
      } catch (err) {
        console.error("Error loading injury risk data:", err);
        setError("Failed to load injury risk data");
      } finally {
        setLoading(false);
      }
    }
    
    loadData();
  }, []);

  // If loading or error, show appropriate message
  if (loading) {
    return <div>Loading injury risk data...</div>;
  }
  
  if (error) {
    return <div className="text-red-500">{error}</div>;
  }
  
  // If no players, show empty message
  if (!players || players.length === 0) {
    return <div>No injury risk data available.</div>;
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
        <AlertTriangle className="h-5 w-5 text-red-500" />
        <h3 className="text-lg font-medium">Injury Risk Model</h3>
      </div>
      
      <p className="text-sm text-gray-600">
        This tool models injury risk for players based on history and current status,
        helping you minimize risk in your fantasy team selection.
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
            <TableHead>Injury History</TableHead>
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
              <TableCell className="text-sm text-gray-600">
                {player.injury_history || "No recent injuries"}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}