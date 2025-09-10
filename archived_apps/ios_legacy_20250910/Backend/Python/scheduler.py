#!/usr/bin/env python3
"""
AFL Fantasy Data Scheduler

This script sets up a background scheduler to update the player data automatically
every 12 hours using data from DFS Australia.
"""

from apscheduler.schedulers.background import BackgroundScheduler
from scraper import get_player_data, update_player_data_from_dfs
import json
import time
import os
import datetime
import logging
import subprocess

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("scheduler.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("fantasy-scheduler")

def update_player_data():
    """
    Fetch new player data and update the player_data.json file
    Also keep a backup of the data with a timestamp
    """
    logger.info("Fetching new player data from sources...")
    
    # Make backup of current file if it exists
    if os.path.exists("player_data.json"):
        try:
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            backup_filename = f"player_data_backup_{timestamp}.json"
            
            with open("player_data.json", "r") as src, open(backup_filename, "w") as dst:
                dst.write(src.read())
            
            logger.info(f"Created backup: {backup_filename}")
            
            # Clean up old backups (keep only 5 most recent)
            backups = sorted([f for f in os.listdir(".") if f.startswith("player_data_backup_")])
            if len(backups) > 5:
                for old_backup in backups[:-5]:
                    try:
                        os.remove(old_backup)
                        logger.info(f"Removed old backup: {old_backup}")
                    except Exception as e:
                        logger.error(f"Failed to remove old backup {old_backup}: {e}")
        except Exception as e:
            logger.error(f"Error creating backup: {e}")
    
    # Try to update player data from DFS Australia
    try:
        success = update_player_data_from_dfs()
        if success:
            logger.info("Player data updated successfully from DFS Australia.")
        else:
            # Fallback: Try using process_draftstars_data.py if available
            logger.warning("Failed to update from DFS Australia directly, trying process_draftstars_data.py")
            try:
                result = subprocess.run(['python', 'process_draftstars_data.py'], 
                                       capture_output=True, text=True, check=True)
                logger.info(f"Process DraftStars data result: {result.stdout}")
                logger.info("Player data updated via process_draftstars_data.py")
            except Exception as e:
                logger.error(f"Failed to run process_draftstars_data.py: {e}")
                
                # Last resort: try to enhance existing data
                try:
                    logger.warning("Trying to enhance existing player data...")
                    subprocess.run(['python', 'enhance_player_data.py'], 
                                  capture_output=True, text=True, check=True)
                    logger.info("Enhanced existing player data")
                except Exception as e:
                    logger.error(f"Failed to enhance player data: {e}")
    except Exception as e:
        logger.error(f"Error updating player data: {e}")

def start_scheduler():
    """
    Start the background scheduler to run the update job every 12 hours
    """
    logger.info("Starting scheduler...")
    
    # Run once at startup to ensure we have fresh data
    update_player_data()
    
    scheduler = BackgroundScheduler()
    scheduler.add_job(update_player_data, 'interval', hours=12)
    scheduler.start()
    logger.info("Scheduler running - will update player data every 12 hours")

    # Prevent script from exiting
    try:
        while True:
            time.sleep(60)
    except (KeyboardInterrupt, SystemExit):
        scheduler.shutdown()
        logger.info("Scheduler shutdown")

if __name__ == "__main__":
    logger.info("AFL Fantasy Data Scheduler starting")
    start_scheduler()