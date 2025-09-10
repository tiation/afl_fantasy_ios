import React, { useState } from "react";
import { 
  Calculator, 
  ArrowUpDown, 
  LineChart 
} from "lucide-react";

// Import components
import { 
  TradeScoreCalculator, 
  OneUpOneDownSuggester, 
  PriceDifferenceDelta 
} from "@/components/tools/trade";

// Define tool types
type TradeTool = {
  id: string;
  name: string;
  icon: React.ReactNode;
  component: React.ReactNode;
  description: string;
};

export default function TradeToolsDashboard() {
  const [selectedTool, setSelectedTool] = useState<string>("trade_score_calculator");

  // Define trade tools
  const tradeTools: TradeTool[] = [
    { 
      id: "trade_score_calculator", 
      name: "Trade Score Calculator", 
      icon: <Calculator className="h-4 w-4 mr-2" />,
      component: <TradeScoreCalculator />,
      description: "Calculate a trade score for a potential trade" 
    },
    { 
      id: "one_up_one_down_suggester", 
      name: "One Up One Down Suggester", 
      icon: <ArrowUpDown className="h-4 w-4 mr-2" />,
      component: <OneUpOneDownSuggester />,
      description: "Find optimal trade combinations" 
    },
    { 
      id: "price_difference_delta", 
      name: "Price Difference Delta", 
      icon: <LineChart className="h-4 w-4 mr-2" />,
      component: <PriceDifferenceDelta />,
      description: "Compare projected price changes between players" 
    }
  ];

  // Find the selected tool
  const currentTool = tradeTools.find(tool => tool.id === selectedTool);

  return (
    <div>
      <div className="mb-4">
        <h3 className="mb-2 font-medium">Trade Analysis Tools</h3>
        <p className="text-sm text-gray-600 mb-4">
          These tools help you analyze potential trades and optimize your team.
        </p>
        
        <div className="flex flex-wrap gap-2 mb-6">
          {tradeTools.map(tool => (
            <button
              key={tool.id}
              className={`flex items-center px-3 py-2 rounded-md text-sm ${
                selectedTool === tool.id
                  ? "bg-primary text-primary-foreground"
                  : "bg-gray-100 hover:bg-gray-200 text-gray-700"
              }`}
              onClick={() => setSelectedTool(tool.id)}
            >
              {tool.icon}
              {tool.name}
            </button>
          ))}
        </div>
      </div>

      {currentTool && (
        <div className="bg-white p-4 rounded-md">
          {currentTool.component}
        </div>
      )}
    </div>
  );
}