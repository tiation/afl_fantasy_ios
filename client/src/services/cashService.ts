import { apiRequest } from "@/lib/queryClient";

export async function fetchPlayerData() {
  const response = await apiRequest("GET", "/api/fantasy/player_data");
  const data = await response.json();
  return data;
}

export async function fetchCashGenerationTracker() {
  const response = await apiRequest("GET", "/api/fantasy/tools/cash_generation_tracker");
  const data = await response.json();
  return data;
}

export async function fetchRookiePriceCurve() {
  const response = await apiRequest("GET", "/api/fantasy/tools/rookie_price_curve_model");
  const data = await response.json();
  return data;
}

export async function fetchDowngradeTargets() {
  const response = await apiRequest("GET", "/api/fantasy/tools/downgrade_target_finder");
  const data = await response.json();
  return data;
}

export async function fetchCashGenCeilingFloor() {
  const response = await apiRequest("GET", "/api/fantasy/tools/cash_gen_ceiling_floor");
  const data = await response.json();
  return data;
}

export async function calculatePricePredictor(playerName: string, scores: number[]) {
  const response = await apiRequest("POST", "/api/fantasy/tools/price_predictor_calculator", {
    player_name: playerName,
    scores: scores
  });
  const data = await response.json();
  return data;
}

export async function fetchPriceCeilingFloor() {
  const response = await apiRequest("GET", "/api/fantasy/tools/price_ceiling_floor_estimator");
  const data = await response.json();
  return data;
}