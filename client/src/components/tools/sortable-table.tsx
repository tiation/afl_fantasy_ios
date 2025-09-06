import { useState } from "react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ArrowDown, ArrowUp } from "lucide-react";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

interface SortConfig {
  key: string;
  direction: 'asc' | 'desc';
}

interface Column {
  key: string;
  label: string;
  sortable?: boolean;
  render?: (value: any, item: any) => React.ReactNode;
}

interface SortableTableProps {
  data: any[];
  columns: Column[];
  emptyMessage?: string;
}

export function SortableTable({ data, columns, emptyMessage = "No data available" }: SortableTableProps) {
  const [sortConfig, setSortConfig] = useState<SortConfig | null>(null);
  const [selectedPlayer, setSelectedPlayer] = useState<any | null>(null);

  const handleSort = (key: string) => {
    let direction: 'asc' | 'desc' = 'asc';
    
    if (sortConfig && sortConfig.key === key) {
      direction = sortConfig.direction === 'asc' ? 'desc' : 'asc';
    }
    
    setSortConfig({ key, direction });
  };

  const sortedData = [...data].sort((a, b) => {
    if (!sortConfig) return 0;
    
    const aValue = a[sortConfig.key];
    const bValue = b[sortConfig.key];
    
    if (aValue === bValue) return 0;
    
    // Handle numeric values
    if (typeof aValue === 'number' && typeof bValue === 'number') {
      return sortConfig.direction === 'asc' ? aValue - bValue : bValue - aValue;
    }
    
    // Handle string values
    if (typeof aValue === 'string' && typeof bValue === 'string') {
      return sortConfig.direction === 'asc' 
        ? aValue.localeCompare(bValue) 
        : bValue.localeCompare(aValue);
    }
    
    // Handle mixed or other types
    return sortConfig.direction === 'asc' 
      ? String(aValue).localeCompare(String(bValue))
      : String(bValue).localeCompare(String(aValue));
  });

  const handlePlayerClick = (player: any) => {
    setSelectedPlayer(player);
  };

  const closePlayerModal = () => {
    setSelectedPlayer(null);
  };

  return (
    <>
      <div className="rounded-md border">
        <Table>
          <TableHeader>
            <TableRow>
              {columns.map((column) => (
                <TableHead 
                  key={column.key}
                  className={column.sortable ? "cursor-pointer" : ""}
                  onClick={column.sortable ? () => handleSort(column.key) : undefined}
                >
                  <div className="flex items-center gap-1">
                    {column.label}
                    {sortConfig && sortConfig.key === column.key && (
                      sortConfig.direction === 'asc' ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />
                    )}
                  </div>
                </TableHead>
              ))}
            </TableRow>
          </TableHeader>
          <TableBody>
            {sortedData.length > 0 ? (
              sortedData.map((item, index) => (
                <TableRow 
                  key={index}
                  className={item.player_name ? "cursor-pointer hover:bg-muted/50" : ""}
                  onClick={item.player_name ? () => handlePlayerClick(item) : undefined}
                >
                  {columns.map((column) => (
                    <TableCell key={column.key}>
                      {column.render 
                        ? column.render(item[column.key], item) 
                        : item[column.key]}
                    </TableCell>
                  ))}
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={columns.length} className="text-center">
                  {emptyMessage}
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </div>

      {/* Player Bio Modal */}
      <Dialog open={selectedPlayer !== null} onOpenChange={(open) => { if (!open) closePlayerModal(); }}>
        <DialogContent className="sm:max-w-[425px]">
          <DialogHeader>
            <DialogTitle>{selectedPlayer?.player_name || 'Player Details'}</DialogTitle>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            {selectedPlayer && (
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-2">
                  <div className="font-medium">Team:</div>
                  <div>{selectedPlayer.team}</div>
                  
                  <div className="font-medium">Position:</div>
                  <div>{selectedPlayer.position}</div>
                  
                  <div className="font-medium">Price:</div>
                  <div>${selectedPlayer.price?.toLocaleString()}</div>
                  
                  <div className="font-medium">Average:</div>
                  <div>{selectedPlayer.average_points?.toFixed(1)}</div>
                  
                  <div className="font-medium">Breakeven:</div>
                  <div>{selectedPlayer.breakeven}</div>
                </div>
                
                {/* Additional player stats based on available data */}
                {selectedPlayer.last_5_scores && (
                  <div>
                    <div className="font-medium mb-1">Last 5 Scores:</div>
                    <div className="flex gap-2">
                      {selectedPlayer.last_5_scores.map((score: number, i: number) => (
                        <div key={i} className="px-2 py-1 bg-muted rounded">{score}</div>
                      ))}
                    </div>
                  </div>
                )}
                
                {/* Any other stats that might be helpful */}
                {selectedPlayer.status && (
                  <div className="grid grid-cols-2 gap-2">
                    <div className="font-medium">Status:</div>
                    <div>{selectedPlayer.status}</div>
                  </div>
                )}
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}