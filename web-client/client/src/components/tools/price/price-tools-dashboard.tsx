import React, { useEffect, useState } from "react";
import {
  fetchPriceProjections,
  fetchBreakevenTrends,
  fetchPriceRecoveryPredictions,
  fetchPriceScoreScatter,
  fetchValueRankings
} from "@/services/priceService";
import { SortableTable } from "../sortable-table";
import { Button } from "@/components/ui/button";
import { Loader2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";

// Sub-components to be exported individually
import { PriceProjectionCalculator } from "./price-projection-calculator";
import { BreakevenTrendAnalyzer } from "./breakeven-trend-analyzer";
import { PriceDropRecoveryPredictor } from "./price-drop-recovery-predictor";
import { PriceScoreScatter } from "./price-score-scatter";
import { ValueRankerByPosition } from "./value-ranker-by-position";

export function PriceToolsDashboard() {
  const [activeTab, setActiveTab] = useState<string>("projections");

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-2 mb-4">
        <Button 
          variant={activeTab === "projections" ? "default" : "outline"} 
          onClick={() => setActiveTab("projections")}
          size="sm"
        >
          Price Projections
        </Button>
        <Button 
          variant={activeTab === "trends" ? "default" : "outline"} 
          onClick={() => setActiveTab("trends")}
          size="sm"
        >
          BE Trends
        </Button>
        <Button 
          variant={activeTab === "recovery" ? "default" : "outline"} 
          onClick={() => setActiveTab("recovery")}
          size="sm"
        >
          Price Recovery
        </Button>
        <Button 
          variant={activeTab === "scatter" ? "default" : "outline"} 
          onClick={() => setActiveTab("scatter")}
          size="sm"
        >
          Price/Score Scatter
        </Button>
        <Button 
          variant={activeTab === "value" ? "default" : "outline"} 
          onClick={() => setActiveTab("value")}
          size="sm"
        >
          Value Rankings
        </Button>
      </div>

      <div className="border rounded-md p-4">
        {activeTab === "projections" && <PriceProjectionCalculator />}
        {activeTab === "trends" && <BreakevenTrendAnalyzer />}
        {activeTab === "recovery" && <PriceDropRecoveryPredictor />}
        {activeTab === "scatter" && <PriceScoreScatter />}
        {activeTab === "value" && <ValueRankerByPosition />}
      </div>
    </div>
  );
}