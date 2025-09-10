import { apiRequest } from '@/lib/queryClient';

/**
 * Fetch data from the Tag Watch Monitor tool
 */
export async function fetchTagWatchMonitor() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/tag_watch_monitor');
  return await response.json();
}

/**
 * Fetch data from the Tag History Impact Tracker tool
 */
export async function fetchTagHistoryImpact() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/tag_history_impact_tracker');
  return await response.json();
}

/**
 * Fetch data from the Tag Target Priority Ranker tool
 */
export async function fetchTagTargetPriority() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/tag_target_priority_ranker');
  return await response.json();
}

/**
 * Fetch data from the Tag Breaker Score Estimator tool
 */
export async function fetchTagBreakerScore() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/tag_breaker_score_estimator');
  return await response.json();
}

/**
 * Fetch data from the Injury Risk Model tool
 */
export async function fetchInjuryRisk() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/injury_risk_model');
  return await response.json();
}

/**
 * Fetch data from the Volatility Index Calculator tool
 */
export async function fetchVolatilityIndex() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/volatility_index_calculator');
  return await response.json();
}

/**
 * Fetch data from the Consistency Score Generator tool
 */
export async function fetchConsistencyScore() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/consistency_score_generator');
  return await response.json();
}

/**
 * Fetch data from the Scoring Range Predictor tool
 */
export async function fetchScoringRange() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/scoring_range_predictor');
  return await response.json();
}

/**
 * Fetch data from the Late Out Risk Estimator tool
 */
export async function fetchLateOutRisk() {
  const response = await apiRequest('GET', '/api/fantasy/tools/risk/late_out_risk_estimator');
  return await response.json();
}