import { useEffect, useState } from "react";
import { apiRequest } from "@/lib/queryClient";
import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Legend,
  Tooltip
} from "recharts";
import { Users } from "lucide-react";

type TeamStructure = {
  rookies: number;
  mid_pricers: number;
  premiums: number;
};

const COLORS = ['#34d399', '#60a5fa', '#8b5cf6']; // green, blue, purple

export default function TeamStructureAnalyzer() {
  const [structure, setStructure] = useState<TeamStructure | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  async function loadStructure() {
    try {
      setLoading(true);
      setError(null);
      
      const response = await apiRequest("GET", "/api/fantasy/tools/ai/team_structure_analyzer");
      const data = await response.json();
      
      if (data.status === "ok" && data.tiers) {
        setStructure(data.tiers);
      } else {
        setError("Failed to load team structure data");
      }
    } catch (err) {
      console.error("Error loading team structure:", err);
      setError("Failed to load team structure data");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadStructure();
  }, []);

  // Prepare chart data
  const getPieData = () => {
    if (!structure) return [];
    
    return [
      { name: 'Rookies', value: structure.rookies },
      { name: 'Mid-pricers', value: structure.mid_pricers },
      { name: 'Premiums', value: structure.premiums }
    ];
  };

  const getTotal = () => {
    if (!structure) return 0;
    return structure.rookies + structure.mid_pricers + structure.premiums;
  };

  const getPercentage = (value: number) => {
    const total = getTotal();
    if (total === 0) return 0;
    return Math.round((value / total) * 100);
  };

  if (loading) {
    return <div>Loading team structure analysis...</div>;
  }

  if (error) {
    return (
      <div className="space-y-4">
        <div className="text-red-500">{error}</div>
        <Button onClick={loadStructure}>Try Again</Button>
      </div>
    );
  }

  if (!structure) {
    return (
      <div className="space-y-4">
        <div>No team structure data available.</div>
        <Button onClick={loadStructure}>Analyze Structure</Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold mb-2">Team Structure Analysis</h3>
        <p className="text-sm text-gray-500 mb-4">
          AI analysis of your team's price structure across rookies, mid-pricers, and premium players.
        </p>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Chart */}
        <Card>
          <CardContent className="pt-6">
            <div className="h-64">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie
                    data={getPieData()}
                    cx="50%"
                    cy="50%"
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                    label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                  >
                    {getPieData().map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value) => [`${value} players`, 'Count']} />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
        
        {/* Stats */}
        <Card>
          <CardContent className="pt-6">
            <div className="space-y-6">
              <div className="text-center mb-4">
                <h3 className="text-lg font-semibold">Team Composition</h3>
                <p className="text-sm text-gray-500">Total: {getTotal()} players</p>
              </div>
              
              <div className="space-y-4">
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Rookies</span>
                    <span className="text-sm font-semibold">{structure.rookies} players ({getPercentage(structure.rookies)}%)</span>
                  </div>
                  <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-green-400 transition-all duration-500 ease-in-out" 
                      style={{ width: `${getPercentage(structure.rookies)}%` }}
                    ></div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Mid-pricers</span>
                    <span className="text-sm font-semibold">{structure.mid_pricers} players ({getPercentage(structure.mid_pricers)}%)</span>
                  </div>
                  <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-blue-400 transition-all duration-500 ease-in-out" 
                      style={{ width: `${getPercentage(structure.mid_pricers)}%` }}
                    ></div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-medium">Premiums</span>
                    <span className="text-sm font-semibold">{structure.premiums} players ({getPercentage(structure.premiums)}%)</span>
                  </div>
                  <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-purple-400 transition-all duration-500 ease-in-out" 
                      style={{ width: `${getPercentage(structure.premiums)}%` }}
                    ></div>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
      
      <div className="text-center pt-4">
        <Button 
          onClick={loadStructure}
          className="mx-auto"
        >
          Refresh Analysis
        </Button>
      </div>
    </div>
  );
}