import { useState } from "react";
import { Button } from "@/components/ui/button";
import { formatCurrency } from "@/lib/utils";
import { 
  TrendingUp, 
  TrendingDown, 
  AlertCircle, 
  ArrowUp, 
  ArrowDown, 
  Clock, 
  Calendar, 
  DollarSign,
  Filter,
  BarChart2
} from "lucide-react";

type PlayerValueChange = {
  id: number;
  name: string;
  position: string;
  team: string;
  currentPrice: number;
  lastWeekPrice: number;
  change: number;
  changePercentage: number;
  priceTrajectory: "up" | "down" | "stable";
  projectedBreakEven: number;
  lastScore: number;
  averageScore: number;
};

export function ValueGainTracker() {
  const [timeFrame, setTimeFrame] = useState<"week" | "month" | "season">("week");
  const [positionFilter, setPositionFilter] = useState<string>("ALL");
  const [showFilters, setShowFilters] = useState(false);
  const [sortBy, setSortBy] = useState<"change" | "percentage" | "projection">("change");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");

  // Mock data for player value changes
  const playerValueData: PlayerValueChange[] = [
    {
      id: 1,
      name: "Charlie Curnow",
      position: "FWD",
      team: "CARL",
      currentPrice: 825000,
      lastWeekPrice: 800500,
      change: 24500,
      changePercentage: 3.06,
      priceTrajectory: "up",
      projectedBreakEven: 85,
      lastScore: 115,
      averageScore: 92.4
    },
    {
      id: 2,
      name: "Nick Daicos",
      position: "MID",
      team: "COLL",
      currentPrice: 1020000,
      lastWeekPrice: 1007200,
      change: 12800,
      changePercentage: 1.27,
      priceTrajectory: "up",
      projectedBreakEven: 115,
      lastScore: 138,
      averageScore: 128.2
    },
    {
      id: 3,
      name: "Tim English",
      position: "RUCK",
      team: "WB",
      currentPrice: 978000,
      lastWeekPrice: 959800,
      change: 18200,
      changePercentage: 1.90,
      priceTrajectory: "up",
      projectedBreakEven: 95,
      lastScore: 124,
      averageScore: 115.6
    },
    {
      id: 4,
      name: "Izak Rankine",
      position: "FWD",
      team: "ADEL",
      currentPrice: 745000,
      lastWeekPrice: 736700,
      change: 8300,
      changePercentage: 1.13,
      priceTrajectory: "up",
      projectedBreakEven: 65,
      lastScore: 94,
      averageScore: 82.5
    },
    {
      id: 5,
      name: "Toby Greene",
      position: "FWD",
      team: "GWS",
      currentPrice: 782000,
      lastWeekPrice: 797300,
      change: -15300,
      changePercentage: -1.92,
      priceTrajectory: "down",
      projectedBreakEven: 98,
      lastScore: 64,
      averageScore: 88.2
    },
    {
      id: 6,
      name: "Jordan De Goey",
      position: "MID/FWD",
      team: "COLL",
      currentPrice: 735000,
      lastWeekPrice: 756700,
      change: -21700,
      changePercentage: -2.87,
      priceTrajectory: "down",
      projectedBreakEven: 105,
      lastScore: 52,
      averageScore: 82.6
    },
    {
      id: 7,
      name: "Sean Darcy",
      position: "RUCK",
      team: "FREM",
      currentPrice: 692000,
      lastWeekPrice: 710900,
      change: -18900,
      changePercentage: -2.66,
      priceTrajectory: "down",
      projectedBreakEven: 115,
      lastScore: 45,
      averageScore: 75.1
    },
    {
      id: 8,
      name: "Isaac Heeney",
      position: "MID/FWD",
      team: "SYD",
      currentPrice: 868000,
      lastWeekPrice: 878200,
      change: -10200,
      changePercentage: -1.16,
      priceTrajectory: "down",
      projectedBreakEven: 110,
      lastScore: 73,
      averageScore: 92.3
    },
    {
      id: 9,
      name: "Jordan Ridley",
      position: "DEF",
      team: "ESS",
      currentPrice: 742000,
      lastWeekPrice: 731500,
      change: 10500,
      changePercentage: 1.44,
      priceTrajectory: "up",
      projectedBreakEven: 75,
      lastScore: 95,
      averageScore: 88.5
    },
    {
      id: 10,
      name: "Andrew Brayshaw",
      position: "MID",
      team: "FREM",
      currentPrice: 815000,
      lastWeekPrice: 824300,
      change: -9300,
      changePercentage: -1.13,
      priceTrajectory: "stable",
      projectedBreakEven: 90,
      lastScore: 88,
      averageScore: 91.2
    }
  ];

  // Filter and sort the data
  const getFilteredAndSortedData = () => {
    let filtered = [...playerValueData];
    
    if (positionFilter !== "ALL") {
      filtered = filtered.filter(player => player.position.includes(positionFilter));
    }
    
    // Apply different time frame data (just for demonstration - would be real data in production)
    if (timeFrame === "month") {
      // Multiply week changes by ~4 for month simulation
      filtered = filtered.map(player => ({
        ...player,
        lastWeekPrice: player.currentPrice - (player.change * 3.8),
        change: player.change * 3.8,
        changePercentage: player.changePercentage * 3.8
      }));
    } else if (timeFrame === "season") {
      // Multiply week changes by ~16 for season simulation
      filtered = filtered.map(player => ({
        ...player,
        lastWeekPrice: player.currentPrice - (player.change * 15.5),
        change: player.change * 15.5,
        changePercentage: player.changePercentage * 15.5
      }));
    }
    
    // Apply sorting
    return filtered.sort((a, b) => {
      let aValue = 0;
      let bValue = 0;
      
      switch (sortBy) {
        case "change":
          aValue = a.change;
          bValue = b.change;
          break;
        case "percentage":
          aValue = a.changePercentage;
          bValue = b.changePercentage;
          break;
        case "projection":
          aValue = a.projectedBreakEven;
          bValue = b.projectedBreakEven;
          break;
        default:
          aValue = a.change;
          bValue = b.change;
      }
      
      return sortDirection === "asc" ? aValue - bValue : bValue - aValue;
    });
  };

  const sortedData = getFilteredAndSortedData();
  
  // Calculate team value insights (for mock display)
  const totalGain = sortedData.reduce((sum, player) => sum + (player.change > 0 ? player.change : 0), 0);
  const totalLoss = sortedData.reduce((sum, player) => sum + (player.change < 0 ? player.change : 0), 0);
  const netChange = totalGain + totalLoss;
  const percentageChange = (netChange / 10000000) * 100; // Assuming $10M team value for demo
  
  // Toggle sort
  const handleSortChange = (column: "change" | "percentage" | "projection") => {
    if (sortBy === column) {
      setSortDirection(sortDirection === "asc" ? "desc" : "asc");
    } else {
      setSortBy(column);
      setSortDirection("desc");
    }
  };

  return (
    <div className="space-y-4">
      <div className="text-sm text-gray-600 mb-2">
        Track player price changes over time to identify value gain opportunities and monitor your team's financial health.
      </div>
      
      <div className="flex flex-wrap gap-2 mb-4">
        <div className="flex text-sm">
          <Button
            variant={timeFrame === "week" ? "default" : "outline"}
            size="sm"
            className="rounded-r-none"
            onClick={() => setTimeFrame("week")}
          >
            <Clock className="h-4 w-4 mr-1" />
            Week
          </Button>
          <Button
            variant={timeFrame === "month" ? "default" : "outline"}
            size="sm"
            className="rounded-none border-x-0"
            onClick={() => setTimeFrame("month")}
          >
            <Calendar className="h-4 w-4 mr-1" />
            Month
          </Button>
          <Button
            variant={timeFrame === "season" ? "default" : "outline"}
            size="sm"
            className="rounded-l-none"
            onClick={() => setTimeFrame("season")}
          >
            <BarChart2 className="h-4 w-4 mr-1" />
            Season
          </Button>
        </div>
        
        <Button
          variant="outline"
          size="sm"
          onClick={() => setShowFilters(!showFilters)}
        >
          <Filter className="h-4 w-4 mr-1" />
          {showFilters ? "Hide Filters" : "Show Filters"}
        </Button>
      </div>
      
      {showFilters && (
        <div className="bg-gray-50 rounded-md p-3 mb-4 space-y-2">
          <div className="text-sm font-medium mb-2">Filter Options</div>
          <div className="flex flex-wrap gap-2">
            <Button
              variant={positionFilter === "ALL" ? "default" : "outline"}
              size="sm"
              onClick={() => setPositionFilter("ALL")}
            >
              All Positions
            </Button>
            <Button
              variant={positionFilter === "MID" ? "default" : "outline"}
              size="sm"
              onClick={() => setPositionFilter("MID")}
            >
              Midfielders
            </Button>
            <Button
              variant={positionFilter === "FWD" ? "default" : "outline"}
              size="sm"
              onClick={() => setPositionFilter("FWD")}
            >
              Forwards
            </Button>
            <Button
              variant={positionFilter === "DEF" ? "default" : "outline"}
              size="sm"
              onClick={() => setPositionFilter("DEF")}
            >
              Defenders
            </Button>
            <Button
              variant={positionFilter === "RUCK" ? "default" : "outline"}
              size="sm"
              onClick={() => setPositionFilter("RUCK")}
            >
              Rucks
            </Button>
          </div>
        </div>
      )}
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
        <div className="bg-white rounded-md p-3 border">
          <div className="flex items-center gap-2 mb-1">
            <TrendingUp className="h-4 w-4 text-green-600" />
            <div className="text-sm font-medium">Total Value Gained</div>
          </div>
          <div className="text-xl font-bold text-green-600">
            +{formatCurrency(totalGain)}
          </div>
        </div>
        
        <div className="bg-white rounded-md p-3 border">
          <div className="flex items-center gap-2 mb-1">
            <TrendingDown className="h-4 w-4 text-red-600" />
            <div className="text-sm font-medium">Total Value Lost</div>
          </div>
          <div className="text-xl font-bold text-red-600">
            {formatCurrency(totalLoss)}
          </div>
        </div>
        
        <div className="bg-white rounded-md p-3 border">
          <div className="flex items-center gap-2 mb-1">
            <DollarSign className="h-4 w-4 text-blue-600" />
            <div className="text-sm font-medium">Net Team Value Change</div>
          </div>
          <div className={`text-xl font-bold ${netChange >= 0 ? 'text-green-600' : 'text-red-600'}`}>
            {netChange >= 0 ? '+' : ''}{formatCurrency(netChange)} ({percentageChange.toFixed(2)}%)
          </div>
        </div>
      </div>
      
      <div className="relative overflow-x-auto border rounded-md">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Player
              </th>
              <th 
                className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                onClick={() => handleSortChange("change")}
              >
                <div className="flex items-center">
                  <span>Value Change</span>
                  {sortBy === "change" && (
                    sortDirection === "asc" ? 
                      <ArrowUp className="h-3 w-3 ml-1" /> : 
                      <ArrowDown className="h-3 w-3 ml-1" />
                  )}
                </div>
              </th>
              <th 
                className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer hidden md:table-cell"
                onClick={() => handleSortChange("percentage")}
              >
                <div className="flex items-center">
                  <span>%</span>
                  {sortBy === "percentage" && (
                    sortDirection === "asc" ? 
                      <ArrowUp className="h-3 w-3 ml-1" /> : 
                      <ArrowDown className="h-3 w-3 ml-1" />
                  )}
                </div>
              </th>
              <th 
                className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider cursor-pointer"
                onClick={() => handleSortChange("projection")}
              >
                <div className="flex items-center">
                  <span>Break Even</span>
                  {sortBy === "projection" && (
                    sortDirection === "asc" ? 
                      <ArrowUp className="h-3 w-3 ml-1" /> : 
                      <ArrowDown className="h-3 w-3 ml-1" />
                  )}
                </div>
              </th>
              <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider hidden md:table-cell">
                Price
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {sortedData.map((player) => (
              <tr key={player.id} className="hover:bg-gray-50">
                <td className="px-3 py-3 whitespace-nowrap">
                  <div className="flex items-center">
                    <div>
                      <div className="text-sm font-medium text-gray-900">{player.name}</div>
                      <div className="text-xs text-gray-500">{player.position} | {player.team}</div>
                    </div>
                  </div>
                </td>
                <td className="px-3 py-3 whitespace-nowrap">
                  <div className={`text-sm font-medium flex items-center ${player.change > 0 ? 'text-green-600' : player.change < 0 ? 'text-red-600' : 'text-gray-500'}`}>
                    {player.priceTrajectory === "up" && <ArrowUp className="h-3 w-3 mr-1" />}
                    {player.priceTrajectory === "down" && <ArrowDown className="h-3 w-3 mr-1" />}
                    {player.change > 0 ? '+' : ''}{formatCurrency(player.change)}
                  </div>
                </td>
                <td className="px-3 py-3 whitespace-nowrap hidden md:table-cell">
                  <div className={`text-sm font-medium ${player.changePercentage > 0 ? 'text-green-600' : player.changePercentage < 0 ? 'text-red-600' : 'text-gray-500'}`}>
                    {player.changePercentage > 0 ? '+' : ''}{player.changePercentage.toFixed(2)}%
                  </div>
                </td>
                <td className="px-3 py-3 whitespace-nowrap">
                  <div className={`text-sm font-medium ${player.projectedBreakEven > player.averageScore ? 'text-red-600' : 'text-green-600'}`}>
                    {player.projectedBreakEven}
                  </div>
                </td>
                <td className="px-3 py-3 whitespace-nowrap text-sm text-gray-900 hidden md:table-cell">
                  {formatCurrency(player.currentPrice)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      
      <div className="bg-gray-50 rounded-md p-3 text-sm">
        <div className="flex gap-2 items-center mb-2">
          <AlertCircle className="h-4 w-4 text-amber-500" />
          <div className="font-medium">Value Gain Strategy</div>
        </div>
        <p className="text-gray-700 mb-2">
          Players with break-evens below their average scores are likely to increase in value, 
          while those with break-evens significantly above their averages may decline. 
          Look for players with recent score spikes but relatively low break-evens as potential value targets.
        </p>
        <p className="text-gray-700">
          For the {timeFrame} period, the optimal value strategy is to {timeFrame === "week" ? "target players with immediate scoring opportunities against weaker opponents" : timeFrame === "month" ? "focus on consistent performers with favorable fixture runs" : "identify under-priced players with long-term scoring potential"}.
        </p>
      </div>
    </div>
  );
}