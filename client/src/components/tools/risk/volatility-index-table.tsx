import { useEffect, useState } from "react";
import { fetchVolatilityIndex } from "@/services/riskService";
import { SortableTable } from "../sortable-table";

type VolatilityPlayer = {
  player_name: string;
  player?: string;
  volatility_score: number;
  // Additional fields for player bio modal
  team?: string;
  position?: string;
  price?: number;
  average_points?: number;
  breakeven?: number;
  status?: string;
  last_5_scores?: number[];
};

export default function VolatilityIndexTable() {
  const [players, setPlayers] = useState<VolatilityPlayer[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        const result = await fetchVolatilityIndex();
        console.log("Volatility data:", result);
        
        if (result.status === "ok") {
          // Handle nested data structure from the server
          let playersData = [];
          if (result.players && result.players.players) {
            playersData = result.players.players;
          } else if (result.players) {
            playersData = result.players;
          } else {
            setError("Invalid data format received");
            return;
          }
          
          // Transform data to ensure consistent structure
          const transformedPlayers = playersData.map((player: any) => ({
            ...player,
            // Ensure player_name exists (use player field if it exists)
            player_name: player.player_name || player.player || '',
            // Include original player field for compatibility
            player: player.player || player.player_name || '',
          }));
          
          setPlayers(transformedPlayers);
        } else {
          setError("Failed to load volatility index data");
        }
      } catch (err) {
        console.error("Error loading volatility index data:", err);
        setError("Failed to load volatility index data");
      } finally {
        setLoading(false);
      }
    }
    
    loadData();
  }, []);

  // Function to get color class based on volatility score
  const getVolatilityColor = (score: number) => {
    if (score >= 30) return "text-red-500 font-medium";
    if (score >= 20) return "text-orange-500 font-medium";
    if (score >= 10) return "text-yellow-500 font-medium";
    return "text-green-500 font-medium";
  };

  // Define columns for the sortable table
  const columns = [
    {
      key: "player_name",
      label: "Player",
      sortable: true,
    },
    {
      key: "volatility_score",
      label: "Volatility Score",
      sortable: true,
      render: (value: number) => (
        <span className={getVolatilityColor(value)}>
          {value.toFixed(1)}
        </span>
      ),
    },
  ];

  // If loading or error, show appropriate message
  if (loading) {
    return <div>Loading volatility index data...</div>;
  }
  
  if (error) {
    return <div className="text-red-500">{error}</div>;
  }
  
  // If no players, show empty message
  if (!players || players.length === 0) {
    return <div>No volatility index data available.</div>;
  }

  return (
    <div className="space-y-4">
      <p className="text-sm text-gray-600 mb-4">
        This tool calculates player score volatility to help you identify consistent 
        performers versus high variance players. Lower scores indicate more consistent performers.
      </p>
      
      <SortableTable 
        data={players} 
        columns={columns} 
        emptyMessage="No volatility index data available." 
      />
    </div>
  );
}