"""
AFL Fantasy Authenticated Data Scraper

This module logs into AFL Fantasy using stored credentials and extracts
authentic user team data for the dashboard cards:
- Team value (sum of all player prices + remaining salary)
- Team score (sum of on-field players' scores, captain doubled)
- Overall rank (user's ranking among all fantasy players)
- Captain data (captain's score + captain ownership %)
"""

import requests
import os
import json
import time
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import TimeoutException, NoSuchElementException

class AFLFantasyAuthenticatedScraper:
    def __init__(self):
        self.session = requests.Session()
        self.driver = None
        self.username = os.getenv('AFL_FANTASY_USERNAME')
        self.password = os.getenv('AFL_FANTASY_PASSWORD')
        self.base_url = "https://fantasy.afl.com.au"
        self.login_url = f"{self.base_url}/login"
        self.team_data = {}
        
    def setup_driver(self):
        """Setup Chrome WebDriver with headless options"""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        
        try:
            self.driver = webdriver.Chrome(options=chrome_options)
            return True
        except Exception as e:
            print(f"Failed to setup Chrome driver: {e}")
            return False

    def login(self):
        """Login to AFL Fantasy using credentials"""
        if not self.username or not self.password:
            print("AFL Fantasy credentials not found in environment variables")
            return False
            
        if not self.setup_driver():
            return False
            
        try:
            print("Navigating to AFL Fantasy login page...")
            self.driver.get(self.login_url)
            
            # Wait for login form to load
            wait = WebDriverWait(self.driver, 20)
            
            # Find and fill username field
            print("Looking for username field...")
            username_field = wait.until(
                EC.presence_of_element_located((By.NAME, "email"))
            )
            username_field.clear()
            username_field.send_keys(self.username)
            
            # Find and fill password field
            print("Looking for password field...")
            password_field = self.driver.find_element(By.NAME, "password")
            password_field.clear()
            password_field.send_keys(self.password)
            
            # Find and click login button
            print("Clicking login button...")
            login_button = self.driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
            login_button.click()
            
            # Wait for login to complete - look for dashboard or profile elements
            print("Waiting for login to complete...")
            try:
                wait.until(
                    EC.any_of(
                        EC.presence_of_element_located((By.CLASS_NAME, "team-name")),
                        EC.presence_of_element_located((By.CLASS_NAME, "user-profile")),
                        EC.presence_of_element_located((By.CLASS_NAME, "dashboard")),
                        EC.url_contains("dashboard"),
                        EC.url_contains("team")
                    )
                )
                print("Successfully logged in to AFL Fantasy!")
                return True
                
            except TimeoutException:
                print("Login timeout - checking current URL...")
                current_url = self.driver.current_url
                print(f"Current URL: {current_url}")
                
                if "login" not in current_url:
                    print("Login appears successful (redirected from login page)")
                    return True
                else:
                    print("Login failed - still on login page")
                    return False
                    
        except Exception as e:
            print(f"Login error: {e}")
            return False

    def get_team_value_data(self):
        """Extract team value data (sum of all player prices + remaining salary)"""
        try:
            print("Extracting team value data...")
            
            # Navigate to team management or squad page
            team_urls = [
                f"{self.base_url}/team",
                f"{self.base_url}/squad",
                f"{self.base_url}/my-team",
                f"{self.base_url}/dashboard"
            ]
            
            for url in team_urls:
                try:
                    self.driver.get(url)
                    time.sleep(3)
                    
                    # Look for team value indicators
                    value_indicators = [
                        ".team-value",
                        ".total-value", 
                        ".squad-value",
                        "[data-testid='team-value']",
                        ".value-remaining",
                        ".salary-remaining"
                    ]
                    
                    for selector in value_indicators:
                        try:
                            elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
                            if elements:
                                print(f"Found value elements with selector: {selector}")
                                for element in elements:
                                    text = element.get_attribute('textContent') or element.text
                                    print(f"Value element text: {text}")
                        except:
                            continue
                    
                    # Extract player prices from team listing
                    player_price_selectors = [
                        ".player-price",
                        ".price",
                        "[data-testid='player-price']",
                        ".player-value"
                    ]
                    
                    total_team_value = 0
                    player_count = 0
                    
                    for selector in player_price_selectors:
                        try:
                            price_elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
                            if price_elements:
                                print(f"Found {len(price_elements)} price elements with selector: {selector}")
                                for element in price_elements:
                                    price_text = element.get_attribute('textContent') or element.text
                                    print(f"Price text: {price_text}")
                                    
                                    # Parse price (handle formats like $500k, $1.2M, etc.)
                                    try:
                                        price_value = self.parse_price_text(price_text)
                                        if price_value > 0:
                                            total_team_value += price_value
                                            player_count += 1
                                    except:
                                        continue
                        except:
                            continue
                    
                    if player_count > 0:
                        print(f"Found {player_count} players with total value: ${total_team_value:,}")
                        self.team_data['team_value'] = total_team_value
                        self.team_data['player_count'] = player_count
                        return total_team_value
                        
                except Exception as e:
                    print(f"Error checking URL {url}: {e}")
                    continue
            
            print("Could not extract team value data")
            return None
            
        except Exception as e:
            print(f"Error extracting team value: {e}")
            return None

    def get_team_score_data(self):
        """Extract team score data (sum of on-field players, captain doubled)"""
        try:
            print("Extracting team score data...")
            
            # Look for current round scores
            score_urls = [
                f"{self.base_url}/team/scores",
                f"{self.base_url}/scores",
                f"{self.base_url}/team",
                f"{self.base_url}/dashboard"
            ]
            
            for url in score_urls:
                try:
                    self.driver.get(url)
                    time.sleep(3)
                    
                    # Look for team score indicators
                    score_selectors = [
                        ".team-score",
                        ".total-score",
                        ".round-score",
                        "[data-testid='team-score']",
                        ".score-total"
                    ]
                    
                    for selector in score_selectors:
                        try:
                            elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
                            for element in elements:
                                score_text = element.get_attribute('textContent') or element.text
                                print(f"Found score text: {score_text}")
                                
                                # Extract numeric score
                                try:
                                    score = self.parse_score_text(score_text)
                                    if score > 0:
                                        self.team_data['team_score'] = score
                                        return score
                                except:
                                    continue
                        except:
                            continue
                    
                    # Alternative: sum individual player scores
                    player_score_selectors = [
                        ".player-score",
                        ".score",
                        "[data-testid='player-score']"
                    ]
                    
                    total_score = 0
                    captain_score = 0
                    
                    for selector in player_score_selectors:
                        try:
                            score_elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
                            if score_elements:
                                print(f"Found {len(score_elements)} player score elements")
                                
                                for element in score_elements:
                                    score_text = element.get_attribute('textContent') or element.text
                                    try:
                                        score = self.parse_score_text(score_text)
                                        if score > 0:
                                            total_score += score
                                            
                                            # Check if this is the captain (doubled score)
                                            parent = element.find_element(By.XPATH, "..")
                                            if "captain" in parent.get_attribute('class').lower():
                                                captain_score = score
                                                total_score += score  # Double the captain
                                    except:
                                        continue
                        except:
                            continue
                    
                    if total_score > 0:
                        self.team_data['team_score'] = total_score
                        if captain_score > 0:
                            self.team_data['captain_score'] = captain_score
                        return total_score
                        
                except Exception as e:
                    print(f"Error checking score URL {url}: {e}")
                    continue
            
            print("Could not extract team score data")
            return None
            
        except Exception as e:
            print(f"Error extracting team score: {e}")
            return None

    def get_rank_data(self):
        """Extract overall rank data"""
        try:
            print("Extracting rank data...")
            
            rank_urls = [
                f"{self.base_url}/rankings",
                f"{self.base_url}/leaderboard", 
                f"{self.base_url}/team",
                f"{self.base_url}/dashboard"
            ]
            
            for url in rank_urls:
                try:
                    self.driver.get(url)
                    time.sleep(3)
                    
                    rank_selectors = [
                        ".overall-rank",
                        ".rank",
                        ".position",
                        "[data-testid='rank']",
                        ".league-position"
                    ]
                    
                    for selector in rank_selectors:
                        try:
                            elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
                            for element in elements:
                                rank_text = element.get_attribute('textContent') or element.text
                                print(f"Found rank text: {rank_text}")
                                
                                try:
                                    rank = self.parse_rank_text(rank_text)
                                    if rank > 0:
                                        self.team_data['overall_rank'] = rank
                                        return rank
                                except:
                                    continue
                        except:
                            continue
                            
                except Exception as e:
                    print(f"Error checking rank URL {url}: {e}")
                    continue
            
            print("Could not extract rank data")
            return None
            
        except Exception as e:
            print(f"Error extracting rank: {e}")
            return None

    def get_captain_data(self):
        """Extract captain score and ownership percentage"""
        try:
            print("Extracting captain data...")
            
            captain_urls = [
                f"{self.base_url}/team",
                f"{self.base_url}/captain",
                f"{self.base_url}/squad"
            ]
            
            for url in captain_urls:
                try:
                    self.driver.get(url)
                    time.sleep(3)
                    
                    # Look for captain indicators
                    captain_selectors = [
                        ".captain",
                        "[data-testid='captain']",
                        ".captain-player",
                        ".captain-score"
                    ]
                    
                    for selector in captain_selectors:
                        try:
                            elements = self.driver.find_elements(By.CSS_SELECTOR, selector)
                            for element in elements:
                                # Extract captain name and score
                                captain_text = element.get_attribute('textContent') or element.text
                                print(f"Found captain element: {captain_text}")
                                
                                # Look for ownership percentage nearby
                                try:
                                    parent = element.find_element(By.XPATH, "..")
                                    ownership_text = parent.get_attribute('textContent')
                                    ownership_pct = self.parse_ownership_text(ownership_text)
                                    if ownership_pct:
                                        self.team_data['captain_ownership'] = ownership_pct
                                except:
                                    pass
                        except:
                            continue
                            
                except Exception as e:
                    print(f"Error checking captain URL {url}: {e}")
                    continue
            
            return self.team_data.get('captain_score', 0)
            
        except Exception as e:
            print(f"Error extracting captain data: {e}")
            return None

    def parse_price_text(self, text):
        """Parse price text like '$500k', '$1.2M' into numeric value"""
        if not text:
            return 0
            
        # Remove currency symbols and spaces
        clean_text = text.replace('$', '').replace(',', '').replace(' ', '').upper()
        
        try:
            if 'M' in clean_text:
                value = float(clean_text.replace('M', '')) * 1000000
            elif 'K' in clean_text:
                value = float(clean_text.replace('K', '')) * 1000
            else:
                value = float(clean_text)
            return int(value)
        except:
            return 0

    def parse_score_text(self, text):
        """Parse score text into numeric value"""
        if not text:
            return 0
            
        # Extract numbers from text
        import re
        numbers = re.findall(r'\d+', text)
        if numbers:
            return int(numbers[0])
        return 0

    def parse_rank_text(self, text):
        """Parse rank text like '#1,234' or '1234th' into numeric value"""
        if not text:
            return 0
            
        # Remove common rank indicators
        clean_text = text.replace('#', '').replace(',', '').replace('th', '').replace('st', '').replace('nd', '').replace('rd', '')
        
        try:
            return int(clean_text)
        except:
            return 0

    def parse_ownership_text(self, text):
        """Parse ownership percentage from text"""
        if not text:
            return None
            
        import re
        # Look for percentage patterns
        pct_match = re.search(r'(\d+(?:\.\d+)?)%', text)
        if pct_match:
            return float(pct_match.group(1))
        return None

    def save_team_data(self):
        """Save extracted team data to JSON file"""
        try:
            with open('afl_fantasy_team_data.json', 'w') as f:
                json.dump(self.team_data, f, indent=2)
            print(f"Saved team data: {self.team_data}")
        except Exception as e:
            print(f"Error saving team data: {e}")

    def get_all_dashboard_data(self):
        """Extract all data needed for dashboard cards"""
        print("Starting AFL Fantasy data extraction...")
        
        if not self.login():
            print("Failed to login to AFL Fantasy")
            return None
        
        print("Successfully logged in, extracting team data...")
        
        # Extract all required data
        team_value = self.get_team_value_data()
        team_score = self.get_team_score_data()
        overall_rank = self.get_rank_data()
        captain_data = self.get_captain_data()
        
        # Save data
        self.save_team_data()
        
        return self.team_data

    def close(self):
        """Close the browser"""
        if self.driver:
            self.driver.quit()

def main():
    """Main function to extract AFL Fantasy dashboard data"""
    scraper = AFLFantasyAuthenticatedScraper()
    
    try:
        data = scraper.get_all_dashboard_data()
        if data:
            print("Successfully extracted AFL Fantasy data:")
            print(json.dumps(data, indent=2))
            return data
        else:
            print("Failed to extract AFL Fantasy data")
            return None
    finally:
        scraper.close()

if __name__ == "__main__":
    main()