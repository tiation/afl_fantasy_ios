#!/usr/bin/env python3
"""
Fix specific key player team assignments that are still incorrect
"""

import json

def fix_key_players():
    """Fix specific key players that still have wrong teams"""
    print("Fixing key player team assignments...")
    
    # Load current data
    with open('player_data_stats_enhanced_20250720_205845.json', 'r') as f:
        players = json.load(f)
    
    # Specific corrections needed
    corrections = {
        'J Dawson': 'Adelaide',  # Currently showing North Melbourne
        'G Hewett': 'Carlton',   # Currently showing West Coast  
        'B Smith': 'Geelong',    # Should be Mid,Fwd
        'H Sheezel': 'North Melbourne',  # Should be Def,Mid
        'Connor Rozee': 'Port Adelaide',  # Full name version
        'Jordan Dawson': 'Adelaide',      # Full name version
        'George Hewett': 'Carlton',       # Full name version
        'Bailey Smith': 'Geelong',        # Full name version
        'Harry Sheezel': 'North Melbourne' # Full name version
    }
    
    updates_made = 0
    
    for player in players:
        name = player['name']
        
        if name in corrections:
            old_team = player['team']
            new_team = corrections[name]
            
            if old_team != new_team:
                print(f"Updating {name}: {old_team} -> {new_team}")
                player['team'] = new_team
                updates_made += 1
    
    print(f"Made {updates_made} key player corrections")
    
    # Save corrected data
    with open('player_data_stats_enhanced_20250720_205845.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    with open('player_data.json', 'w') as f:
        json.dump(players, f, indent=2)
    
    # Verify key players
    key_names = ['J Dawson', 'G Hewett', 'B Smith', 'C Rozee', 'C Daniel', 'H Sheezel']
    print(f"\nVerified key players:")
    for name in key_names:
        for player in players:
            if player['name'] == name:
                print(f"  {name}: {player['team']} {player['position']} ${player['price']:,}")
                break
    
    print("Key player teams corrected!")

if __name__ == "__main__":
    fix_key_players()