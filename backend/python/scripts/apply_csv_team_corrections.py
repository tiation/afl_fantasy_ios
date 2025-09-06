#!/usr/bin/env python3

import json
import csv
import sys

def apply_csv_team_corrections():
    """Apply the CSV team corrections to the main data file"""
    
    # Load CSV team mappings
    csv_file = "attached_assets/PLAYER TEAM AND NAME_1753070441702.csv"
    team_mapping = {}
    
    try:
        with open(csv_file, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                player_name = row['Player'].strip()
                team = row['Club'].strip()
                team_mapping[player_name] = team
    except FileNotFoundError:
        print(f"Error: {csv_file} not found")
        return False
    
    print(f"Loaded {len(team_mapping)} team mappings from CSV")
    
    # Load the main player data file
    data_file = "player_data_stats_enhanced_20250720_205845.json"
    
    try:
        with open(data_file, 'r') as f:
            players = json.load(f)
    except FileNotFoundError:
        print(f"Error: {data_file} not found")
        return False
    
    print(f"Loaded {len(players)} players from main data file")
    
    players_updated = 0
    players_removed = 0
    critical_fixes = {}
    
    # Process each player
    updated_players = []
    for player in players:
        player_name = player.get('name', '').strip()
        
        # Remove Steely Green (fictional player)
        if player_name == "Steely Green":
            print(f"Removing fictional player: {player_name}")
            players_removed += 1
            continue
            
        # Apply CSV team mapping if available
        if player_name in team_mapping:
            old_team = player.get('team', 'Unknown')
            new_team = team_mapping[player_name]
            
            if old_team != new_team:
                player['team'] = new_team
                players_updated += 1
                critical_fixes[player_name] = f"{old_team} -> {new_team}"
                print(f"Updated {player_name}: {old_team} -> {new_team}")
        
        updated_players.append(player)
    
    # Save the updated data
    with open(data_file, 'w') as f:
        json.dump(updated_players, f, indent=2)
    
    print(f"\nSummary:")
    print(f"- Updated {players_updated} players with correct teams")
    print(f"- Removed {players_removed} fictional players")
    print(f"- Final player count: {len(updated_players)}")
    
    if critical_fixes:
        print(f"\nCritical fixes applied:")
        for player, change in critical_fixes.items():
            print(f"  {player}: {change}")
    
    print(f"Updated {data_file}")
    
    return True

if __name__ == "__main__":
    success = apply_csv_team_corrections()
    sys.exit(0 if success else 1)