/**
 * Cash Tools Module
 * 
 * This module exports all the functions from the cash tools service
 */

import axios from 'axios';
const CASH_API_BASE_URL = 'http://localhost:5001/api/cash';

// Helper function to handle API requests
async function fetchFromCashAPI(endpoint: string, params?: any) {
  try {
    if (params) {
      const response = await axios.post(`${CASH_API_BASE_URL}/${endpoint}`, params);
      return response.data;
    } else {
      const response = await axios.get(`${CASH_API_BASE_URL}/${endpoint}`);
      return response.data;
    }
  } catch (error: any) {
    console.error(`Error calling cash API (${endpoint}):`, error.message);
    throw new Error(`Failed to fetch data from cash API: ${error.message}`);
  }
}

// Export cash tools services
export const cashToolsService = {
  // Get cash generation tracker data
  async getCashGenerationTrackerData() {
    return await fetchFromCashAPI('generation_tracker');
  },

  // Get rookie price curve data
  async getRookiePriceCurveData() {
    return await fetchFromCashAPI('rookie_price_curve');
  },

  // Get downgrade targets data
  async getDowngradeTargets() {
    return await fetchFromCashAPI('downgrade_targets');
  },

  // Get cash generation ceiling/floor data
  async getCashGenCeilingFloor() {
    return await fetchFromCashAPI('ceiling_floor');
  },

  // Calculate price predictions for a player
  async calculatePricePredictions(playerName: string, scores: number[]) {
    return await fetchFromCashAPI('price_predictor', { player_name: playerName, scores });
  },

  // Get price ceiling/floor estimates
  async getPriceCeilingFloor() {
    return await fetchFromCashAPI('price_ceiling_floor');
  }
};