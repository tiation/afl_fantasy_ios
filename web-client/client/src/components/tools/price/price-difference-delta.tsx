import { useState } from "react";
import { Button } from "@/components/ui/button";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { 
  CircleDollarSign, LineChart, TrendingDown, TrendingUp, BarChart 
} from "lucide-react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

export default function PriceDifferenceDelta() {
  const [isLoading, setIsLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const { toast } = useToast();
  
  // In a real implementation, we would:
  // 1. Allow users to select multiple players to compare
  // 2. Send request to API
  // 3. Display results in a visually appealing way
  
  const calculatePriceDelta = async () => {
    setIsLoading(true);
    
    try {
      // Placeholder data for demo purposes
      const demoData = {
        players: [
          {
            id: 1,
            name: "Marcus Bontempelli",
            position: "MID",
            team: "Western Bulldogs",
            price: 1100000,
            breakeven: 114,
            average: 120.5,
            projectedScore: 125
          },
          {
            id: 2,
            name: "Andrew Brayshaw",
            position: "MID",
            team: "Fremantle",
            price: 950000,
            breakeven: 105,
            average: 107.2,
            projectedScore: 110
          },
          {
            id: 3,
            name: "Matt Rowell",
            position: "MID",
            team: "Gold Coast",
            price: 680000,
            breakeven: 85,
            average: 92.1,
            projectedScore: 95
          },
          {
            id: 4,
            name: "Tim English",
            position: "RUCK",
            team: "Western Bulldogs",
            price: 880000,
            breakeven: 93,
            average: 101.4,
            projectedScore: 105
          },
          {
            id: 5,
            name: "Jordan Dawson",
            position: "DEF",
            team: "Adelaide",
            price: 790000,
            breakeven: 89,
            average: 96.3,
            projectedScore: 100
          }
        ]
      };
      
      const response = await apiRequest("POST", "/api/fantasy/tools/price_difference_delta", demoData);
      const data = await response.json();
      
      if (data.status === "error") {
        toast({
          title: "Error",
          description: data.message || "Failed to calculate price deltas",
          variant: "destructive"
        });
      } else {
        setResult(data);
      }
    } catch (error) {
      console.error("Error calculating price deltas:", error);
      toast({
        title: "Error",
        description: "Failed to calculate price deltas",
        variant: "destructive"
      });
    } finally {
      setIsLoading(false);
    }
  };
  
  // Helper function to format currency in k format
  const formatCurrency = (value: number) => {
    return `$${(value / 1000).toFixed(0)}k`;
  };
  
  // Helper function to get trend icon
  const getTrendIcon = (value: number) => {
    if (value > 0) return <TrendingUp className="h-4 w-4 text-green-500" />;
    if (value < 0) return <TrendingDown className="h-4 w-4 text-red-500" />;
    return null;
  };
  
  // Helper function to get trend color class
  const getTrendColorClass = (value: number) => {
    if (value > 0) return "text-green-600";
    if (value < 0) return "text-red-600";
    return "text-gray-600";
  };
  
  return (
    <div className="space-y-4">
      <div className="text-sm text-gray-600 mb-4">
        The Price Difference Delta tool compares projected price changes for multiple players and helps you make informed trade decisions.
      </div>
      
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-base flex items-center">
            <LineChart className="h-4 w-4 mr-2" />
            Selected Players
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="mb-4">
            <p className="text-sm text-gray-600">
              5 players selected from your player list for comparison.
            </p>
          </div>
          
          <Button
            onClick={calculatePriceDelta}
            disabled={isLoading}
            className="w-full"
          >
            <BarChart className="h-4 w-4 mr-2" />
            {isLoading ? "Calculating..." : "Calculate Price Deltas"}
          </Button>
        </CardContent>
      </Card>
      
      {result && (
        <div className="mt-6">
          <Card className="overflow-hidden">
            <CardHeader className="pb-2">
              <CardTitle className="text-base flex items-center">
                <CircleDollarSign className="h-4 w-4 mr-2" />
                Price Difference Analysis
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-[200px]">Player</TableHead>
                      <TableHead className="text-right">Current</TableHead>
                      <TableHead className="text-right">Projected (1 Round)</TableHead>
                      <TableHead className="text-right">Delta (1 Round)</TableHead>
                      <TableHead className="text-right">Projected (3 Rounds)</TableHead>
                      <TableHead className="text-right">Delta (3 Rounds)</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {result.players && result.players.map((player: any) => (
                      <TableRow key={player.id}>
                        <TableCell className="font-medium">
                          <div>{player.name}</div>
                          <div className="text-xs text-gray-500">{player.team} | {player.position}</div>
                        </TableCell>
                        <TableCell className="text-right font-medium">
                          {formatCurrency(player.price)}
                        </TableCell>
                        <TableCell className="text-right">
                          {player.projectedPrices && player.projectedPrices.length > 0 ? 
                            formatCurrency(player.projectedPrices[0]) : formatCurrency(player.price)}
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex items-center justify-end">
                            <span className={getTrendColorClass(player.priceDelta1 || 0)}>
                              {(player.priceDelta1 || 0) > 0 ? "+" : ""}
                              {formatCurrency(player.priceDelta1 || 0)}
                            </span>
                            <span className="ml-1">
                              {getTrendIcon(player.priceDelta1 || 0)}
                            </span>
                          </div>
                          <div className="text-xs text-gray-500">
                            {(player.priceDelta1Percent || 0) > 0 ? "+" : ""}
                            {(player.priceDelta1Percent || 0).toFixed(1)}%
                          </div>
                        </TableCell>
                        <TableCell className="text-right">
                          {player.projectedPrices && player.projectedPrices.length > 2 ? 
                            formatCurrency(player.projectedPrices[2]) : formatCurrency(player.price)}
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="flex items-center justify-end">
                            <span className={getTrendColorClass(player.priceDelta3 || 0)}>
                              {(player.priceDelta3 || 0) > 0 ? "+" : ""}
                              {formatCurrency(player.priceDelta3 || 0)}
                            </span>
                            <span className="ml-1">
                              {getTrendIcon(player.priceDelta3 || 0)}
                            </span>
                          </div>
                          <div className="text-xs text-gray-500">
                            {(player.priceDelta3Percent || 0) > 0 ? "+" : ""}
                            {(player.priceDelta3Percent || 0).toFixed(1)}%
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-base">1-Round Price Change Ranking</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {result.players && result.players
                    .slice()
                    .sort((a: any, b: any) => (b.priceDelta1 || 0) - (a.priceDelta1 || 0))
                    .map((player: any, index: number) => (
                      <div key={`${player.id}-1round`} className="flex justify-between items-center">
                        <div className="flex items-center">
                          <Badge variant="outline" className="mr-2">
                            {index + 1}
                          </Badge>
                          <span className="truncate">{player.name}</span>
                        </div>
                        <span className={getTrendColorClass(player.priceDelta1 || 0)}>
                          {(player.priceDelta1 || 0) > 0 ? "+" : ""}
                          {formatCurrency(player.priceDelta1 || 0)}
                        </span>
                      </div>
                    ))}
                </div>
              </CardContent>
            </Card>
            
            <Card>
              <CardHeader className="pb-2">
                <CardTitle className="text-base">3-Round Price Change Ranking</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {result.players && result.players
                    .slice()
                    .sort((a: any, b: any) => (b.priceDelta3 || 0) - (a.priceDelta3 || 0))
                    .map((player: any, index: number) => (
                      <div key={`${player.id}-3round`} className="flex justify-between items-center">
                        <div className="flex items-center">
                          <Badge variant="outline" className="mr-2">
                            {index + 1}
                          </Badge>
                          <span className="truncate">{player.name}</span>
                        </div>
                        <span className={getTrendColorClass(player.priceDelta3 || 0)}>
                          {(player.priceDelta3 || 0) > 0 ? "+" : ""}
                          {formatCurrency(player.priceDelta3 || 0)}
                        </span>
                      </div>
                    ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
      )}
    </div>
  );
}