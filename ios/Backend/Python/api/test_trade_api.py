import requests
import json

def test_trade_score_api():
    """Test the trade_score API endpoint"""
    
    # API endpoint URL
    url = "http://localhost:5001/api/trade_score"
    
    # Example payload
    payload = {
        "player_in": {
            "price": 850000,
            "breakeven": 90,
            "proj_scores": [95.5, 88.2, 105.1, 92.3, 98.7],
            "is_red_dot": False
        },
        "player_out": {
            "price": 720000,
            "breakeven": 75,
            "proj_scores": [70.2, 82.5, 78.4, 85.1, 76.3],
            "is_red_dot": True
        },
        "round_number": 8,
        "team_value": 15200000,
        "league_avg_value": 14800000
    }
    
    # Make the POST request
    try:
        response = requests.post(url, json=payload)
        
        # Print the response details
        print(f"Status Code: {response.status_code}")
        print(f"Response Body: {response.text}")
        
        # Check if the request was successful
        if response.status_code == 200:
            print("Test SUCCESS: API returned a 200 OK response")
        else:
            print(f"Test FAILED: API returned a {response.status_code} response")
    
    except requests.exceptions.ConnectionError:
        print("ERROR: Could not connect to the API server. Make sure it's running at http://localhost:5001")
    except Exception as e:
        print(f"ERROR: An unexpected error occurred: {str(e)}")

if __name__ == "__main__":
    test_trade_score_api()