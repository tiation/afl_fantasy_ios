#!/usr/bin/env python3
"""
Basic AFL Fantasy Scraper
Scrapes general fantasy data from AFL.com.au
"""

import os
import time
import pandas as pd
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup

def setup_driver():
    """Set up Chrome driver with appropriate options"""
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36")
    
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    return driver

def scrape_afl_fantasy_basic():
    """Scrape basic AFL Fantasy data"""
    print("🚀 Starting AFL Fantasy basic scraper...")
    
    driver = setup_driver()
    
    try:
        # Navigate to AFL Fantasy page
        url = 'https://www.afl.com.au/fantasy'
        print(f"📄 Opening: {url}")
        driver.get(url)
        
        # Wait for page to load
        time.sleep(5)
        
        # Get page source
        soup = BeautifulSoup(driver.page_source, 'html.parser')
        
        # Try to find common table/data structures
        print("🔍 Looking for data tables...")
        
        # Look for various table patterns
        tables = soup.find_all('table')
        if tables:
            print(f"✅ Found {len(tables)} tables")
            
            for i, table in enumerate(tables):
                try:
                    # Try to convert table to DataFrame
                    df = pd.read_html(str(table))[0]
                    if len(df) > 0:
                        print(f"📊 Table {i+1}: {df.shape[0]} rows, {df.shape[1]} columns")
                        
                        # Save table
                        filename = f"afl_fantasy_table_{i+1}.csv"
                        df.to_csv(filename, index=False)
                        print(f"💾 Saved: {filename}")
                        
                        # Show first few rows
                        print(f"Preview of {filename}:")
                        print(df.head())
                        print("-" * 50)
                        
                except Exception as e:
                    print(f"⚠️ Could not process table {i+1}: {e}")
        else:
            print("❌ No tables found on page")
            
        # Look for player cards or other data structures
        player_cards = soup.find_all(['div', 'article'], class_=lambda x: x and 'player' in x.lower())
        if player_cards:
            print(f"🏃 Found {len(player_cards)} potential player elements")
            
        # Save raw HTML for inspection
        with open('afl_fantasy_page.html', 'w', encoding='utf-8') as f:
            f.write(soup.prettify())
        print("💾 Saved raw HTML as: afl_fantasy_page.html")
            
    except Exception as e:
        print(f"❌ Error during scraping: {e}")
        
    finally:
        driver.quit()
        print("✅ Browser closed")

if __name__ == "__main__":
    scrape_afl_fantasy_basic()
