"""
AFL Fantasy Simple HTTP Scraper

Uses requests to authenticate with AFL Fantasy and extract dashboard data
without requiring Selenium WebDriver.
"""

import requests
import os
import json
import re
from bs4 import BeautifulSoup
import time

class AFLFantasyHTTPScraper:
    def __init__(self):
        self.session = requests.Session()
        self.username = os.getenv('AFL_FANTASY_USERNAME')
        self.password = os.getenv('AFL_FANTASY_PASSWORD')
        self.base_url = "https://fantasy.afl.com.au"
        self.team_data = {}
        
        # Set headers to mimic a real browser
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        })

    def login(self):
        """Login to AFL Fantasy using HTTP requests"""
        if not self.username or not self.password:
            print("AFL Fantasy credentials not found")
            return False
            
        try:
            print("Getting AFL Fantasy login page...")
            login_url = f"{self.base_url}/login"
            
            # Get login page to extract CSRF token or other required fields
            response = self.session.get(login_url)
            if response.status_code != 200:
                print(f"Failed to load login page: {response.status_code}")
                return False
            
            soup = BeautifulSoup(response.text, 'html.parser')
            print("Successfully loaded login page")
            
            # Look for CSRF token or other hidden fields
            csrf_token = None
            token_input = soup.find('input', {'name': '_token'})
            if token_input:
                csrf_token = token_input.get('value')
                print(f"Found CSRF token: {csrf_token[:20]}...")
            
            # Prepare login data
            login_data = {
                'email': self.username,
                'password': self.password,
            }
            
            if csrf_token:
                login_data['_token'] = csrf_token
            
            # Submit login form
            print("Submitting login credentials...")
            login_response = self.session.post(login_url, data=login_data, allow_redirects=True)
            
            # Check if login was successful
            if login_response.status_code == 200:
                # Look for indicators of successful login
                page_content = login_response.text.lower()
                
                if 'dashboard' in page_content or 'team' in page_content or 'logout' in page_content:
                    print("Successfully logged in to AFL Fantasy!")
                    return True
                elif 'login' in login_response.url:
                    print("Login failed - still on login page")
                    print("Response URL:", login_response.url)
                    return False
                else:
                    print("Login status unclear, proceeding...")
                    return True
            else:
                print(f"Login request failed: {login_response.status_code}")
                return False
                
        except Exception as e:
            print(f"Login error: {e}")
            return False

    def extract_team_data(self):
        """Extract team data from AFL Fantasy pages"""
        try:
            # Try multiple URLs that might contain team data
            team_urls = [
                f"{self.base_url}/dashboard",
                f"{self.base_url}/team",
                f"{self.base_url}/my-team",
                f"{self.base_url}/squad",
                f"{self.base_url}/"
            ]
            
            for url in team_urls:
                try:
                    print(f"Checking URL: {url}")
                    response = self.session.get(url)
                    
                    if response.status_code == 200:
                        soup = BeautifulSoup(response.text, 'html.parser')
                        
                        # Extract team value data
                        team_value = self.extract_team_value(soup, response.text)
                        if team_value:
                            self.team_data['team_value'] = team_value
                            print(f"Found team value: ${team_value:,}")
                        
                        # Extract team score
                        team_score = self.extract_team_score(soup, response.text)
                        if team_score:
                            self.team_data['team_score'] = team_score
                            print(f"Found team score: {team_score}")
                        
                        # Extract rank
                        rank = self.extract_rank(soup, response.text)
                        if rank:
                            self.team_data['overall_rank'] = rank
                            print(f"Found rank: {rank}")
                        
                        # Extract captain data
                        captain_data = self.extract_captain_data(soup, response.text)
                        if captain_data:
                            self.team_data.update(captain_data)
                            print(f"Found captain data: {captain_data}")
                        
                        # If we found some data, we can continue with this page
                        if self.team_data:
                            print(f"Successfully extracted data from {url}")
                            break
                            
                except Exception as e:
                    print(f"Error processing URL {url}: {e}")
                    continue
            
            return len(self.team_data) > 0
            
        except Exception as e:
            print(f"Error extracting team data: {e}")
            return False

    def extract_team_value(self, soup, page_text):
        """Extract team value from page content"""
        try:
            # Look for team value patterns in text
            value_patterns = [
                r'\$(\d+(?:,\d{3})*(?:\.\d+)?)[MKmk]?',
                r'team.{0,20}value.{0,20}\$?(\d+(?:,\d{3})*)',
                r'value.{0,20}\$(\d+(?:,\d{3})*)',
                r'(\d+(?:,\d{3})*)\s*remaining'
            ]
            
            for pattern in value_patterns:
                matches = re.findall(pattern, page_text, re.IGNORECASE)
                for match in matches:
                    try:
                        # Clean and convert value
                        clean_value = match.replace(',', '')
                        if clean_value.isdigit():
                            value = int(clean_value)
                            # AFL Fantasy team values are typically in millions
                            if 10000000 <= value <= 15000000:  # $10M to $15M range
                                return value
                    except:
                        continue
            
            # Look for specific HTML elements
            value_selectors = [
                '.team-value', '.total-value', '.squad-value',
                '[data-testid="team-value"]', '.value-display'
            ]
            
            for selector in value_selectors:
                elements = soup.select(selector)
                for element in elements:
                    text = element.get_text(strip=True)
                    value = self.parse_currency_text(text)
                    if value and 10000000 <= value <= 15000000:
                        return value
            
            return None
            
        except Exception as e:
            print(f"Error extracting team value: {e}")
            return None

    def extract_team_score(self, soup, page_text):
        """Extract team score from page content"""
        try:
            # Look for score patterns
            score_patterns = [
                r'score.{0,20}(\d{3,4})',
                r'total.{0,20}(\d{3,4})',
                r'points.{0,20}(\d{3,4})'
            ]
            
            for pattern in score_patterns:
                matches = re.findall(pattern, page_text, re.IGNORECASE)
                for match in matches:
                    try:
                        score = int(match)
                        # AFL Fantasy scores typically 1000-3000
                        if 500 <= score <= 4000:
                            return score
                    except:
                        continue
            
            # Look for HTML elements
            score_selectors = [
                '.team-score', '.total-score', '.round-score',
                '[data-testid="team-score"]', '.score-display'
            ]
            
            for selector in score_selectors:
                elements = soup.select(selector)
                for element in elements:
                    text = element.get_text(strip=True)
                    try:
                        score = int(re.findall(r'\d+', text)[0])
                        if 500 <= score <= 4000:
                            return score
                    except:
                        continue
            
            return None
            
        except Exception as e:
            print(f"Error extracting team score: {e}")
            return None

    def extract_rank(self, soup, page_text):
        """Extract overall rank from page content"""
        try:
            # Look for rank patterns
            rank_patterns = [
                r'rank.{0,20}#?(\d{1,7})',
                r'position.{0,20}(\d{1,7})',
                r'#(\d{1,7})'
            ]
            
            for pattern in rank_patterns:
                matches = re.findall(pattern, page_text, re.IGNORECASE)
                for match in matches:
                    try:
                        rank = int(match)
                        # AFL Fantasy ranks can be up to ~500k
                        if 1 <= rank <= 1000000:
                            return rank
                    except:
                        continue
            
            return None
            
        except Exception as e:
            print(f"Error extracting rank: {e}")
            return None

    def extract_captain_data(self, soup, page_text):
        """Extract captain information"""
        try:
            captain_data = {}
            
            # Look for captain score in captain-related text
            captain_patterns = [
                r'captain.{0,50}(\d{2,3})',
                r'(c).{0,20}(\d{2,3})'
            ]
            
            for pattern in captain_patterns:
                matches = re.findall(pattern, page_text, re.IGNORECASE)
                for match in matches:
                    try:
                        if isinstance(match, tuple):
                            score = int(match[1]) if match[1].isdigit() else int(match[0])
                        else:
                            score = int(match)
                        
                        if 0 <= score <= 300:  # Reasonable captain score range
                            captain_data['captain_score'] = score
                            break
                    except:
                        continue
            
            # Look for ownership percentage
            ownership_patterns = [
                r'(\d{1,2}(?:\.\d+)?)%.*captain',
                r'captain.*(\d{1,2}(?:\.\d+)?)%'
            ]
            
            for pattern in ownership_patterns:
                matches = re.findall(pattern, page_text, re.IGNORECASE)
                for match in matches:
                    try:
                        ownership = float(match)
                        if 0 <= ownership <= 100:
                            captain_data['captain_ownership'] = ownership
                            break
                    except:
                        continue
            
            return captain_data if captain_data else None
            
        except Exception as e:
            print(f"Error extracting captain data: {e}")
            return None

    def parse_currency_text(self, text):
        """Parse currency text like '$12.5M' or '$500K'"""
        try:
            # Remove non-numeric characters except decimal point
            clean_text = re.sub(r'[^\d.]', '', text)
            
            if 'M' in text.upper():
                return int(float(clean_text) * 1000000)
            elif 'K' in text.upper():
                return int(float(clean_text) * 1000)
            else:
                return int(float(clean_text))
        except:
            return None

    def save_data(self):
        """Save extracted data to JSON file"""
        try:
            with open('afl_fantasy_team_data.json', 'w') as f:
                json.dump(self.team_data, f, indent=2)
            print(f"Saved team data: {self.team_data}")
            return True
        except Exception as e:
            print(f"Error saving data: {e}")
            return False

    def scrape_dashboard_data(self):
        """Main method to scrape all dashboard data"""
        print("Starting AFL Fantasy HTTP scraper...")
        
        if not self.login():
            print("Failed to authenticate with AFL Fantasy")
            return None
        
        print("Authentication successful, extracting team data...")
        
        if self.extract_team_data():
            self.save_data()
            return self.team_data
        else:
            print("Failed to extract team data")
            return None

def main():
    """Main function"""
    scraper = AFLFantasyHTTPScraper()
    data = scraper.scrape_dashboard_data()
    
    if data:
        print("Successfully extracted AFL Fantasy data:")
        print(json.dumps(data, indent=2))
        return data
    else:
        print("Failed to extract AFL Fantasy data")
        return None

if __name__ == "__main__":
    main()