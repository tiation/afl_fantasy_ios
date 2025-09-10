#!/usr/bin/env python3
"""
AFL Fantasy Selenium Scraper

Uses Selenium WebDriver to log into AFL Fantasy and extract team data
from the JavaScript-rendered pages.
"""

import os
import json
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

class AFLFantasySeleniumScraper:
    def __init__(self):
        self.username = os.getenv('AFL_FANTASY_USERNAME')
        self.password = os.getenv('AFL_FANTASY_PASSWORD')
        self.driver = None
        
    def setup_driver(self):
        """Setup Chrome WebDriver with headless options"""
        chrome_options = Options()
        chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-gpu")
        chrome_options.add_argument("--window-size=1920,1080")
        chrome_options.add_argument("--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36")
        
        service = Service(ChromeDriverManager().install())
        self.driver = webdriver.Chrome(service=service, options=chrome_options)
        
    def login(self):
        """Login to AFL Fantasy"""
        if not self.username or not self.password:
            print("Error: AFL Fantasy credentials not found")
            return False
            
        try:
            print(f"Navigating to AFL Fantasy login page...")
            self.driver.get("https://fantasy.afl.com.au/auth/login")
            
            # Wait for page to load
            WebDriverWait(self.driver, 10).until(
                EC.presence_of_element_located((By.TAG_NAME, "body"))
            )
            
            print("Page loaded, looking for login elements...")
            
            # Save screenshot for debugging
            self.driver.save_screenshot("login_page.png")
            print("Saved screenshot: login_page.png")
            
            # Save page source for analysis
            with open("login_page_source.html", "w", encoding="utf-8") as f:
                f.write(self.driver.page_source)
            print("Saved page source: login_page_source.html")
            
            # Look for login form elements - try multiple selectors
            email_selectors = [
                "input[type='email']",
                "input[name='email']",
                "input[name='username']", 
                "input[placeholder*='email']",
                "input[placeholder*='Email']",
                "#email",
                "#username"
            ]
            
            password_selectors = [
                "input[type='password']",
                "input[name='password']",
                "#password"
            ]
            
            email_input = None
            password_input = None
            
            # Try to find email input
            for selector in email_selectors:
                try:
                    email_input = self.driver.find_element(By.CSS_SELECTOR, selector)
                    print(f"Found email input with selector: {selector}")
                    break
                except:
                    continue
                    
            # Try to find password input
            for selector in password_selectors:
                try:
                    password_input = self.driver.find_element(By.CSS_SELECTOR, selector)
                    print(f"Found password input with selector: {selector}")
                    break
                except:
                    continue
            
            if not email_input or not password_input:
                print("Could not find login form elements")
                
                # Try looking for login buttons that might open a modal
                login_buttons = self.driver.find_elements(By.XPATH, "//button[contains(text(), 'Login') or contains(text(), 'Sign In') or contains(text(), 'Log In')]")
                if login_buttons:
                    print(f"Found {len(login_buttons)} login buttons, clicking first one...")
                    login_buttons[0].click()
                    time.sleep(3)
                    
                    # Try finding inputs again after clicking
                    for selector in email_selectors:
                        try:
                            email_input = self.driver.find_element(By.CSS_SELECTOR, selector)
                            print(f"Found email input after modal: {selector}")
                            break
                        except:
                            continue
                            
                    for selector in password_selectors:
                        try:
                            password_input = self.driver.find_element(By.CSS_SELECTOR, selector)
                            print(f"Found password input after modal: {selector}")
                            break
                        except:
                            continue
            
            if email_input and password_input:
                print("Entering credentials...")
                email_input.clear()
                email_input.send_keys(self.username)
                
                password_input.clear()
                password_input.send_keys(self.password)
                
                # Look for submit button
                submit_selectors = [
                    "button[type='submit']",
                    "input[type='submit']",
                    "button[value='Login']",
                    "//button[contains(text(), 'Login')]",
                    "//button[contains(text(), 'Sign In')]",
                    "//button[contains(text(), 'Log In')]"
                ]
                
                submit_button = None
                for selector in submit_selectors:
                    try:
                        if selector.startswith("//"):
                            submit_button = self.driver.find_element(By.XPATH, selector)
                        else:
                            submit_button = self.driver.find_element(By.CSS_SELECTOR, selector)
                        print(f"Found submit button with selector: {selector}")
                        break
                    except:
                        continue
                
                if submit_button:
                    print("Clicking submit button...")
                    submit_button.click()
                    
                    # Wait for redirect
                    time.sleep(5)
                    
                    current_url = self.driver.current_url
                    print(f"Current URL after login attempt: {current_url}")
                    
                    if "login" not in current_url.lower():
                        print("Login appears successful!")
                        return True
                    else:
                        print("Still on login page - login may have failed")
                        return False
                else:
                    print("Could not find submit button")
                    return False
            else:
                print("Could not find both email and password inputs")
                return False
                
        except Exception as e:
            print(f"Login error: {e}")
            return False
    
    def get_team_data(self):
        """Extract team data from AFL Fantasy"""
        try:
            # Navigate to team page
            team_urls = [
                "https://fantasy.afl.com.au/my-team",
                "https://fantasy.afl.com.au/team",
                "https://fantasy.afl.com.au/teams",
                "https://fantasy.afl.com.au/classic/my-team"
            ]
            
            for url in team_urls:
                print(f"Trying team URL: {url}")
                self.driver.get(url)
                time.sleep(5)
                
                # Save screenshot
                self.driver.save_screenshot(f"team_page_{url.split('/')[-1]}.png")
                
                # Save page source
                with open(f"team_page_{url.split('/')[-1]}.html", "w", encoding="utf-8") as f:
                    f.write(self.driver.page_source)
                
                # Look for player elements
                player_elements = self.driver.find_elements(By.XPATH, "//div[contains(@class, 'player') or contains(text(), 'Player')]")
                if player_elements:
                    print(f"Found {len(player_elements)} potential player elements on {url}")
                    break
            
            # Extract any visible text that might contain player names
            page_text = self.driver.find_element(By.TAG_NAME, "body").text
            
            # Save the visible text
            with open("team_page_text.txt", "w", encoding="utf-8") as f:
                f.write(page_text)
            print("Saved visible page text to team_page_text.txt")
            
            # Look for your known players in the page text
            known_players = [
                "Harry Sheezel", "Lachie Whitfield", "Matt Roberts", "Riley Bice", "Jaxon Prior", "Joe Fonti",
                "Andrew Brayshaw", "Jordan Dawson", "Zach Merrett", "Levi Ashcroft", "Hugh Boxshall", "Chad Warner", "Max Holmes",
                "Harry Boyd", "Rowan Marshall", "Tristan Xerri",
                "Izak Rankine", "Christian Petracca", "Campbell Gray", "Bailey Smith", "Nick Martin", "Xavier O'Halloran",
                "Angus Clarke", "James Leake", "Finn O'Sullivan", "Saad El-Hawll", "Isaac Kako", "Jack Macrae", "Connor Rozee"
            ]
            
            found_players = []
            for player in known_players:
                if player in page_text:
                    found_players.append(player)
                    print(f"Found player on page: {player}")
            
            return found_players
            
        except Exception as e:
            print(f"Error extracting team data: {e}")
            return None
    
    def close(self):
        """Close the browser"""
        if self.driver:
            self.driver.quit()

def main():
    scraper = AFLFantasySeleniumScraper()
    
    try:
        scraper.setup_driver()
        
        if scraper.login():
            players = scraper.get_team_data()
            
            if players:
                print(f"\nFound {len(players)} players from your team:")
                for player in players:
                    print(f"- {player}")
                    
                # Save results
                with open("selenium_extracted_players.json", "w") as f:
                    json.dump(players, f, indent=2)
                print("\nSaved extracted players to selenium_extracted_players.json")
            else:
                print("No players found - check the saved HTML files for manual analysis")
        else:
            print("Login failed")
            
    finally:
        scraper.close()

if __name__ == "__main__":
    main()