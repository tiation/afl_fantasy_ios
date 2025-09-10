"""
Your original AFL Fantasy player scraper - now integrated with the backend system
Run this to scrape player data and make it available to the iOS app via the API
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

def run_original_scraper():
    """Run your original scraping logic"""
    
    # Load player list
    excel_file = "AFL_Fantasy_Player_URLs.xlsx"
    if not os.path.exists(excel_file):
        print(f"⚠️  {excel_file} not found. Please create this file with columns:")
        print("   - playerId: Unique player identifier")
        print("   - url: AFL Fantasy player page URL")
        print("   Exiting...")
        return
    
    df = pd.read_excel(excel_file)
    print(f"📊 Loaded {len(df)} players from {excel_file}")

    # Setup headless Chrome
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    
    service = Service()
    try:
        driver = webdriver.Chrome(service=service, options=options)
        print("✅ Chrome driver initialized")
    except Exception as e:
        print(f"❌ Failed to initialize Chrome driver: {e}")
        return

    # Output folder
    output_folder = "dfs_player_summary"
    os.makedirs(output_folder, exist_ok=True)
    print(f"📁 Output folder: {output_folder}")

    # Table IDs to extract
    TABLE_IDS = {
        "Career Averages": "fantasyPlayerCareer",
        "Opponent Splits": "vsOpponentCareer",
        "Game Logs": "playerGames"
    }

    successful_scrapes = 0
    failed_scrapes = []

    # Scrape loop
    for index, row in df.iterrows():
        player_id = row["playerId"]
        url = row["url"]
        print(f"🔄 Scraping {player_id} ({index + 1}/{len(df)})...")

        output_path = os.path.join(output_folder, f"{player_id}.xlsx")

        # Delete existing file
        if os.path.exists(output_path):
            try:
                os.remove(output_path)
            except PermissionError:
                print(f"❌ File in use or locked: {output_path}")
                failed_scrapes.append(player_id)
                continue

        try:
            driver.get(url)
            time.sleep(3)  # Let page fully load

            soup = BeautifulSoup(driver.page_source, "html.parser")
            writer = pd.ExcelWriter(output_path, engine="openpyxl")
            found_any = False

            for sheet_name, table_id in TABLE_IDS.items():
                table = soup.select_one(f"table#{table_id}")
                if table:
                    try:
                        df_table = pd.read_html(StringIO(str(table)))[0]
                        df_table.to_excel(writer, sheet_name=sheet_name, index=False)
                        found_any = True
                        print(f"  ✅ Found {sheet_name}")
                    except Exception as e:
                        print(f"  ⚠️ Error parsing {sheet_name}: {e}")
                else:
                    print(f"  ⚠️ Table '{sheet_name}' not found")

            writer.close()
            
            if found_any:
                print(f"✅ Saved {player_id}.xlsx")
                successful_scrapes += 1
            else:
                print(f"⚠️ No tables found for {player_id}")
                failed_scrapes.append(player_id)

        except Exception as e:
            print(f"❌ Error scraping {player_id}: {e}")
            failed_scrapes.append(player_id)
        
        # Small delay between requests to be respectful
        time.sleep(1)

    driver.quit()
    
    # Summary
    print(f"\n📈 Scraping complete!")
    print(f"✅ Successful: {successful_scrapes}/{len(df)}")
    if failed_scrapes:
        print(f"❌ Failed: {len(failed_scrapes)} players")
        print(f"   Failed players: {', '.join(failed_scrapes[:10])}{'...' if len(failed_scrapes) > 10 else ''}")
    
    # Save summary for the API
    summary_data = {
        'total_players': len(df),
        'successful_scrapes': successful_scrapes,
        'failed_scrapes': len(failed_scrapes),
        'output_folder': output_folder,
        'scraped_at': time.strftime('%Y-%m-%d %H:%M:%S')
    }
    
    with open(os.path.join(output_folder, 'scrape_summary.json'), 'w') as f:
        import json
        json.dump(summary_data, f, indent=2)
    
    print(f"📋 Summary saved to {output_folder}/scrape_summary.json")

if __name__ == "__main__":
    print("🏈 AFL Fantasy Player Scraper")
    print("=" * 50)
    
    # Check if the Flask API is running
    try:
        import requests
        response = requests.get('http://127.0.0.1:9001/health', timeout=5)
        if response.status_code == 200:
            print("✅ Flask API is running - scraped data will be available to iOS app")
        else:
            print("⚠️  Flask API not responding properly")
    except Exception:
        print("⚠️  Flask API not running - start with: python api/trade_api.py")
    
    print()
    run_original_scraper()
    
    print("\n🚀 Scraper complete! Data is now available via the API endpoints:")
    print("   http://127.0.0.1:9001/api/players")
    print("   http://127.0.0.1:9001/api/cash-cows") 
    print("   http://127.0.0.1:9001/api/captain-recommendations")
