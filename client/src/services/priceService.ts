/**
 * Service module for AFL Fantasy price analysis tools
 */

/**
 * Fetches price projections for players based on breakeven
 * @returns Promise with price projection data
 */
export const fetchPriceProjections = async () => {
  try {
    const response = await fetch('/api/price-tools/projection');
    return response.json();
  } catch (error) {
    console.error('Error fetching price projections:', error);
    throw error;
  }
};

/**
 * Fetches breakeven trends for premium players
 * @returns Promise with breakeven trend data
 */
export const fetchBreakevenTrends = async () => {
  try {
    const response = await fetch('/api/price-tools/be-trend');
    return response.json();
  } catch (error) {
    console.error('Error fetching breakeven trends:', error);
    throw error;
  }
};

/**
 * Fetches price drop recovery predictions for premium players
 * @returns Promise with price recovery data
 */
export const fetchPriceRecoveryPredictions = async () => {
  try {
    const response = await fetch('/api/price-tools/recovery');
    return response.json();
  } catch (error) {
    console.error('Error fetching price recovery predictions:', error);
    throw error;
  }
};

/**
 * Fetches price vs score scatter plot data
 * @returns Promise with scatter plot coordinate data
 */
export const fetchPriceScoreScatter = async () => {
  try {
    const response = await fetch('/api/price-tools/scatter');
    return response.json();
  } catch (error) {
    console.error('Error fetching price score scatter data:', error);
    throw error;
  }
};

/**
 * Fetches value rankings by position
 * @returns Promise with value-ranked player data
 */
export const fetchValueRankings = async () => {
  try {
    const response = await fetch('/api/price-tools/value-rank');
    return response.json();
  } catch (error) {
    console.error('Error fetching value rankings:', error);
    throw error;
  }
};