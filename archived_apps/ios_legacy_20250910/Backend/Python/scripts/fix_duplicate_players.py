#!/usr/bin/env python3

import json
import sys

def fix_duplicate_players():
    """Remove duplicate players and fix inconsistent team names"""
    
    data_file = "player_data_stats_enhanced_20250720_205845.json"
    
    try:
        with open(data_file, 'r') as f:
            players = json.load(f)
    except FileNotFoundError:
        print(f"Error: {data_file} not found")
        return False
    
    print(f"Starting with {len(players)} players")
    
    # Standardize team names
    team_mapping = {
        'Richmond': 'RIC',
        'St Kilda': 'STK'
    }
    
    # Fix team inconsistencies
    for player in players:
        team = player.get('team', '')
        if team in team_mapping:
            player['team'] = team_mapping[team]
    
    # Remove duplicates by keeping the player with higher price (more likely to be correct)
    seen_players = {}
    unique_players = []
    
    for player in players:
        name = player.get('name', '').strip()
        if not name:
            continue
            
        if name in seen_players:
            existing = seen_players[name]
            current_price = player.get('price', 0)
            existing_price = existing.get('price', 0)
            
            # Special case: Jhye Clark should keep the lower price (more accurate)
            if name == "Jhye Clark":
                if current_price < existing_price:
                    # Replace with current player (lower price for Jhye Clark)
                    seen_players[name] = player
                    unique_players = [p for p in unique_players if p.get('name') != name]
                    unique_players.append(player)
                    print(f"Kept lower price for {name}: ${current_price:,} vs ${existing_price:,}")
                else:
                    print(f"Kept existing lower price for {name}: ${existing_price:,} vs ${current_price:,}")
            else:
                # For all other players, keep higher price
                if current_price > existing_price:
                    seen_players[name] = player
                    unique_players = [p for p in unique_players if p.get('name') != name]
                    unique_players.append(player)
                    print(f"Kept higher price for {name}: ${current_price:,} vs ${existing_price:,}")
                else:
                    print(f"Kept existing higher price for {name}: ${existing_price:,} vs ${current_price:,}")
        else:
            seen_players[name] = player
            unique_players.append(player)
    
    print(f"Removed {len(players) - len(unique_players)} duplicate players")
    print(f"Final count: {len(unique_players)} unique players")
    
    # Save the cleaned data
    with open(data_file, 'w') as f:
        json.dump(unique_players, f, indent=2)
    
    print(f"Updated {data_file}")
    return True

if __name__ == "__main__":
    success = fix_duplicate_players()
    sys.exit(0 if success else 1)