#!/usr/bin/env python3
"""
AFL Fantasy Platform - Data Scraper Service
Microservice for automated data collection and updates
"""

import os
import sys
import time
import logging
import json
import subprocess
from datetime import datetime
from typing import Dict, List, Optional

# Add the current directory to Python path for imports
sys.path.append('/app')

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/scraper.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class AFLFantasyDataScraper:
    """Main data scraper service for AFL Fantasy platform"""
    
    def __init__(self):
        self.data_sources = [
            'dfs_australia',
            'footywire',
            'afl_fantasy'
        ]
        self.last_update = None
        
    def update_player_data(self) -> bool:
        """Update player data from all available sources"""
        try:
            logger.info("Starting player data update...")
            
            # Use subprocess to run existing scraper scripts
            try:
                # Try to run existing Python scrapers as subprocesses
                logger.info("Running data update via subprocess...")
                result = subprocess.run([
                    'python3', 'complete_data_overhaul.py'
                ], capture_output=True, text=True, timeout=300)
                
                if result.returncode == 0:
                    logger.info("Data update completed successfully via subprocess")
                    return True
                else:
                    logger.warning(f"Subprocess failed: {result.stderr}")
            except Exception as e:
                logger.warning(f"Could not run scraper subprocess: {e}")
            
            # Try each data source in priority order
            data_updated = False
            
            # 1. Try DFS Australia (primary source)
            try:
                logger.info("Attempting DFS Australia data update...")
                dfs_data = get_dfs_player_data()
                if dfs_data and len(dfs_data) > 100:
                    self.save_player_data(dfs_data, 'dfs_australia')
                    data_updated = True
                    logger.info(f"Successfully updated {len(dfs_data)} players from DFS Australia")
            except Exception as e:
                logger.warning(f"DFS Australia update failed: {e}")
            
            # 2. Try FootyWire (secondary source)
            if not data_updated:
                try:
                    logger.info("Attempting FootyWire data update...")
                    footywire_data = get_footywire_data()
                    if footywire_data and len(footywire_data) > 100:
                        self.save_player_data(footywire_data, 'footywire')
                        data_updated = True
                        logger.info(f"Successfully updated {len(footywire_data)} players from FootyWire")
                except Exception as e:
                    logger.warning(f"FootyWire update failed: {e}")
            
            # 3. Try AFL Fantasy (if credentials available)
            if not data_updated and os.getenv('AFL_FANTASY_USERNAME'):
                try:
                    logger.info("Attempting AFL Fantasy data update...")
                    afl_data = scrape_afl_fantasy_data()
                    if afl_data and len(afl_data) > 100:
                        self.save_player_data(afl_data, 'afl_fantasy')
                        data_updated = True
                        logger.info(f"Successfully updated {len(afl_data)} players from AFL Fantasy")
                except Exception as e:
                    logger.warning(f"AFL Fantasy update failed: {e}")
            
            if data_updated:
                self.last_update = datetime.now()
                logger.info("Player data update completed successfully")
                return True
            else:
                logger.error("All data sources failed - no updates performed")
                return False
                
        except Exception as e:
            logger.error(f"Critical error in player data update: {e}")
            return False
    
    def save_player_data(self, player_data: List[Dict], source: str) -> None:
        """Save player data to JSON file with backup"""
        try:
            # Create backup of existing data
            if os.path.exists('/app/player_data.json'):
                backup_path = f"/app/player_data_backup_{int(time.time())}.json"
                os.rename('/app/player_data.json', backup_path)
                logger.info(f"Created backup: {backup_path}")
            
            # Save new data
            with open('/app/player_data.json', 'w', encoding='utf-8') as f:
                json.dump(player_data, f, indent=2, ensure_ascii=False)
            
            # Update metadata
            metadata = {
                'last_updated': datetime.now().isoformat(),
                'source': source,
                'player_count': len(player_data),
                'update_id': int(time.time())
            }
            
            with open('/app/data_metadata.json', 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2)
            
            logger.info(f"Saved {len(player_data)} players from {source}")
            
        except Exception as e:
            logger.error(f"Failed to save player data: {e}")
            raise
    
    def update_fixture_data(self) -> bool:
        """Update fixture and DVP data"""
        try:
            logger.info("Starting fixture data update...")
            
            # Use subprocess to update fixture data
            try:
                result = subprocess.run([
                    'python3', 'dvp_matrix_scraper.py'
                ], capture_output=True, text=True, timeout=120)
                
                if result.returncode == 0:
                    logger.info("Fixture data updated successfully")
                    return True
            except Exception as e:
                logger.warning(f"Could not update fixture data: {e}")
            
            # Update DVP data
            dvp_data = get_dvp_data()
            if dvp_data:
                with open('/app/dvp_matrix.json', 'w') as f:
                    json.dump(dvp_data, f, indent=2)
                logger.info("DVP data updated successfully")
            
            # Update fixture data
            fixture_data = get_current_fixtures()
            if fixture_data:
                with open('/app/fixtures.json', 'w') as f:
                    json.dump(fixture_data, f, indent=2)
                logger.info("Fixture data updated successfully")
            
            return True
            
        except Exception as e:
            logger.error(f"Fixture data update failed: {e}")
            return False
    
    def health_check(self) -> Dict:
        """Perform health check of the scraper service"""
        status = {
            'service': 'data_scraper',
            'status': 'healthy',
            'last_update': self.last_update.isoformat() if self.last_update else None,
            'data_sources_available': [],
            'timestamp': datetime.now().isoformat()
        }
        
        # Check data source availability
        for source in self.data_sources:
            try:
                # Simple connectivity check for each source
                if source == 'dfs_australia':
                    import requests
                    resp = requests.get('https://www.dfsaustralia.com.au', timeout=5)
                    if resp.status_code == 200:
                        status['data_sources_available'].append(source)
                # Add other source checks as needed
            except:
                pass
        
        return status
    
    def run_scheduled_updates(self):
        """Run the scheduled update cycle"""
        logger.info("=== Starting scheduled data update cycle ===")
        
        # Update player data
        player_success = self.update_player_data()
        
        # Update fixture data
        fixture_success = self.update_fixture_data()
        
        # Log summary
        if player_success and fixture_success:
            logger.info("=== All updates completed successfully ===")
        elif player_success:
            logger.warning("=== Player data updated, fixture update failed ===")
        elif fixture_success:
            logger.warning("=== Fixture data updated, player update failed ===")
        else:
            logger.error("=== All updates failed ===")

def main():
    """Main service loop"""
    logger.info("Starting AFL Fantasy Data Scraper Service")
    
    # Create logs directory
    os.makedirs('/app/logs', exist_ok=True)
    
    # Initialize scraper
    scraper = AFLFantasyDataScraper()
    
    # Run initial update
    logger.info("Running initial data update...")
    scraper.run_scheduled_updates()
    
    # Main service loop with simple timer (12 hour intervals)
    logger.info("Data scraper service is running. Updates every 12 hours.")
    update_interval = 12 * 60 * 60  # 12 hours in seconds
    
    while True:
        try:
            time.sleep(update_interval)
            scraper.run_scheduled_updates()
        except KeyboardInterrupt:
            logger.info("Received shutdown signal")
            break
        except Exception as e:
            logger.error(f"Unexpected error in main loop: {e}")
            time.sleep(300)  # Wait 5 minutes before retrying

if __name__ == "__main__":
    main()