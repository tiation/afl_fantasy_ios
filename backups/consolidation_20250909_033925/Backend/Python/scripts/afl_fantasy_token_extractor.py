"""
AFL Fantasy Token Extractor

This script helps identify the authentication tokens needed to access
AFL Fantasy API endpoints by analyzing the website structure.
"""

import requests
import os
import json
import re
from urllib.parse import urlparse, parse_qs

class AFLFantasyTokenExtractor:
    def __init__(self):
        self.session = requests.Session()
        self.username = os.getenv('AFL_FANTASY_USERNAME')
        self.password = os.getenv('AFL_FANTASY_PASSWORD')
        self.base_url = "https://fantasy.afl.com.au"
        
        # Enhanced headers to bypass basic bot detection
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
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

    def analyze_login_page(self):
        """Analyze the AFL Fantasy login page structure"""
        try:
            print("Analyzing AFL Fantasy login page...")
            
            # First, visit the main page
            main_response = self.session.get(self.base_url)
            print(f"Main page status: {main_response.status_code}")
            
            if main_response.status_code == 200:
                # Look for login links or forms
                content = main_response.text
                
                # Extract potential login URLs
                login_patterns = [
                    r'href=["\']([^"\']*login[^"\']*)["\']',
                    r'action=["\']([^"\']*login[^"\']*)["\']',
                    r'url\(["\']([^"\']*login[^"\']*)["\']'
                ]
                
                login_urls = set()
                for pattern in login_patterns:
                    matches = re.findall(pattern, content, re.IGNORECASE)
                    for match in matches:
                        if match.startswith('/'):
                            login_urls.add(self.base_url + match)
                        elif match.startswith('http'):
                            login_urls.add(match)
                
                print(f"Found potential login URLs: {login_urls}")
                
                # Look for API endpoints in JavaScript
                api_patterns = [
                    r'["\']([^"\']*api[^"\']*)["\']',
                    r'fetch\(["\']([^"\']*)["\']',
                    r'axios\.[get|post]+\(["\']([^"\']*)["\']'
                ]
                
                api_endpoints = set()
                for pattern in api_patterns:
                    matches = re.findall(pattern, content, re.IGNORECASE)
                    for match in matches:
                        if 'api' in match.lower():
                            api_endpoints.add(match)
                
                print(f"Found potential API endpoints: {list(api_endpoints)[:10]}")  # Show first 10
                
                return {
                    'login_urls': list(login_urls),
                    'api_endpoints': list(api_endpoints)[:20],  # Limit to 20
                    'main_page_accessible': True
                }
            else:
                print(f"Failed to access main page: {main_response.status_code}")
                return None
                
        except Exception as e:
            print(f"Error analyzing login page: {e}")
            return None

    def test_alternative_endpoints(self):
        """Test alternative AFL Fantasy endpoints"""
        try:
            print("Testing alternative AFL Fantasy endpoints...")
            
            endpoints_to_test = [
                "/api/auth/login",
                "/api/user/login", 
                "/auth/login",
                "/login/api",
                "/api/session",
                "/api/teams",
                "/api/players",
                "/api/user/profile",
                "/api/dashboard"
            ]
            
            results = {}
            
            for endpoint in endpoints_to_test:
                url = self.base_url + endpoint
                try:
                    response = self.session.get(url)
                    results[endpoint] = {
                        'status': response.status_code,
                        'headers': dict(response.headers),
                        'content_type': response.headers.get('content-type', ''),
                        'size': len(response.content)
                    }
                    print(f"{endpoint}: {response.status_code}")
                except Exception as e:
                    results[endpoint] = {'error': str(e)}
            
            return results
            
        except Exception as e:
            print(f"Error testing endpoints: {e}")
            return None

    def extract_javascript_config(self):
        """Extract configuration and API endpoints from JavaScript files"""
        try:
            print("Extracting JavaScript configuration...")
            
            # Get main page first
            main_response = self.session.get(self.base_url)
            if main_response.status_code != 200:
                return None
            
            content = main_response.text
            
            # Look for JavaScript files
            js_patterns = [
                r'src=["\']([^"\']*\.js[^"\']*)["\']',
                r'href=["\']([^"\']*\.js[^"\']*)["\']'
            ]
            
            js_files = set()
            for pattern in js_patterns:
                matches = re.findall(pattern, content)
                for match in matches:
                    if match.startswith('/'):
                        js_files.add(self.base_url + match)
                    elif match.startswith('http'):
                        js_files.add(match)
            
            print(f"Found {len(js_files)} JavaScript files")
            
            # Analyze a few key JS files for API configurations
            api_configs = {}
            for js_url in list(js_files)[:5]:  # Limit to first 5 files
                try:
                    js_response = self.session.get(js_url)
                    if js_response.status_code == 200:
                        js_content = js_response.text
                        
                        # Look for API base URLs and endpoints
                        config_patterns = [
                            r'apiUrl["\']?\s*[:=]\s*["\']([^"\']+)["\']',
                            r'baseUrl["\']?\s*[:=]\s*["\']([^"\']+)["\']',
                            r'API_BASE["\']?\s*[:=]\s*["\']([^"\']+)["\']',
                            r'["\']([^"\']*api[^"\']*)["\']'
                        ]
                        
                        for pattern in config_patterns:
                            matches = re.findall(pattern, js_content, re.IGNORECASE)
                            if matches:
                                api_configs[js_url] = matches[:10]  # Limit results
                                break
                                
                except Exception as e:
                    print(f"Error analyzing {js_url}: {e}")
                    continue
            
            return api_configs
            
        except Exception as e:
            print(f"Error extracting JavaScript config: {e}")
            return None

    def generate_authentication_guide(self):
        """Generate a comprehensive guide for AFL Fantasy authentication"""
        try:
            print("Generating AFL Fantasy authentication analysis...")
            
            analysis = {
                'timestamp': str(time.time()),
                'base_url': self.base_url,
                'credentials_available': bool(self.username and self.password)
            }
            
            # Analyze login page
            login_analysis = self.analyze_login_page()
            if login_analysis:
                analysis['login_analysis'] = login_analysis
            
            # Test endpoints
            endpoint_results = self.test_alternative_endpoints()
            if endpoint_results:
                analysis['endpoint_tests'] = endpoint_results
            
            # Extract JS config
            js_config = self.extract_javascript_config()
            if js_config:
                analysis['javascript_config'] = js_config
            
            # Save analysis
            with open('afl_fantasy_auth_analysis.json', 'w') as f:
                json.dump(analysis, f, indent=2)
            
            print("Authentication analysis complete. Check afl_fantasy_auth_analysis.json")
            return analysis
            
        except Exception as e:
            print(f"Error generating authentication guide: {e}")
            return None

