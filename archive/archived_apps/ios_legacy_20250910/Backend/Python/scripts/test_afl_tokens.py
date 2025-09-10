#!/usr/bin/env python3
"""
Test AFL Fantasy Tokens
Replace the token values below with what you found in the browser.
"""

import requests
import json

# Replace these with your actual tokens
AFL_TOKENS = {
    "Authorization": "Bearer YOUR_TOKEN_HERE",
    "Cookie": "YOUR_COOKIE_HERE", 
    "X-Auth-Token": "YOUR_X_AUTH_TOKEN_HERE"
}

def test_token(endpoint, headers):
    """Test if a token works with an AFL Fantasy endpoint"""
    try:
        url = f"https://fantasy.afl.com.au{endpoint}"
        response = requests.get(url, headers=headers)
        
        print(f"Testing {endpoint}")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            try:
                data = response.json()
                print("✅ Success! Got JSON response")
                if 'team' in str(data).lower():
                    print("🎯 Contains team data!")
                return data
            except:
                print("⚠️  Got response but not JSON")
        else:
            print(f"❌ Failed: {response.status_code}")
            
    except Exception as e:
        print(f"Error: {e}")
    
    return None

# Test different combinations
endpoints_to_test = [
    "/api/user/profile",
    "/api/teams/my-team",
    "/api/classic/my-team", 
    "/api/user/teams"
]

print("🧪 Testing tokens...")
for endpoint in endpoints_to_test:
    # Test with Authorization header
    headers = {"Authorization": AFL_TOKENS["Authorization"]}
    test_token(endpoint, headers)
    
    # Test with Cookie
    headers = {"Cookie": AFL_TOKENS["Cookie"]} 
    test_token(endpoint, headers)
    
    # Test with custom header
    headers = {"X-Auth-Token": AFL_TOKENS["X-Auth-Token"]}
    test_token(endpoint, headers)
    
    print("-" * 50)
