#!/usr/bin/env python3
"""
DFS Australia Fantasy Big Board Scraper

This script scrapes player data from the DFS Australia Fantasy Big Board webpage
(https://dfsaustralia.com/fantasy-big-board/) to get actual AFL Fantasy prices and stats.
"""

import json
import requests
from bs4 import BeautifulSoup
from datetime import datetime
import re

def scrape_fantasy_bigboard():
    """Fetch AFL Fantasy player data from DFS Australia API endpoint"""
    api_url = "https://dfsaustralia.com/wp-admin/admin-ajax.php"
    print(f"Fetching data from DFS Australia API...")
    
    player_data = []
    
    try:
        # Fetch all positions (ALL, DEF, MID, RUC, FWD)
        for position in ["ALL", "DEF", "MID", "RUC", "FWD"]:
            # Create the POST request to the AJAX endpoint
            response = requests.post(
                api_url,
                data={
                    "action": "afl_fantasy_big_board_call",
                    "position": position
                },
                headers={
                    "Content-Type": "application/x-www-form-urlencoded",
                    "Referer": "https://dfsaustralia.com/fantasy-big-board/",
                    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
                }
            )
            response.raise_for_status()
            
            # Parse the JSON response
            try:
                # The API might return a JSON string instead of a parsed object
                response_text = response.text
                
                # Try to parse the JSON from the response text
                try:
                    # If the response is already a string that needs to be parsed
                    json_data = json.loads(response_text)
                except json.JSONDecodeError:
                    # If it's a different format, print and fallback
                    print(f"Could not parse JSON response for {position}. Response: {response_text[:200]}...")
                    continue
                    
                print(f"Received data for position {position}")
                
                # Process each player in the response
                if not isinstance(json_data, list):
                    print(f"Expected list but got {type(json_data)}. Skipping position {position}")
                    continue
                    
                for player_entry in json_data:
                    # Ensure the player entry is a dictionary
                    if not isinstance(player_entry, dict):
                        continue
                        
                    # Skip entries without a name
                    if 'player' not in player_entry or not player_entry['player']:
                        continue
                    
                    # Extract and clean player name
                    name = player_entry.get('player', '').strip()
                    
                    # Get team name
                    team = player_entry.get('team', '').strip()
                    
                    # Get position
                    pos_code = player_entry.get('position', '')
                    if pos_code == 'RUC':
                        position = 'RUCK'
                    elif pos_code == 'DEF':
                        position = 'DEF'
                    elif pos_code == 'FWD':
                        position = 'FWD'
                    else:
                        position = 'MID'  # Default to MID
                    
                    # Get price (remove $ and commas)
                    price_raw = player_entry.get('priceFantasy', 0)
                    if isinstance(price_raw, str):
                        price_raw = re.sub(r'[$,]', '', price_raw)
                        try:
                            price = int(float(price_raw) * 1000)  # Convert to correct format
                        except ValueError:
                            price = 0
                    else:
                        price = int(price_raw * 1000) if price_raw else 0
                    
                    # Get average points
                    avg_points = player_entry.get('FPreg', 0)
                    if isinstance(avg_points, str):
                        try:
                            avg_points = float(avg_points)
                        except ValueError:
                            avg_points = 0
                    
                    # Get breakeven
                    breakeven = player_entry.get('breakevenFantasy')
                    try:
                        breakeven = int(breakeven) if breakeven else int(avg_points * 0.9)
                    except ValueError:
                        breakeven = int(avg_points * 0.9)
                    
                    # Get games played
                    games = player_entry.get('games', 0)
                    if isinstance(games, str):
                        try:
                            games = int(games)
                        except ValueError:
                            games = 1
                    
                    # Calculate projected score (avg + 5 is a reasonable projection)
                    projected_score = int(avg_points + 5)
                    
                    # Get player status
                    status = player_entry.get('status', 'fit').lower()
                    if not status or status == 'available':
                        status = 'fit'
                    
                    # Create player object
                    player = {
                        "name": name,
                        "team": team,
                        "position": position,
                        "price": price,
                        "avg": round(avg_points, 1),
                        "games": games,
                        "breakeven": breakeven,
                        "projected_score": projected_score,
                        "status": status,
                        "source": "dfs_australia_api",
                        "timestamp": int(datetime.now().timestamp())
                    }
                    
                    # Add to our player data list
                    player_data.append(player)
                    
            except (json.JSONDecodeError, ValueError) as e:
                print(f"Error parsing JSON for position {position}: {e}")
                print(f"Response text: {response.text[:200]}...")  # Print first 200 chars for debugging
                continue
        
        # Remove duplicates (keeping one entry per player, preferring specific position data)
        unique_players = {}
        for player in player_data:
            player_name = player['name']
            curr_position = player.get('position', 'MID')  # Current player position
            
            # If we already have this player but from the "ALL" query, replace with position-specific data
            if player_name in unique_players and unique_players[player_name].get('from_all', False):
                unique_players[player_name] = player
            # If we don't have this player yet, add them
            elif player_name not in unique_players:
                # Mark if this player came from the "ALL" query
                player['from_all'] = curr_position == "ALL"
                unique_players[player_name] = player
        
        # Convert back to list and remove the temporary 'from_all' field
        deduplicated_players = list(unique_players.values())
        for player in deduplicated_players:
            if 'from_all' in player:
                del player['from_all']
        
        # Sort by average points (highest first)
        deduplicated_players.sort(key=lambda x: x['avg'], reverse=True)
        
        print(f"Successfully fetched {len(deduplicated_players)} players")
        return deduplicated_players
        
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data from API: {e}")
        return []

def save_to_json(data, filename='player_data.json'):
    """Save the player data to a JSON file."""
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    print(f"Saved {len(data)} players to {filename}")

def main():
    """Main function to scrape the big board data and save it to JSON."""
    player_data = scrape_fantasy_bigboard()
    
    if player_data:
        save_to_json(player_data)
        print(f"Successfully scraped {len(player_data)} players from DFS Australia Fantasy Big Board")
    else:
        print("No player data was scraped. Using calculated data instead.")
        
        # Fall back to using the process_afl_data.py script
        import process_afl_data
        process_afl_data.main()

if __name__ == "__main__":
    main()