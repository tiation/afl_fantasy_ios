import React, { useState } from "react";
import { 
  CircleDollarSign, 
  Shield, 
  Sparkles, 
  ArrowRightCircle,
  Calculator,
  ArrowUpDown,
  LineChart,
  TrendingUp,
  TrendingDown,
  PiggyBank,
  Percent,
  Activity,
  AlertTriangle,
  Clock,
  BarChart3,
  Trophy,
  Users,
  TrendingUp as TrendingUpward,
  LayoutGrid,
  FileBarChart
} from "lucide-react";

// Trade tools
import { TradeScoreCalculator } from "@/components/tools/trade/trade-score-calculator";
import { OneUpOneDownSuggester } from "@/components/tools/trade/one-up-one-down-suggester";
import PriceDifferenceDelta from "@/components/tools/price/price-difference-delta";

// Cash tools
import { 
  CashGenerationTracker,
  RookiePriceCurve,
  // DowngradeTargetFinder, // Temporarily disabled
  CashGenCeilingFloor,
  PricePredictorCalculator
} from "@/components/tools/cash";

// Risk tools
import {
  TagWatchTable,
  VolatilityIndexTable,
  ConsistencyScoreTable,
  InjuryRiskTable,
  LateOutRiskTable,
  ScoringRangeTable
} from "@/components/tools/risk";

// AI tools
import {
  AITradeSuggester,
  TeamStructureAnalyzer,
  AIInsights,
  AICaptainAdvisor
} from "@/components/tools/ai";

// Role tool components - temporarily disabled due to missing module
// import {
//   RoleChangeDetector,
//   CBATrendAnalyzer, 
//   PositionalImpactScoring,
//   PossessionTypeProfiler
// } from "@/pages/tools";

const sectionStyles: Record<string, React.CSSProperties> = {
  "Trade Analysis Tools": { backgroundColor: "#E8EAF6" },
  "Cash Generation Tools": { backgroundColor: "#E0F7FA" },
  "Risk & Tag Tools": { backgroundColor: "#FFF3E0" },
  "AI Assistant Tools": { backgroundColor: "#E8F5E9" },
  "Role & Positional Tools": { backgroundColor: "#F3E5F5" }
};

type SectionKey = "trade" | "cash" | "risk" | "ai" | "role";

