#!/usr/bin/env python3
"""
Test AFL Fantasy Classic Endpoints

Test various AFL Fantasy Classic API endpoints to find team data
"""

import requests
import json
import os

def test_afl_classic_endpoints():
    """Test AFL Fantasy Classic endpoints for team data"""
    
    username = os.getenv('AFL_FANTASY_USERNAME')
    password = os.getenv('AFL_FANTASY_PASSWORD')
    
    print(f"Testing AFL Fantasy Classic endpoints for user: {username}")
    
    # Create session with user credentials
    session = requests.Session()
    session.headers.update({
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Referer': 'https://fantasy.afl.com.au/',
        'Origin': 'https://fantasy.afl.com.au'
    })
    
    # Test endpoints that might contain team data
    endpoints_to_test = [
        "/api/classic/team",
        "/api/classic/my-team", 
        "/api/classic/teams",
        "/api/classic/user/team",
        "/api/v1/classic/team",
        "/api/v2/classic/team",
        "/classic/api/team",
        "/classic/api/my-team",
        "/api/teams/classic",
        "/api/user/classic/team"
    ]
    
    base_url = "https://fantasy.afl.com.au"
    
    print("\nTesting endpoints...")
    
    for endpoint in endpoints_to_test:
        try:
            url = f"{base_url}{endpoint}"
            print(f"\nTesting: {url}")
            
            # Test without authentication first
            response = session.get(url)
            print(f"Status: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    print("✅ Got JSON response!")
                    
                    # Check if it contains team data
                    text_content = str(data).lower()
                    if any(keyword in text_content for keyword in ['team', 'player', 'lineup', 'squad']):
                        print("🎯 Contains potential team data!")
                        
                        # Save the response
                        filename = f"afl_response_{endpoint.replace('/', '_').replace('-', '_')}.json"
                        with open(filename, 'w') as f:
                            json.dump(data, f, indent=2)
                        print(f"💾 Saved response to {filename}")
                        
                        # Show preview of data
                        print("Preview:", str(data)[:200] + "...")
                        
                except json.JSONDecodeError:
                    print("⚠️  Got response but not JSON")
                    if len(response.text) > 0:
                        print(f"Response preview: {response.text[:100]}...")
                        
            elif response.status_code == 401:
                print("🔒 Requires authentication")
                
            elif response.status_code == 403:
                print("🚫 Forbidden - need proper permissions")
                
            elif response.status_code == 404:
                print("❌ Endpoint not found")
                
            else:
                print(f"⚠️  Unexpected status: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error: {e}")
    
    # Also test some general endpoints that might reveal API structure
    print("\n" + "="*50)
    print("Testing general endpoints...")
    
    general_endpoints = [
        "/api",
        "/api/version",
        "/api/config", 
        "/api/health",
        "/api/status"
    ]
    
    for endpoint in general_endpoints:
        try:
            url = f"{base_url}{endpoint}"
            response = session.get(url)
            print(f"{endpoint}: {response.status_code}")
            
            if response.status_code == 200 and 'json' in response.headers.get('content-type', ''):
                try:
                    data = response.json()
                    filename = f"afl_general_{endpoint.replace('/', '_')}.json"
                    with open(filename, 'w') as f:
                        json.dump(data, f, indent=2)
                    print(f"  💾 Saved to {filename}")
                except:
                    pass
                    
        except Exception as e:
            print(f"  ❌ {endpoint}: {e}")

def test_with_basic_auth():
    """Test endpoints with basic authentication"""
    
    username = os.getenv('AFL_FANTASY_USERNAME')
    password = os.getenv('AFL_FANTASY_PASSWORD')
    
    if not username or not password:
        print("No credentials available for authentication test")
        return
        
    print(f"\nTesting with basic authentication...")
    
    session = requests.Session()
    session.auth = (username, password)
    
    # Test key endpoints with auth
    auth_endpoints = [
        "/api/classic/team",
        "/api/classic/my-team",
        "/api/user/profile"
    ]
    
    for endpoint in auth_endpoints:
        try:
            url = f"https://fantasy.afl.com.au{endpoint}"
            response = session.get(url)
            print(f"{endpoint}: {response.status_code}")
            
            if response.status_code == 200:
                try:
                    data = response.json()
                    if 'team' in str(data).lower():
                        print(f"  🎯 Found team data with auth!")
                        filename = f"afl_auth_{endpoint.replace('/', '_')}.json"
                        with open(filename, 'w') as f:
                            json.dump(data, f, indent=2)
                        print(f"  💾 Saved to {filename}")
                except:
                    pass
                    
        except Exception as e:
            print(f"  ❌ {endpoint}: {e}")

if __name__ == "__main__":
    test_afl_classic_endpoints()
    test_with_basic_auth()
    print("\n✅ Endpoint testing complete. Check saved files for any team data found.")