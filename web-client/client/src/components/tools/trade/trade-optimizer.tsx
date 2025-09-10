import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { formatCurrency } from "@/lib/utils";
import { 
  AlertCircle, 
  Cpu, 
  ArrowRight, 
  TrendingUp, 
  ChevronDown, 
  ChevronUp, 
  Users, 
  Percent
} from "lucide-react";

type Player = {
  id: number;
  name: string;
  position: string;
  team: string;
  price: number;
  breakEven?: number;
  averagePoints?: number;
  lastScore?: number;
  projectedPoints?: number;
  roi?: number;
  valuePerPoint?: number;
  ownership?: number;
  nextOpponent?: string;
};

type OptimizedTradeResult = {
  playerOut: Player;
  playerIn: Player;
  projectedPointsGain: number;
  valueChange: number;
  roi: number;
  confidence: number;
  reasoning: string;
};

export function TradeOptimizer() {
  const [results, setResults] = useState<OptimizedTradeResult[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [budget, setBudget] = useState(300000);
  const [position, setPosition] = useState<string>("ALL");
  const [sortBy, setSortBy] = useState<string>("roi");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");
  const [showAll, setShowAll] = useState(false);

  // Mock data
  const mockResults: OptimizedTradeResult[] = [
    {
      playerOut: {
        id: 101,
        name: "Jack Macrae",
        position: "MID",
        team: "WB",
        price: 783000,
        breakEven: 132,
        averagePoints: 88.4,
        lastScore: 65,
        projectedPoints: 91.5,
        valuePerPoint: 8855,
        ownership: 12.3,
        nextOpponent: "ESS"
      },
      playerIn: {
        id: 201,
        name: "Errol Gulden",
        position: "MID",
        team: "SYD",
        price: 915000,
        breakEven: 110,
        averagePoints: 128.3,
        lastScore: 128,
        projectedPoints: 122.7,
        valuePerPoint: 7130,
        ownership: 18.9,
        nextOpponent: "NTH"
      },
      projectedPointsGain: 31.2,
      valueChange: -132000,
      roi: 0.24,
      confidence: 0.85,
      reasoning: "Gulden's consistent ceiling makes him a premium upgrade despite the price difference. Macrae's role has diminished in recent weeks."
    },
    {
      playerOut: {
        id: 102,
        name: "Tom Hawkins",
        position: "FWD",
        team: "GEEL",
        price: 654000,
        breakEven: 105,
        averagePoints: 76.7,
        lastScore: 62,
        projectedPoints: 71.5,
        valuePerPoint: 8527,
        ownership: 8.1,
        nextOpponent: "HAW"
      },
      playerIn: {
        id: 202,
        name: "Charlie Curnow",
        position: "FWD",
        team: "CARL",
        price: 825000,
        breakEven: 85,
        averagePoints: 92.4,
        lastScore: 115,
        projectedPoints: 96.8,
        valuePerPoint: 8934,
        ownership: 22.5,
        nextOpponent: "COL"
      },
      projectedPointsGain: 25.3,
      valueChange: -171000,
      roi: 0.15,
      confidence: 0.78,
      reasoning: "Curnow's ceiling and form have been elite, making him worth the upgrade cost. Hawkins is showing signs of decline in his TOG and scoring output."
    },
    {
      playerOut: {
        id: 103,
        name: "Nick Watson",
        position: "FWD",
        team: "GCFC",
        price: 475000,
        breakEven: 92,
        averagePoints: 75.2,
        lastScore: 68,
        projectedPoints: 68.4,
        valuePerPoint: 6316,
        ownership: 31.2,
        nextOpponent: "MEL"
      },
      playerIn: {
        id: 203,
        name: "Izak Rankine",
        position: "FWD",
        team: "ADEL",
        price: 745000,
        breakEven: 65,
        averagePoints: 82.5,
        lastScore: 94,
        projectedPoints: 89.3,
        valuePerPoint: 9030,
        ownership: 15.8,
        nextOpponent: "PTA"
      },
      projectedPointsGain: 20.9,
      valueChange: -270000,
      roi: 0.08,
      confidence: 0.75,
      reasoning: "Watson has peaked in price with BE approaching his average. Rankine offers significantly higher ceiling and consistent midfield minutes."
    },
    {
      playerOut: {
        id: 104,
        name: "Jeremy Cameron",
        position: "FWD",
        team: "GEEL",
        price: 682000,
        breakEven: 112,
        averagePoints: 80.3,
        lastScore: 0,
        projectedPoints: 0,
        valuePerPoint: 8493,
        ownership: 18.4,
        nextOpponent: "HAW"
      },
      playerIn: {
        id: 204,
        name: "Noah Anderson",
        position: "MID",
        team: "GCFC",
        price: 678000,
        breakEven: 72,
        averagePoints: 84.7,
        lastScore: 92,
        projectedPoints: 88.5,
        valuePerPoint: 8004,
        ownership: 6.2,
        nextOpponent: "MEL"
      },
      projectedPointsGain: 88.5,
      valueChange: 4000,
      roi: 22.13,
      confidence: 0.95,
      reasoning: "Cameron is injured (concussion) and out for at least one week. Anderson offers similar price point with excellent form and low ownership."
    },
    {
      playerOut: {
        id: 105,
        name: "Sean Darcy",
        position: "RUCK",
        team: "FREM",
        price: 692000,
        breakEven: 115,
        averagePoints: 75.1,
        lastScore: 45,
        projectedPoints: 72.8,
        valuePerPoint: 9215,
        ownership: 5.9,
        nextOpponent: "RIC"
      },
      playerIn: {
        id: 205,
        name: "Tim English",
        position: "RUCK",
        team: "WB",
        price: 978000,
        breakEven: 95,
        averagePoints: 115.6,
        lastScore: 124,
        projectedPoints: 112.3,
        valuePerPoint: 8459,
        ownership: 25.7,
        nextOpponent: "ESS"
      },
      projectedPointsGain: 39.5,
      valueChange: -286000,
      roi: 0.14,
      confidence: 0.92,
      reasoning: "Darcy is sharing ruck duties in a timeshare situation. English offers elite scoring and midfield minutes as a solo ruck."
    }
  ];

  // Handle click on sort header
  const handleSort = (column: string) => {
    if (sortBy === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortBy(column);
      setSortDirection("desc");
    }
  };

  // Run optimizer
  const runOptimizer = () => {
    setIsLoading(true);
    
    // Simulate API call with timeout
    setTimeout(() => {
      // Filter by position if needed
      let filtered = [...mockResults];
      if (position !== "ALL") {
        filtered = mockResults.filter(r => r.playerOut.position === position);
      }
      
      // Sort results
      const sorted = [...filtered].sort((a, b) => {
        let aValue = 0;
        let bValue = 0;
        
        switch (sortBy) {
          case "roi":
            aValue = a.roi;
            bValue = b.roi;
            break;
          case "points":
            aValue = a.projectedPointsGain;
            bValue = b.projectedPointsGain;
            break;
          case "value":
            aValue = a.valueChange;
            bValue = b.valueChange;
            break;
          case "confidence":
            aValue = a.confidence;
            bValue = b.confidence;
            break;
          default:
            aValue = a.roi;
            bValue = b.roi;
        }
        
        return sortDirection === "asc" ? aValue - bValue : bValue - aValue;
      });
      
      // Check budget constraints
      const affordableResults = sorted.filter(r => r.valueChange <= budget);
      
      setResults(affordableResults);
      setIsLoading(false);
    }, 1500);
  };

  // Get arrow for sort direction
  const getSortArrow = (column: string) => {
    if (sortBy !== column) return null;
    return sortDirection === "asc" ? 
      <ChevronUp className="h-4 w-4" /> : 
      <ChevronDown className="h-4 w-4" />;
  };

  return (
    <div className="space-y-4">
      <div className="text-sm text-gray-600 mb-2">
        The Trade Optimizer analyzes your team and the player pool to find the most efficient trades based on projected points, value, and strategic importance.
      </div>
      
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-4">
        <div>
          <label htmlFor="budget" className="block text-xs font-medium mb-1">Available Budget</label>
          <Input
            id="budget"
            type="number"
            value={budget}
            onChange={(e) => setBudget(parseInt(e.target.value))}
            className="h-9"
          />
        </div>
        
        <div>
          <label htmlFor="position" className="block text-xs font-medium mb-1">Position Filter</label>
          <select
            id="position"
            value={position}
            onChange={(e) => setPosition(e.target.value)}
            className="w-full rounded-md border border-input px-3 py-1.5 text-sm h-9"
          >
            <option value="ALL">All Positions</option>
            <option value="MID">Midfielders</option>
            <option value="FWD">Forwards</option>
            <option value="DEF">Defenders</option>
            <option value="RUCK">Rucks</option>
          </select>
        </div>
        
        <div className="flex items-end">
          <Button 
            onClick={runOptimizer}
            className="w-full h-9"
            disabled={isLoading}
          >
            {isLoading ? (
              <div className="flex items-center">
                <div className="animate-spin h-4 w-4 border-2 border-white border-t-transparent rounded-full mr-2"></div>
                Analyzing...
              </div>
            ) : (
              <div className="flex items-center">
                <Cpu className="h-4 w-4 mr-2" />
                Run Optimizer
              </div>
            )}
          </Button>
        </div>
      </div>
      
      {results.length > 0 && (
        <div className="border rounded-md overflow-hidden">
          <div className="bg-gray-100 px-4 py-2 font-medium">
            Optimized Trade Suggestions
          </div>
          
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Trade</th>
                <th 
                  className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                  onClick={() => handleSort("points")}
                >
                  <div className="flex items-center">
                    <span>+Pts</span>
                    {getSortArrow("points")}
                  </div>
                </th>
                <th 
                  className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                  onClick={() => handleSort("value")}
                >
                  <div className="flex items-center">
                    <span>Value</span>
                    {getSortArrow("value")}
                  </div>
                </th>
                <th 
                  className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hidden md:table-cell"
                  onClick={() => handleSort("roi")}
                >
                  <div className="flex items-center">
                    <span>ROI</span>
                    {getSortArrow("roi")}
                  </div>
                </th>
                <th 
                  className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hidden md:table-cell"
                  onClick={() => handleSort("confidence")}
                >
                  <div className="flex items-center">
                    <span>Conf.</span>
                    {getSortArrow("confidence")}
                  </div>
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {results.slice(0, showAll ? results.length : 3).map((result, index) => (
                <tr key={index} className="hover:bg-gray-50">
                  <td className="px-3 py-3 whitespace-nowrap">
                    <div className="font-medium text-sm">
                      <div className="flex items-center">
                        <div>
                          <div className="font-medium">
                            {result.playerOut.name} 
                            <span className="text-xs text-gray-500 ml-1">({result.playerOut.team})</span>
                          </div>
                          <div className="text-xs text-gray-600">
                            {result.playerOut.position} | Avg: {result.playerOut.averagePoints?.toFixed(1)} | BE: {result.playerOut.breakEven}
                          </div>
                        </div>
                        <ArrowRight className="h-4 w-4 mx-2 text-gray-400" />
                        <div>
                          <div className="font-medium">
                            {result.playerIn.name}
                            <span className="text-xs text-gray-500 ml-1">({result.playerIn.team})</span>
                          </div>
                          <div className="text-xs text-gray-600">
                            {result.playerIn.position} | Avg: {result.playerIn.averagePoints?.toFixed(1)} | BE: {result.playerIn.breakEven}
                          </div>
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-3 py-3 whitespace-nowrap">
                    <div className="text-sm font-medium text-green-600">
                      +{result.projectedPointsGain.toFixed(1)}
                    </div>
                  </td>
                  <td className="px-3 py-3 whitespace-nowrap">
                    <div className={`text-sm font-medium ${result.valueChange > 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {result.valueChange > 0 ? '+' : ''}{formatCurrency(result.valueChange)}
                    </div>
                  </td>
                  <td className="px-3 py-3 whitespace-nowrap hidden md:table-cell">
                    <div className="text-sm font-medium">
                      {(result.roi * 100).toFixed(1)}%
                    </div>
                  </td>
                  <td className="px-3 py-3 whitespace-nowrap hidden md:table-cell">
                    <div className="text-sm font-medium">
                      {(result.confidence * 100).toFixed(0)}%
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          
          {results.length > 3 && (
            <div className="bg-gray-50 px-4 py-2 text-center">
              <Button 
                variant="ghost" 
                onClick={() => setShowAll(!showAll)}
                className="text-sm"
              >
                {showAll ? "Show Less" : `Show ${results.length - 3} More Results`}
              </Button>
            </div>
          )}
        </div>
      )}
      
      {results.length > 0 && (
        <div className="bg-gray-50 rounded-md p-3 text-sm space-y-3">
          <div className="flex gap-2 items-center">
            <AlertCircle className="h-4 w-4 text-amber-500" />
            <div className="text-gray-700">
              <span className="font-medium">Trade Strategy Insights</span>
            </div>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div className="bg-white rounded-md p-3 border">
              <div className="flex gap-2 items-center mb-2">
                <TrendingUp className="h-4 w-4 text-green-600" />
                <div className="font-medium text-sm">Scoring Impact</div>
              </div>
              <p className="text-xs text-gray-600">
                Prioritizing trades with high projected point gains can significantly improve your weekly score. Focus on consistent performers over volatile scorers.
              </p>
            </div>
            
            <div className="bg-white rounded-md p-3 border">
              <div className="flex gap-2 items-center mb-2">
                <Percent className="h-4 w-4 text-blue-600" />
                <div className="font-medium text-sm">Value Considerations</div>
              </div>
              <p className="text-xs text-gray-600">
                When trading up to premiums, look for players with break-evens below their scoring average for the best value growth opportunity.
              </p>
            </div>
            
            <div className="bg-white rounded-md p-3 border">
              <div className="flex gap-2 items-center mb-2">
                <Users className="h-4 w-4 text-purple-600" />
                <div className="font-medium text-sm">Ownership Strategy</div>
              </div>
              <p className="text-xs text-gray-600">
                Consider trading against the crowd for differentiation in key positions, especially when targeting league rankings over overall score.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}