export default function AFLFantasyDashboard() {
  const [openSection, setOpenSection] = useState<SectionKey | null>("trade");
  const [selectedTool, setSelectedTool] = useState<string>("trade_score_calculator");

  const toggleSection = (key: SectionKey) => {
    if (openSection === key) {
      setOpenSection(null);
    } else {
      setOpenSection(key);
      // Set default tool for the section
      switch (key) {
        case "trade":
          setSelectedTool("trade_score_calculator");
          break;
        case "cash":
          setSelectedTool("cash_generation_tracker");
          break;
        case "risk":
          setSelectedTool("tag_watch_monitor");
          break;
        case "ai":
          setSelectedTool("ai_insights_dashboard");
          break;
        case "role":
          setSelectedTool("role_change_detector");
          break;
      }
    }
  };

  // Get the icon for a tool
  const getToolIcon = (toolId: string) => {
    switch (toolId) {
      // Trade tools
      case "trade_score_calculator":
        return <Calculator className="h-4 w-4 mr-2" />;
      case "one_up_one_down_suggester":
        return <ArrowUpDown className="h-4 w-4 mr-2" />;
      case "price_difference_delta":
        return <LineChart className="h-4 w-4 mr-2" />;
        
      // Cash tools
      case "cash_generation_tracker":
        return <CircleDollarSign className="h-4 w-4 mr-2" />;
      case "rookie_price_curve_model":
        return <TrendingUp className="h-4 w-4 mr-2" />;
      case "downgrade_target_finder":
        return <TrendingDown className="h-4 w-4 mr-2" />;
      case "cash_gen_ceiling_floor":
        return <PiggyBank className="h-4 w-4 mr-2" />;
      case "price_predictor_calculator":
        return <Percent className="h-4 w-4 mr-2" />;
      
      // Risk tools
      case "tag_watch_monitor":
        return <Shield className="h-4 w-4 mr-2" />;
      case "volatility_index_calculator":
        return <Activity className="h-4 w-4 mr-2" />;
      case "injury_risk_model":
        return <AlertTriangle className="h-4 w-4 mr-2" />;
      case "consistency_score_generator":
        return <Calculator className="h-4 w-4 mr-2" />;
      case "late_out_risk_estimator":
        return <Clock className="h-4 w-4 mr-2" />;
      case "scoring_range_predictor":
        return <BarChart3 className="h-4 w-4 mr-2" />;
      
      // AI tools
      case "ai_insights_dashboard":
        return <Sparkles className="h-4 w-4 mr-2" />;
      case "ai_trade_suggester":
        return <ArrowUpDown className="h-4 w-4 mr-2" />;
      case "ai_captain_advisor":
        return <Trophy className="h-4 w-4 mr-2" />;
      case "team_structure_analyzer":
        return <Users className="h-4 w-4 mr-2" />;
        
      // Role tools
      case "role_change_detector":
        return <ArrowRightCircle className="h-4 w-4 mr-2" />;
      case "cba_trend_analyzer":
        return <TrendingUpward className="h-4 w-4 mr-2" />;
      case "positional_impact_scoring":
        return <LayoutGrid className="h-4 w-4 mr-2" />;
      case "possession_type_profiler":
        return <FileBarChart className="h-4 w-4 mr-2" />;
      
      default:
        return null;
    }
  };

  // Render the selected tool
  const renderSelectedTool = () => {
    switch (selectedTool) {
      // Trade tools
      case "trade_score_calculator":
        return <TradeScoreCalculator />;
      case "one_up_one_down_suggester":
        return <OneUpOneDownSuggester />;
      case "price_difference_delta":
        return <PriceDifferenceDelta />;
        
      // Cash tools
      case "cash_generation_tracker":
        return <CashGenerationTracker />;
      case "rookie_price_curve_model":
        return <RookiePriceCurve />;
      case "downgrade_target_finder":
        return <div>Downgrade Target Finder - Coming Soon</div>; // Temporarily disabled
      case "cash_gen_ceiling_floor":
        return <CashGenCeilingFloor />;
      case "price_predictor_calculator":
        return <PricePredictorCalculator />;
        
      // Risk tools
      case "tag_watch_monitor":
        return <TagWatchTable />;
      case "volatility_index_calculator":
        return <VolatilityIndexTable />;
      case "injury_risk_model":
        return <InjuryRiskTable />;
      case "consistency_score_generator":
        return <ConsistencyScoreTable />;
      case "late_out_risk_estimator":
        return <LateOutRiskTable />;
      case "scoring_range_predictor":
        return <ScoringRangeTable />;
      
      // AI tools
      case "ai_insights_dashboard":
        return <AIInsights />;
      case "ai_trade_suggester":
        return <AITradeSuggester />;
      case "ai_captain_advisor":
        return <AICaptainAdvisor />;
      case "team_structure_analyzer":
        return <TeamStructureAnalyzer />;
      
      // Role tools - temporarily disabled
      case "role_change_detector":
        return <div>Role Change Detector - Coming Soon</div>;
      case "cba_trend_analyzer":
        return <div>CBA Trend Analyzer - Coming Soon</div>;
      case "positional_impact_scoring":
        return <div>Positional Impact Scoring - Coming Soon</div>;
      case "possession_type_profiler":
        return <div>Possession Type Profiler - Coming Soon</div>;
      
      default:
        return <div>Tool not found</div>;
    }
  };

  // Tool definitions
  const tradeTools = [
    { id: "trade_score_calculator", name: "Trade Score Calculator", description: "Calculate a trade score for a potential trade" },
    { id: "one_up_one_down_suggester", name: "One Up One Down Suggester", description: "Find optimal trade combinations" },
    { id: "price_difference_delta", name: "Price Difference Delta", description: "Compare projected price changes between players" }
  ];

  const cashTools = [
    { id: "cash_generation_tracker", name: "Cash Generation Tracker", description: "Track projected cash generation for players over time" },
    { id: "rookie_price_curve_model", name: "Rookie Price Curve Model", description: "Model the price trajectory of rookies" },
    { id: "downgrade_target_finder", name: "Downgrade Target Finder", description: "Find optimal downgrade targets with low breakevens" },
    { id: "cash_gen_ceiling_floor", name: "Cash Gen Ceiling/Floor", description: "Calculate potential ceiling and floor price changes" },
    { id: "price_predictor_calculator", name: "Price Predictor Calculator", description: "Predict player price changes based on future scores" }
  ];

  const riskTools = [
    { id: "tag_watch_monitor", name: "Tag Watch Monitor", description: "Monitor players at risk of being tagged by opponents" },
    { id: "volatility_index_calculator", name: "Volatility Index Calculator", description: "Calculate a player's score volatility to identify consistent performers" },
    { id: "injury_risk_model", name: "Injury Risk Model", description: "Evaluate the injury risk of players based on history and current status" },
    { id: "consistency_score_generator", name: "Consistency Score Generator", description: "Generate consistency scores to identify reliable performers" },
    { id: "late_out_risk_estimator", name: "Late Out Risk Estimator", description: "Estimate the risk of players being late withdrawals" },
    { id: "scoring_range_predictor", name: "Scoring Range Predictor", description: "Predict the likely scoring range for players based on historical data" }
  ];

  const aiTools = [
    { id: "ai_insights_dashboard", name: "AI Insights Dashboard", description: "Comprehensive AI analysis dashboard with all insights in one view" },
    { id: "ai_trade_suggester", name: "AI Trade Suggester", description: "Get AI-powered trade recommendations based on current data" },
    { id: "ai_captain_advisor", name: "AI Captain Advisor", description: "Find the optimal captain picks using AI analysis" },
    { id: "team_structure_analyzer", name: "Team Structure Analyzer", description: "Analyze your team structure across rookies, mid-pricers, and premiums" }
  ];

  const roleTools = [
    { id: "role_change_detector", name: "Role Change Detector", description: "Detect significant changes in player roles and their fantasy impact" },
    { id: "cba_trend_analyzer", name: "CBA Trend Analyzer", description: "Analyze Centre Bounce Attendance trends and their fantasy implications" },
    { id: "positional_impact_scoring", name: "Positional Impact Scoring", description: "Analyze how positional changes affect fantasy scoring" },
    { id: "possession_type_profiler", name: "Possession Type Profiler", description: "Profile players based on possession types and fantasy scoring" }
  ];

  return (
    <div style={{ padding: "20px", fontFamily: "Arial, sans-serif" }}>
      <h1 className="text-2xl font-bold mb-4">AFL Fantasy Coach Dashboard</h1>

      {/* TRADE TOOLS */}
      <div style={{ ...sectionStyles["Trade Analysis Tools"], padding: "10px", marginBottom: "10px", borderRadius: "8px" }}>
        <h2 
          onClick={() => toggleSection("trade")} 
          style={{ cursor: "pointer", fontWeight: "bold", display: "flex", alignItems: "center" }}
          className="text-xl"
        >
          <ArrowUpDown className="h-5 w-5 mr-2" />
          Trade Analysis Tools {openSection === "trade" ? "▲" : "▼"}
        </h2>
        {openSection === "trade" && (
          <div className="p-2">
            <div className="flex flex-wrap gap-2 mb-4">
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
                  {getToolIcon(tool.id)}
                  {tool.name}
                </button>
              ))}
            </div>
            <div className="bg-white p-4 rounded-md shadow">
              {renderSelectedTool()}
            </div>
          </div>
        )}
      </div>

      {/* CASH TOOLS */}
      <div style={{ ...sectionStyles["Cash Generation Tools"], padding: "10px", marginBottom: "10px", borderRadius: "8px" }}>
        <h2 
          onClick={() => toggleSection("cash")} 
          style={{ cursor: "pointer", fontWeight: "bold", display: "flex", alignItems: "center" }}
          className="text-xl"
        >
          <CircleDollarSign className="h-5 w-5 mr-2" />
          Cash Generation Tools {openSection === "cash" ? "▲" : "▼"}
        </h2>
        {openSection === "cash" && (
          <div className="p-2">
            <div className="flex flex-wrap gap-2 mb-4">
              {cashTools.map(tool => (
                <button
                  key={tool.id}
                  className={`flex items-center px-3 py-2 rounded-md text-sm ${
                    selectedTool === tool.id
                      ? "bg-primary text-primary-foreground"
                      : "bg-gray-100 hover:bg-gray-200 text-gray-700"
                  }`}
                  onClick={() => setSelectedTool(tool.id)}
                >
                  {getToolIcon(tool.id)}
                  {tool.name}
                </button>
              ))}
            </div>
            <div className="bg-white p-4 rounded-md shadow">
              {renderSelectedTool()}
            </div>
          </div>
        )}
      </div>

      {/* RISK TOOLS */}
      <div style={{ ...sectionStyles["Risk & Tag Tools"], padding: "10px", marginBottom: "10px", borderRadius: "8px" }}>
        <h2 
          onClick={() => toggleSection("risk")} 
          style={{ cursor: "pointer", fontWeight: "bold", display: "flex", alignItems: "center" }}
          className="text-xl"
        >
          <Shield className="h-5 w-5 mr-2" />
          Risk & Tag Tools {openSection === "risk" ? "▲" : "▼"}
        </h2>
        {openSection === "risk" && (
          <div className="p-2">
            <div className="flex flex-wrap gap-2 mb-4">
              {riskTools.map(tool => (
                <button
                  key={tool.id}
                  className={`flex items-center px-3 py-2 rounded-md text-sm ${
                    selectedTool === tool.id
                      ? "bg-primary text-primary-foreground"
                      : "bg-gray-100 hover:bg-gray-200 text-gray-700"
                  }`}
                  onClick={() => setSelectedTool(tool.id)}
                >
                  {getToolIcon(tool.id)}
                  {tool.name}
                </button>
              ))}
            </div>
            <div className="bg-white p-4 rounded-md shadow">
              {renderSelectedTool()}
            </div>
          </div>
        )}
      </div>

      {/* AI TOOLS */}
      <div style={{ ...sectionStyles["AI Assistant Tools"], padding: "10px", marginBottom: "10px", borderRadius: "8px" }}>
        <h2 
          onClick={() => toggleSection("ai")} 
          style={{ cursor: "pointer", fontWeight: "bold", display: "flex", alignItems: "center" }}
          className="text-xl"
        >
          <Sparkles className="h-5 w-5 mr-2" />
          AI Assistant Tools {openSection === "ai" ? "▲" : "▼"}
        </h2>
        {openSection === "ai" && (
          <div className="p-2">
            <div className="flex flex-wrap gap-2 mb-4">
              {aiTools.map(tool => (
                <button
                  key={tool.id}
                  className={`flex items-center px-3 py-2 rounded-md text-sm ${
                    selectedTool === tool.id
                      ? "bg-primary text-primary-foreground"
                      : "bg-gray-100 hover:bg-gray-200 text-gray-700"
                  }`}
                  onClick={() => setSelectedTool(tool.id)}
                >
                  {getToolIcon(tool.id)}
                  {tool.name}
                </button>
              ))}
            </div>
            <div className="bg-white p-4 rounded-md shadow">
              {renderSelectedTool()}
            </div>
          </div>
        )}
      </div>

      {/* ROLE TOOLS */}
      <div style={{ ...sectionStyles["Role & Positional Tools"], padding: "10px", marginBottom: "10px", borderRadius: "8px" }}>
        <h2 
          onClick={() => toggleSection("role")} 
          style={{ cursor: "pointer", fontWeight: "bold", display: "flex", alignItems: "center" }}
          className="text-xl"
        >
          <ArrowRightCircle className="h-5 w-5 mr-2" />
          Role & Positional Tools {openSection === "role" ? "▲" : "▼"}
        </h2>
        {openSection === "role" && (
          <div className="p-2">
            <div className="flex flex-wrap gap-2 mb-4">
              {roleTools.map(tool => (
                <button
                  key={tool.id}
                  className={`flex items-center px-3 py-2 rounded-md text-sm ${
                    selectedTool === tool.id
                      ? "bg-primary text-primary-foreground"
                      : "bg-gray-100 hover:bg-gray-200 text-gray-700"
                  }`}
                  onClick={() => setSelectedTool(tool.id)}
                >
                  {getToolIcon(tool.id)}
                  {tool.name}
                </button>
              ))}
            </div>
            <div className="bg-white p-4 rounded-md shadow">
              {renderSelectedTool()}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}