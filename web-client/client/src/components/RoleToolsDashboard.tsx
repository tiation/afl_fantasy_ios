import React, { useState, useEffect } from "react";
import { Card } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { 
  ArrowRightCircle, 
  TrendingUp, 
  TrendingDown,
  LayoutGrid,
  FileBarChart,
  Clock
} from "lucide-react";

type RoleChangePlayer = {
  player: string;
  team: string;
  old_role: string;
  new_role: string;
  role_change: string;
  fantasy_impact: string;
  last_update: string;
};

type CBAPlayer = {
  player: string;
  team: string;
  recent_cba_percentage: number;
  previous_cba_percentage: number;
  cba_change: number;
  trend_direction: string;
  fantasy_relevance: string;
};

type PositionImpact = {
  position: string;
  avg_score_in_position: number;
  ceiling: number;
  floor: number;
  score_volatility: string;
  fantasy_opportunities: number;
};

type PossessionPlayer = {
  player: string;
  team: string;
  contested_possession_pct: number;
  uncontested_possession_pct: number;
  inside_50s_per_game: number;
  rebound_50s_per_game: number;
  tackles_per_game: number;
  clearances_per_game: number;
  fantasy_points_per_possession: number;
};

export default function RoleToolsDashboard() {
  // State for role change data
  const [roleChanges, setRoleChanges] = useState<RoleChangePlayer[]>([]);
  const [loadingRoleChanges, setLoadingRoleChanges] = useState(true);
  
  // State for CBA trend data
  const [cbaTrends, setCBATrends] = useState<CBAPlayer[]>([]);
  const [loadingCBATrends, setLoadingCBATrends] = useState(true);
  
  // State for positional impact data
  const [positionImpacts, setPositionImpacts] = useState<PositionImpact[]>([]);
  const [loadingPositionImpacts, setLoadingPositionImpacts] = useState(true);
  
  // State for possession profile data
  const [possessionProfiles, setPossessionProfiles] = useState<PossessionPlayer[]>([]);
  const [loadingPossessionProfiles, setLoadingPossessionProfiles] = useState(true);

  useEffect(() => {
    // Load role change data (mock data for now)
    const mockRoleChanges = [
      {
        player: "Marcus Bontempelli",
        team: "Western Bulldogs",
        old_role: "Inside Mid",
        new_role: "Forward",
        role_change: "Midfield to Forward",
        fantasy_impact: "High",
        last_update: "2025-05-01"
      },
      {
        player: "Christian Petracca",
        team: "Melbourne",
        old_role: "Inside Mid",
        new_role: "Wing",
        role_change: "Inside Mid to Wing",
        fantasy_impact: "Medium",
        last_update: "2025-05-01"
      }
    ];
    
    // Load CBA trend data (mock data for now)
    const mockCBATrends = [
      {
        player: "Max Gawn",
        team: "Melbourne",
        recent_cba_percentage: 95,
        previous_cba_percentage: 90,
        cba_change: 5,
        trend_direction: "up",
        fantasy_relevance: "Medium"
      },
      {
        player: "Tim English",
        team: "Western Bulldogs",
        recent_cba_percentage: 85,
        previous_cba_percentage: 75,
        cba_change: 10,
        trend_direction: "up",
        fantasy_relevance: "Medium"
      }
    ];
    
    // Load positional impact data (mock data for now)
    const mockPositionImpacts = [
      {
        position: "Inside Mid",
        avg_score_in_position: 95,
        ceiling: 145,
        floor: 60,
        score_volatility: "Medium",
        fantasy_opportunities: 9
      },
      {
        position: "Ruck",
        avg_score_in_position: 90,
        ceiling: 135,
        floor: 55,
        score_volatility: "High",
        fantasy_opportunities: 8
      }
    ];
    
    // Load possession profile data (mock data for now)
    const mockPossessionProfiles = [
      {
        player: "Jack Macrae",
        team: "Western Bulldogs",
        contested_possession_pct: 40,
        uncontested_possession_pct: 60,
        inside_50s_per_game: 4.5,
        rebound_50s_per_game: 1.2,
        tackles_per_game: 5.3,
        clearances_per_game: 6.1,
        fantasy_points_per_possession: 0.48
      },
      {
        player: "Lachie Neale",
        team: "Brisbane Lions",
        contested_possession_pct: 55,
        uncontested_possession_pct: 45,
        inside_50s_per_game: 3.8,
        rebound_50s_per_game: 0.9,
        tackles_per_game: 6.5,
        clearances_per_game: 7.2,
        fantasy_points_per_possession: 0.52
      }
    ];

    // Set data with slight delay to simulate API calls
    setTimeout(() => {
      setRoleChanges(mockRoleChanges);
      setLoadingRoleChanges(false);
      
      setCBATrends(mockCBATrends);
      setLoadingCBATrends(false);
      
      setPositionImpacts(mockPositionImpacts);
      setLoadingPositionImpacts(false);
      
      setPossessionProfiles(mockPossessionProfiles);
      setLoadingPossessionProfiles(false);
    }, 500);
  }, []);

  // Helper functions
  const getImpactBadge = (impact: string) => {
    let color = "";
    switch (impact.toLowerCase()) {
      case 'high': color = "bg-red-500 text-white"; break;
      case 'medium': color = "bg-amber-500 text-white"; break;
      case 'low': color = "bg-green-500 text-white"; break;
      default: color = "bg-gray-500 text-white";
    }
    return <span className={`px-2 py-1 rounded text-xs font-bold ${color}`}>{impact}</span>;
  };

  const getTrendIndicator = (trend: string) => {
    if (trend === "up") return <TrendingUp className="h-4 w-4 text-green-500" />;
    if (trend === "down") return <TrendingDown className="h-4 w-4 text-red-500" />;
    return <Clock className="h-4 w-4 text-gray-500" />;
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      {/* Role Change Detector */}
      <Card className="p-4 shadow-md">
        <div className="flex items-center gap-2 mb-3">
          <ArrowRightCircle className="h-5 w-5 text-purple-600" />
          <h3 className="text-lg font-bold">Role Change Detector</h3>
        </div>
        
        {loadingRoleChanges ? (
          <p>Loading role changes...</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-2">Player</th>
                  <th className="text-left py-2">Role Change</th>
                  <th className="text-right py-2">Impact</th>
                </tr>
              </thead>
              <tbody>
                {roleChanges.map((player, i) => (
                  <tr key={i} className="border-b">
                    <td className="py-2 font-medium">
                      {player.player}
                      <div className="text-xs text-gray-500">{player.team}</div>
                    </td>
                    <td className="py-2">
                      <div className="flex items-center gap-1">
                        <span className="text-xs text-gray-500">{player.old_role}</span>
                        <ArrowRightCircle className="h-3 w-3 text-purple-600" />
                        <span className="text-xs font-medium">{player.new_role}</span>
                      </div>
                    </td>
                    <td className="py-2 text-right">{getImpactBadge(player.fantasy_impact)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
      
      {/* CBA Trend Analyzer */}
      <Card className="p-4 shadow-md">
        <div className="flex items-center gap-2 mb-3">
          <TrendingUp className="h-5 w-5 text-green-600" />
          <h3 className="text-lg font-bold">CBA Trend Analyzer</h3>
        </div>
        
        {loadingCBATrends ? (
          <p>Loading CBA trends...</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-2">Player</th>
                  <th className="text-center py-2">Recent %</th>
                  <th className="text-right py-2">Change</th>
                  <th className="text-right py-2">Trend</th>
                </tr>
              </thead>
              <tbody>
                {cbaTrends.map((player, i) => (
                  <tr key={i} className="border-b">
                    <td className="py-2 font-medium">
                      {player.player}
                      <div className="text-xs text-gray-500">{player.team}</div>
                    </td>
                    <td className="py-2 text-center">{player.recent_cba_percentage}%</td>
                    <td className={`py-2 text-right ${player.cba_change > 0 ? "text-green-500" : player.cba_change < 0 ? "text-red-500" : ""}`}>
                      {player.cba_change > 0 ? "+" : ""}{player.cba_change}%
                    </td>
                    <td className="py-2 text-right">{getTrendIndicator(player.trend_direction)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
      
      {/* Positional Impact Scoring */}
      <Card className="p-4 shadow-md">
        <div className="flex items-center gap-2 mb-3">
          <LayoutGrid className="h-5 w-5 text-blue-600" />
          <h3 className="text-lg font-bold">Positional Impact Scoring</h3>
        </div>
        
        {loadingPositionImpacts ? (
          <p>Loading position impacts...</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-2">Position</th>
                  <th className="text-center py-2">Avg Score</th>
                  <th className="text-right py-2">Ceiling/Floor</th>
                </tr>
              </thead>
              <tbody>
                {positionImpacts.map((pos, i) => (
                  <tr key={i} className="border-b">
                    <td className="py-2 font-medium">{pos.position}</td>
                    <td className="py-2 text-center font-medium">{pos.avg_score_in_position}</td>
                    <td className="py-2 text-right">
                      <span className="text-green-500">{pos.ceiling}</span>
                      {" / "}
                      <span className="text-red-500">{pos.floor}</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
      
      {/* Possession Type Profiler */}
      <Card className="p-4 shadow-md">
        <div className="flex items-center gap-2 mb-3">
          <FileBarChart className="h-5 w-5 text-orange-600" />
          <h3 className="text-lg font-bold">Possession Type Profiler</h3>
        </div>
        
        {loadingPossessionProfiles ? (
          <p>Loading possession profiles...</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b">
                  <th className="text-left py-2">Player</th>
                  <th className="text-center py-2">Contested %</th>
                  <th className="text-right py-2">Fantasy Pts/Poss</th>
                </tr>
              </thead>
              <tbody>
                {possessionProfiles.map((player, i) => (
                  <tr key={i} className="border-b">
                    <td className="py-2 font-medium">
                      {player.player}
                      <div className="text-xs text-gray-500">{player.team}</div>
                    </td>
                    <td className="py-2 text-center">{player.contested_possession_pct}%</td>
                    <td className="py-2 text-right font-medium">{player.fantasy_points_per_possession.toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    </div>
  );
}