/**
 * Cash Tools Service
 * 
 * This service provides methods to communicate with the Python Cash Tools API
 */

import axios from 'axios';

// Define the base URL for the Python API
const CASH_API_BASE_URL = 'http://localhost:5001/api/cash';

// Types for cash generation tracker response
export type CashGenerationPlayer = {
  player: string;
  team: string;
  price: number;
  breakeven: number;
  '3_game_avg': number;
  price_change_est: number;
};

export type CashGenerationResponse = {
  status: string;
  data: CashGenerationPlayer[];
};

// Types for rookie price curve model response
export type RookiePriceProjection = {
  player: string;
  price: number;
  l3_avg: number;
  price_projection_next_3: number;
};

export type RookiePriceCurveResponse = {
  status: string;
  data: RookiePriceProjection[];
};

// Types for downgrade target finder response
export type DowngradeTarget = {
  name: string;
  team: string;
  position: string;
  price: number;
  breakeven: number;
  avg: number;
  games: number;
  status: string;
  l3_avg: number;
};

export type DowngradeTargetResponse = {
  status: string;
  data: DowngradeTarget[];
};

// Types for cash gen ceiling/floor response
export type CashGenCeilingFloor = {
  player: string;
  team: string;
  price: number;
  floor_change: number;
  ceiling_change: number;
};

export type CashGenCeilingFloorResponse = {
  status: string;
  data: CashGenCeilingFloor[];
};

// Types for price predictor calculator
export type PriceChange = {
  round: number;
  score: number;
  price_change: number;
  new_price: number;
};

export type PricePredictorResponse = {
  status: string;
  data: {
    player: string;
    starting_price: number;
    starting_breakeven: number;
    price_changes: PriceChange[];
    final_price: number;
  };
};

// Types for price ceiling/floor estimator
export type PriceCeilingFloor = {
  player: string;
  team: string;
  position: string;
  current_price: number;
  ceiling_price: number;
  floor_price: number;
  ceiling_gain: number;
  floor_loss: number;
};

export type PriceCeilingFloorResponse = {
  status: string;
  data: PriceCeilingFloor[];
};

/**
 * Fetch data from the cash generation tracker
 */
export async function getCashGenerationTrackerData(): Promise<CashGenerationResponse> {
  try {
    const response = await axios.get(`${CASH_API_BASE_URL}/generation_tracker`);
    return response.data;
  } catch (error) {
    console.error('Error fetching cash generation tracker data:', error);
    return {
      status: 'error',
      data: []
    };
  }
}

/**
 * Fetch data from the rookie price curve model
 */
export async function getRookiePriceCurveData(): Promise<RookiePriceCurveResponse> {
  try {
    const response = await axios.get(`${CASH_API_BASE_URL}/rookie_price_curve`);
    return response.data;
  } catch (error) {
    console.error('Error fetching rookie price curve data:', error);
    return {
      status: 'error',
      data: []
    };
  }
}

/**
 * Fetch data from the downgrade target finder
 */
export async function getDowngradeTargets(): Promise<DowngradeTargetResponse> {
  try {
    const response = await axios.get(`${CASH_API_BASE_URL}/downgrade_targets`);
    return response.data;
  } catch (error) {
    console.error('Error fetching downgrade targets:', error);
    return {
      status: 'error',
      data: []
    };
  }
}

/**
 * Fetch data from the cash gen ceiling/floor
 */
export async function getCashGenCeilingFloor(): Promise<CashGenCeilingFloorResponse> {
  try {
    const response = await axios.get(`${CASH_API_BASE_URL}/ceiling_floor`);
    return response.data;
  } catch (error) {
    console.error('Error fetching cash gen ceiling/floor data:', error);
    return {
      status: 'error',
      data: []
    };
  }
}

/**
 * Calculate price predictions for a player with given scores
 */
export async function calculatePricePredictions(
  playerName: string,
  scores: number[]
): Promise<PricePredictorResponse> {
  try {
    const response = await axios.post(`${CASH_API_BASE_URL}/price_predictor`, {
      player_name: playerName,
      scores: scores
    });
    return response.data;
  } catch (error) {
    console.error('Error calculating price predictions:', error);
    return {
      status: 'error',
      data: {
        player: playerName,
        starting_price: 0,
        starting_breakeven: 0,
        price_changes: [],
        final_price: 0
      }
    };
  }
}

/**
 * Fetch data from the price ceiling/floor estimator
 */
export async function getPriceCeilingFloor(): Promise<PriceCeilingFloorResponse> {
  try {
    const response = await axios.get(`${CASH_API_BASE_URL}/price_ceiling_floor`);
    return response.data;
  } catch (error) {
    console.error('Error fetching price ceiling/floor data:', error);
    return {
      status: 'error',
      data: []
    };
  }
}