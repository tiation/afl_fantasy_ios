import { apiRequest } from "@/lib/queryClient";

/**
 * Fetch AI Trade Suggester data
 */
export async function fetchAITrade() {
  const response = await apiRequest("GET", "/api/fantasy/tools/ai/ai_trade_suggester");
  const data = await response.json();
  if (data.status === "ok") {
    return {
      downgrade_out: data.downgrade_out,
      upgrade_in: data.upgrade_in
    };
  }
  throw new Error("Failed to fetch AI trade suggestion");
}

/**
 * Fetch AI Captain Advisor data
 */
export async function fetchAICaptain() {
  const response = await apiRequest("GET", "/api/fantasy/tools/ai/ai_captain_advisor");
  const data = await response.json();
  if (data.status === "ok" && Array.isArray(data.players)) {
    return data.players;
  }
  throw new Error("Failed to fetch AI captain recommendations");
}

/**
 * Fetch Team Structure Analyzer data
 */
export async function fetchTeamStructure() {
  const response = await apiRequest("GET", "/api/fantasy/tools/ai/team_structure_analyzer");
  const data = await response.json();
  if (data.status === "ok" && data.tiers) {
    return data.tiers;
  }
  throw new Error("Failed to fetch team structure data");
}

/**
 * Fetch Ownership Risk Monitor data
 */
export async function fetchOwnershipRisk() {
  const response = await apiRequest("GET", "/api/fantasy/tools/ai/ownership_risk_monitor");
  const data = await response.json();
  if (data.status === "ok" && Array.isArray(data.players)) {
    return data.players;
  }
  throw new Error("Failed to fetch ownership risk data");
}

/**
 * Fetch Form vs Price Scanner data
 */
export async function fetchFormVsPrice() {
  const response = await apiRequest("GET", "/api/fantasy/tools/ai/form_vs_price_scanner");
  const data = await response.json();
  if (data.status === "ok" && Array.isArray(data.players)) {
    return data.players;
  }
  throw new Error("Failed to fetch form vs price data");
}