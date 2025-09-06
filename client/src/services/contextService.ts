/**
 * Service module for AFL Fantasy contextual analysis tools
 */

/**
 * Fetches bye round optimizer data
 * @returns Promise with bye round distribution data
 */
export const fetchByeOptimizer = async () => {
  try {
    const response = await fetch('/api/context/bye-optimizer');
    return response.json();
  } catch (error) {
    console.error('Error fetching bye round optimizer data:', error);
    throw error;
  }
};

/**
 * Fetches late season taper data
 * @returns Promise with late season player performance taper data
 */
export const fetchLateSeasonTaper = async () => {
  try {
    const response = await fetch('/api/context/late-season-taper');
    return response.json();
  } catch (error) {
    console.error('Error fetching late season taper data:', error);
    throw error;
  }
};

/**
 * Fetches fast start profile data
 * @returns Promise with player early-season performance data
 */
export const fetchFastStartProfiles = async () => {
  try {
    const response = await fetch('/api/context/fast-start-profiles');
    return response.json();
  } catch (error) {
    console.error('Error fetching fast start profiles:', error);
    throw error;
  }
};

/**
 * Fetches venue bias data
 * @returns Promise with player venue bias data
 */
export const fetchVenueBias = async () => {
  try {
    const response = await fetch('/api/context/venue-bias');
    return response.json();
  } catch (error) {
    console.error('Error fetching venue bias data:', error);
    throw error;
  }
};

/**
 * Fetches contract year motivation data
 * @returns Promise with player contract year motivation data
 */
export const fetchContractMotivation = async () => {
  try {
    const response = await fetch('/api/context/contract-motivation');
    return response.json();
  } catch (error) {
    console.error('Error fetching contract motivation data:', error);
    throw error;
  }
};