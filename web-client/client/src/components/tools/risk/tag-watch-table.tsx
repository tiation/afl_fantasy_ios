import { useEffect, useState } from "react";
import { fetchTagWatchMonitor } from "@/services/riskService";
import { Badge } from "@/components/ui/badge";
import { AlertCircle } from "lucide-react";
import { SortableTable } from "../sortable-table";

type TagWatchPlayer = {
  player_name: string;
  team: string;
  tag_risk: string;
  player?: string;
  // Add additional fields that might be used for player bio
  position?: string;
  price?: number;
  average_points?: number;
  breakeven?: number;
  status?: string;
  last_5_scores?: number[];
};

export function TagWatchTable() {
  const [data, setData] = useState<TagWatchPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const result = await fetchTagWatchMonitor();
        console.log('Tag Watch Data:', result);
        
        if (result.status === "ok") {
          // Handle nested data structure from the server
          let players = [];
          if (result.players && result.players.players) {
            players = result.players.players;
          } else if (result.players) {
            players = result.players;
          } else {
            setError("Invalid data format received");
            return;
          }
          
          // Transform to ensure consistent structure
          const transformedPlayers = players.map((player: any) => ({
            ...player,
            // Ensure player_name exists (use player field if it exists)
            player_name: player.player_name || player.player || '',
            // Include original player field for compatibility
            player: player.player || player.player_name || '',
          }));
          
          setData(transformedPlayers);
        } else {
          setError("Failed to load tag watch data");
        }
      } catch (err) {
        console.error("Error loading tag watch data:", err);
        setError("Failed to load tag watch data");
      } finally {
        setLoading(false);
      }
    }
    
    loadData();
  }, []);

  // Define columns for the sortable table
  const columns = [
    {
      key: "player_name",
      label: "Player",
      sortable: true,
    },
    {
      key: "team",
      label: "Team",
      sortable: true,
    },
    {
      key: "tag_risk",
      label: "Tag Risk",
      sortable: true,
      render: (value: string) => (
        <Badge 
          variant={value === "High" ? "destructive" : "outline"}
          className="flex items-center gap-1"
        >
          {value === "High" && <AlertCircle className="h-3 w-3" />}
          {value}
        </Badge>
      ),
    },
  ];

  // If loading or error, show appropriate message
  if (loading) {
    return <div>Loading tag watch data...</div>;
  }
  
  if (error) {
    return <div className="text-red-500">{error}</div>;
  }
  
  // If no players, show empty message
  if (!data || data.length === 0) {
    return <div>No tag watch data available.</div>;
  }

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-600 mb-4">
        This tool identifies players who are frequently tagged by opponents, 
        helping you make informed decisions about player selection.
      </p>
      
      <SortableTable 
        data={data} 
        columns={columns} 
        emptyMessage="No tag watch data available." 
      />
    </div>
  );
}