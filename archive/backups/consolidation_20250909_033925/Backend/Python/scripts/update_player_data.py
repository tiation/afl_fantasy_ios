#!/usr/bin/env python
"""
Script to update player data from DFS Australia.
This script uses the scraper module to fetch fresh AFL Fantasy player data.
"""

import os
import json
from scraper import get_dfs_australia_player_data, update_player_data

def main():
    """Update player data from DFS Australia"""
    print("Fetching AFL Fantasy player data from DFS Australia...")
    
    # Get player data
    players = get_dfs_australia_player_data()
    
    if not players:
        print("Error: Failed to scrape player data.")
        return 1
    
    print(f"Successfully scraped data for {len(players)} players.")
    
    # Update the player data file
    success = update_player_data(players)
    
    if success:
        print("Player data updated successfully!")
        
        # Show sample data
        print("\nSample player data:")
        print(json.dumps(players[0], indent=2))
    else:
        print("Error: Failed to update player data file.")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())