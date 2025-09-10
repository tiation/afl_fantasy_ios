import { useState, useEffect } from "react";
import { useQuery } from "@tanstack/react-query";
import { useLocation } from "wouter";
import SimplePlayerTable from "@/components/player-stats/simple-player-table";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { AlertCircle, Loader2 } from "lucide-react";

interface Player {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  averagePoints: number;
  lastScore: number;
  projectedScore: number;
  breakEven: number;
  l3Average: number;
  l5Average: number;
  priceChange: number;
  selectionPercentage: number;
  roundsPlayed: number;
  totalPoints: number;
  kicks?: number;
  handballs?: number;
  disposals?: number;
  marks?: number;
  tackles?: number;
  clearances?: number;
  hitouts?: number;
  standardDeviation?: number;
  consistency?: number;
  isInjured?: boolean;
  isSuspended?: boolean;
}

export default function PlayerStats() {
  const [searchQuery, setSearchQuery] = useState("");
  const [positionFilter, setPositionFilter] = useState("");
  const [location] = useLocation();
  
  // Extract search query from URL if present
  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const q = urlParams.get("q");
    if (q) {
      setSearchQuery(q);
    }
  }, [location]);

  // Player data fetching with proper error handling
  const { data: players, isLoading, error } = useQuery<Player[]>({
    queryKey: ['/api/stats/combined-stats'],
    retry: 3,
    retryDelay: 1000,
  });

  if (error) {
    return (
      <div className="p-4">
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>
            Failed to load player statistics. Please check your connection and try again.
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center p-8">
        <Loader2 className="h-8 w-8 animate-spin" />
        <span className="ml-2">Loading player statistics...</span>
      </div>
    );
  }

  return (
    <div className="p-4 space-y-4">
      <div>
        <h1 className="text-3xl font-bold text-white mb-2">Player Statistics</h1>
        <p className="text-gray-400">Comprehensive analysis across all player categories</p>
      </div>
      
      <SimplePlayerTable 
        players={players || []} 
        isLoading={isLoading}
      />
    </div>
  );
}
