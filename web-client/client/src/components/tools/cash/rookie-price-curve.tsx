import { useState, useEffect, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "@/components/ui/table";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { BarChart, TrendingUp, ArrowDown, ArrowUp } from "lucide-react";

type RookieProjection = {
  player: string;
  price: number;
  l3_avg: number;
  price_projection_next_3: number;
};

type SortField = "player" | "price" | "l3_avg" | "price_projection_next_3" | "projected_gain";
type SortOrder = "asc" | "desc";

export function RookiePriceCurve() {
  const [searchTerm, setSearchTerm] = useState("");
  const [sortField, setSortField] = useState<SortField>("projected_gain");
  const [sortOrder, setSortOrder] = useState<SortOrder>("desc");
  const { toast } = useToast();
  
  // Fetch rookie price curve data
  const { data, isLoading, error } = useQuery({
    queryKey: ['/api/fantasy/tools/cash/rookie_price_curve_model'],
    staleTime: 1000 * 60 * 5, // Cache for 5 minutes
  });
  
  // Handle error
  useEffect(() => {
    if (error) {
      toast({
        title: "Error",
        description: "Failed to load rookie price curve data",
        variant: "destructive",
      });
    }
  }, [error, toast]);
  
  // Filter rookies based on search term
  const filteredRookies = useMemo(() => {
    if (!data?.rookies) return [];
    
    return data.rookies.filter((rookie: RookieProjection) => {
      return rookie.player.toLowerCase().includes(searchTerm.toLowerCase());
    });
  }, [data?.rookies, searchTerm]);
  
  // Calculate projected gain for each rookie and sort
  const sortedRookies = useMemo(() => {
    return [...(filteredRookies || [])].sort((a, b) => {
      // Calculate projected gain for comparison if that's the sort field
      if (sortField === "projected_gain") {
        const aPriceChange = a.price_projection_next_3 - a.price;
        const bPriceChange = b.price_projection_next_3 - b.price;
        return sortOrder === "asc" ? aPriceChange - bPriceChange : bPriceChange - aPriceChange;
      }
      
      // Otherwise sort by the specified field
      let aValue: any = a[sortField as keyof RookieProjection];
      let bValue: any = b[sortField as keyof RookieProjection];
      
      // Handle string comparison
      if (typeof aValue === 'string' && typeof bValue === 'string') {
        aValue = aValue.toLowerCase();
        bValue = bValue.toLowerCase();
      }
      
      if (aValue === bValue) return 0;
      
      // Determine sort direction
      const sortVal = aValue > bValue ? 1 : -1;
      return sortOrder === 'asc' ? sortVal : -sortVal;
    });
  }, [filteredRookies, sortField, sortOrder]);
  
  // Sort handler
  const handleSort = (field: SortField) => {
    if (sortField === field) {
      // Toggle sort order if same field
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      // New field, set appropriate default sort order
      setSortField(field);
      // Price projections and gain typically show highest first
      if (field === 'price_projection_next_3' || field === 'projected_gain' || field === 'l3_avg') {
        setSortOrder('desc');
      } else {
        setSortOrder('asc');
      }
    }
  };
  
  // Helper to get sort icon
  const getSortIcon = (field: SortField) => {
    if (sortField !== field) return null;
    return sortOrder === 'asc' ? <ArrowUp className="h-3 w-3 ml-1 inline" /> : <ArrowDown className="h-3 w-3 ml-1 inline" />;
  };
  
  // Helper for sorting header class
  const getSortableHeaderClass = (field: SortField) => {
    return `cursor-pointer hover:bg-gray-50 ${sortField === field ? 'text-primary' : ''}`;
  };
  
  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-2">
        <p className="text-sm text-gray-600">
          Model the projected price trajectory of rookies over the next three rounds based on their recent performance.
        </p>
        
        <Input
          type="text"
          placeholder="Search players..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="w-full md:max-w-xs"
        />
      </div>
      
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead
                    className={getSortableHeaderClass("player")}
                    onClick={() => handleSort("player")}
                  >
                    Player {getSortIcon("player")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("price")}`}
                    onClick={() => handleSort("price")}
                  >
                    Current Price {getSortIcon("price")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("l3_avg")}`}
                    onClick={() => handleSort("l3_avg")}
                  >
                    3-Game Avg {getSortIcon("l3_avg")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("price_projection_next_3")}`}
                    onClick={() => handleSort("price_projection_next_3")}
                  >
                    Projected Price (+3 Rounds) {getSortIcon("price_projection_next_3")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("projected_gain")}`}
                    onClick={() => handleSort("projected_gain")}
                  >
                    Projected Gain {getSortIcon("projected_gain")}
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  // Loading skeleton state
                  Array.from({ length: 5 }).map((_, index) => (
                    <TableRow key={`skeleton-${index}`}>
                      <TableCell><Skeleton className="h-5 w-32" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-20 ml-auto" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-12 ml-auto" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-20 ml-auto" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-20 ml-auto" /></TableCell>
                    </TableRow>
                  ))
                ) : sortedRookies.length > 0 ? (
                  sortedRookies.map((rookie: RookieProjection, index) => {
                    const projectedGain = rookie.price_projection_next_3 - rookie.price;
                    const gainPercentage = ((projectedGain / rookie.price) * 100).toFixed(1);
                    
                    return (
                      <TableRow 
                        key={`${rookie.player}-${index}`}
                        className={projectedGain > 0 ? "bg-green-50" : ""}
                      >
                        <TableCell className="font-medium">{rookie.player}</TableCell>
                        <TableCell className="text-right">${(rookie.price / 1000).toFixed(1)}k</TableCell>
                        <TableCell className="text-right">{rookie.l3_avg}</TableCell>
                        <TableCell className="text-right">${(rookie.price_projection_next_3 / 1000).toFixed(1)}k</TableCell>
                        <TableCell className="text-right">
                          <div className="flex items-center justify-end">
                            <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
                            ${(projectedGain / 1000).toFixed(1)}k
                            <span className="text-xs text-gray-500 ml-1">({gainPercentage}%)</span>
                          </div>
                        </TableCell>
                      </TableRow>
                    );
                  })
                ) : (
                  <TableRow>
                    <TableCell colSpan={5} className="text-center py-4 text-gray-500">
                      No rookies found. Try refining your search.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}