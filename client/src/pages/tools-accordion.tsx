import React, { useState } from "react";
import { 
  ArrowUpDown, 
  CircleDollarSign, 
  Shield, 
  Sparkles, 
  ArrowRightCircle,
  BarChartHorizontal,
  TrendingUp,
  DollarSign,
  Layers,
  Calculator,
  Tag,
  Activity,
  CheckSquare,
  Thermometer,
  Timer,
  LineChart,
  Brain,
  Medal,
  Layout,
  Crown,
  GitCommit,
  TrendingDown,
  Shuffle,
  Briefcase,
  BarChart,
  LineChartIcon,
  ScatterChart,
  BadgeDollarSign,
  CalendarDays,
  Map,
  Compass,
  CloudRain,
  Wind,
  Calendar,
  MapPin,
  Star,
  Lightbulb,
  Users
} from "lucide-react";
import { Card } from "@/components/ui/card";

// Import collapsible tool component
import { CollapsibleTool } from "@/components/tools/collapsible-tool";

// Import captain tools
import {
  CaptainScorePredictor,
  ViceCaptainOptimizer,
  FormBasedCaptainAnalyzer
} from "@/components/tools/captain";

// Import trade tools
import { TradeScoreCalculator } from "@/components/tools/trade/trade-score-calculator";
import { OneUpOneDownSuggester } from "@/components/tools/trade/one-up-one-down-suggester";
import { PriceDifferenceDelta } from "@/components/tools/trade/price-difference-delta";

// Import cash tools
import { 
  CashGenerationTracker, 
  CashCeilingFloorTracker,
  RookiePriceCurve,
  CashCowTracker,
  BuySellTimingTool,
  CashGenCeilingFloor, 
  PricePredictorCalculator
} from "@/components/tools/cash";

// Import risk tools
import { 
  TagWatchTable,
  VolatilityIndexTable,
  ConsistencyScoreTable,
  InjuryRiskTable,
  LateOutRiskTable,
  ScoringRangeTable
} from "@/components/tools/risk";

// Import AI tools
import { 
  AIInsights,
  AITradeSuggester,
  TeamStructureAnalyzer,
  AICaptainAdvisor
} from "@/components/tools/ai";

// Import role tools
import {
  RoleChangeDetector,
  CBATrendAnalyzer,
  PositionalImpactScoring,
  PossessionTypeProfiler
} from "@/components/tools/role";

// Import price predictor tools
import { PriceProjectionCalculator } from "@/components/tools/price/price-projection-calculator";
import { BreakevenTrendAnalyzer } from "@/components/tools/price/breakeven-trend-analyzer";
import { PriceDropRecoveryPredictor } from "@/components/tools/price/price-drop-recovery-predictor";
import { PriceScoreScatter } from "@/components/tools/price/price-score-scatter";
import { ValueRankerByPosition } from "@/components/tools/price/value-ranker-by-position";

// Import fixture analysis tools
import {
  FixtureDifficultyScanner,
  MatchupDVPAnalyzer,
  FixtureSwingRadar,
  TravelImpactEstimator,
  WeatherForecastRiskModel
} from "@/components/tools/fixture";

// Import context analysis tools
import {
  ByeRoundOptimizer,
  LateSeasonTaperFlagger,
  FastStartProfileScanner,
  VenueBiasDetector,
  ContractYearMotivationChecker
} from "@/components/tools/context";

type SectionKey = "trade" | "cash" | "risk" | "ai" | "role" | "captain" | "price" | "fixture" | "context";

