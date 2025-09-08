"""
AFL Fantasy Player Data Scraper
Enhanced version integrated with the existing backend API system
"""

import os
import time
import json
import logging
import pandas as pd
from io import StringIO
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from datetime import datetime
from pathlib import Path

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AFLPlayerScraper:
    def __init__(self, output_folder="dfs_player_summary", headless=True):
        self.output_folder = Path(output_folder)
        self.output_folder.mkdir(exist_ok=True)
        self.headless = headless
        
        # Table IDs to extract
        self.TABLE_IDS = {
            "Career Averages": "fantasyPlayerCareer",
            "Opponent Splits": "vsOpponentCareer", 
            "Game Logs": "playerGames"
        }
        
        # Initialize driver
        self.driver = None
        self._setup_driver()
        
        # Cache for processed data
        self.processed_data = {}
    
    def _setup_driver(self):
        """Setup headless Chrome driver"""
        options = Options()
        if self.headless:
            options.add_argument("--headless")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument("--window-size=1920,1080")
        
        # User agent to avoid blocking
        options.add_argument("--user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36")
        
        service = Service()
        try:
            self.driver = webdriver.Chrome(service=service, options=options)
            logger.info("✅ Chrome driver initialized successfully")
        except Exception as e:
            logger.error(f"❌ Failed to initialize Chrome driver: {e}")
            raise
    
    def load_player_list(self, excel_path="AFL_Fantasy_Player_URLs.xlsx"):
        """Load player URLs from Excel file"""
        try:
            df = pd.read_excel(excel_path)
            logger.info(f"📊 Loaded {len(df)} players from {excel_path}")
            return df
        except FileNotFoundError:
            logger.error(f"❌ Excel file not found: {excel_path}")
            # Create sample data structure for testing
            sample_data = {
                'playerId': ['player_001', 'player_002'],
                'url': [
                    'https://example.com/player1',
                    'https://example.com/player2'
                ]
            }
            return pd.DataFrame(sample_data)
    
    def scrape_player(self, player_id, url):
        """Scrape individual player data"""
        logger.info(f"🔄 Scraping {player_id}...")
        
        output_path = self.output_folder / f"{player_id}.xlsx"
        
        # Remove existing file if it exists
        if output_path.exists():
            try:
                output_path.unlink()
            except PermissionError:
                logger.error(f"❌ File in use or locked: {output_path}")
                return None
        
        try:
            self.driver.get(url)
            time.sleep(3)  # Let page fully load
            
            soup = BeautifulSoup(self.driver.page_source, "html.parser")
            writer = pd.ExcelWriter(output_path, engine="openpyxl")
            found_any = False
            scraped_data = {}
            
            for sheet_name, table_id in self.TABLE_IDS.items():
                table = soup.select_one(f"table#{table_id}")
                if table:
                    try:
                        df_table = pd.read_html(StringIO(str(table)))[0]
                        df_table.to_excel(writer, sheet_name=sheet_name, index=False)
                        
                        # Store data for API integration
                        scraped_data[sheet_name.lower().replace(' ', '_')] = df_table.to_dict('records')
                        found_any = True
                        logger.info(f"✅ Found {sheet_name} table for {player_id}")
                    except Exception as e:
                        logger.warning(f"⚠️ Error parsing {sheet_name} table for {player_id}: {e}")
                else:
                    logger.warning(f"⚠️ Table '{sheet_name}' not found for {player_id}")
            
            writer.close()
            
            if found_any:
                logger.info(f"✅ Saved {player_id}.xlsx")
                
                # Cache processed data for API
                self.processed_data[player_id] = {
                    'player_id': player_id,
                    'url': url,
                    'scraped_at': datetime.now().isoformat(),
                    'data': scraped_data
                }
                
                return scraped_data
            else:
                logger.warning(f"⚠️ No tables found for {player_id}")
                return None
                
        except Exception as e:
            logger.error(f"❌ Error scraping {player_id}: {e}")
            return None
    
    def scrape_all_players(self, excel_path="AFL_Fantasy_Player_URLs.xlsx"):
        """Scrape all players from the Excel file"""
        df = self.load_player_list(excel_path)
        total_players = len(df)
        successful_scrapes = 0
        
        logger.info(f"🚀 Starting scrape of {total_players} players...")
        
        for index, row in df.iterrows():
            player_id = row["playerId"]
            url = row["url"]
            
            result = self.scrape_player(player_id, url)
            if result:
                successful_scrapes += 1
            
            # Progress update
            progress = ((index + 1) / total_players) * 100
            logger.info(f"📈 Progress: {progress:.1f}% ({index + 1}/{total_players})")
            
            # Small delay between requests
            time.sleep(1)
        
        logger.info(f"✅ Scraping complete. {successful_scrapes}/{total_players} successful")
        
        # Save aggregated data for API consumption
        self.save_api_data()
        
        return self.processed_data
    
    def save_api_data(self):
        """Save processed data in format suitable for API consumption"""
        api_data_path = self.output_folder / "afl_players_api_data.json"
        
        try:
            with open(api_data_path, 'w') as f:
                json.dump(self.processed_data, f, indent=2, default=str)
            logger.info(f"💾 Saved API data to {api_data_path}")
        except Exception as e:
            logger.error(f"❌ Error saving API data: {e}")
    
    def get_player_data(self, player_id):
        """Get processed data for a specific player (for API integration)"""
        return self.processed_data.get(player_id)
    
    def get_all_players_summary(self):
        """Get summary of all scraped players for API"""
        summary = []
        for player_id, data in self.processed_data.items():
            # Extract key metrics from career averages if available
            career_data = data.get('data', {}).get('career_averages', [])
            latest_season = career_data[0] if career_data else {}
            
            summary.append({
                'player_id': player_id,
                'name': latest_season.get('Player', player_id),
                'games_played': latest_season.get('GP', 0),
                'fantasy_average': latest_season.get('Fant Avg', 0),
                'last_updated': data.get('scraped_at')
            })
        
        return summary
    
    def cleanup(self):
        """Clean up resources"""
        if self.driver:
            self.driver.quit()
            logger.info("🧹 Driver cleaned up")

# Integration with existing trade_api.py
def integrate_with_api():
    """Integration function for the existing Flask API"""
    scraper = AFLPlayerScraper()
    
    # This function can be called from trade_api.py
    def get_player_stats(player_id):
        """Get player statistics for API consumption"""
        data = scraper.get_player_data(player_id)
        if data:
            career_stats = data.get('data', {}).get('career_averages', [])
            if career_stats:
                return career_stats[0]  # Latest season
        return None
    
    def get_all_players():
        """Get all players summary for API"""
        return scraper.get_all_players_summary()
    
    return {
        'get_player_stats': get_player_stats,
        'get_all_players': get_all_players,
        'scraper': scraper
    }

if __name__ == "__main__":
    # Command line usage
    import argparse
    
    parser = argparse.ArgumentParser(description="AFL Fantasy Player Scraper")
    parser.add_argument("--excel", default="AFL_Fantasy_Player_URLs.xlsx", help="Excel file with player URLs")
    parser.add_argument("--output", default="dfs_player_summary", help="Output folder")
    parser.add_argument("--no-headless", action="store_true", help="Run Chrome in visible mode")
    
    args = parser.parse_args()
    
    scraper = AFLPlayerScraper(
        output_folder=args.output,
        headless=not args.no_headless
    )
    
    try:
        scraper.scrape_all_players(args.excel)
    finally:
        scraper.cleanup()
