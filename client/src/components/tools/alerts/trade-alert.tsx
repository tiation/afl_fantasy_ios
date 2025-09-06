import React, { useState, useEffect } from "react";
import { 
  BellRing, 
  X, 
  TrendingUp, 
  TrendingDown, 
  AlertTriangle, 
  CheckCircle2, 
  Heart, 
  Star 
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { formatCurrency } from "@/lib/utils";

export type AlertType = 
  | "price-increase"
  | "price-decrease"
  | "injury"
  | "selection"
  | "captain-recommendation"
  | "trade-recommendation"
  | "favorite-player";

export type PlayerAlert = {
  id: string;
  type: AlertType;
  playerId: number;
  playerName: string;
  playerTeam: string;
  playerPosition: string;
  message: string;
  details?: string;
  created: Date;
  read: boolean;
  value?: number;
  importance: "low" | "medium" | "high" | "critical";
};

interface TradeAlertProps {
  alert: PlayerAlert;
  onDismiss: (id: string) => void;
  onAction?: (alert: PlayerAlert) => void;
}

export function TradeAlert({ alert, onDismiss, onAction }: TradeAlertProps) {
  const [isVisible, setIsVisible] = useState(true);
  const [timeAgo, setTimeAgo] = useState<string>("");
  
  // Format relative time
  useEffect(() => {
    const getTimeAgo = () => {
      const now = new Date();
      const diffMs = now.getTime() - alert.created.getTime();
      const diffMins = Math.floor(diffMs / 60000);
      
      if (diffMins < 1) return "just now";
      if (diffMins < 60) return `${diffMins}m ago`;
      
      const diffHours = Math.floor(diffMins / 60);
      if (diffHours < 24) return `${diffHours}h ago`;
      
      const diffDays = Math.floor(diffHours / 24);
      return `${diffDays}d ago`;
    };
    
    setTimeAgo(getTimeAgo());
    
    // Update time ago every minute
    const interval = setInterval(() => {
      setTimeAgo(getTimeAgo());
    }, 60000);
    
    return () => clearInterval(interval);
  }, [alert.created]);
  
  // Handle dismiss animation
  const handleDismiss = () => {
    setIsVisible(false);
    setTimeout(() => onDismiss(alert.id), 300);
  };
  
  // Get alert icon based on type
  const getAlertIcon = () => {
    switch (alert.type) {
      case "price-increase":
        return <TrendingUp className="h-5 w-5 text-green-600" />;
      case "price-decrease":
        return <TrendingDown className="h-5 w-5 text-red-600" />;
      case "injury":
        return <AlertTriangle className="h-5 w-5 text-red-600" />;
      case "selection":
        return <CheckCircle2 className="h-5 w-5 text-blue-600" />;
      case "captain-recommendation":
        return <Star className="h-5 w-5 text-yellow-500" />;
      case "trade-recommendation":
        return <TrendingUp className="h-5 w-5 text-purple-600" />;
      case "favorite-player":
        return <Heart className="h-5 w-5 text-pink-600" />;
      default:
        return <BellRing className="h-5 w-5 text-gray-600" />;
    }
  };

  // Get border and background color based on importance
  const getImportanceStyles = () => {
    switch (alert.importance) {
      case "critical":
        return "border-red-500 bg-red-50";
      case "high":
        return "border-amber-500 bg-amber-50";
      case "medium":
        return "border-blue-400 bg-blue-50";
      case "low":
      default:
        return "border-gray-300 bg-gray-50";
    }
  };
  
  // Get action button based on alert type
  const getActionButton = () => {
    if (!onAction) return null;
    
    let buttonText = "";
    switch (alert.type) {
      case "price-increase":
      case "price-decrease":
        buttonText = "View Player";
        break;
      case "injury":
        buttonText = "Replace Player";
        break;
      case "selection":
        buttonText = "View Selection";
        break;
      case "captain-recommendation":
        buttonText = "Make Captain";
        break;
      case "trade-recommendation":
        buttonText = "View Trade";
        break;
      case "favorite-player":
        buttonText = "View Stats";
        break;
      default:
        buttonText = "View Details";
    }
    
    return (
      <Button 
        size="sm" 
        variant="outline" 
        className="mt-2"
        onClick={() => onAction(alert)}
      >
        {buttonText}
      </Button>
    );
  };
  
  return (
    <div 
      className={`border-l-4 rounded-md overflow-hidden mb-3 transition-all duration-300 ${
        isVisible ? "opacity-100 translate-x-0" : "opacity-0 translate-x-full"
      } ${getImportanceStyles()}`}
    >
      <div className="p-3 relative">
        <Button
          variant="ghost"
          size="sm"
          className="absolute top-1 right-1 h-6 w-6 p-0 rounded-full"
          onClick={handleDismiss}
        >
          <X className="h-3 w-3" />
        </Button>
        
        <div className="flex gap-3">
          <div className="mt-0.5">
            {getAlertIcon()}
          </div>
          
          <div className="flex-1 pr-6">
            <div className="flex flex-wrap items-center gap-x-2 mb-0.5">
              <span className="font-medium text-sm">{alert.playerName}</span>
              <span className="text-xs text-gray-500">
                {alert.playerPosition} | {alert.playerTeam}
              </span>
            </div>
            
            <div className="text-sm">{alert.message}</div>
            
            {alert.value !== undefined && (
              <div className={`text-sm font-medium ${
                alert.type === "price-increase" ? "text-green-600" : 
                alert.type === "price-decrease" ? "text-red-600" : ""
              }`}>
                {alert.type === "price-increase" && "+"}{formatCurrency(alert.value)}
              </div>
            )}
            
            {alert.details && (
              <div className="text-xs text-gray-600 mt-1">{alert.details}</div>
            )}
            
            {getActionButton()}
            
            <div className="text-xs text-gray-500 mt-2">
              {timeAgo}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}