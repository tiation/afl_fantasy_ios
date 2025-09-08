"""
AFL Fantasy Token Capture

Uses existing credentials to log into AFL Fantasy and capture API tokens
from the browser session for authentic data access.
"""

import requests
import os
import json
import re
from bs4 import BeautifulSoup
import time
from urllib.parse import urlparse, parse_qs

class AFLFantasyTokenCapture:
    def __init__(self):
        self.session = requests.Session()
        self.username = os.getenv('AFL_FANTASY_USERNAME')
        self.password = os.getenv('AFL_FANTASY_PASSWORD')
        self.base_url = "https://fantasy.afl.com.au"
        self.tokens = {}
        
        # Set comprehensive headers
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'none',
            'Sec-Fetch-User': '?1',
            'Cache-Control': 'max-age=0'
        })

    def capture_network_tokens(self):
        """Capture tokens by simulating browser login flow"""
        try:
            print("Starting AFL Fantasy login process...")
            
            # Step 1: Get the main page and extract any initial tokens
            print("Getting main page...")
            main_response = self.session.get(self.base_url)
            
            if main_response.status_code != 200:
                print(f"Failed to access main page: {main_response.status_code}")
                return False
            
            # Extract cookies and tokens from main page
            for cookie in self.session.cookies:
                print(f"Initial cookie: {cookie.name} = {cookie.value[:20]}...")
                if 'token' in cookie.name.lower() or 'session' in cookie.name.lower():
                    self.tokens[cookie.name] = cookie.value
            
            # Step 2: Try to find and access login page
            login_urls = [
                f"{self.base_url}/login",
                f"{self.base_url}/auth/login", 
                f"{self.base_url}/user/login"
            ]
            
            login_response = None
            working_login_url = None
            
            for login_url in login_urls:
                try:
                    print(f"Trying login URL: {login_url}")
                    response = self.session.get(login_url)
                    if response.status_code == 200:
                        login_response = response
                        working_login_url = login_url
                        print(f"Found working login URL: {login_url}")
                        break
                except Exception as e:
                    print(f"Error with {login_url}: {e}")
                    continue
            
            if not login_response:
                print("Could not find accessible login page")
                return False
            
            # Step 3: Extract CSRF tokens and form data
            soup = BeautifulSoup(login_response.text, 'html.parser')
            
            # Look for CSRF tokens
            csrf_inputs = soup.find_all('input', {'name': re.compile(r'token|csrf', re.I)})
            for input_tag in csrf_inputs:
                token_name = input_tag.get('name')
                token_value = input_tag.get('value')
                if token_name and token_value:
                    self.tokens[token_name] = token_value
                    print(f"Found CSRF token: {token_name}")
            
            # Look for meta CSRF tokens
            meta_tokens = soup.find_all('meta', {'name': re.compile(r'token|csrf', re.I)})
            for meta_tag in meta_tokens:
                token_name = meta_tag.get('name')
                token_value = meta_tag.get('content')
                if token_name and token_value:
                    self.tokens[token_name] = token_value
                    print(f"Found meta token: {token_name}")
            
            # Step 4: Prepare login data
            login_data = {
                'email': self.username,
                'password': self.password,
            }
            
            # Add any CSRF tokens to login data
            for token_name, token_value in self.tokens.items():
                if 'csrf' in token_name.lower() or 'token' in token_name.lower():
                    login_data[token_name] = token_value
            
            # Step 5: Submit login
            print("Submitting login credentials...")
            
            # Update headers for form submission
            self.session.headers.update({
                'Content-Type': 'application/x-www-form-urlencoded',
                'Origin': self.base_url,
                'Referer': working_login_url
            })
            
            login_submit_response = self.session.post(working_login_url, data=login_data, allow_redirects=True)
            
            print(f"Login submission status: {login_submit_response.status_code}")
            print(f"Final URL: {login_submit_response.url}")
            
            # Step 6: Capture post-login tokens and cookies
            for cookie in self.session.cookies:
                if cookie.name not in self.tokens:  # New cookie from login
                    print(f"New post-login cookie: {cookie.name} = {cookie.value[:20]}...")
                    self.tokens[cookie.name] = cookie.value
            
            # Step 7: Test access to protected pages to find API endpoints
            protected_urls = [
                f"{self.base_url}/dashboard",
                f"{self.base_url}/team",
                f"{self.base_url}/my-team"
            ]
            
            for url in protected_urls:
                try:
                    print(f"Testing access to: {url}")
                    response = self.session.get(url)
                    print(f"Response status: {response.status_code}")
                    
                    if response.status_code == 200:
                        # Look for API calls in the page content
                        self.extract_api_calls_from_page(response.text, url)
                        break
                        
                except Exception as e:
                    print(f"Error accessing {url}: {e}")
                    continue
            
            return len(self.tokens) > 0
            
        except Exception as e:
            print(f"Error in token capture: {e}")
            return False

    def extract_api_calls_from_page(self, page_content, page_url):
        """Extract API calls from page content"""
        try:
            print("Extracting API endpoints from page content...")
            
            # Look for API endpoints in JavaScript
            api_patterns = [
                r'fetch\(["\']([^"\']*api[^"\']*)["\']',
                r'axios\.[get|post]+\(["\']([^"\']*api[^"\']*)["\']',
                r'["\']([^"\']*\/api\/[^"\']*)["\']',
                r'apiUrl\s*[:=]\s*["\']([^"\']+)["\']',
                r'baseUrl\s*[:=]\s*["\']([^"\']+)["\']'
            ]
            
            api_endpoints = set()
            for pattern in api_patterns:
                matches = re.findall(pattern, page_content, re.IGNORECASE)
                api_endpoints.update(matches)
            
            # Test discovered API endpoints
            for endpoint in list(api_endpoints)[:10]:  # Test first 10
                if endpoint.startswith('/'):
                    full_url = self.base_url + endpoint
                elif not endpoint.startswith('http'):
                    full_url = self.base_url + '/' + endpoint
                else:
                    full_url = endpoint
                
                try:
                    print(f"Testing API endpoint: {full_url}")
                    api_response = self.session.get(full_url)
                    print(f"API response: {api_response.status_code}")
                    
                    if api_response.status_code == 200:
                        # This is a working API endpoint
                        self.test_team_data_endpoint(full_url)
                        
                except Exception as e:
                    print(f"Error testing {full_url}: {e}")
                    continue
                    
        except Exception as e:
            print(f"Error extracting API calls: {e}")

    def test_team_data_endpoint(self, endpoint_url):
        """Test if an endpoint returns team data"""
        try:
            response = self.session.get(endpoint_url)
            if response.status_code == 200:
                try:
                    data = response.json()
                    
                    # Look for team-related data structures
                    team_indicators = ['team', 'player', 'score', 'rank', 'value', 'captain']
                    
                    data_str = json.dumps(data).lower()
                    found_indicators = [indicator for indicator in team_indicators if indicator in data_str]
                    
                    if found_indicators:
                        print(f"Found team data at {endpoint_url}")
                        print(f"Indicators: {found_indicators}")
                        
                        # Try to extract actual team data
                        self.extract_dashboard_data_from_api(data, endpoint_url)
                        
                except json.JSONDecodeError:
                    # Not JSON, might be HTML with embedded data
                    pass
                    
        except Exception as e:
            print(f"Error testing team data endpoint: {e}")

    def extract_dashboard_data_from_api(self, api_data, source_url):
        """Extract dashboard data from API response"""
        try:
            print(f"Extracting dashboard data from API response...")
            
            dashboard_data = {}
            
            # Recursive function to search through nested data
            def search_data(obj, path=""):
                if isinstance(obj, dict):
                    for key, value in obj.items():
                        current_path = f"{path}.{key}" if path else key
                        
                        # Look for team value indicators
                        if any(indicator in key.lower() for indicator in ['value', 'salary', 'money', 'cost']):
                            if isinstance(value, (int, float)) and 10000000 <= value <= 15000000:
                                dashboard_data['team_value'] = value
                                print(f"Found team value: {value} at {current_path}")
                        
                        # Look for score indicators
                        if any(indicator in key.lower() for indicator in ['score', 'points']):
                            if isinstance(value, (int, float)) and 500 <= value <= 4000:
                                dashboard_data['team_score'] = value
                                print(f"Found team score: {value} at {current_path}")
                        
                        # Look for rank indicators
                        if any(indicator in key.lower() for indicator in ['rank', 'position']):
                            if isinstance(value, (int, float)) and 1 <= value <= 1000000:
                                dashboard_data['overall_rank'] = value
                                print(f"Found rank: {value} at {current_path}")
                        
                        # Look for captain indicators
                        if any(indicator in key.lower() for indicator in ['captain']):
                            if isinstance(value, dict):
                                captain_data = self.extract_captain_data_from_obj(value)
                                if captain_data:
                                    dashboard_data.update(captain_data)
                        
                        # Recurse into nested objects
                        search_data(value, current_path)
                        
                elif isinstance(obj, list):
                    for i, item in enumerate(obj):
                        search_data(item, f"{path}[{i}]")
            
            search_data(api_data)
            
            if dashboard_data:
                # Save the extracted data
                with open('afl_fantasy_dashboard_data.json', 'w') as f:
                    json.dump({
                        'data': dashboard_data,
                        'source_url': source_url,
                        'extracted_at': time.time(),
                        'tokens_used': list(self.tokens.keys())
                    }, f, indent=2)
                
                print(f"Successfully extracted dashboard data: {dashboard_data}")
                return dashboard_data
            
            return None
            
        except Exception as e:
            print(f"Error extracting dashboard data: {e}")
            return None

    def extract_captain_data_from_obj(self, captain_obj):
        """Extract captain data from object"""
        try:
            captain_data = {}
            
            for key, value in captain_obj.items():
                if 'score' in key.lower() and isinstance(value, (int, float)):
                    captain_data['captain_score'] = value
                elif 'name' in key.lower() and isinstance(value, str):
                    captain_data['captain_name'] = value
                elif any(indicator in key.lower() for indicator in ['ownership', 'percentage', '%']):
                    if isinstance(value, (int, float)):
                        captain_data['captain_ownership'] = value
            
            return captain_data if captain_data else None
            
        except Exception as e:
            print(f"Error extracting captain data: {e}")
            return None

    def save_tokens(self):
        """Save captured tokens to file"""
        try:
            token_data = {
                'tokens': self.tokens,
                'captured_at': time.time(),
                'base_url': self.base_url
            }
            
            with open('afl_fantasy_tokens.json', 'w') as f:
                json.dump(token_data, f, indent=2)
            
            print(f"Saved {len(self.tokens)} tokens to file")
            return True
            
        except Exception as e:
            print(f"Error saving tokens: {e}")
            return False

    def run_token_capture(self):
        """Main method to capture tokens and extract data"""
        print("Starting AFL Fantasy token capture...")
        
        if not self.username or not self.password:
            print("AFL Fantasy credentials not found")
            return None
        
        print(f"Using credentials for: {self.username}")
        
        success = self.capture_network_tokens()
        
        if success:
            self.save_tokens()
            print("Token capture completed successfully")
            return self.tokens
        else:
            print("Token capture failed")
            return None

def main():
    """Main function"""
    capturer = AFLFantasyTokenCapture()
    tokens = capturer.run_token_capture()
    
    if tokens:
        print("\n=== Captured Tokens ===")
        for name, value in tokens.items():
            print(f"{name}: {value[:20]}...")
        return tokens
    else:
        print("Failed to capture AFL Fantasy tokens")
        return None

if __name__ == "__main__":
    main()