def main():
    """Main function to analyze AFL Fantasy authentication"""
    import time
    
    extractor = AFLFantasyTokenExtractor()
    
    if not extractor.username or not extractor.password:
        print("WARNING: AFL Fantasy credentials not found in environment")
        print("Available credentials:", {
            'username': bool(extractor.username),
            'password': bool(extractor.password)
        })
    
    analysis = extractor.generate_authentication_guide()
    
    if analysis:
        print("\n=== AFL Fantasy Authentication Analysis ===")
        print(f"Credentials available: {analysis.get('credentials_available', False)}")
        
        if 'login_analysis' in analysis:
            login_data = analysis['login_analysis']
            print(f"Main page accessible: {login_data.get('main_page_accessible', False)}")
            print(f"Login URLs found: {len(login_data.get('login_urls', []))}")
            print(f"API endpoints found: {len(login_data.get('api_endpoints', []))}")
        
        if 'endpoint_tests' in analysis:
            endpoint_data = analysis['endpoint_tests']
            working_endpoints = [ep for ep, data in endpoint_data.items() 
                               if isinstance(data, dict) and data.get('status') == 200]
            print(f"Working endpoints: {working_endpoints}")
        
        return analysis
    else:
        print("Failed to complete authentication analysis")
        return None

if __name__ == "__main__":
    main()