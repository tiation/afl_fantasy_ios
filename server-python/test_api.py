#!/usr/bin/env python3
"""
Test script for AFL Fantasy Trade API
"""
import requests
import json

def test_trade_api():
    url = "http://127.0.0.1:5001/api/trade_score"
    
    test_data = {
        "player_in": {
            "price": 1100000,
            "breakeven": 114,
            "proj_scores": [125, 122, 118, 130, 120],
            "is_red_dot": False
        },
        "player_out": {
            "price": 930000,
            "breakeven": 120,
            "proj_scores": [105, 110, 102, 108, 104],
            "is_red_dot": False
        },
        "round_number": 13,
        "team_value": 15800000,
        "league_avg_value": 15200000
    }
    
    try:
        print("Testing AFL Fantasy Trade API...")
        print(f"Sending request to {url}")
        
        response = requests.post(url, json=test_data, timeout=10)
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ API Test Successful!")
            print("Trade Score Result:")
            print(json.dumps(result, indent=2))
            return True
        else:
            print(f"❌ API Test Failed: {response.status_code}")
            print(f"Error: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print("❌ Connection Error: Flask server may not be running on port 5001")
        return False
    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        return False

if __name__ == "__main__":
    test_trade_api()
