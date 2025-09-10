#!/usr/bin/env python3

import json
import sys

def fix_critical_players():
    """Fix specific player team assignments that are wrong"""
    
    # Critical fixes based on user feedback
    critical_fixes = {
        "Hunter Clark": "St Kilda",
        "Bailey Smith": "Geelong", 
        "Rowan Marshall": "St Kilda"
    }
    
    # Load the current player data
    data_file = "player_data_stats_enhanced_20250720_205845.json"
    
    try:
        with open(data_file, 'r') as f:
            players = json.load(f)
    except FileNotFoundError:
        print(f"Error: {data_file} not found")
        return False
    
    players_fixed = 0
    steely_green_found = False
    
    # Process each player
    for player in players:
        player_name = player.get('name', '')
        
        # Remove Steely Green (fictional player)
        if player_name == "Steely Green":
            steely_green_found = True
            print(f"Found fictional player: {player_name} - will be removed")
            continue
            
        # Fix team assignments
        if player_name in critical_fixes:
            old_team = player.get('team', 'Unknown')
            new_team = critical_fixes[player_name]
            player['team'] = new_team
            players_fixed += 1
            print(f"Fixed {player_name}: {old_team} -> {new_team}")
    
    # Remove Steely Green from the data
    if steely_green_found:
        players = [p for p in players if p.get('name') != "Steely Green"]
        print(f"Removed Steely Green from dataset")
    
    # Save the updated data
    with open(data_file, 'w') as f:
        json.dump(players, f, indent=2)
    
    print(f"\nFixed {players_fixed} players")
    print(f"Updated {data_file}")
    
    return True

if __name__ == "__main__":
    success = fix_critical_players()
    sys.exit(0 if success else 1)