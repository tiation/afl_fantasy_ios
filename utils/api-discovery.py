#!/usr/bin/env python3
"""
API Discovery Tool - Find hidden APIs on websites
"""

import requests
import json
from urllib.parse import urlparse

def check_common_api_endpoints(base_url):
    """Check common API endpoint patterns"""
    
    # Common API patterns
    api_patterns = [
        '/api/',
        '/api/v1/',
        '/api/v2/',
        '/data/',
        '/json/',
        '/_api/',
        '/rest/',
        '/graphql',
        '/query',
        
        # Sports/Fantasy specific
        '/players',
        '/teams',
        '/fixtures',
        '/stats',
        '/rankings',
        '/scores',
        '/bootstrap-static',  # Common in fantasy sports
        '/gameweek',
        '/live',
        
        # AFL Fantasy specific guesses
        '/classic/api/',
        '/draft/api/',
        '/api/players/all',
        '/api/bootstrap',
        '/api/fixtures/current',
        '/api/team/',
        '/api/league/',
    ]
    
    found_endpoints = []
    
    print(f"Checking {base_url} for API endpoints...\n")
    
    for pattern in api_patterns:
        url = base_url.rstrip('/') + pattern
        try:
            response = requests.get(url, timeout=5, allow_redirects=False)
            
            # Check if endpoint exists and returns JSON
            if response.status_code in [200, 301, 302]:
                content_type = response.headers.get('content-type', '')
                
                if 'json' in content_type:
                    print(f"✓ Found JSON API: {url}")
                    print(f"  Status: {response.status_code}")
                    print(f"  Content-Type: {content_type}")
                    
                    # Try to parse JSON
                    try:
                        data = response.json()
                        print(f"  Response preview: {str(data)[:100]}...")
                    except:
                        pass
                    
                    found_endpoints.append({
                        'url': url,
                        'status': response.status_code,
                        'content_type': content_type
                    })
                    print()
                    
            elif response.status_code == 401:
                print(f"⚠ Found protected API (needs auth): {url}")
                found_endpoints.append({
                    'url': url,
                    'status': response.status_code,
                    'needs_auth': True
                })
                
        except requests.exceptions.RequestException:
            # Silently skip failed requests
            pass
    
    return found_endpoints

def check_afl_fantasy_apis():
    """Check AFL Fantasy specific endpoints"""
    
    # AFL Fantasy domains to check
    domains = [
        'https://fantasy.afl.com.au',
        'https://www.afl.com.au',
        'https://api.afl.com.au',  # Possible API subdomain
    ]
    
    all_endpoints = []
    
    for domain in domains:
        print(f"\n{'='*50}")
        print(f"Checking domain: {domain}")
        print(f"{'='*50}\n")
        
        endpoints = check_common_api_endpoints(domain)
        all_endpoints.extend(endpoints)
    
    # Summary
    print(f"\n{'='*50}")
    print(f"SUMMARY: Found {len(all_endpoints)} potential API endpoints")
    print(f"{'='*50}\n")
    
    for ep in all_endpoints:
        print(f"• {ep['url']}")
        if ep.get('needs_auth'):
            print(f"  (Requires authentication)")
    
    return all_endpoints

if __name__ == "__main__":
    # Check AFL Fantasy APIs
    endpoints = check_afl_fantasy_apis()
    
    # Save results
    with open('discovered_apis.json', 'w') as f:
        json.dump(endpoints, f, indent=2)
    
    print(f"\nResults saved to discovered_apis.json")