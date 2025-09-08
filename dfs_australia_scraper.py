#!/usr/bin/env python3
"""
DFS Australia AFL Fantasy Scraper
Specialized scraper for dfsaustralia.com player data
"""

import os
import time
import pandas as pd
from io import StringIO
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

def setup_driver():
    """Set up Chrome driver with options for DFS Australia"""
    options = Options()
    options.add_argument("--headless")  # Enable headless mode since no login needed
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-blink-features=AutomationControlled")
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)
    options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    
    # Execute script to hide webdriver property
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    
    return driver

def wait_for_page_load(driver, url, timeout=45):
    """Wait for the page to fully load and pass any verification screens"""
    print(f"⏳ Loading: {url}")
    driver.get(url)
    
    # Wait for initial load
    time.sleep(8)
    
    # Check for verification/loading screens
    verification_texts = [
        "please wait while your request is being verified",
        "one moment, please",
        "loading",
        "verifying"
    ]
    
    start_time = time.time()
    max_checks = 10
    check_count = 0
    
    while time.time() - start_time < timeout and check_count < max_checks:
        page_text = driver.page_source.lower()
        page_length = len(driver.page_source)
        
        print(f"🔍 Page length: {page_length} characters")
        
        # Check if we're still on a loading/verification screen
        is_loading = any(text in page_text for text in verification_texts)
        
        if is_loading:
            print("⏳ Still on verification/loading screen, waiting...")
            time.sleep(5)
            check_count += 1
            continue
            
        # Check if we have substantial content
        has_content = (
            "fantasy" in page_text or 
            "player" in page_text or 
            "stats" in page_text or 
            "afl" in page_text
        ) and page_length > 10000
        
        if has_content:
            print("✅ Page loaded successfully with content")
            return True
        
        print(f"⏳ Waiting for content... (attempt {check_count + 1})")
        time.sleep(5)
        check_count += 1
    
    print(f"⚠️ Page load completed with {len(driver.page_source)} characters")
    return True  # Continue anyway to see what we got

def extract_player_data(driver, player_id, player_name):
    """Extract player data from the loaded page"""
    print(f"🔍 Extracting data for {player_name}...")
    
    soup = BeautifulSoup(driver.page_source, 'html.parser')
    
    # Save raw HTML for debugging
    debug_file = f"debug_{player_id}.html"
    with open(debug_file, 'w', encoding='utf-8') as f:
        f.write(driver.page_source)
    print(f"💾 Saved debug HTML: {debug_file}")
    
    # Look for tables
    tables = soup.find_all('table')
    print(f"📊 Found {len(tables)} tables")
    
    # Extract tables
    table_data = {}
    for i, table in enumerate(tables):
        try:
            # Try pandas read_html first
            df_list = pd.read_html(StringIO(str(table)))
            if df_list and len(df_list[0]) > 0:
                df = df_list[0]
                table_name = f"Table_{i+1}"
                table_data[table_name] = df
                print(f"✅ Extracted {table_name}: {df.shape[0]} rows x {df.shape[1]} cols")
                print(f"   Sample: {df.head(2).to_string()}")
        except Exception as e:
            print(f"⚠️ Could not parse table {i+1}: {e}")
            # Try manual extraction
            try:
                rows = table.find_all('tr')
                if rows:
                    table_text_data = []
                    for row in rows:
                        cells = row.find_all(['td', 'th'])
                        row_data = [cell.get_text(strip=True) for cell in cells]
                        if row_data:
                            table_text_data.append(row_data)
                    
                    if table_text_data:
                        max_cols = max(len(row) for row in table_text_data)
                        # Pad rows to same length
                        padded_data = [row + [''] * (max_cols - len(row)) for row in table_text_data]
                        df = pd.DataFrame(padded_data[1:], columns=padded_data[0] if padded_data else [])
                        table_name = f"Manual_Table_{i+1}"
                        table_data[table_name] = df
                        print(f"✅ Manually extracted {table_name}: {df.shape[0]} rows x {df.shape[1]} cols")
            except Exception as e2:
                print(f"⚠️ Manual extraction also failed: {e2}")
    
    # Look for divs with data
    data_divs = soup.find_all('div', class_=lambda x: x and any(word in str(x).lower() for word in ['data', 'stat', 'score', 'fantasy', 'player']))
    if data_divs:
        print(f"🔍 Found {len(data_divs)} potential data divs")
    
    # Look for any structured data
    all_text = soup.get_text()
    if "fantasy" in all_text.lower():
        print("✅ Found 'fantasy' in page text")
    if "afl" in all_text.lower():
        print("✅ Found 'afl' in page text")
    
    return table_data

def scrape_dfs_australia():
    """Main scraping function for DFS Australia"""
    print("🚀 Starting DFS Australia AFL Fantasy scraper...")
    
    # Load player URLs
    try:
        df = pd.read_excel("AFL_Fantasy_Player_URLs.xlsx")
        print(f"✅ Loaded {len(df)} players from Excel file")
    except FileNotFoundError:
        print("❌ AFL_Fantasy_Player_URLs.xlsx not found!")
        return
    
    # Setup output folder
    output_folder = "dfs_player_summary"
    os.makedirs(output_folder, exist_ok=True)
    print(f"📁 Output folder: {output_folder}")
    
    # Setup driver
    driver = setup_driver()
    successful_scrapes = 0
    failed_scrapes = 0
    
    try:
        # Test with first 3 players to see what we get
        test_players = df.head(3)
        
        for index, row in test_players.iterrows():
            player_id = row["playerId"]
            player_name = row["Player"]
            url = row["url"]
            
            print(f"\n🏃 [{index+1}/{len(test_players)}] Processing {player_name} ({player_id})")
            
            output_path = os.path.join(output_folder, f"{player_id}.xlsx")
            
            # Remove existing file
            if os.path.exists(output_path):
                try:
                    os.remove(output_path)
                except PermissionError:
                    print(f"❌ File in use: {output_path}")
                    failed_scrapes += 1
                    continue
            
            try:
                # Load the page and wait for it to be ready
                wait_for_page_load(driver, url, timeout=60)
                
                # Extract data
                player_data = extract_player_data(driver, player_id, player_name)
                
                if player_data:
                    # Save to Excel with multiple sheets
                    with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
                        for sheet_name, table_df in player_data.items():
                            # Clean sheet name for Excel
                            clean_sheet_name = sheet_name.replace("/", "-")[:31]
                            table_df.to_excel(writer, sheet_name=clean_sheet_name, index=False)
                    
                    print(f"✅ Saved {player_name} data with {len(player_data)} sheets")
                    successful_scrapes += 1
                else:
                    print(f"⚠️ No tabular data extracted for {player_name}")
                    # Save a basic file anyway with page info
                    info_df = pd.DataFrame({
                        'Player': [player_name],
                        'PlayerID': [player_id], 
                        'URL': [url],
                        'PageLength': [len(driver.page_source)],
                        'Status': ['No tables found']
                    })
                    info_df.to_excel(output_path, index=False)
                    failed_scrapes += 1
                
                # Be respectful - wait between requests
                time.sleep(5)
                
            except Exception as e:
                print(f"❌ Error processing {player_name}: {e}")
                failed_scrapes += 1
                continue
    
    finally:
        driver.quit()
        print("\n" + "="*60)
        print("📊 SCRAPING SUMMARY")
        print("="*60)
        print(f"✅ Successful: {successful_scrapes}")
        print(f"❌ Failed: {failed_scrapes}")
        print(f"📁 Output folder: {output_folder}")
        print("✅ Browser closed")

if __name__ == "__main__":
    scrape_dfs_australia()
