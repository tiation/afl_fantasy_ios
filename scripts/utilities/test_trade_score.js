import axios from 'axios';

async function testTradeScoreEndpoint() {
  try {
    const url = 'http://localhost:5000/api/trade_score';
    
    const payload = {
      player_in: {
        price: 850000,
        breakeven: 90,
        proj_scores: [95.5, 88.2, 105.1, 92.3, 98.7],
        is_red_dot: false
      },
      player_out: {
        price: 720000,
        breakeven: 75,
        proj_scores: [70.2, 82.5, 78.4, 85.1, 76.3],
        is_red_dot: true
      },
      round_number: 8,
      team_value: 15200000,
      league_avg_value: 14800000
    };
    
    console.log('Sending request to trade_score endpoint via Express proxy...');
    const response = await axios.post(url, payload);
    
    console.log('Response Status:', response.status);
    console.log('Response Body:', JSON.stringify(response.data, null, 2));
    
    if (response.status === 200 && response.data.status === 'ok') {
      console.log('Test PASSED: API returned success response');
      console.log(`Trade Score: ${response.data.trade_score}/100`);
      console.log('Recommendation:', response.data.recommendation);
      console.log('Explanations:');
      response.data.explanations?.forEach((explanation, index) => {
        console.log(`  ${index + 1}. ${explanation}`);
      });
    } else {
      console.log('Test FAILED: Unexpected response');
    }
  } catch (error) {
    console.error('ERROR:', error.message);
    if (error.response) {
      console.error('Response Status:', error.response.status);
      console.error('Response Body:', error.response.data);
    }
  }
}

// Run the test
testTradeScoreEndpoint();