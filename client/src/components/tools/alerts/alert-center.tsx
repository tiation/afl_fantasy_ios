import React, { useState, useEffect } from "react";
import { 
  Bell, 
  BellOff, 
  Filter, 
  CheckCircle2, 
  AlertTriangle, 
  TrendingUp, 
  Trash2, 
  X
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Badge } from "@/components/ui/badge";
import { 
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuCheckboxItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { TradeAlert, PlayerAlert, AlertType } from "./trade-alert";

// Demo data - in a real app this would come from an API or state management
const generateMockAlerts = (): PlayerAlert[] => {
  return [
    {
      id: "1",
      type: "price-increase",
      playerId: 101,
      playerName: "Izak Rankine",
      playerTeam: "ADEL",
      playerPosition: "FWD",
      message: "Price increased after a big score!",
      details: "Break-even of 65 was significantly lower than scored 94 points.",
      created: new Date(Date.now() - 1000 * 60 * 30), // 30 mins ago
      read: false,
      value: 8300,
      importance: "medium"
    },
    {
      id: "2",
      type: "injury",
      playerId: 102,
      playerName: "Jeremy Cameron",
      playerTeam: "GEEL",
      playerPosition: "FWD",
      message: "Injured during the match with concussion.",
      details: "Expected to miss at least 1 week due to concussion protocols.",
      created: new Date(Date.now() - 1000 * 60 * 120), // 2 hours ago
      read: false,
      importance: "high"
    },
    {
      id: "3",
      type: "captain-recommendation",
      playerId: 103,
      playerName: "Marcus Bontempelli",
      playerTeam: "WB",
      playerPosition: "MID",
      message: "Optimal captain choice for this week.",
      details: "Facing ESS who allow the 2nd most fantasy points to midfielders.",
      created: new Date(Date.now() - 1000 * 60 * 60 * 5), // 5 hours ago
      read: true,
      importance: "medium"
    },
    {
      id: "4",
      type: "price-decrease",
      playerId: 104,
      playerName: "Jordan De Goey",
      playerTeam: "COLL",
      playerPosition: "MID/FWD",
      message: "Price dropping quickly after poor performance.",
      details: "Scored only 52 vs a break-even of 105.",
      created: new Date(Date.now() - 1000 * 60 * 60 * 12), // 12 hours ago
      read: false,
      value: -21700,
      importance: "medium"
    },
    {
      id: "5",
      type: "trade-recommendation",
      playerId: 105,
      playerName: "Noah Anderson",
      playerTeam: "GCFC",
      playerPosition: "MID",
      message: "Recommended trade target based on fixture and form.",
      details: "Low break-even (72) and favorable next 3 matches.",
      created: new Date(Date.now() - 1000 * 60 * 60 * 24), // 1 day ago
      read: true,
      importance: "medium"
    },
    {
      id: "6",
      type: "selection",
      playerId: 106,
      playerName: "Harry Sheezel",
      playerTeam: "NTH",
      playerPosition: "DEF/MID",
      message: "No longer playing MID - position change alerts.",
      details: "Moved to half-back role in team selection.",
      created: new Date(Date.now() - 1000 * 60 * 60 * 36), // 1.5 days ago
      read: false,
      importance: "high"
    },
    {
      id: "7",
      type: "favorite-player",
      playerId: 107,
      playerName: "Nick Daicos",
      playerTeam: "COLL",
      playerPosition: "MID",
      message: "Your favorite player had a huge score!",
      details: "Nick Daicos scored 138 points in the last round.",
      created: new Date(Date.now() - 1000 * 60 * 60 * 48), // 2 days ago
      read: true,
      importance: "low"
    }
  ];
};

// Alert filter types
type FilterState = {
  [key in AlertType]?: boolean;
} & {
  unreadOnly: boolean;
};

export default function AlertCenter() {
  const [alerts, setAlerts] = useState<PlayerAlert[]>(generateMockAlerts());
  const [filteredAlerts, setFilteredAlerts] = useState<PlayerAlert[]>(alerts);
  const [isOpen, setIsOpen] = useState(false);
  const [filters, setFilters] = useState<FilterState>({
    unreadOnly: false,
    "price-increase": true,
    "price-decrease": true,
    "injury": true,
    "selection": true,
    "captain-recommendation": true,
    "trade-recommendation": true,
    "favorite-player": true
  });
  
  // Count unread alerts
  const unreadCount = alerts.filter(alert => !alert.read).length;
  
  // Apply filters when alerts or filters change
  useEffect(() => {
    let filtered = [...alerts];
    
    // Filter by read status
    if (filters.unreadOnly) {
      filtered = filtered.filter(alert => !alert.read);
    }
    
    // Filter by alert types
    filtered = filtered.filter(alert => filters[alert.type]);
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.created.getTime() - a.created.getTime());
    
    setFilteredAlerts(filtered);
  }, [alerts, filters]);
  
  // Handle dismissing an alert
  const handleDismiss = (id: string) => {
    setAlerts(alerts.filter(alert => alert.id !== id));
  };
  
  // Handle clearing all alerts
  const handleClearAll = () => {
    setAlerts([]);
  };
  
  // Handle marking all as read
  const handleMarkAllRead = () => {
    setAlerts(alerts.map(alert => ({ ...alert, read: true })));
  };
  
  // Handle action button click on alert
  const handleAlertAction = (alert: PlayerAlert) => {
    // In a real app, this would navigate to the relevant page or perform an action
    console.log("Alert action:", alert);
    
    // Mark as read when acted upon
    setAlerts(
      alerts.map(a => 
        a.id === alert.id 
          ? { ...a, read: true } 
          : a
      )
    );
  };
  
  return (
    <div>
      <Sheet open={isOpen} onOpenChange={setIsOpen}>
        <Button 
          variant="outline" 
          size="icon" 
          className="relative"
          onClick={() => setIsOpen(true)}
        >
          <Bell className="h-[1.2rem] w-[1.2rem]" />
          {unreadCount > 0 && (
            <Badge 
              className="absolute -top-2 -right-2 h-5 min-w-5 p-0 flex items-center justify-center"
              variant="destructive"
            >
              {unreadCount}
            </Badge>
          )}
        </Button>
        <SheetContent className="sm:max-w-md w-[90vw]">
          <SheetHeader className="flex flex-row items-center justify-between">
            <SheetTitle className="flex items-center">
              <Bell className="h-5 w-5 mr-2" />
              <span>Alerts Center</span>
              {unreadCount > 0 && (
                <Badge className="ml-2" variant="secondary">
                  {unreadCount} unread
                </Badge>
              )}
            </SheetTitle>
            <Button 
              variant="ghost" 
              size="icon" 
              className="absolute right-4 top-4"
              onClick={() => setIsOpen(false)}
            >
              <X className="h-4 w-4" />
            </Button>
          </SheetHeader>
          
          <div className="py-4">
            <div className="flex justify-between items-center mb-4">
              <div className="flex items-center space-x-2">
                <Switch
                  id="unread-only"
                  checked={filters.unreadOnly}
                  onCheckedChange={(checked) => 
                    setFilters({...filters, unreadOnly: checked})
                  }
                />
                <Label htmlFor="unread-only" className="text-sm">
                  Unread only
                </Label>
              </div>
              
              <div className="flex items-center gap-2">
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button variant="outline" size="sm" className="h-8 text-xs">
                      <Filter className="h-3.5 w-3.5 mr-1" />
                      Filter
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end" className="w-56">
                    <DropdownMenuCheckboxItem
                      checked={filters["price-increase"]}
                      onCheckedChange={(checked) => 
                        setFilters({...filters, "price-increase": checked})
                      }
                    >
                      <TrendingUp className="h-4 w-4 mr-2 text-green-600" />
                      Price Increases
                    </DropdownMenuCheckboxItem>
                    <DropdownMenuCheckboxItem
                      checked={filters["price-decrease"]}
                      onCheckedChange={(checked) => 
                        setFilters({...filters, "price-decrease": checked})
                      }
                    >
                      <TrendingUp className="h-4 w-4 mr-2 text-red-600 rotate-180" />
                      Price Decreases
                    </DropdownMenuCheckboxItem>
                    <DropdownMenuCheckboxItem
                      checked={filters["injury"]}
                      onCheckedChange={(checked) => 
                        setFilters({...filters, "injury": checked})
                      }
                    >
                      <AlertTriangle className="h-4 w-4 mr-2 text-red-600" />
                      Injuries
                    </DropdownMenuCheckboxItem>
                    <DropdownMenuCheckboxItem
                      checked={filters["selection"]}
                      onCheckedChange={(checked) => 
                        setFilters({...filters, "selection": checked})
                      }
                    >
                      <CheckCircle2 className="h-4 w-4 mr-2 text-blue-600" />
                      Selection Changes
                    </DropdownMenuCheckboxItem>
                    <DropdownMenuCheckboxItem
                      checked={filters["captain-recommendation"]}
                      onCheckedChange={(checked) => 
                        setFilters({...filters, "captain-recommendation": checked})
                      }
                    >
                      <CheckCircle2 className="h-4 w-4 mr-2 text-yellow-500" />
                      Captain Recommendations
                    </DropdownMenuCheckboxItem>
                    <DropdownMenuCheckboxItem
                      checked={filters["trade-recommendation"]}
                      onCheckedChange={(checked) => 
                        setFilters({...filters, "trade-recommendation": checked})
                      }
                    >
                      <TrendingUp className="h-4 w-4 mr-2 text-purple-600" />
                      Trade Recommendations
                    </DropdownMenuCheckboxItem>
                  </DropdownMenuContent>
                </DropdownMenu>
                
                <Button 
                  variant="ghost" 
                  size="sm" 
                  className="h-8 text-xs"
                  onClick={handleClearAll}
                  disabled={alerts.length === 0}
                >
                  <Trash2 className="h-3.5 w-3.5 mr-1" />
                  Clear All
                </Button>
                
                <Button 
                  variant="ghost" 
                  size="sm" 
                  className="h-8 text-xs"
                  onClick={handleMarkAllRead}
                  disabled={unreadCount === 0}
                >
                  <CheckCircle2 className="h-3.5 w-3.5 mr-1" />
                  Mark All Read
                </Button>
              </div>
            </div>
            
            <div className="space-y-1 max-h-[70vh] overflow-y-auto pr-1">
              {filteredAlerts.length === 0 ? (
                <div className="text-center py-12 text-gray-500">
                  <BellOff className="h-8 w-8 mx-auto mb-3 opacity-50" />
                  <p className="text-sm">No alerts to display</p>
                  <p className="text-xs mt-1">
                    {alerts.length === 0 
                      ? "You're all caught up!" 
                      : "Try changing your filters"}
                  </p>
                </div>
              ) : (
                filteredAlerts.map(alert => (
                  <TradeAlert
                    key={alert.id}
                    alert={alert}
                    onDismiss={handleDismiss}
                    onAction={handleAlertAction}
                  />
                ))
              )}
            </div>
          </div>
        </SheetContent>
      </Sheet>
    </div>
  );
}