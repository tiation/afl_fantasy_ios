import { useState, useEffect, useMemo } from "react";
import { useQuery } from "@tanstack/react-query";
import { apiRequest } from "@/lib/queryClient";
import { useToast } from "@/hooks/use-toast";
import { Table, TableHeader, TableRow, TableHead, TableBody, TableCell } from "@/components/ui/table";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { TrendingDown, PiggyBank, ArrowDown, ArrowUp } from "lucide-react";

type DowngradeTarget = {
  name: string;
  team: string;
  price: number;
  breakeven: number;
  l3_avg: number;
  games: number;
  position: string;
};

type SortField = "name" | "team" | "position" | "price" | "breakeven" | "l3_avg" | "games";
type SortOrder = "asc" | "desc";

export function DowngradeTargetFinder() {
  const [searchTerm, setSearchTerm] = useState("");
  const [positionFilter, setPositionFilter] = useState<string>("all");
  const [sortField, setSortField] = useState<SortField>("price");
  const [sortOrder, setSortOrder] = useState<SortOrder>("asc");
  
  const { toast } = useToast();
  
  // Fetch downgrade targets data
  const { data, isLoading, error } = useQuery({
    queryKey: ['/api/fantasy/tools/cash/downgrade_target_finder'],
    staleTime: 1000 * 60 * 5, // Cache for 5 minutes
  });
  
  // Handle error
  useEffect(() => {
    if (error) {
      toast({
        title: "Error",
        description: "Failed to load downgrade targets data",
        variant: "destructive",
      });
    }
  }, [error, toast]);
  
  // Filter targets based on search term and position
  const filteredTargets = useMemo(() => {
    if (!data?.targets) return [];
    
    return data.targets.filter((target: DowngradeTarget) => {
      const matchesSearch = 
        target.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        target.team.toLowerCase().includes(searchTerm.toLowerCase());
        
      const matchesPosition = positionFilter === "all" || target.position === positionFilter;
      
      return matchesSearch && matchesPosition;
    });
  }, [data?.targets, searchTerm, positionFilter]);
  
  // Sorted targets
  const sortedTargets = useMemo(() => {
    return [...filteredTargets].sort((a, b) => {
      let aValue: any = a[sortField];
      let bValue: any = b[sortField];
      
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
  }, [filteredTargets, sortField, sortOrder]);
  
  // Get unique positions for the filter
  const positions = useMemo(() => (
    data?.targets 
      ? Array.from(new Set(data.targets.map((target: DowngradeTarget) => target.position)))
      : []
  ), [data?.targets]);
  
  // Sort handler
  const handleSort = (field: SortField) => {
    if (sortField === field) {
      // Toggle sort order if same field
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      // New field, default to ascending
      setSortField(field);
      setSortOrder('asc');
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
          Find optimal downgrade targets based on low breakevens and recent performance to maximize cash generation.
        </p>
        
        <div className="flex flex-col md:flex-row gap-2">
          <Input
            type="text"
            placeholder="Search players or teams..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full md:max-w-xs"
          />
          
          <Select value={positionFilter} onValueChange={setPositionFilter}>
            <SelectTrigger className="w-full md:w-[150px]">
              <SelectValue placeholder="All Positions" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Positions</SelectItem>
              {positions.map((position) => (
                <SelectItem key={position} value={position || "unknown"}>
                  {position || "Unknown"}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>
      
      <Card>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead 
                    className={getSortableHeaderClass("name")}
                    onClick={() => handleSort("name")}
                  >
                    Player {getSortIcon("name")}
                  </TableHead>
                  <TableHead
                    className={getSortableHeaderClass("team")}
                    onClick={() => handleSort("team")}
                  >
                    Team {getSortIcon("team")}
                  </TableHead>
                  <TableHead
                    className={getSortableHeaderClass("position")}
                    onClick={() => handleSort("position")}
                  >
                    Position {getSortIcon("position")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("price")}`}
                    onClick={() => handleSort("price")}
                  >
                    Price {getSortIcon("price")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("breakeven")}`}
                    onClick={() => handleSort("breakeven")}
                  >
                    Breakeven {getSortIcon("breakeven")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("l3_avg")}`}
                    onClick={() => handleSort("l3_avg")}
                  >
                    3-Game Avg {getSortIcon("l3_avg")}
                  </TableHead>
                  <TableHead 
                    className={`text-right ${getSortableHeaderClass("games")}`}
                    onClick={() => handleSort("games")}
                  >
                    Games {getSortIcon("games")}
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {isLoading ? (
                  // Loading skeleton state
                  Array.from({ length: 5 }).map((_, index) => (
                    <TableRow key={`skeleton-${index}`}>
                      <TableCell><Skeleton className="h-5 w-32" /></TableCell>
                      <TableCell><Skeleton className="h-5 w-24" /></TableCell>
                      <TableCell><Skeleton className="h-5 w-12" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-16 ml-auto" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-12 ml-auto" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-12 ml-auto" /></TableCell>
                      <TableCell className="text-right"><Skeleton className="h-5 w-8 ml-auto" /></TableCell>
                    </TableRow>
                  ))
                ) : sortedTargets.length > 0 ? (
                  sortedTargets.map((target: DowngradeTarget, index) => (
                    <TableRow key={`${target.name}-${index}`} className={target.breakeven < target.l3_avg ? "bg-green-50" : ""}>
                      <TableCell className="font-medium">{target.name}</TableCell>
                      <TableCell>{target.team}</TableCell>
                      <TableCell>{target.position}</TableCell>
                      <TableCell className="text-right">${(target.price / 1000).toFixed(1)}k</TableCell>
                      <TableCell className="text-right">
                        <div className="flex items-center justify-end">
                          {target.breakeven < target.l3_avg ? (
                            <PiggyBank className="h-4 w-4 text-green-500 mr-1" />
                          ) : (
                            <TrendingDown className="h-4 w-4 text-red-500 mr-1" />
                          )}
                          {target.breakeven}
                        </div>
                      </TableCell>
                      <TableCell className="text-right">{target.l3_avg}</TableCell>
                      <TableCell className="text-right">{target.games}</TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={7} className="text-center py-4 text-gray-500">
                      No downgrade targets found. Try refining your search.
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