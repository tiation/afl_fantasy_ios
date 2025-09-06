import { findOneUpOneDownCombinations } from './trade/one-up-one-down-suggester';
import { calculateTradeScore } from './trade/trade-score-calculator';
import { calculatePriceDifferenceDelta } from './trade/price-difference-delta';
import { directCashToolsService, setupCashTools } from './cash-direct';
import * as riskDirectTools from './risk-direct';
import * as aiDirectTools from './ai-direct';
import { fantasyTools } from '../types/fantasy-tools';

// Set up direct cash tools integration
setupCashTools().catch(err => {
  console.error('Failed to set up direct cash tools integration:', err);
});

// Tool categories and descriptions
export const toolCategories = [
  {
    id: "trade",
    name: "Trade Analysis",
    description: "Tools to analyze trades, optimize moves, and maximize team value",
    tools: [
      {
        id: "trade_score_calculator",
        name: "Trade Score Calculator",
        description: "Calculate the effectiveness score of a proposed trade"
      },
      {
        id: "one_up_one_down_suggester",
        name: "One Up One Down Suggester",
        description: "Find optimal trade combinations to upgrade one player and downgrade another"
      },
      {
        id: "price_difference_delta",
        name: "Price Difference Delta",
        description: "Compare projected price changes between players"
      }
    ]
  },
  {
    id: "cash",
    name: "Cash Generation",
    description: "Tools to analyze cash cows, track value generation, and optimize your bank",
    tools: [
      {
        id: "cash_generation_tracker",
        name: "Cash Generation Tracker",
        description: "Track projected cash generation for players over time"
      },
      {
        id: "rookie_price_curve_model",
        name: "Rookie Price Curve Model",
        description: "Model the price trajectory of rookies"
      },
      {
        id: "downgrade_target_finder",
        name: "Downgrade Target Finder",
        description: "Find optimal downgrade targets with low breakevens"
      },
      {
        id: "cash_gen_ceiling_floor",
        name: "Cash Gen Ceiling/Floor",
        description: "Calculate potential ceiling and floor price changes"
      }
    ]
  },
  {
    id: "price",
    name: "Price Predictor",
    description: "Tools to predict price changes, estimate ceilings/floors, and optimize trades",
    tools: [
      {
        id: "price_predictor_calculator",
        name: "Price Predictor Calculator",
        description: "Calculate projected price based on expected score vs breakeven"
      },
      {
        id: "price_ceiling_floor_estimator",
        name: "Price Ceiling/Floor Estimator", 
        description: "Estimate the ceiling and floor price for a player"
      }
    ]
  },
  {
    id: "risk",
    name: "Risk Analysis",
    description: "Tools to analyze player risks, tags, volatility, and consistency",
    tools: [
      {
        id: "tag_watch_monitor",
        name: "Tag Watch Monitor",
        description: "Monitor players likely to be tagged by opponents"
      },
      {
        id: "tag_history_impact_tracker",
        name: "Tag History Impact Tracker",
        description: "Track historical scoring impact of tags on players"
      },
      {
        id: "tag_target_priority_ranker",
        name: "Tag Target Priority Ranker",
        description: "Rank players by their likelihood of being tagged"
      },
      {
        id: "tag_breaker_score_estimator",
        name: "Tag Breaker Score Estimator",
        description: "Estimate how well players perform when tagged"
      },
      {
        id: "injury_risk_model",
        name: "Injury Risk Model",
        description: "Model injury risk for players based on past injury history"
      },
      {
        id: "volatility_index_calculator",
        name: "Volatility Index Calculator",
        description: "Calculate score volatility for players"
      },
      {
        id: "consistency_score_generator",
        name: "Consistency Score Generator",
        description: "Generate consistency scores for players"
      },
      {
        id: "scoring_range_predictor",
        name: "Scoring Range Predictor",
        description: "Predict scoring ranges for players"
      },
      {
        id: "late_out_risk_estimator",
        name: "Late Out Risk Estimator",
        description: "Estimate risk of players being late outs"
      }
    ]
  },
  {
    id: "ai",
    name: "AI Assistance",
    description: "AI-powered tools to help with fantasy team decisions and optimization",
    tools: [
      {
        id: "ai_trade_suggester",
        name: "AI Trade Suggester",
        description: "Suggests one up/one down combination for trades"
      },
      {
        id: "ai_captain_advisor",
        name: "AI Captain Advisor",
        description: "Recommends top 3 captains based on average and volatility"
      },
      {
        id: "team_structure_analyzer",
        name: "Team Structure Analyzer",
        description: "Provides a summary of team structure by price tiers"
      },
      {
        id: "ownership_risk_monitor",
        name: "Ownership Risk Monitor",
        description: "Flags common high-priced underperformers"
      },
      {
        id: "form_vs_price_scanner",
        name: "Form vs Price Scanner",
        description: "Identifies over- or under-valued players"
      }
    ]
  }
];

// Export all fantasy tools
export const fantasyToolsService = {
  // Trade Tools
  calculateTradeScore,
  findOneUpOneDownCombinations,
  calculatePriceDifferenceDelta,
  
  // Cash Tools
  getCashGenerationTrackerData: directCashToolsService.getCashGenerationTrackerData,
  getRookiePriceCurveData: directCashToolsService.getRookiePriceCurveData,
  getDowngradeTargets: directCashToolsService.getDowngradeTargets,
  getCashGenCeilingFloor: directCashToolsService.getCashGenCeilingFloor,
  calculatePricePredictions: directCashToolsService.calculatePricePredictions,
  getPriceCeilingFloor: directCashToolsService.getPriceCeilingFloor,
  
  // Risk Tools
  getTagWatchMonitorData: async () => ({ data: await riskDirectTools.tag_watch_monitor() }),
  getTagHistoryImpactTrackerData: async () => ({ data: await riskDirectTools.tag_history_impact_tracker() }),
  getTagTargetPriorityRankerData: async () => ({ data: await riskDirectTools.tag_target_priority_ranker() }),
  getTagBreakerScoreEstimatorData: async () => ({ data: await riskDirectTools.tag_breaker_score_estimator() }),
  getInjuryRiskModelData: async () => ({ data: await riskDirectTools.injury_risk_model() }),
  getVolatilityIndexCalculatorData: async () => ({ data: await riskDirectTools.volatility_index_calculator() }),
  getConsistencyScoreGeneratorData: async () => ({ data: await riskDirectTools.consistency_score_generator() }),
  getScoringRangePredictorData: async () => ({ data: await riskDirectTools.scoring_range_predictor() }),
  getLateOutRiskEstimatorData: async () => ({ data: await riskDirectTools.late_out_risk_estimator() }),
  
  // AI Tools
  getAITradeSuggesterData: async () => ({ data: await aiDirectTools.ai_trade_suggester() }),
  getAICaptainAdvisorData: async () => ({ data: await aiDirectTools.ai_captain_advisor() }),
  getTeamStructureAnalyzerData: async () => ({ data: await aiDirectTools.team_structure_analyzer() }),
  getOwnershipRiskMonitorData: async () => ({ data: await aiDirectTools.ownership_risk_monitor() }),
  getFormVsPriceScannerData: async () => ({ data: await aiDirectTools.form_vs_price_scanner() }),
  
  // Tool categories for API
  toolCategories
};