export default function ToolsAccordionPage() {
  const [openSection, setOpenSection] = useState<SectionKey | null>(null);

  const toggleSection = (key: SectionKey) => {
    setOpenSection(prev => (prev === key ? null : key));
  };

  return (
    <div className="container mx-auto px-3 md:px-6 py-6 bg-gray-900 min-h-screen">
      <div className="mb-6">
        <h1 className="text-2xl md:text-3xl font-bold mb-2 text-white">⚡ AFL Fantasy Tools</h1>
        <p className="text-gray-400">
          🚀 Maximize your fantasy performance with our suite of advanced analytical tools
        </p>
      </div>

      <div className="w-full max-w-4xl mx-auto">
        {/* CASH GENERATION TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-green-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("cash")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <CircleDollarSign className="h-5 w-5 mr-3 text-green-400" />
              <h2 className="text-lg font-medium text-white">💰 Cash Generation Tools</h2>
            </div>
            <span className="text-green-400 text-lg">{openSection === "cash" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "cash" && (
            <div className="p-4 pt-0 border-t border-green-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="💵 Cash Generation Tracker" icon={<DollarSign />} colorClass="text-green-400">
                <CashGenerationTracker />
              </CollapsibleTool>
              
              <CollapsibleTool title="🐄 Cash Cow Tracker" icon={<TrendingUp />} colorClass="text-green-400">
                <CashCowTracker />
              </CollapsibleTool>
              
              <CollapsibleTool title="📈 Buy/Sell Timing Tool" icon={<TrendingUp />} colorClass="text-green-400">
                <BuySellTimingTool />
              </CollapsibleTool>
              
              <CollapsibleTool title="🎯 Cash Gen: Ceiling & Floor Visualizer" icon={<Layers />} colorClass="text-green-400">
                <CashCeilingFloorTracker />
              </CollapsibleTool>
            </div>
          )}
        </Card>

        {/* TAG & RISK TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-red-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("risk")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <Shield className="h-5 w-5 mr-3 text-red-400" />
              <h2 className="text-lg font-medium text-white">🔒 Tag & Risk Tools</h2>
            </div>
            <span className="text-red-400 text-lg">{openSection === "risk" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "risk" && (
            <div className="p-4 pt-0 border-t border-red-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="⚠️ Tag Watch Monitor" icon={<Tag />} colorClass="text-red-400">
                <TagWatchTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="📊 Tag History Impact Tracker" icon={<Activity />} colorClass="text-red-400">
                <VolatilityIndexTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="🎯 Tag Target Priority Ranker" icon={<CheckSquare />} colorClass="text-red-400">
                <ConsistencyScoreTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="🩹 Tag Breaker Score Estimator" icon={<Thermometer />} colorClass="text-red-400">
                <InjuryRiskTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="🚨 Injury Risk Model" icon={<Thermometer />} colorClass="text-red-400">
                <InjuryRiskTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="📈 Volatility Index Calculator" icon={<Activity />} colorClass="text-red-400">
                <VolatilityIndexTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="✅ Consistency Score Generator" icon={<CheckSquare />} colorClass="text-red-400">
                <ConsistencyScoreTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="📉 Scoring Range Predictor" icon={<LineChart />} colorClass="text-red-400">
                <ScoringRangeTable />
              </CollapsibleTool>
              
              <CollapsibleTool title="⏰ Late Out Risk Estimator" icon={<Timer />} colorClass="text-red-400">
                <LateOutRiskTable />
              </CollapsibleTool>
            </div>
          )}
        </Card>

        {/* AI STRATEGY & ASSISTANT TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-purple-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("ai")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <Sparkles className="h-5 w-5 mr-3 text-purple-400" />
              <h2 className="text-lg font-medium text-white">🤖 AI Strategy & Assistant Tools</h2>
            </div>
            <span className="text-purple-400 text-lg">{openSection === "ai" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "ai" && (
            <div className="p-4 pt-0 border-t border-purple-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="🔄 AI Trade Suggester" icon={<Shuffle />} colorClass="text-purple-400">
                <AITradeSuggester />
              </CollapsibleTool>
              
              <CollapsibleTool title="👑 AI Captain Advisor" icon={<Crown />} colorClass="text-purple-400">
                <AICaptainAdvisor />
              </CollapsibleTool>
              
              <CollapsibleTool title="🏗️ Team Structure Analyzer" icon={<Layout />} colorClass="text-purple-400">
                <TeamStructureAnalyzer />
              </CollapsibleTool>
              
              <CollapsibleTool title="👥 Ownership Risk Monitor" icon={<Users />} colorClass="text-purple-400">
                <AIInsights />
              </CollapsibleTool>
              
              <CollapsibleTool title="📊 Form vs Price Scanner" icon={<LineChart />} colorClass="text-purple-400">
                <AIInsights />
              </CollapsibleTool>
            </div>
          )}
        </Card>

        {/* CAPTAINCY TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-yellow-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("captain")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <Crown className="h-5 w-5 mr-3 text-yellow-400" />
              <h2 className="text-lg font-medium text-white">👑 Captaincy Tools</h2>
            </div>
            <span className="text-yellow-400 text-lg">{openSection === "captain" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "captain" && (
            <div className="p-4 pt-0 border-t border-yellow-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="🎯 Captain Optimizer" icon={<Calculator />} colorClass="text-yellow-400">
                <CaptainScorePredictor />
              </CollapsibleTool>
              
              <CollapsibleTool title="🔄 Auto Captain Loop" icon={<Shuffle />} colorClass="text-yellow-400">
                <ViceCaptainOptimizer />
              </CollapsibleTool>
              
              <CollapsibleTool title="✅ Loop Validity Checker" icon={<CheckSquare />} colorClass="text-yellow-400">
                <FormBasedCaptainAnalyzer />
              </CollapsibleTool>
              
              <CollapsibleTool title="📊 VC Success Rate Calculator" icon={<BarChartHorizontal />} colorClass="text-yellow-400">
                <FormBasedCaptainAnalyzer />
              </CollapsibleTool>
              
              <CollapsibleTool title="📈 Captain Ceiling Estimator" icon={<TrendingUp />} colorClass="text-yellow-400">
                <FormBasedCaptainAnalyzer />
              </CollapsibleTool>
              
              <CollapsibleTool title="🛡️ Loop Strategy Risk Score" icon={<Shield />} colorClass="text-yellow-400">
                <FormBasedCaptainAnalyzer />
              </CollapsibleTool>
            </div>
          )}
        </Card>

        {/* PRICE PREDICTOR TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-blue-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("price")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <BadgeDollarSign className="h-5 w-5 mr-3 text-blue-400" />
              <h2 className="text-lg font-medium text-white">📊 Price Predictor Tools</h2>
            </div>
            <span className="text-blue-400 text-lg">{openSection === "price" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "price" && (
            <div className="p-4 pt-0 border-t border-blue-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="🧮 Price Predictor Calculator" icon={<Calculator />} colorClass="text-blue-400">
                <PricePredictorCalculator />
              </CollapsibleTool>
              
              <CollapsibleTool title="📈 Price Ceiling/Floor Estimator" icon={<Layers />} colorClass="text-blue-400">
                <PriceProjectionCalculator />
              </CollapsibleTool>
            </div>
          )}
        </Card>

        {/* FIXTURE & MATCHUP TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-indigo-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("fixture")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <CalendarDays className="h-5 w-5 mr-3 text-indigo-400" />
              <h2 className="text-lg font-medium text-white">📅 Fixture & Matchup Tools</h2>
            </div>
            <span className="text-indigo-400 text-lg">{openSection === "fixture" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "fixture" && (
            <div className="p-4 pt-0 border-t border-indigo-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="🎯 Matchup Score Forecaster" icon={<Calculator />} colorClass="text-indigo-400">
                <FixtureDifficultyScanner />
              </CollapsibleTool>
              
              <CollapsibleTool title="📈 Fixture Swing Radar" icon={<TrendingUp />} colorClass="text-indigo-400">
                <FixtureSwingRadar />
              </CollapsibleTool>
              
              <CollapsibleTool title="🚨 Bye Round Threat Tracker" icon={<Calendar />} colorClass="text-indigo-400">
                <FixtureDifficultyScanner />
              </CollapsibleTool>
              
              <CollapsibleTool title="📊 Opponent Form Model" icon={<BarChartHorizontal />} colorClass="text-indigo-400">
                <MatchupDVPAnalyzer />
              </CollapsibleTool>
            </div>
          )}
        </Card>

        {/* ROLE & POSITIONAL TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-pink-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("role")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <ArrowRightCircle className="h-5 w-5 mr-3 text-pink-400" />
              <h2 className="text-lg font-medium text-white">⚡ Role & Positional Tools</h2>
            </div>
            <span className="text-pink-400 text-lg">{openSection === "role" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "role" && (
            <div className="p-4 pt-0 border-t border-pink-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="🔄 Role Change Detector" icon={<GitCommit />} colorClass="text-pink-400">
                <RoleChangeDetector />
              </CollapsibleTool>
              
              <CollapsibleTool title="📈 CBA Trend Analyzer" icon={<TrendingUp />} colorClass="text-pink-400">
                <CBATrendAnalyzer />
              </CollapsibleTool>
              
              <CollapsibleTool title="🏆 Positional Impact Scoring" icon={<Medal />} colorClass="text-pink-400">
                <PositionalImpactScoring />
              </CollapsibleTool>
              
              <CollapsibleTool title="💼 Possession Type Profiler" icon={<Briefcase />} colorClass="text-pink-400">
                <PossessionTypeProfiler />
              </CollapsibleTool>
            </div>
          )}
        </Card>

        {/* TRADE TOOLS */}
        <Card className="mb-5 border-2 bg-gray-800 border-cyan-500 shadow-lg hover:shadow-xl transition-shadow">
          <div 
            onClick={() => toggleSection("trade")}
            className="p-4 cursor-pointer flex items-center justify-between"
          >
            <div className="flex items-center">
              <ArrowUpDown className="h-5 w-5 mr-3 text-cyan-400" />
              <h2 className="text-lg font-medium text-white">🔄 Trade Tools</h2>
            </div>
            <span className="text-cyan-400 text-lg">{openSection === "trade" ? "▲" : "▼"}</span>
          </div>
          
          {openSection === "trade" && (
            <div className="p-4 pt-0 border-t border-cyan-500/30 space-y-4 bg-gray-900">
              <CollapsibleTool title="🧮 Trade Score Calculator" icon={<Calculator />} colorClass="text-cyan-400">
                <TradeScoreCalculator />
              </CollapsibleTool>
              
              <CollapsibleTool title="⬆️⬇️ One Up One Down" icon={<ArrowUpDown />} colorClass="text-cyan-400">
                <OneUpOneDownSuggester />
              </CollapsibleTool>
              
              <CollapsibleTool title="📊 Price Difference Delta" icon={<BarChartHorizontal />} colorClass="text-cyan-400">
                <PriceDifferenceDelta />
              </CollapsibleTool>
              
              <CollapsibleTool title="📈 Trade Analyzer" icon={<LineChart />} colorClass="text-cyan-400">
                <TradeScoreCalculator />
              </CollapsibleTool>
              
              <CollapsibleTool title="💰 Value Gain Tracker" icon={<TrendingUp />} colorClass="text-cyan-400">
                <PriceDifferenceDelta />
              </CollapsibleTool>
              
              <CollapsibleTool title="🔥 Trade Burn Risk Analyzer" icon={<Thermometer />} colorClass="text-cyan-400">
                <TradeScoreCalculator />
              </CollapsibleTool>
              
              <CollapsibleTool title="📊 Trade Return Analyzer" icon={<Activity />} colorClass="text-cyan-400">
                <TradeScoreCalculator />
              </CollapsibleTool>
              
              <CollapsibleTool title="🔄 Trade Optimizer" icon={<Shuffle />} colorClass="text-cyan-400">
                <TradeScoreCalculator />
              </CollapsibleTool>
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}