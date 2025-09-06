#!/usr/bin/env python3

import json

def fix_tom_mccarthy():
    """Fix Tom McCarthy's data - correct team and position"""
    
    data_file = "player_data_stats_enhanced_20250720_205845.json"
    
    try:
        with open(data_file, 'r') as f:
            players = json.load(f)
    except FileNotFoundError:
        print(f"Error: {data_file} not found")
        return False
    
    print(f"Looking for Tom McCarthy variants in {len(players)} players")
    
    found = False
    for player in players:
        name = player.get('name', '')
        # Check for various spellings
        if 'macarthy' in name.lower() or 'mccarthy' in name.lower():
            print(f"Found: {name}")
            if 't mccarthy' in name.lower() or 't macarthy' in name.lower() or name.lower() == 't. mccarthy':
                # This is Tom McCarthy
                old_team = player.get('team', 'Unknown')
                old_position = player.get('position', '')
                
                # Correct the data
                player['name'] = 'Tom McCarthy'  # Standardize name
                player['team'] = 'WCE'  # West Coast Eagles
                player['position'] = 'Def,Mid'  # Def/Mid
                
                print(f"Updated Tom McCarthy:")
                print(f"  Name: {name} -> Tom McCarthy")
                print(f"  Team: {old_team} -> WCE")
                print(f"  Position: {old_position} -> Def,Mid")
                found = True
                break
    
    if not found:
        print("Tom McCarthy not found in player data")
        # Show all players with similar names
        print("Similar names found:")
        for player in players:
            name = player.get('name', '')
            if 'mc' in name.lower() and ('carthy' in name.lower() or 'carty' in name.lower()):
                print(f"  - {name} ({player.get('team', 'Unknown')})")
        return False
    
    # Save the updated data
    with open(data_file, 'w') as f:
        json.dump(players, f, indent=2)
    
    print(f"Updated {data_file}")
    return True

if __name__ == "__main__":
    success = fix_tom_mccarthy()
    exit(0 if success else 1)