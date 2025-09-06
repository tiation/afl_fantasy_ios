import React, { useState } from "react";
import { 
  ArrowUpDown, 
  CircleDollarSign, 
  Shield, 
  Sparkles, 
  ArrowRightCircle
} from "lucide-react";
import { Card } from "@/components/ui/card";

// Import role tools
import {
  RoleChangeDetector,
  CBATrendAnalyzer,
  PositionalImpactScoring,
  PossessionTypeProfiler
} from "@/components/tools/role";

// Import cash tools
import { 
  CashGenerationTracker, 
  RookiePriceCurve 
} from "@/components/tools/cash";

// Import risk tools
import { 
  TagWatchTable 
} from "@/components/tools/risk";

// Import AI tools
import { 
  AIInsights 
} from "@/components/tools/ai";

// Import trade tools
import { 
  TradeScoreCalculator 
} from "@/components/tools/trade";

type SectionKey = "trade" | "cash" | "risk" | "ai" | "role";

export default function AFLFantasyDashboard() {
  const [openSection, setOpenSection] = useState<SectionKey | null>(null);

  const toggleSection = (key: SectionKey) => {
    setOpenSection(prev => (prev === key ? null : key));
  };

  return (
    <div className="w-full max-w-3xl mx-auto">
      <h1 className="text-xl md:text-2xl font-bold mb-4">AFL Fantasy Coach Dashboard</h1>

      {/* TRADE TOOLS */}
      <Card className="mb-4 border-2 bg-blue-50 border-blue-200 shadow-sm hover:shadow-md transition-shadow">
        <div 
          onClick={() => toggleSection("trade")}
          className="p-3 md:p-4 cursor-pointer flex items-center justify-between"
        >
          <div className="flex items-center">
            <ArrowUpDown className="h-4 w-4 md:h-5 md:w-5 mr-2 text-blue-600" />
            <h2 className="text-base md:text-lg font-medium">Trade Analysis Tools</h2>
          </div>
          <span className="text-blue-600">{openSection === "trade" ? "▲" : "▼"}</span>
        </div>
        
        {openSection === "trade" && (
          <div className="p-3 md:p-4 pt-0 border-t border-blue-100">
            <TradeScoreCalculator />
          </div>
        )}
      </Card>

      {/* CASH TOOLS */}
      <Card className="mb-4 border-2 bg-cyan-50 border-cyan-200 shadow-sm hover:shadow-md transition-shadow">
        <div 
          onClick={() => toggleSection("cash")}
          className="p-3 md:p-4 cursor-pointer flex items-center justify-between"
        >
          <div className="flex items-center">
            <CircleDollarSign className="h-4 w-4 md:h-5 md:w-5 mr-2 text-cyan-600" />
            <h2 className="text-base md:text-lg font-medium">Cash Generation Tools</h2>
          </div>
          <span className="text-cyan-600">{openSection === "cash" ? "▲" : "▼"}</span>
        </div>
        
        {openSection === "cash" && (
          <div className="p-3 md:p-4 pt-0 border-t border-cyan-100">
            <CashGenerationTracker />
          </div>
        )}
      </Card>

      {/* RISK TOOLS */}
      <Card className="mb-4 border-2 bg-orange-50 border-orange-200 shadow-sm hover:shadow-md transition-shadow">
        <div 
          onClick={() => toggleSection("risk")}
          className="p-3 md:p-4 cursor-pointer flex items-center justify-between"
        >
          <div className="flex items-center">
            <Shield className="h-4 w-4 md:h-5 md:w-5 mr-2 text-orange-600" />
            <h2 className="text-base md:text-lg font-medium">Risk & Tag Tools</h2>
          </div>
          <span className="text-orange-600">{openSection === "risk" ? "▲" : "▼"}</span>
        </div>
        
        {openSection === "risk" && (
          <div className="p-3 md:p-4 pt-0 border-t border-orange-100">
            <TagWatchTable />
          </div>
        )}
      </Card>

      {/* AI TOOLS */}
      <Card className="mb-4 border-2 bg-green-50 border-green-200 shadow-sm hover:shadow-md transition-shadow">
        <div 
          onClick={() => toggleSection("ai")}
          className="p-3 md:p-4 cursor-pointer flex items-center justify-between"
        >
          <div className="flex items-center">
            <Sparkles className="h-4 w-4 md:h-5 md:w-5 mr-2 text-green-600" />
            <h2 className="text-base md:text-lg font-medium">AI Assistant Tools</h2>
          </div>
          <span className="text-green-600">{openSection === "ai" ? "▲" : "▼"}</span>
        </div>
        
        {openSection === "ai" && (
          <div className="p-3 md:p-4 pt-0 border-t border-green-100">
            <AIInsights />
          </div>
        )}
      </Card>

      {/* ROLE TOOLS */}
      <Card className="mb-4 border-2 bg-purple-50 border-purple-200 shadow-sm hover:shadow-md transition-shadow">
        <div 
          onClick={() => toggleSection("role")}
          className="p-3 md:p-4 cursor-pointer flex items-center justify-between"
        >
          <div className="flex items-center">
            <ArrowRightCircle className="h-4 w-4 md:h-5 md:w-5 mr-2 text-purple-600" />
            <h2 className="text-base md:text-lg font-medium">Role & Positional Tools</h2>
          </div>
          <span className="text-purple-600">{openSection === "role" ? "▲" : "▼"}</span>
        </div>
        
        {openSection === "role" && (
          <div className="p-3 md:p-4 pt-0 border-t border-purple-100">
            <RoleChangeDetector />
          </div>
        )}
      </Card>
    </div>
  );
}