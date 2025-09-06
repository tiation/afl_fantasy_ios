/**
 * Service module for AFL Fantasy fixture analysis tools
 */

/**
 * Fetches fixture difficulty ratings for teams
 * @returns Promise with fixture difficulty data
 */
export const fetchFixtureDifficulty = async () => {
  try {
    const response = await fetch('/api/fixture/fixture-difficulty');
    return response.json();
  } catch (error) {
    console.error('Error fetching fixture difficulty:', error);
    throw error;
  }
};

/**
 * Fetches matchup DVP (Defense vs Position) data
 * @returns Promise with matchup DVP data
 */
export const fetchMatchupDVP = async () => {
  try {
    const response = await fetch('/api/fixture/matchup-dvp');
    return response.json();
  } catch (error) {
    console.error('Error fetching matchup DVP:', error);
    throw error;
  }
};

/**
 * Fetches fixture swing radar data
 * @returns Promise with fixture swing data
 */
export const fetchFixtureSwing = async () => {
  try {
    const response = await fetch('/api/fixture/fixture-swing');
    return response.json();
  } catch (error) {
    console.error('Error fetching fixture swing:', error);
    throw error;
  }
};

/**
 * Fetches travel impact data for teams
 * @returns Promise with travel impact data
 */
export const fetchTravelImpact = async () => {
  try {
    const response = await fetch('/api/fixture/travel-impact');
    return response.json();
  } catch (error) {
    console.error('Error fetching travel impact:', error);
    throw error;
  }
};

/**
 * Fetches weather forecast risk data
 * @returns Promise with weather risk data
 */
export const fetchWeatherRisk = async () => {
  try {
    const response = await fetch('/api/fixture/weather-risk');
    return response.json();
  } catch (error) {
    console.error('Error fetching weather risk:', error);
    throw error;
  }
};