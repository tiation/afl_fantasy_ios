#!/usr/bin/env python3
"""
AFL Fantasy Token Finder

This script helps identify the authentication tokens needed to access
AFL Fantasy API endpoints by analyzing network traffic patterns.
"""

import requests
import json
import re
from urllib.parse import urlparse, parse_qs

class AFLTokenFinder:
    def __init__(self):
        self.session = requests.Session()
        self.base_url = "https://fantasy.afl.com.au"
        self.api_patterns = []
        
    def analyze_afl_endpoints(self):
        """Analyze AFL Fantasy to identify API endpoint patterns"""
        
        print("🔍 Analyzing AFL Fantasy API patterns...")
        
        # Common AFL Fantasy API endpoints to check
        potential_endpoints = [
            "/api/user/profile",
            "/api/teams/my-team", 
            "/api/classic/my-team",
            "/api/user/teams",
            "/api/teams",
            "/api/v1/teams",
            "/api/v2/teams",
            "/graphql",
            "/api/auth/me",
            "/api/player/data",
            "/api/teams/lineup"
        ]
        
        print("📋 Common AFL Fantasy API endpoints to look for:")
        for endpoint in potential_endpoints:
            full_url = f"{self.base_url}{endpoint}"
            print(f"  • {full_url}")
            
        print("\n🔧 Steps to find your tokens:")
        print("1. Open AFL Fantasy website and login")
        print("2. Open Browser Developer Tools (F12)")
        print("3. Go to Network tab")
        print("4. Navigate to your team page")
        print("5. Look for requests to endpoints above")
        print("6. Check these header fields in successful requests:")
        
        auth_headers = [
            "Authorization",
            "Bearer",
            "X-Auth-Token", 
            "X-API-Key",
            "Cookie",
            "X-Session-Token",
            "X-User-Token",
            "Authentication"
        ]
        
        for header in auth_headers:
            print(f"   → {header}")
            
        return potential_endpoints, auth_headers
    
    def test_endpoint_access(self, endpoint, headers=None):
        """Test if an endpoint is accessible with given headers"""
        try:
            url = f"{self.base_url}{endpoint}"
            response = self.session.get(url, headers=headers or {})
            
            print(f"Testing {endpoint}: Status {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if 'team' in str(data).lower() or 'player' in str(data).lower():
                        print(f"✅ Found team/player data in {endpoint}")
                        return True, data
                except:
                    pass
                    
            return False, None
            
        except Exception as e:
            print(f"❌ Error testing {endpoint}: {e}")
            return False, None
    
    def generate_token_extraction_guide(self):
        """Generate a detailed guide for token extraction"""
        
        guide = """
🎯 AFL FANTASY TOKEN EXTRACTION GUIDE

STEP 1: Open AFL Fantasy
→ Go to https://fantasy.afl.com.au
→ Login with your credentials

STEP 2: Open Developer Tools
→ Press F12 (or right-click → Inspect)
→ Click on "Network" tab
→ Check "Preserve log" option

STEP 3: Navigate to Team Page
→ Go to your team/lineup page
→ Watch for new network requests

STEP 4: Find API Calls
Look for requests to these patterns:
→ fantasy.afl.com.au/api/*
→ Requests returning JSON data
→ Requests with your team information

STEP 5: Extract Headers
For successful API requests, copy these headers:
→ Authorization: Bearer [token]
→ Cookie: [session_data]
→ X-Auth-Token: [token]
→ Any other authentication headers

STEP 6: Common Token Locations
→ Authorization header (most common)
→ Cookie values (session tokens)
→ Custom X-* headers
→ Query parameters (?token=...)

STEP 7: Test the Token
→ Look for responses containing your actual team data
→ Player names, prices, scores should match your team
"""
        
        print(guide)
        
        with open("token_extraction_guide.txt", "w") as f:
            f.write(guide)
        print("💾 Saved detailed guide to token_extraction_guide.txt")
    
    def create_token_test_script(self):
        """Create a script template for testing extracted tokens"""
        
        test_script = '''#!/usr/bin/env python3
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
'''
        
        with open("test_afl_tokens.py", "w") as f:
            f.write(test_script)
        print("🧪 Created test_afl_tokens.py - edit this file with your tokens")

def main():
    finder = AFLTokenFinder()
    
    print("🏈 AFL Fantasy Token Finder")
    print("=" * 50)
    
    # Analyze endpoints
    endpoints, headers = finder.analyze_afl_endpoints()
    
    print("\n" + "=" * 50)
    
    # Generate extraction guide
    finder.generate_token_extraction_guide()
    
    print("\n" + "=" * 50)
    
    # Create test script
    finder.create_token_test_script()
    
    print("\n✅ Ready! Follow the guide to extract your tokens.")

if __name__ == "__main__":
    main()