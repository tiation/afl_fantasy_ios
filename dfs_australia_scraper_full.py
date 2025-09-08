#!/usr/bin/env python3
"""
DFS Australia AFL Fantasy Scraper - Full Production Version
Scrapes all AFL Fantasy player data from dfsaustralia.com
"""

import os
import time
import pandas as pd
from io import StringIO
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager

def setup_driver():
    """Set up Chrome driver with options for DFS Australia"""
    options = Options()
    options.add_argument("--headless")
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
    driver.get(url)
    time.sleep(8)  # Initial wait
    
    verification_texts = [
        "please wait while your request is being verified",
        "one moment, please",
        "loading",
        "verifying"
    ]
    
    start_time = time.time()
    max_checks = 8
    check_count = 0
    
    while time.time() - start_time < timeout and check_count < max_checks:
        page_text = driver.page_source.lower()
        page_length = len(driver.page_source)
        
        # Check if we're still on a loading/verification screen
        is_loading = any(text in page_text for text in verification_texts)
        
        if is_loading:
            time.sleep(5)
            check_count += 1
            continue
            
        # Check if we have substantial content
        has_content = (
            ("fantasy" in page_text or "player" in page_text or "stats" in page_text or "afl" in page_text) 
            and page_length > 10000
        )
        
        if has_content:
            return True
        
        time.sleep(5)
        check_count += 1
    
    return True  # Continue anyway

def extract_player_data(driver, player_id, player_name, save_debug=False):
    """Extract player data from the loaded page"""
    soup = BeautifulSoup(driver.page_source, 'html.parser')
    
    # Save debug HTML if requested
    if save_debug:
        debug_file = f"debug_{player_id}.html"
        with open(debug_file, 'w', encoding='utf-8') as f:
            f.write(driver.page_source)
    
    # Look for tables
    tables = soup.find_all('table')
    
    # Extract tables
    table_data = {}
    table_names = {
        2: "Season_Summary",
        4: "vs_Opposition", 
        6: "Recent_Games",
        8: "vs_Venues",
        10: "vs_Specific_Opposition",
        12: "All_Games"
    }
    
    for i, table in enumerate(tables):
        try:
            # Try pandas read_html first
            df_list = pd.read_html(StringIO(str(table)))
            if df_list and len(df_list[0]) > 0:
                df = df_list[0]
                if df.shape[0] > 1:  # Only save if has meaningful data
                    table_name = table_names.get(i, f"Table_{i}")
                    table_data[table_name] = df
        except Exception:
            # Try manual extraction for complex tables
            try:
                rows = table.find_all('tr')
                if rows and len(rows) > 1:
                    table_text_data = []
                    for row in rows:
                        cells = row.find_all(['td', 'th'])
                        row_data = [cell.get_text(strip=True) for cell in cells]
                        if row_data and any(cell.strip() for cell in row_data):
                            table_text_data.append(row_data)
                    
                    if len(table_text_data) > 1:
                        max_cols = max(len(row) for row in table_text_data)
                        # Pad rows to same length
                        padded_data = [row + [''] * (max_cols - len(row)) for row in table_text_data]
                        df = pd.DataFrame(padded_data[1:], columns=padded_data[0])
                        if df.shape[0] > 0:
                            table_name = table_names.get(i, f"Manual_Table_{i}")
                            table_data[table_name] = df
            except Exception:
                continue
    
    return table_data

def scrape_all_players():
    """Scrape all players from the Excel file"""
    print("🚀 Starting DFS Australia AFL Fantasy scraper - FULL VERSION")
    
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
    
    # Clean up any old debug files
    for debug_file in [f for f in os.listdir('.') if f.startswith('debug_CD_I') and f.endswith('.html')]:
        try:
            os.remove(debug_file)
        except:
            pass
    
    print(f"📁 Output folder: {output_folder}")
    print(f"🎯 Target: Process all {len(df)} players")
    
    # Setup driver
    driver = setup_driver()
    successful_scrapes = 0
    failed_scrapes = 0
    skipped_scrapes = 0
    
    try:
        for index, row in df.iterrows():
            player_id = row["playerId"]
            player_name = row["Player"]
            url = row["url"]
            
            print(f"\n🏃 [{index+1}/{len(df)}] Processing {player_name} ({player_id})")
            
            output_path = os.path.join(output_folder, f"{player_id}.xlsx")
            
            # Skip if file already exists and is recent
            if os.path.exists(output_path):
                file_age = time.time() - os.path.getmtime(output_path)
                if file_age < 3600:  # Less than 1 hour old
                    print(f"⏭️ Skipping - recent file exists ({file_age/60:.1f}m old)")
                    skipped_scrapes += 1
                    continue
                else:
                    try:
                        os.remove(output_path)
                    except PermissionError:
                        print(f"❌ File in use: {output_path}")
                        failed_scrapes += 1
                        continue
            
            try:
                # Load the page
                wait_for_page_load(driver, url, timeout=60)
                
                # Extract data (save debug for first few or failures)
                save_debug = index < 3  # Only save debug for first 3 players
                player_data = extract_player_data(driver, player_id, player_name, save_debug)
                
                if player_data:
                    # Save to Excel with multiple sheets
                    with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
                        for sheet_name, table_df in player_data.items():
                            # Clean sheet name for Excel (max 31 chars)
                            clean_sheet_name = sheet_name.replace("/", "-").replace(":", "")[:31]
                            table_df.to_excel(writer, sheet_name=clean_sheet_name, index=False)
                    
                    print(f"✅ Saved {len(player_data)} data sheets")
                    successful_scrapes += 1
                else:
                    print(f"⚠️ No tabular data extracted")
                    # Create basic info file
                    info_df = pd.DataFrame({
                        'Player': [player_name],
                        'PlayerID': [player_id], 
                        'URL': [url],
                        'Status': ['No data tables found']
                    })
                    info_df.to_excel(output_path, index=False)
                    failed_scrapes += 1
                
                # Progress summary every 10 players
                if (index + 1) % 10 == 0:
                    print(f"\n📊 Progress: {index+1}/{len(df)} | ✅ {successful_scrapes} | ❌ {failed_scrapes} | ⏭️ {skipped_scrapes}")
                
                # Be respectful - wait between requests
                time.sleep(4)
                
            except Exception as e:
                print(f"❌ Error processing {player_name}: {e}")
                failed_scrapes += 1
                continue
    
    finally:
        driver.quit()
        
        print("\n" + "="*80)
        print("📊 FINAL SCRAPING SUMMARY")
        print("="*80)
        print(f"✅ Successful: {successful_scrapes}")
        print(f"❌ Failed: {failed_scrapes}")  
        print(f"⏭️ Skipped: {skipped_scrapes}")
        print(f"🎯 Total processed: {successful_scrapes + failed_scrapes + skipped_scrapes}")
        print(f"📁 Output folder: {output_folder}")
        
        # Show success rate
        if successful_scrapes + failed_scrapes > 0:
            success_rate = (successful_scrapes / (successful_scrapes + failed_scrapes)) * 100
            print(f"📈 Success rate: {success_rate:.1f}%")
        
        print("✅ Browser closed")

if __name__ == "__main__":
    scrape_all_players()
