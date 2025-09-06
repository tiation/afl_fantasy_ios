/**
 * Fetches captain score predictions for top L3 scorers
 * @returns Promise with captain score predictions
 */
export const fetchCaptainScorePredictor = async () => {
  try {
    const response = await fetch('/api/captains/score-predictor');
    return response.json();
  } catch (error) {
    console.error('Error fetching captain score predictor data:', error);
    throw error;
  }
};

/**
 * Fetches vice-captain/captain optimizer recommendations
 * @returns Promise with vice-captain optimizer data
 */
export const fetchViceCaptainOptimizer = async () => {
  try {
    const response = await fetch('/api/captains/vice-captain-optimizer');
    return response.json();
  } catch (error) {
    console.error('Error fetching vice-captain optimizer data:', error);
    throw error;
  }
};

/**
 * Fetches loophole detection opportunities
 * @returns Promise with loophole detector data
 */
export const fetchLoopholeDetector = async () => {
  try {
    const response = await fetch('/api/captains/loophole-detector');
    return response.json();
  } catch (error) {
    console.error('Error fetching loophole detector data:', error);
    throw error;
  }
};

/**
 * Fetches form-based captain analysis data
 * @returns Promise with form-based captain analyzer data
 */
export const fetchFormBasedCaptainAnalyzer = async () => {
  try {
    const response = await fetch('/api/captains/form-based-analyzer');
    return response.json();
  } catch (error) {
    console.error('Error fetching form-based captain analyzer data:', error);
    throw error;
  }
};

/**
 * Fetches matchup-based captain recommendations
 * @returns Promise with matchup-based captain advisor data
 */
export const fetchMatchupBasedCaptainAdvisor = async () => {
  try {
    const response = await fetch('/api/captains/matchup-based-advisor');
    return response.json();
  } catch (error) {
    console.error('Error fetching matchup-based captain advisor data:', error);
    throw error;
  }
};