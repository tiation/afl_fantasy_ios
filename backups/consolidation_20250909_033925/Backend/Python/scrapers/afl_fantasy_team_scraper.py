#!/usr/bin/env python3
"""
AFL Fantasy Team Scraper

This script logs into the AFL Fantasy website using stored credentials
and extracts the user's actual team composition from the HTML.
"""

import requests
import os
import json
import re
from bs4 import BeautifulSoup
import time

class AFLFantasyTeamScraper:
    def __init__(self):
        self.session = requests.Session()
        self.username = os.getenv('AFL_FANTASY_USERNAME')
        self.password = os.getenv('AFL_FANTASY_PASSWORD')
        self.base_url = "https://fantasy.afl.com.au"
        
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
        """Login to AFL Fantasy website"""
        if not self.username or not self.password:
            print("Error: AFL Fantasy credentials not found in environment variables")
            return False
            
        print(f"Attempting to login with username: {self.username}")
        
        try:
            # Get login page first
            login_url = f"{self.base_url}/auth/login"
            response = self.session.get(login_url)
            print(f"Login page status: {response.status_code}")
            
            # Parse login form to find any hidden fields/tokens
            soup = BeautifulSoup(response.text, 'html.parser')
            login_form = soup.find('form')
            
            if not login_form:
                print("Could not find login form on page")
                return False
            
            # Prepare login data
            login_data = {
                'username': self.username,
                'password': self.password,
            }
            
            # Look for any hidden fields (CSRF tokens, etc.)
            hidden_inputs = soup.find_all('input', type='hidden')
            for hidden in hidden_inputs:
                if hidden.get('name') and hidden.get('value'):
                    login_data[hidden.get('name')] = hidden.get('value')
                    print(f"Found hidden field: {hidden.get('name')}")
            
            # Submit login form
            login_response = self.session.post(login_url, data=login_data, allow_redirects=True)
            print(f"Login response status: {login_response.status_code}")
            print(f"Final URL after login: {login_response.url}")
            
            # Check if login was successful
            if "dashboard" in login_response.url.lower() or "team" in login_response.url.lower():
                print("Login appears successful!")
                return True
            elif "login" in login_response.url.lower():
                print("Login failed - still on login page")
                return False
            else:
                print("Login status unclear, proceeding...")
                return True
                
        except Exception as e:
            print(f"Login error: {e}")
            return False

    def get_team_data(self):
        """Extract team data from AFL Fantasy pages"""
        print("Fetching team data...")
        
        try:
            # Try different possible team page URLs
            team_urls = [
                f"{self.base_url}/team",
                f"{self.base_url}/my-team",
                f"{self.base_url}/teams",
                f"{self.base_url}/dashboard"
            ]
            
            team_html = None
            for url in team_urls:
                response = self.session.get(url)
                print(f"Trying URL {url}: {response.status_code}")
                
                if response.status_code == 200:
                    team_html = response.text
                    print(f"Successfully accessed: {url}")
                    break
            
            if not team_html:
                print("Could not access team pages")
                return None
            
            # Parse the HTML
            soup = BeautifulSoup(team_html, 'html.parser')
            
            # Save HTML for analysis
            with open('team_page.html', 'w', encoding='utf-8') as f:
                f.write(soup.prettify())
            print("Saved team page HTML to team_page.html for analysis")
            
            # Look for player data in various possible formats
            players = self.extract_players_from_html(soup)
            
            return players
            
        except Exception as e:
            print(f"Error fetching team data: {e}")
            return None

    def extract_players_from_html(self, soup):
        """Extract player names from the HTML soup"""
        players = {
            'defenders': [],
            'midfielders': [], 
            'rucks': [],
            'forwards': [],
            'bench': []
        }
        
        # Look for common patterns where player names might appear
        print("Searching for player data patterns...")
        
        # Pattern 1: Look for elements with player-related classes
        player_elements = soup.find_all(['div', 'span', 'td'], class_=re.compile(r'player|team|name', re.I))
        print(f"Found {len(player_elements)} elements with player-related classes")
        
        # Pattern 2: Look for text that matches known player names
        known_players = [
            "Harry Sheezel", "Lachie Whitfield", "Matt Roberts", "Riley Bice", "Jaxon Prior", "Joe Fonti",
            "Andrew Brayshaw", "Jordan Dawson", "Zach Merrett", "Levi Ashcroft", "Hugh Boxshall", "Chad Warner", "Max Holmes",
            "Harry Boyd", "Rowan Marshall", "Tristan Xerri",
            "Izak Rankine", "Christian Petracca", "Campbell Gray", "Bailey Smith", "Nick Martin", "Xavier O'Halloran",
            "Angus Clarke", "James Leake", "Finn O'Sullivan", "Saad El-Hawll", "Isaac Kako", "Jack Macrae", "Connor Rozee"
        ]
        
        found_players = []
        all_text = soup.get_text()
        
        for player in known_players:
            if player in all_text:
                found_players.append(player)
                print(f"Found player in HTML: {player}")
        
        # Pattern 3: Look for JSON data embedded in script tags
        script_tags = soup.find_all('script')
        for script in script_tags:
            if script.string and ('player' in script.string.lower() or 'team' in script.string.lower()):
                print("Found potential player data in script tag")
                try:
                    # Try to extract JSON data
                    script_content = script.string
                    if '{' in script_content and '}' in script_content:
                        print("Script contains JSON-like data")
                        # Save script content for manual analysis
                        with open('team_script_data.txt', 'w') as f:
                            f.write(script_content)
                        print("Saved script data to team_script_data.txt")
                except:
                    pass
        
        print(f"Found {len(found_players)} known players in HTML")
        return found_players

    def save_results(self, players):
        """Save extracted player data"""
        if players:
            with open('extracted_team_data.json', 'w') as f:
                json.dump(players, f, indent=2)
            print("Saved extracted team data to extracted_team_data.json")

def main():
    scraper = AFLFantasyTeamScraper()
    
    if scraper.login():
        players = scraper.get_team_data()
        scraper.save_results(players)
    else:
        print("Login failed. Please check credentials.")

if __name__ == "__main__":
    main()