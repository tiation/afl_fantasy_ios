import { useState } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { 
  OneUpOneDownSuggester, 
  PriceDifferenceDelta, 
  TradeOptimizer, 
  TradeScoreCalculator,
  ValueGainTracker,
  TradeRiskAnalyzer,
  TradeBurnRiskAnalyzer,
  TradeReturnAnalyzer
} from "./index";
import { AIAlertGenerator } from "../alerts/ai-alert-generator";
import AlertCenter from "../alerts/alert-center";
import { BellRing, BrainCircuit } from "lucide-react";

/**
 * Trade tools component that provides access to various trade-related tools
 */
export default function TradeTools() {
  const [activeTab, setActiveTab] = useState<string>("trade-optimizer");

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center mb-2">
        <h2 className="text-lg font-semibold">Trade Tools</h2>
        <div className="flex items-center gap-2">
          <AlertCenter />
        </div>
      </div>
    
      <Tabs
        value={activeTab}
        onValueChange={setActiveTab}
        className="w-full"
      >
        <TabsList className="w-full flex flex-wrap">
          <TabsTrigger value="trade-optimizer" className="flex-1">
            Trade Optimizer
          </TabsTrigger>
          <TabsTrigger value="trade-score-calculator" className="flex-1">
            Score Calculator
          </TabsTrigger>
          <TabsTrigger value="value-gain-tracker" className="flex-1">
            Value Tracker
          </TabsTrigger>
          <TabsTrigger value="trade-risk-analyzer" className="flex-1">
            Risk Analyzer
          </TabsTrigger>
          <TabsTrigger value="trade-burn-risk-analyzer" className="flex-1">
            Burn Risk
          </TabsTrigger>
          <TabsTrigger value="trade-return-analyzer" className="flex-1">
            Return Analyzer
          </TabsTrigger>
          <TabsTrigger value="one-up-one-down-suggester" className="flex-1">
            One Up One Down
          </TabsTrigger>
          <TabsTrigger value="price-difference-delta" className="flex-1">
            Price Delta
          </TabsTrigger>
          <TabsTrigger value="ai-alerts" className="flex-1">
            <BellRing className="h-4 w-4 mr-1" />
            AI Alerts
          </TabsTrigger>
        </TabsList>

        <TabsContent value="trade-optimizer" className="pt-4">
          <TradeOptimizer />
        </TabsContent>

        <TabsContent value="trade-score-calculator" className="pt-4">
          <TradeScoreCalculator />
        </TabsContent>

        <TabsContent value="value-gain-tracker" className="pt-4">
          <ValueGainTracker />
        </TabsContent>

        <TabsContent value="trade-risk-analyzer" className="pt-4">
          <TradeRiskAnalyzer />
        </TabsContent>

        <TabsContent value="one-up-one-down-suggester" className="pt-4">
          <OneUpOneDownSuggester />
        </TabsContent>

        <TabsContent value="price-difference-delta" className="pt-4">
          <PriceDifferenceDelta />
        </TabsContent>

        <TabsContent value="trade-burn-risk-analyzer" className="pt-4">
          <TradeBurnRiskAnalyzer />
        </TabsContent>

        <TabsContent value="trade-return-analyzer" className="pt-4">
          <TradeReturnAnalyzer />
        </TabsContent>
        
        <TabsContent value="ai-alerts" className="pt-4">
          <AIAlertGenerator />
        </TabsContent>
      </Tabs>
    </div>
  );
}