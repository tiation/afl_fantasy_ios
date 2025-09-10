import React, { useState, useEffect, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import HeatMapView from "@/components/player-stats/heat-map-view";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Separator } from "@/components/ui/separator";
import { Button } from "@/components/ui/button";
import { 
  Loader2, Search, Filter, Download, ChevronUp, ChevronDown, 
  Shield, Dumbbell, Users, ChevronRight, Share2, Info
} from "lucide-react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import CollapsibleStatsKey from "@/components/player-stats/collapsible-stats-key";
import { categoryTitleMap, categoryConfigs, statsKeyExplanations } from "@/components/player-stats/category-header-mapper";
import NewPlayerStats from "@/components/player-stats/new-player-stats";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuTrigger
} from "@/components/ui/dropdown-menu";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";

export default function StatsPage() {
  const [activeTab, setActiveTab] = useState("all-players");
  const [searchQuery, setSearchQuery] = useState("");
  const [positionFilter, setPositionFilter] = useState<string>("all");
  const [teamFilter, setTeamFilter] = useState<string>("all");
  const [sortField, setSortField] = useState<string>("price");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");
  const [selectedPlayer, setSelectedPlayer] = useState<any>(null);
  const [activeSection, setActiveSection] = useState("stats-redesign");
  const [activeCategory, setActiveCategory] = useState("rd-key-stats");
  
  // Fetch data from API
  const { data: dfsData, isLoading: dfsLoading } = useQuery({
    queryKey: ['/api/stats/dfs-australia'],
    staleTime: 1000 * 60 * 5, // 5 minutes
  });
  
  const { data: footyWireData, isLoading: footyWireLoading } = useQuery({
    queryKey: ['/api/stats/footywire'],
    staleTime: 1000 * 60 * 5, // 5 minutes
  });
  
  const { data: combinedData, isLoading: combinedLoading } = useQuery({
    queryKey: ['/api/stats/combined-stats'],
    staleTime: 1000 * 60 * 5, // 5 minutes
  });

  // Fetch projected scores for all players using the new comprehensive endpoint
  const { data: projectedScores } = useQuery({
    queryKey: ['/api/score-projection/all-players'],
    queryFn: async () => {
      const response = await fetch('/api/score-projection/all-players?round=20');
      if (!response.ok) throw new Error('Failed to fetch projected scores');
      const result = await response.json();
      return result.success ? result.data : [];
    },
    enabled: !!combinedData,
    staleTime: 1000 * 60 * 10, // 10 minutes
  });

  // Enhanced data with projected scores
  const enhancedData = useMemo(() => {
    if (!combinedData || !Array.isArray(combinedData)) return [];
    
    // Create a map of projected scores by player name
    const projectedScoreMap = new Map();
    if (projectedScores && Array.isArray(projectedScores)) {
      projectedScores.forEach((proj: any) => {
        projectedScoreMap.set(proj.playerName, proj.projectedScore);
      });
    }
    
    return combinedData.map((player: any) => ({
      ...player,
      projectedScore: projectedScoreMap.get(player.name) || 0
    }));
  }, [combinedData, projectedScores]);
  
  // Define the typing for DVP matrix
  interface DVPData {
    pointsAllowed?: number;
    dvpScore?: number;
  }
  
  interface DVPMatrix {
    DEF: Record<string, DVPData>;
    MID: Record<string, DVPData>;
    RUC: Record<string, DVPData>;
    FWD: Record<string, DVPData>;
  }
  
  const { data: dvpMatrix, isLoading: dvpLoading } = useQuery<DVPMatrix>({
    queryKey: ['/api/stats/dvp-matrix'],
    staleTime: 1000 * 60 * 60, // 1 hour
  });
  
  // Determine which data to display based on active tab
  const displayData = (): any[] => {
    if (activeTab === "all-players") {
      return Array.isArray(enhancedData) ? enhancedData : [];
    } else if (activeTab === "dfs-australia") {
      return Array.isArray(dfsData) ? dfsData : [];
    } else if (activeTab === "footywire") {
      return Array.isArray(footyWireData) ? footyWireData : [];
    }
    return [];
  };
  
  // Filter and sort the data
  const processedData = () => {
    let data = displayData();
    
    // Apply search filter
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      data = data.filter((player: any) => 
        player.name?.toLowerCase().includes(query) ||
        player.team?.toLowerCase().includes(query)
      );
    }
    
    // Apply position filter
    if (positionFilter && positionFilter !== "all") {
      data = data.filter((player: any) => player.position === positionFilter);
    }
    
    // Apply team filter
    if (teamFilter && teamFilter !== "all") {
      data = data.filter((player: any) => player.team === teamFilter);
    }
    
    // Sort data
    if (sortField) {
      data = [...data].sort((a: any, b: any) => {
        if (a[sortField] === undefined || a[sortField] === null) return 1;
        if (b[sortField] === undefined || b[sortField] === null) return -1;
        
        if (typeof a[sortField] === 'string') {
          return sortDirection === 'asc' 
            ? a[sortField].localeCompare(b[sortField])
            : b[sortField].localeCompare(a[sortField]);
        } else {
          return sortDirection === 'asc' 
            ? a[sortField] - b[sortField]
            : b[sortField] - a[sortField];
        }
      });
    }
    
    return data;
  };
  
  // Update sort when header is clicked
  const handleSort = (field: string) => {
    if (sortField === field) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc');
    } else {
      setSortField(field);
      setSortDirection('desc');
    }
  };
  
  // Get sort icon
  const getSortIcon = (field: string) => {
    if (sortField !== field) return null;
    return sortDirection === 'asc' ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />;
  };
  
  // Extract unique teams for the filter
  const getUniqueTeams = () => {
    const data = displayData();
    const teams = new Set(data.map((player: any) => player.team).filter(Boolean));
    return Array.from(teams).sort();
  };
  
  // Handle export to CSV
  const exportToCSV = () => {
    const data = processedData();
    const headers = ["Name", "Position", "Team", "Price", "Avg", "BE", "L3", "L5", "Last", "Proj"];
    
    // Create CSV content
    const csvContent = [
      headers.join(','),
      ...data.map((player: any) => [
        player.name || '',
        player.position || '',
        player.team || '',
        player.price || 0,
        player.averageScore || 0,
        player.breakEven || 0,
        player.l3Average || 0,
        player.l5Average || 0,
        player.lastScore || 0,
        player.projectedScore || 0
      ].join(','))
    ].join('\n');
    
    // Create download link
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', 'afl_fantasy_stats.csv');
    link.style.visibility = 'hidden';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };
  
  // Loading state
  if ((activeTab === "all-players" && combinedLoading) || 
      (activeTab === "dfs-australia" && dfsLoading) || 
      (activeTab === "footywire" && footyWireLoading)) {
    return (
      <div className="flex items-center justify-center h-96">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <p className="ml-2">Loading player data...</p>
      </div>
    );
  }
  
  // Define colors for golden sections like in the screenshots
  const sectionColors = {
    headerBg: "bg-amber-300",
    headerText: "text-gray-800",
    greenButton: "bg-green-500 hover:bg-green-600 text-white",
    sortButton: "bg-green-500 hover:bg-green-600 text-white rounded-lg",
    tabButton: "bg-gray-200 hover:bg-gray-300",
    activeTab: "bg-green-500 text-white",
  };
  
  // Function to open player details dialog
  const openPlayerDetails = (player: any) => {
    setSelectedPlayer(player);
  };

  return (
    <div className="container mx-auto py-3">
      <div className="space-y-4">
        {/* Stats Table Section - Now at top */}
        <div className="w-full">
          <div className="p-4 bg-gray-900 rounded-lg shadow-lg">
                {/* Full width stats table */}
                <NewPlayerStats
                  players={processedData().map((player: any) => ({
                    id: player.id || player.name,
                    name: player.name,
                    team: player.team || "Unknown",
                    position: player.position || "MID",
                    price: player.price || 0,
                    averagePoints: player.averagePoints || player.averageScore || 0,
                    lastScore: player.lastScore || 0,
                    l3Average: player.l3Average || 0,
                    l5Average: player.l5Average || 0,
                    breakEven: player.breakEven || 0,
                    priceChange: player.priceChange || 0,
                    pricePerPoint: player.pricePerPoint || 0,
                    totalPoints: player.totalPoints || 0,
                    selectionPercentage: player.selectionPercentage || 0,
                    kicks: player.kicks || 0,
                    handballs: player.handballs || 0,
                    marks: player.marks || 0,
                    tackles: player.tackles || 0,
                    hitouts: player.hitouts || 0,
                    freeKicksFor: player.freeKicksFor || 0,
                    freeKicksAgainst: player.freeKicksAgainst || 0,
                    clearances: player.clearances || 0,
                    cba: player.cba || 0,
                    kickIns: player.kickIns || 0,
                    contestedMarks: player.contestedMarks || 0,
                    uncontestedMarks: player.uncontestedMarks || 0,
                    contestedDisposals: player.contestedDisposals || 0,
                    uncontestedDisposals: player.uncontestedDisposals || 0,
                    disposals: player.disposals || 0,
                  }))}
                  isLoading={combinedLoading}
                  onSearch={setSearchQuery}
                  onFilter={(position) => setPositionFilter(position)}
                  searchQuery={searchQuery}
                  positionFilter={positionFilter}
                />
              </div>
          </div>

        {/* Visualization Cards - HeatMapView Component */}
        <div className="mb-6">
          <HeatMapView 
            players={processedData().map((player: any) => ({
              id: player.id || player.name,
              name: player.name,
              team: player.team || "Unknown",
              position: player.position || "MID",
              price: player.price || 0,
              averagePoints: player.averagePoints || player.averageScore || 0,
              lastScore: player.lastScore || 0,
              l3Average: player.l3Average || 0,
              l5Average: player.l5Average || 0,
              breakEven: player.breakEven || 0,
              priceChange: player.priceChange || 0,
              pricePerPoint: player.pricePerPoint || 0,
              totalPoints: player.totalPoints || 0,
              selectionPercentage: player.selectionPercentage || 0,
            }))}
            dvpMatrix={dvpMatrix || { DEF: {}, MID: {}, RUC: {}, FWD: {} }}
          />
        </div>
      </div>
    </div>
  );
}