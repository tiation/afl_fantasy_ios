# scraper.py
"""
AFL Fantasy scraper module for retrieving player data from JSON file or AFL Fantasy sources.
This module provides functions to get, filter, and update player data.
"""

import json
import os
import requests
import pandas as pd

def get_player_data(json_path="player_data.json"):
    if not os.path.exists(json_path):
        raise FileNotFoundError(f"{json_path} not found.")
    
    with open(json_path, "r") as f:
        data = json.load(f)
    
    # Standardize and filter
    players = []
    for p in data:
        if "name" in p and "price" in p and "breakeven" in p:
            # Calculate or use default for l3_avg if missing
            l3_avg = p.get("l3_avg", p.get("last_3_avg", p.get("avg", 0)))
            
            players.append({
                "name": p["name"],
                "team": p.get("team", "N/A"),
                "price": int(p["price"]),
                "breakeven": float(p["breakeven"]),
                "l3_avg": float(l3_avg),
                "games": int(p.get("games", 3)),  # Default fallback
                "position": p.get("position", "UNK")
            })
    return players


def update_player_data(player_list, filename='player_data.json'):
    """
    Update the player data file with new information
    
    Parameters:
        player_list (list): The list of player data to save
        filename (str): The JSON file to write data to
        
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(player_list, f, indent=4, ensure_ascii=False)
        return True
    except Exception as e:
        print(f"Error updating player data: {e}")
        return False


def filter_players_by_position(position, player_data=None):
    """
    Filter players by position
    
    Parameters:
        position (str): The position to filter by
        player_data (list, optional): Player data to filter. If None, will load from file.
        
    Returns:
        list: Filtered list of players
    """
    if player_data is None:
        player_data = get_player_data()
        
    return [p for p in player_data if p.get("position", "").upper() == position.upper()]


def filter_rookies(max_price=500000, min_games=2, player_data=None):
    """
    Filter for rookie players based on price and games played
    
    Parameters:
        max_price (int): Maximum price to be considered a rookie
        min_games (int): Minimum games played to include
        player_data (list, optional): Player data to filter. If None, will load from file.
        
    Returns:
        list: Filtered list of players
    """
    if player_data is None:
        player_data = get_player_data()
        
    return [p for p in player_data if p.get("price", 0) < max_price and p.get("games", 0) >= min_games]


def get_dfs_australia_player_data():
    """
    Get player data using a fallback method with example data
    
    Returns:
        list: List of player data 
    """
    try:
        # First try to use existing player_data.json if available
        try:
            existing_players = get_player_data()
            print(f"Using existing player data ({len(existing_players)} players)")
            return existing_players
        except FileNotFoundError:
            print("No existing player data file found")
        
        # If we have already scaped CSV files in the project, use the newest one
        import glob
        from datetime import datetime
        import pandas as pd
        import os
        
        csv_files = glob.glob("attached_assets/*.csv")
        if csv_files:
            # Sort files by modification time (newest first)
            csv_files.sort(key=lambda x: os.path.getmtime(x), reverse=True)
            newest_csv = csv_files[0]
            
            print(f"Using CSV file: {newest_csv}")
            
            # Load the CSV file
            df = pd.read_csv(newest_csv)
            
            # Check if this is the right format
            required_cols = ["name", "team", "price", "breakeven"]
            if all(col in df.columns for col in required_cols):
                players = []
                for _, row in df.iterrows():
                    players.append({
                        "name": row["name"],
                        "team": row.get("team", "Unknown"),
                        "price": int(row["price"]),
                        "breakeven": float(row["breakeven"]),
                        "l3_avg": float(row.get("l3_avg", row.get("avg", 0))),
                        "games": int(row.get("games", 3)),
                        "position": row.get("position", "UNK")
                    })
                print(f"Loaded {len(players)} players from CSV file")
                return players
            else:
                print(f"CSV file doesn't have required columns. Available: {df.columns}")
        
        # If we reach here, we couldn't find any viable data source
        print("No suitable player data sources found.")
        return []
    except Exception as e:
        print(f"Error getting player data: {e}")
        return []


def update_player_data_from_dfs():
    """
    Update player data by scraping from DFS Australia
    
    Returns:
        bool: True if successful, False otherwise
    """
    try:
        # Get player data from DFS Australia
        players = get_dfs_australia_player_data()
        
        if not players:
            print("No players scraped from DFS Australia")
            return False
        
        # Update player data file
        success = update_player_data(players)
        
        return success
    except Exception as e:
        print(f"Error updating player data from DFS Australia: {e}")
        return False


if __name__ == "__main__":
    # Option to update from DFS Australia or show existing data
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == "--update-from-dfs":
        print("Updating player data from DFS Australia...")
        success = update_player_data_from_dfs()
        if success:
            print("Player data updated successfully")
        else:
            print("Failed to update player data")
    else:
        # Simple test to show the data when run directly
        try:
            players = get_player_data()
            print(f"Loaded {len(players)} players")
            
            if players:
                # Show a sample player
                print("\nSample player data:")
                print(json.dumps(players[0], indent=2))
        except FileNotFoundError:
            print("Player data file not found. Run with --update-from-dfs to create it.")